// ignore_for_file: unused_element, curly_braces_in_flow_control_structures, file_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:GEMS/controller/WorkOrder/bloc/mainBloc.dart';
import 'package:GEMS/controller/WorkOrder/pending_sync.dart';
import 'package:GEMS/controller/WorkOrder/widgets/pending_sync_banner.dart';
import 'package:GEMS/data/repository/work_order_detail_repository.dart';
import 'package:GEMS/model/execution.dart';
import 'package:GEMS/model/user.dart';
import 'package:GEMS/model/workorder.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:GEMS/view/dialog.dart';
import 'package:toast/toast.dart';
import '../../main.dart';


final ButtonStyle actionButtonStyle = ElevatedButton.styleFrom(
  minimumSize: Size(double.infinity, 52),            // full‐width, 52 px tall
  padding: EdgeInsets.symmetric(vertical: 0),        // we control height via minimumSize
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),         // 12 px rounded corners
  ),
  elevation: 2,
);

class ComplaintSection extends StatefulWidget {
  final String taskNo;
  final String siteName;
  final String taskStatus;
  final bool viewer;
  final String id;
  final bool isComplaintProgress;
  final bool isAssign;
  final String woTaskType;
  final String woTaskCategory;

  const ComplaintSection({
    super.key,
    required this.id,
    required this.taskNo,
    required this.siteName,
    required this.taskStatus,
    required this.viewer,
    this.isAssign = false,
    this.isComplaintProgress = false,
    required this.woTaskType,
    required this.woTaskCategory,
  });

  @override
  ComplaintSectionState createState() => ComplaintSectionState();
}

class ComplaintSectionState extends State<ComplaintSection> {
  late final MainBloc _bloc;
  late final PendingSyncController _pendingSyncController;
  bool showtime = false;
  bool _blocInitialized = false;
  StreamSubscription<MutationFeedback>? _feedbackSub;
  bool _offlineToggleInFlight = false;
  bool _syncInFlight = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize the bloc only once since context is now available.
    if (!_blocInitialized) {
      _bloc = MainBloc(
        id: widget.id,
        status: widget.taskStatus,
        taskNo: widget.taskNo,
        context: navigatorKey.currentContext!,
        woTaskCategory: widget.woTaskType,
      );
      _pendingSyncController = PendingSyncController(
        pendingCount$: _bloc.pendingActions$,
        retry: _bloc.retryPendingSync,
      );
      _blocInitialized = true;
      _feedbackSub = _bloc.feedback$.listen((feedback) {
        if (!mounted) return;
        if (feedback.type == MutationFeedbackType.queued) {
          Toast.show(
            feedback.message,
            duration: Toast.lengthLong,
            gravity: Toast.bottom,
          );
        } else if (feedback.type == MutationFeedbackType.success) {
          Toast.show(
            feedback.message,
            duration: Toast.lengthShort,
            gravity: Toast.bottom,
          );
        } else if (feedback.type == MutationFeedbackType.error) {
          Toast.show(
            feedback.message,
            duration: Toast.lengthShort,
            gravity: Toast.bottom,
            backgroundColor: AppColors.danger,
          );
        }
      });
      // Check user preferences to decide if the time view should be shown.
      User.getPrefUser.then((value) {
        final User user = User.fromMap(value);
        final List<String> roles = user.roles.map((role) => role.desc).toList();
        if (roles.contains("WO Executor") && mounted) {
          setState(() {
            showtime = true;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _feedbackSub?.cancel();
    if (_blocInitialized) {
      _bloc.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    debugPrint('the widget is ${widget.taskNo}, ${widget.taskStatus}, ${widget.viewer}, ${widget.isAssign}, ${widget.woTaskType}');
    final standardButton = _BuildStandardButton(
      _bloc,
      widget.viewer,
      widget.taskStatus,
      widget.woTaskType,
      _showOutOfScopeDialog,
    );

    final viewButton = _BuildViewButton(
      widget.isComplaintProgress,
      widget.isAssign,
      widget.viewer,
      widget.taskStatus,
      standardButton,
      _bloc.reject,
      alert,
    );

    debugPrint("widget parameters are ${widget.taskNo}, ${widget.taskStatus}, ${widget.viewer}, ${widget.isAssign}, ${widget.woTaskType}");
    debugPrint("bloc parameters are ${_bloc.id}, ${_bloc.checkpoint}");
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskNo, style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.w600)),
      ),
      body: StreamBuilder<List<WorkOrderStatus>>(
        stream: _bloc.sections$,
        builder: (ctx, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final sections = snapshot.data!;
          return Column(
            children: [
              _buildOfflineControls(),
              StreamBuilder<bool>(
                stream: _bloc.offlineMode$,
                builder: (_, offlineSnapshot) {
                  final offline = offlineSnapshot.data ?? false;
                  if (offline) {
                    return const SizedBox.shrink();
                  }
                  return PendingSyncIndicator(controller: _pendingSyncController);
                },
              ),
              // 1) The scrolling list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _bloc.refresh,
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 12),
                    itemCount: sections.length + (showtime ? 1 : 0),
                    itemBuilder: (c, i) {
                      if (i == 0 && showtime) {
                        return _TimeDuration(stream: _bloc.execution$);
                      }
                      final idx = i - (showtime ? 1 : 0);
                      return BuildTile(
                        workOrderStatus: sections[idx],
                        onTap: () => _bloc.openScreen(
                          context,
                          sections[idx],
                          viewOnly: widget.viewer,
                          pendingSync: _pendingSyncController,
                        ),
                      );
                    },
                  ),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Builder(builder: (_) {
                    // 1) If this is the Assigner on a WR Check ticket:
                    if (!widget.viewer && widget.taskStatus == "WR Verified") {
                      return Row(
                        children: [
                          // Mark Out-of-Scope
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _showOutOfScopeDialog(context),
                              style: actionButtonStyle.copyWith(
                                backgroundColor: WidgetStatePropertyAll(AppColors.danger),
                              ),
                              child: const Text("Out-of-Scope", style: TextStyle(color: AppColors.white),),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Accept & Proceed
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                try {
                                  final result = await _bloc.attendanceApprove('');
                                  if (result == WorkOrderActionResult.success) {
                                    alert("Ticket marked as Approved");
                                  }
                                } catch (err) {
                                  debugPrint('Failed to approve attendance: $err');
                                }
                              },  // existing submit flow
                              style: actionButtonStyle.copyWith(
                                backgroundColor: WidgetStatePropertyAll(AppColors.primary),
                              ),
                              child: const Text("Accept & Proceed", 
                                  style: TextStyle(color: AppColors.white)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                        ],
                      );
                    }

                    debugPrint("Masuk kat condition 2");
                    debugPrint("widget.viewer: ${widget.viewer}, _bloc.checkpoint: ${_bloc.checkpoint}");

                    // 2) Otherwise, your original buttons:
                    return (!widget.viewer && _bloc.checkpoint != 1)
                      ? viewButton
                      : standardButton;
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static const Set<String> _offlineEligibleStatuses = {'In Progress', 'WR Check'};

  bool get _isOfflineEligible => _offlineEligibleStatuses.contains(widget.taskStatus);

  Widget _buildOfflineControls() {
    return StreamBuilder<bool>(
      stream: _bloc.offlineMode$,
      builder: (context, snapshot) {
        final isOffline = snapshot.data ?? false;
        final isEligible = _isOfflineEligible;
        if (!isEligible && !isOffline) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isOffline ? Icons.offline_pin : Icons.cloud_queue,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Offline mode',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dark,
                        ),
                      ),
                    ),
                    Switch(
                      value: isOffline,
                      onChanged: _offlineToggleInFlight
                          ? null
                          : (value) {
                              if (value && !isEligible) {
                                Toast.show(
                                  'Offline mode is only available for In Progress or WR Check tickets.',
                                  duration: Toast.lengthShort,
                                  gravity: Toast.bottom,
                                );
                                return;
                              }
                              _toggleOfflineMode(value);
                            },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isOffline
                      ? 'We\'ll save all updates on this device. Tap Sync now once you\'re ready to push changes online.'
                      : isEligible
                          ? 'Enable offline mode when you expect to lose connectivity. We\'ll cache the task and you can sync later.'
                          : 'Offline mode is limited to tickets that are In Progress or WR Check.',
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
                if (_offlineToggleInFlight) ...[
                  const SizedBox(height: 12),
                  const LinearProgressIndicator(minHeight: 3),
                ],
                if (isOffline) ...[
                  const SizedBox(height: 12),
                  StreamBuilder<int>(
                    stream: _bloc.pendingActions$,
                    builder: (context, pendingSnapshot) {
                      final pending = pendingSnapshot.data ?? 0;
                      final label = pending == 1 ? 'action waiting to sync' : 'actions waiting to sync';
                      return Text(
                        '$pending $label',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.dark.withValues(alpha: 0.7),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: _syncInFlight
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.sync),
                      label: Text(_syncInFlight ? 'Syncing…' : 'Sync now'),
                      onPressed: _syncInFlight ? null : _handleManualSync,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleOfflineMode(bool enable) async {
    if (_offlineToggleInFlight) return;
    setState(() {
      _offlineToggleInFlight = true;
    });
    try {
      if (enable) {
        await _bloc.enableOfflineMode();
      } else {
        await _bloc.disableOfflineMode();
      }
    } finally {
      if (mounted) {
        setState(() {
          _offlineToggleInFlight = false;
        });
      }
    }
  }

  Future<void> _handleManualSync() async {
    if (_syncInFlight) return;
    setState(() {
      _syncInFlight = true;
    });
    try {
      Toast.show(
        'Syncing offline changes…',
        duration: Toast.lengthShort,
        gravity: Toast.bottom,
      );
      await _bloc.syncOfflineChanges();
    } finally {
      if (mounted) {
        setState(() {
          _syncInFlight = false;
        });
      }
    }
  }

  void alert(String txt) {
    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (BuildContext context) => CustomDialog(
        rootPage: "/workorder",
        description: txt,
        buttonText: "Okay",
        image: Image.asset("assets/icon_trans.png", height: 40),
      ),
    );
  }

  void _showOutOfScopeDialog(BuildContext context) {
    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (_) => CustomDialog(
        rootPage: "/workorder",
        title: "Remark",
        description: "Please enter reason for Out-of-Scope",
        buttonText: "Submit",
        cancel: true,
        secondButton: false,
        image: Image.asset("assets/icon_trans.png", height: 40),
        remarkTapped: (text) async {
          Navigator.pop(context);
          try {
            final result = await _bloc.returnOutOfScope(text);
            if (!mounted) return;
            if (result == WorkOrderActionResult.success) {
              alert("Ticket marked Out-of-Scope");
            }
          } catch (e) {
            alert("We couldn't process your request at this moment. Please try again later. If the issue persists, contact support.");
            debugPrint("Error marking Out-of-Scope: $e");
          }
        },
      ),
    );
  }
}

///
/// A refined list item that shows a complaint/section using a Card and Chip
///
class BuildTile extends StatelessWidget {
  final WorkOrderStatus workOrderStatus;
  final VoidCallback onTap;

  const BuildTile({
    super.key,
    required this.workOrderStatus,
    required this.onTap,
  });

  Color _getStatusColor(String? status) {
    switch (status) {
      case "Info":
        return AppColors.info;
      case "Pending":
        return AppColors.danger;
      case "In Progress":
        return AppColors.primary;
      default:
        return AppColors.success;
    }
  }

  Color _getCardBgColorByStatus(String? status) {
    switch (status) {
      case "Info":
        return AppColors.infoLight;
      case "Pending":
        return AppColors.dangerLight;
      case "In Progress":
        return AppColors.primaryLight;
      default:
        return AppColors.successLight;
    }
  }

  String _getDisplayStatus(String? status, String? materialStatus) {
    if (status == "Pending" && materialStatus != null && materialStatus.isNotEmpty) {
      return materialStatus;
    }
    return status ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final String statusText = _getDisplayStatus(
      workOrderStatus.sectionStatus,
      workOrderStatus.sectionStatusMaterial,
    );
    final Color accent = _getStatusColor(workOrderStatus.sectionStatus);

    final String title = [
      if (workOrderStatus.sectionName != null) "${workOrderStatus.sectionName}.",
      if (workOrderStatus.sectionDesc != null) workOrderStatus.sectionDesc
    ].join(' ');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: _getCardBgColorByStatus(workOrderStatus.sectionStatus),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0,2))],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            // 1) Left accent stripe
            Container(
              width: 6,
              height: 72,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // 2) Icon
            Icon(Icons.assignment, color: accent),
            const SizedBox(width: 12),

            // 3) Title & status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: accent,
                    ),
                  ),
                ],
              ),
            ),

            Icon(Icons.chevron_right, color: Colors.black38),

            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

///
/// A temporary tile that follows a similar style as BuildTile (if needed).
///
class _BuildTempTile extends StatelessWidget {
  final String title;
  final String status;
  final VoidCallback onTap;

  const _BuildTempTile(
    this.title,
    this.status,
    this.onTap,
  );

  @override
  Widget build(BuildContext context) {
    final Color statusColor = colorTheme4;
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Text(
                "F. ",
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  color: colorTheme3,
                ),
              ),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: colorTheme3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Chip(
                label: Text(
                  status,
                  style: TextStyle(color: Colors.white, fontFamily: 'Avenir'),
                ),
                backgroundColor: statusColor,
              ),
              const Icon(
                Icons.arrow_right,
                color: Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

///
/// The view button widget which conditionally displays a reject button alongside the standard button.
///
class _BuildViewButton extends StatelessWidget {
  final bool progress;
  final bool isAssign;
  final bool viewer;
  final String status;
  final Widget button; // standardButton
  final Future<WorkOrderActionResult> Function(String) reject;
  final Function(String) alert;

  const _BuildViewButton(
    this.progress,
    this.isAssign,
    this.viewer,
    this.status,
    this.button,
    this.reject,
    this.alert,
  );

  String getButtonLabel(String status) {
    switch (status) {
      case "Assign":
        return "Reject";
      case "Check":
      case "WR Verified":
        return "Re-Open";
      default:
        return "Revisit";
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('button created. progress: $progress, isAssign: $isAssign, viewer: $viewer, status: $status');
    // If in progress or assign mode, just show the single FAB you passed in
    if (isAssign || status == "Check" || status == "WR Verified" || viewer) {
      return button;
    }

    var buttonTextLabel = getButtonLabel(status);
    var bgColor = getButtonBgColorByStatus(buttonTextLabel);
    var labelColor = bgColor == AppColors.warning ? AppColors.dark : AppColors.white;

    // Otherwise lay out Reject + Submit side by side
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // 1) Reject button
          if (!viewer)
            Expanded(
              child: ElevatedButton(
                onPressed: () => _showRejectDialog(context),
                style: actionButtonStyle.copyWith(
                  backgroundColor: WidgetStatePropertyAll(bgColor),
                  foregroundColor: WidgetStatePropertyAll(AppColors.white),
                ),
                child: Text(buttonTextLabel, style: TextStyle(color: labelColor)),
              ),
            ),

          if (!viewer) const SizedBox(width: 12),

          // 2) Submit/View Form button (your standard FAB)
          Expanded(child: button),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (_) => CustomDialog(
        rootPage: "/workorder",
        title: "Remark",
        description: "Remark",
        buttonText: "Okay",
        secondButton: false,
        cancel: true,
        okayTapped: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
        image: Image.asset("assets/icon_trans.png", height: 40),
        remarkTapped: (text) async {
          Navigator.pop(context);
          try {
            final result = await reject(text);
            if (result == WorkOrderActionResult.success) {
              alert("Operation successful");
            }
          } catch (e) {
            alert("We couldn't process your request at this moment. Please try again later. If the issue persists, contact support.");
          }
        },
      ),
    );
  }
}

///
/// A floating action button allowing the user to reject/revisit a complaint.
///
class _BuildRejectButton extends StatelessWidget {
  final String label;
  final Function(String) alert;
  final Future<WorkOrderActionResult> Function(String) reject;

  const _BuildRejectButton(
    String status,
    this.reject,
    this.alert,
  )  : label = status == "Assign"
            ? "Reject"
            : status == "Verify"
                ? "Re-Open"
                : "Revisit";

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: "reject_button",
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.red,
      onPressed: () => showDialog(
        barrierDismissible: false,
        context: navigatorKey.currentContext!,
        builder: _buildDialog,
      ),
    );
  }

  Widget _buildDialog(BuildContext context) {
    return CustomDialog(
      rootPage: "/workorder",
      title: "Remark",
      description: "Remark",
      buttonText: "Okay",
      secondButton: false,
      cancel: true,
      okayTapped: () {
        Navigator.pop(context);
        Navigator.pop(context);
      },
      image: Image.asset("assets/icon_trans.png", height: 40),
      remarkTapped: (text) async {
        Navigator.pop(context);
        try {
          final result = await reject(text);
          if (result == WorkOrderActionResult.success) {
            alert("Operation successful");
          }
        } catch (e) {
          alert("We couldn't process your request at this moment. Please try again later. If the issue persists, contact support.");
        }
      },
    );
  }
}

///
/// The standard button widget which toggles between a loading indicator and text depending on the stream.
///
class _BuildStandardButton extends StatelessWidget {
  final MainBloc bloc;
  final bool viewOnly;
  final String mainStatus;
  final String woTaskStatus;
  final void Function(BuildContext) outOfScopeOnPressAction;

  const _BuildStandardButton(
    this.bloc,
    this.viewOnly,
    this.mainStatus, 
    this.woTaskStatus, 
    this.outOfScopeOnPressAction,
  );

  void alert(String txt) {
    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (BuildContext context) => CustomDialog(
        rootPage: "/workorder",
        description: txt,
        buttonText: "Okay",
        image: Image.asset("assets/icon_trans.png", height: 40),
      ),
    );
  }

  bool shouldShowOutOfScopeButton() {
    if(mainStatus == "Assign" && woTaskStatus == "Self Finding") {
      return true;
    } else if(mainStatus == "WR Verified" && woTaskStatus == "Client Complaint") {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
  final reOpenButton = Expanded(
                child: FloatingActionButton.extended(
                  heroTag: "reopen_button",
                  label: const Text(
                    "Re-Open",
                    style: TextStyle(color: Colors.black),
                  ),
                  backgroundColor: AppColors.warning,
                  onPressed: () {
                    showDialog(
                      context: navigatorKey.currentContext!,
                      barrierDismissible: false,
                      builder: (_) => CustomDialog(
                        rootPage: "/workorder",
                        title: "Remark",
                        description: "Remark",
                        buttonText: "Okay",
                        secondButton: false,
                        cancel: true,
                        okayTapped: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        image: Image.asset("assets/icon_trans.png", height: 40),
                        remarkTapped: (text) async {
                          Navigator.pop(context);
                          try {
                            final result = await bloc.reOpen(text);
                            if (result == WorkOrderActionResult.success) {
                              alert("Operation successful");
                            }
                          } catch (e) {
                            alert("We couldn't process your request at this moment. Please try again later. If the issue persists, contact support.");
                          }
                        },
                      ),
                    );
                  },
                ),
              );

  bool shouldShowReOpenButton() {
      if(viewOnly) return false;
      if(mainStatus == "Check" && woTaskStatus == "Client Complaint") return true;
      if(mainStatus == "Verify" && woTaskStatus != "Client Complaint") return true; // public, internal

      // else if (mainStatus == "Check" && woTaskStatus == "Client Complaint") return true;
      return false;
    }

      debugPrint("ReOpenCondition: ${shouldShowReOpenButton()}");

    debugPrint('hideOutOfScopeButton: ${shouldShowOutOfScopeButton() }');

    ToastContext().init(context);
    return StreamBuilder<bool>(
      stream: bloc.enable$,
      builder: (context, snapshot) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // New button (conditionally displayed)
            if (shouldShowOutOfScopeButton())
              Expanded(
                child: FloatingActionButton.extended(
                  heroTag: "out_of_scope_button",
                  label: const Text(
                    "Out-of-Scope",
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: AppColors.dangerDark, // Use your desired color
                  onPressed: () {
                    outOfScopeOnPressAction(context);
                  },
                ),
              ),
            if (shouldShowOutOfScopeButton())
              const SizedBox(width: 16), // Add spacing between buttons

            // if status is verify then
            if (shouldShowReOpenButton()) reOpenButton,
            if (shouldShowReOpenButton()) const SizedBox(width: 16), // Add spacing between buttons

            // Existing Submit button
            Expanded(
              child: FloatingActionButton.extended(
                heroTag: "accept_button",
                label: StreamBuilder<bool>(
                  stream: bloc.loading$,
                  builder: (_, loadingSnapshot) => loadingSnapshot.data == false
                      ? Text(
                          viewOnly ? "View Form" : "Submit",
                          style: const TextStyle(color: Colors.white),
                        )
                      : const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                ),
                backgroundColor:
                    (viewOnly || (snapshot.data ?? false)) ? colorTheme2 : AppColors.primaryDark,
                onPressed: () async {
                  if (viewOnly) {
                    // just view
                    bloc.openComplaint(context, viewOnly: viewOnly);
                  } else if (mainStatus == "Assign" ||
                      mainStatus == "Revisit" ||
                      mainStatus == "WR Reassign") {
                    // old Assign/Revisit path: must be enabled to submit
                    if (snapshot.data == true) {
                      try {
                        final result = await bloc.submit();
                        if (result == WorkOrderActionResult.success &&
                            navigatorKey.currentContext != null) {
                          showDialog(
                            context: navigatorKey.currentContext!,
                            barrierDismissible: false,
                            builder: _buildDialog,
                          );
                        }
                      } catch (err) {
                        Toast.show(
                          "We couldn't submit the request. Please try again.",
                          duration: Toast.lengthShort,
                          gravity: Toast.bottom,
                          backgroundColor: AppColors.danger,
                        );
                        debugPrint('Submit failed: $err');
                      }
                    } else {
                      Toast.show(
                        "All sections must be completed before submit",
                        duration: 1,
                      );
                    }
                  } else {
                    // DEFAULT for everything *else* (including WR Verified):
                    // if enabled → open the form; otherwise toast
                    debugPrint("snapshot : ${snapshot.data.toString()}");
                    debugPrint("mainStatus : $mainStatus");
                    if (snapshot.data == true ||
                        mainStatus == "WR Verified" ||
                        mainStatus == "WR Re-Open") {
                      if (mainStatus == "WR Check") {
                        var body = {
                          "action": "submit_wr_check",
                          "woTaskId": bloc.id,
                        };

                        final provider = Provider(fetchURL: "/api/m_wo.php");

                        try {
                          await provider.post(url: "/api/m_wo.php", body: body);
                          alert("Request submitted successfully");
                        } catch (err) {
                          Toast.show(
                            err.toString(),
                            duration: Toast.lengthShort,
                            gravity: Toast.bottom,
                            backgroundColor: AppColors.danger,
                          );
                        }
                      } else {
                        bloc.openComplaint(context, viewOnly: viewOnly);
                      }
                    } else {
                      Toast.show(
                        "All sections must be completed before submit",
                        duration: 1,
                      );
                    }
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialog(BuildContext context) {
    return CustomDialog(
      title: "Assignation Completed",
      rootPage: '/workorder',
      description: "Assignation technician has successfully updated.",
      buttonText: "Okay",
      image: Image.asset(
        "assets/icon_trans.png",
        height: 40,
      ),
    );
  }
}

///
/// A widget that displays time details in a table layout.
///
class _TimeDuration extends StatelessWidget {
  final Stream<ExecutionModel> stream;
  const _TimeDuration({required this.stream});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: StreamBuilder<ExecutionModel>(
        stream: stream,
        builder: (context, snap) {
          if (!snap.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final e = snap.data!;

          // pick colors
          final respColor = AppColors.info;
          final compColor = AppColors.success;

          return Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Top row: Response / Completion
                  Row(
                    children: [
                      // Response
                      Expanded(
                        child: _TimeSection(
                          title: "Response Time",
                          slaLabel: "SLA Time",
                          slaValue: e.responseTimeSla,
                          dueLabel: "Time Due",
                          dueValue: e.responseTimeDue,
                          accent: respColor,
                          exceeded: e.responseTimeExceeded,
                        ),
                      ),

                      // divider
                      Container(
                        width: 1,
                        height: 100,
                        color: Colors.grey.shade300,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                      ),

                      // Completion
                      Expanded(
                        child: _TimeSection(
                          title: "Completion Time",
                          slaLabel: "SLA Time",
                          slaValue: e.completionTimeSla,
                          dueLabel: "Time Due",
                          dueValue: e.completionTimeDue,
                          accent: compColor,
                          exceeded: e.completionTimeExceeded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Bottom row: Assigned / Execute
                  Row(
                    children: [
                      Expanded(
                        child: _TimeSmall(
                          label: "Assigned Time",
                          value: e.assignTime,
                          accent: respColor,
                          exceeded: e.responseTimeExceeded,
                        ),
                      ),
                      Expanded(
                        child: _TimeSmall(
                          label: "Execute Time",
                          value: e.execute,
                          accent: compColor,
                          exceeded: e.completionTimeExceeded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Big section widget used in the top row
class _TimeSection extends StatelessWidget {
  final String title, slaLabel, slaValue, dueLabel, dueValue;
  final Color accent;
  final bool exceeded;

  const _TimeSection({
    required this.title,
    required this.slaLabel,
    required this.slaValue,
    required this.dueLabel,
    required this.dueValue,
    required this.accent,
    required this.exceeded,
  });

  @override
  Widget build(BuildContext context) {
    final valueStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: exceeded ? AppColors.danger : accent,
    );

    final labelStyle = TextStyle(fontSize: 12, color: AppColors.dark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.dark)),
        const SizedBox(height: 12),

        // SLA
        Text(slaLabel, style: labelStyle),
        const SizedBox(height: 4),
        Text(slaValue, style: valueStyle),

        const SizedBox(height: 12),

        // Due
        Text(dueLabel, style: labelStyle),
        const SizedBox(height: 4),
        Text(dueValue, style: valueStyle),
      ],
    );
  }
}

/// Small label+value used in the bottom row
class _TimeSmall extends StatelessWidget {
  final String label, value;
  final Color accent;
  final bool exceeded;

  const _TimeSmall({
    required this.label,
    required this.value,
    required this.accent,
    required this.exceeded,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 12, color: AppColors.dark)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: exceeded ? AppColors.danger : accent)),
      ],
    );
  }
}
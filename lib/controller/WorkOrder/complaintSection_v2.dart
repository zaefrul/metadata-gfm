import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/WorkOrder/bloc/mainBloc.dart';
import 'package:gfm_gems/model/execution.dart';
import 'package:gfm_gems/model/user.dart';
import 'package:gfm_gems/model/workorder.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:gfm_gems/view/dialog.dart';
import 'package:toast/toast.dart';

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

  const ComplaintSection({
    Key? key,
    required this.id,
    required this.taskNo,
    required this.siteName,
    required this.taskStatus,
    required this.viewer,
    this.isAssign = false,
    this.isComplaintProgress = false,
  }) : super(key: key);

  @override
  _ComplaintSectionState createState() => _ComplaintSectionState();
}

class _ComplaintSectionState extends State<ComplaintSection> {
  late final MainBloc _bloc;
  bool showtime = false;
  bool _blocInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize the bloc only once since context is now available.
    if (!_blocInitialized) {
      debugPrint("Bloc initialized");
      debugPrint("ID: ${widget.id}");
      debugPrint("Status: ${widget.taskStatus}");
      debugPrint("Task No: ${widget.taskNo}");
      debugPrint("Viewer: ${widget.viewer}");
      _bloc = MainBloc(
        id: widget.id,
        status: widget.taskStatus,
        taskNo: widget.taskNo,
        context: context,
      );
      _blocInitialized = true;
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
  Widget build(BuildContext context) {
    final standardButton = _BuildStandardButton(
      _bloc,
      widget.viewer,
      widget.taskStatus,
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

    return Scaffold(
      appBar: AppBar(/* … */),
      body: StreamBuilder<List<WorkOrderStatus>>(
        stream: _bloc.sections$,
        builder: (ctx, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final sections = snapshot.data!;
          return Column(
            children: [
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
                        ),
                      );
                    },
                  ),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: (!widget.viewer && _bloc.checkpoint != 1) ? viewButton : standardButton,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void alert(String txt) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        rootPage: "/workorder",
        description: txt,
        buttonText: "Okay",
        image: Image.asset("assets/icon_trans.png", height: 40),
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
    Key? key,
    required this.workOrderStatus,
    required this.onTap,
  }) : super(key: key);

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
    this.onTap, {
    Key? key,
  }) : super(key: key);

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
  final Future<void> Function(String) reject;
  final Function(String) alert;

  const _BuildViewButton(
    this.progress,
    this.isAssign,
    this.viewer,
    this.status,
    this.button,
    this.reject,
    this.alert, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If in progress or assign mode, just show the single FAB you passed in
    if (progress || isAssign) {
      return button;
    }

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
                  backgroundColor: MaterialStateProperty.all(AppColors.primary),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                child: Text(
                  status == "Assign" ? "Reject" 
                    : status == "WR Verified" ? "Re‑Open" 
                    : "Revisit",
                ),
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
      context: context,
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
        remarkTapped: (text) {
          Navigator.pop(context);
          reject(text)
              .then((_) => alert("Operation successful"))
              .catchError(alert);
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
  final Future<void> Function(String) reject;

  _BuildRejectButton(
    String status,
    this.reject,
    this.alert, {
    Key? key,
  })  : label = status == "Assign"
            ? "Reject"
            : status == "WR Verified"
                ? "Re-Open"
                : "Revisit",
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: "reject_button",
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.red,
      onPressed: () => showDialog(
        context: context,
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
      remarkTapped: (text) {
        Navigator.pop(context);
        reject(text)
            .then((_) => alert("Operation successful"))
            .catchError(alert);
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

  const _BuildStandardButton(
    this.bloc,
    this.viewOnly,
    this.mainStatus, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return StreamBuilder<bool>(
      stream: bloc.enable$,
      builder: (context, snapshot) {
        return FloatingActionButton.extended(
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
              (viewOnly || (snapshot.data ?? false)) ? colorTheme2 : colorTheme3,
          onPressed: () {
            if (viewOnly) {
              bloc.openComplaint(context, viewOnly: viewOnly);
            } else if (mainStatus == "Assign" ||
                mainStatus == "Revisit" ||
                mainStatus == "WR Reassign") {
              if (snapshot.data != null && snapshot.data!) {
                bloc.submit().then((_) {
                  showDialog(context: context, builder: _buildDialog);
                }).catchError((err) => Toast.show(err));
              } else {
                Toast.show("All sections must be completed before submit",
                    duration: 1);
              }
            } else {
              if (snapshot.data != null && snapshot.data!) {
                bloc.openComplaint(context, viewOnly: viewOnly);
              } else {
                Toast.show("All sections must be completed before submit",
                    duration: 1);
              }
            }
          },
        );
      },
    );
  }

  Widget _buildDialog(BuildContext context) {
    return CustomDialog(
      rootPage: "/workorder",
      title: "Assignation Completed",
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
  const _TimeDuration({Key? key, required this.stream}) : super(key: key);

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
                          slaValue: e.responseTimeSla ?? "-",
                          dueLabel: "Time Due",
                          dueValue: e.responseTimeDue ?? "-",
                          accent: respColor,
                          exceeded:
                              e.responseTimeExceeded ?? false,
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
                          slaValue: e.completionTimeSla ?? "-",
                          dueLabel: "Time Due",
                          dueValue: e.completionTimeDue ?? "-",
                          accent: compColor,
                          exceeded:
                              e.completionTimeExceeded ?? false,
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
                          value: e.assignTime ?? "-",
                          accent: respColor,
                          exceeded: e.responseTimeExceeded ?? false,
                        ),
                      ),
                      Expanded(
                        child: _TimeSmall(
                          label: "Execute Time",
                          value: e.execute ?? "-",
                          accent: compColor,
                          exceeded: e.completionTimeExceeded ?? false,
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
    Key? key,
    required this.title,
    required this.slaLabel,
    required this.slaValue,
    required this.dueLabel,
    required this.dueValue,
    required this.accent,
    required this.exceeded,
  }) : super(key: key);

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
    Key? key,
    required this.label,
    required this.value,
    required this.accent,
    required this.exceeded,
  }) : super(key: key);

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
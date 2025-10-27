import 'package:flutter/material.dart';
import 'package:built_collection/built_collection.dart';
import 'package:GEMS/controller/PPM/Form/pdf.dart';
import 'package:GEMS/model/execution.dart';
import 'package:GEMS/model/responseValue.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:toast/toast.dart';
import 'package:GEMS/model/form.dart' as formModel;
import 'package:GEMS/controller/PPM/pending_sync.dart';
import 'package:GEMS/controller/PPM/widgets/pending_sync_banner.dart';
import 'package:GEMS/data/repository/ppm_repository.dart';

import 'add_technician.dart';
import 'formA.dart';
import 'formB.dart';
import 'formC.dart';
import 'formD.dart';
import 'formE.dart';
import 'formF.dart';
import 'formG.dart';
import 'formH.dart';

class FormView extends StatefulWidget {
  final String id;
  final String siteName;
  final String taskNo;
  final String taskStatus;
  final VoidCallback refresh;
  final bool viewer;

  const FormView({
    required this.id,
    required this.siteName,
    required this.taskNo,
    required this.taskStatus,
    required this.refresh,
    this.viewer = false,
    super.key,
  });

  @override
  _FormViewState createState() => _FormViewState(id: id);
}

class _FormViewState extends State<FormView> {
  List<String> allStatus = [];
  final Map<String, String> titles = {
    "A": "A. Asset Details",
    "B":
        "B. Safety Precaution / General Guidline prior to maintenance activity",
    "C": "C. Qualitative Task",
    "D": "D. Quantitative Task",
    "E": "E. Spare Parts / Material Used",
    "F": "F. Additional Reports",
    "G": "G. Comments / Remarks",
    "H": "H. Maintenance Image",
    "I": "I. Executor",
  };

  late Provider provider;
  final String id;
  bool verified = true;
  bool fieldDisable = true;
  ResponseValue? responseValue;
  List<String> statusList = [];
  int checkpoint = 1;
  PPMPendingSyncController? _pendingSync;
  final PPMRepository _repository = PPMRepository();
  bool _isOfflineMode = false;
  bool _offlineToggleInFlight = false;
  Future<ExecutionModel>? _timeFuture; // Cache the future
  bool _isLoading = true; // Track initial load state

  _FormViewState({required this.id});

  @override
  void initState() {
    super.initState();

    _pendingSync = PPMPendingSyncController();
    _pendingSync?.setPPMTaskId(widget.id);

    if (widget.taskStatus == "Check") checkpoint = 2;
    if (widget.taskStatus == "Verify") checkpoint = 3;
    if (widget.taskStatus == "Closed") checkpoint = 4;

    if (widget.taskStatus == "Open") {
      fieldDisable = true;
      verified = false;
    }
    if (widget.taskStatus == "In Progress" ||
        widget.taskStatus == "Re-Open") {
      fieldDisable = false;
    }

    if (widget.viewer) fieldDisable = true;

    provider = Provider(
      taskID: widget.id,
      fetchURL: "/ppm_v2/ppm_section_status/",
    );

    // Load everything in parallel for faster initial load
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Load all data in parallel instead of sequentially
    await Future.wait([
      _loadOfflineState(),
      _loadExecutionInfo(),
      refreshStatus(),
    ]);
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadExecutionInfo() async {
    try {
      final future = Provider(
        fetchURL: '/ppm_v2/execution_info/',
        taskID: widget.id,
      ).getJson(url: '/ppm_v2/execution_info/');
      
      final execData = await future;
      final model = ExecutionModel.fromJson(execData);
      
      if (mounted) {
        _timeFuture = Future.value(model);
      }
    } catch (err) {
      debugPrint('Failed to load execution info: $err');
      // Set a default/error future so the UI doesn't break
      if (mounted) {
        _timeFuture = Future.error(err);
      }
    }
  }

  Future<void> _loadOfflineState() async {
    final isOffline = await _repository.isOfflineModeEnabled(widget.id);
    if (mounted) {
      setState(() {
        _isOfflineMode = isOffline;
      });
    }
  }

  Future<void> _toggleOfflineMode(bool enable) async {
    if (_offlineToggleInFlight) return;
    setState(() {
      _offlineToggleInFlight = true;
    });
    try {
      await _repository.setOfflineMode(
        ppmTaskId: widget.id,
        enabled: enable,
      );
      if (mounted) {
        setState(() {
          _isOfflineMode = enable;
        });
        Toast.show(
          enable
              ? 'Offline mode enabled. We will store your updates locally until you sync.'
              : 'Offline mode disabled. You are back to live updates.',
          duration: Toast.lengthShort,
          gravity: Toast.bottom,
        );
      }
    } catch (err) {
      Toast.show(
        'Failed to toggle offline mode: $err',
        duration: Toast.lengthShort,
        gravity: Toast.bottom,
      );
    } finally {
      if (mounted) {
        setState(() {
          _offlineToggleInFlight = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pendingSync?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    provider.context = context;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: colorTheme3),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            getTitle(widget.siteName, bold: true),
            Text(
              widget.taskNo,
              style: TextStyle(fontSize: 16, color: colorTheme3),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
      body: responseValue == null
    ? Center(child: CircularProgressIndicator())
    : RefreshIndicator(
        onRefresh: refreshStatus,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Add pending sync banner at the top
              if (_pendingSync != null)
                PPMPendingSyncIndicator(controller: _pendingSync!),
              
              // Offline Mode Toggle
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
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
                              value: _isOfflineMode,
                              onChanged: _offlineToggleInFlight
                                  ? null
                                  : (value) {
                                      _toggleOfflineMode(value);
                                    },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isOfflineMode
                              ? 'We\'ll save all updates on this device. All actions will be queued and synced automatically when online.'
                              : 'Enable offline mode when you expect to lose connectivity. We\'ll cache the task and you can sync later.',
                          style: const TextStyle(fontSize: 14, height: 1.4),
                        ),
                        if (_offlineToggleInFlight) ...[
                          const SizedBox(height: 12),
                          const LinearProgressIndicator(minHeight: 3),
                        ],
                        // Show snapshot info when offline mode is enabled
                        if (_isOfflineMode && !_offlineToggleInFlight)
                          FutureBuilder<Map<String, dynamic>?>(
                            future: _repository.loadSnapshot(widget.id),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || snapshot.data == null) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    'Preparing offline copy…',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.dark.withValues(alpha: 0.7),
                                    ),
                                  ),
                                );
                              }
                              
                              final snapshotData = snapshot.data!;
                              final createdAt = snapshotData['createdAt'] as String?;
                              final sections = snapshotData['sections'] as List<dynamic>? ?? [];
                              
                              String cachedTime = 'Unknown';
                              if (createdAt != null) {
                                try {
                                  final date = DateTime.parse(createdAt);
                                  final now = DateTime.now();
                                  final diff = now.difference(date);
                                  
                                  if (diff.inMinutes < 1) {
                                    cachedTime = 'Just now';
                                  } else if (diff.inHours < 1) {
                                    cachedTime = '${diff.inMinutes}m ago';
                                  } else if (diff.inDays < 1) {
                                    cachedTime = '${diff.inHours}h ago';
                                  } else {
                                    cachedTime = '${diff.inDays}d ago';
                                  }
                                } catch (_) {
                                  cachedTime = 'Recently';
                                }
                              }
                              
                              return Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Cached $cachedTime',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.dark.withValues(alpha: 0.7),
                                      ),
                                    ),
                                    if (sections.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          '${sections.length} sections available offline',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: AppColors.dark.withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              
              ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: statusList.length + 1,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, item) {
                  if (item == 0) {
                    // Use cached future instead of creating new one
                    return FutureBuilder<ExecutionModel>(
                      future: _timeFuture,
                      builder: (context, snapshot) {
                        // Show loading state during initial load
                        if (_isLoading && !snapshot.hasData) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Loading time allocation..."),
                              ],
                            ),
                          );
                        }
                        
                        final String max = snapshot.data?.max ?? "0";
                        final String min = snapshot.data?.min ?? "0";
                        final bool exceed = snapshot.data?.exceed ?? false;
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Min Time Allocated : $min",
                                style: TextStyle(color: exceed ? Colors.red : Colors.black),
                              ),
                              SizedBox(height: 12),
                              Text("Max Time Allocated : $max"),
                            ],
                          ),
                        );
                      },
                    );
                  }

                  formModel.Form form = responseValue?.statusList != null
                      ? responseValue!.statusList![item - 1]
                      : formModel.Form();
                  return tile(
                    form.ppmTaskSectionName,
                    form.ppmTaskSectionStatus,
                    form.checkParts,
                    form.checkAdditionalReport,
                  );
                },
              ),

              // Bottom Submit Button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                child: ElevatedButton.icon(
                  icon: Icon(widget.viewer ? Icons.visibility : Icons.send, 
                      color: (widget.viewer || enableSubmit)
                        ? AppColors.white
                        : AppColors.dark),
                  label: Text(widget.viewer ? "View Form" : "Submit", 
                      style: TextStyle(color: (widget.viewer || enableSubmit)
                        ? AppColors.white
                        : AppColors.dark)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (widget.viewer || enableSubmit)
                        ? AppColors.primary
                        : AppColors.secondaryLight,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: (widget.viewer || enableSubmit)
                      ? () {
                          var page = PDF(
                            id: widget.id,
                            transactionNo: widget.taskNo,
                            viewer: widget.viewer,
                            checkpoint: checkpoint,
                            submitted: () {
                              widget.refresh();
                              fieldDisable = true;
                            },
                          );
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => page,
                          ));
                        }
                      : () {
                          if (!verified) {
                            Toast.show(
                              "To get started, you need to scan the QR code of the asset from section A. Asset Details.",
                              duration: 3,
                            );
                          } else {
                            Toast.show(
                              "All sections must be completed before submit",
                              duration: 1,
                            );
                          }
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getTitle(String text, {bool bold = false, double? size}) => Container(
        padding: EdgeInsets.only(top: 3),
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: colorTheme3,
          ),
        ),
      );

  Widget status(String text) {
    Color color;
    if (text == "Info") {
      color = colorTheme2;
    } else if (text == "Pending") {
      color = colorTheme4;
    } else if (text == "In Progress") {
      color = colorTheme1;
    } else {
      color = colorTheme3;
    }

    return Container(
      alignment: Alignment.center,
      height: 30.0,
      width: 100.0,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontFamily: 'Avenir'),
      ),
    );
  }

  Widget tile(String item, String statusDesc, String parts, String report) {
    final Color accent = _getStatusColor(statusDesc);
    final Color bgColor = _getStatusCardColor(statusDesc);
    final String title = titles[item] ?? 'Section';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: InkWell(
        onTap: () => _openFormSection(item, parts, report),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            // Accent stripe
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

            // Section icon
            Icon(Icons.assignment, color: accent),
            const SizedBox(width: 12),

            // Title and Status
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
                    statusDesc,
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

  Color _getStatusColor(String? status) {
    switch (status) {
      case "Info":
        return AppColors.info;
      case "Pending":
        return AppColors.danger;
      case "In Progress":
        return AppColors.primary;
      case "Completed":
        return AppColors.success;
      default:
        return AppColors.secondary;
    }
  }

  Color _getStatusCardColor(String? status) {
    switch (status) {
      case "Info":
        return AppColors.infoLight;
      case "Pending":
        return AppColors.dangerLight;
      case "In Progress":
        return AppColors.primaryLight;
      case "Completed":
        return AppColors.successLight;
      default:
        return AppColors.secondaryLight;
    }
  }

  void _openFormSection(String item, String parts, String report) {
    Object object = Container(); // default fallback

    if (item == "A") {
      object = FormA(
        id,
        verification: (bool status) {
          setState(() {
            verified = status;
            fieldDisable = !status;
          });
        },
        viewer: widget.viewer,
        verified: verified,
      );
    } else if (item == "B") {
      object = FormB(id);
    } else if (item == "C") {
      object = FormC(id, verified, (_) => refreshStatus(), fieldDisable);
    } else if (item == "D") {
      object = FormD(id, verified, () => refreshStatus(), fieldDisable);
    } else if (item == "E") {
      object = FormE(id, verified, () => refreshStatus(), fieldDisable, parts);
    } else if (item == "F") {
      object = FormF(id, verified, () => refreshStatus(), fieldDisable, report);
    } else if (item == "G") {
      object = FormG(id, verified, (_) => refreshStatus(), fieldDisable);
    } else if (item == "H") {
      object = FormH(id, verified, (_) => refreshStatus(), fieldDisable);
    } else if (item == "I") {
      object = PPMAddTechnician(id, verified, () => refreshStatus(), fieldDisable);
    }

    Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => object as Widget))
      .whenComplete(() => refreshStatus());
  }

  bool get enableSubmit {
    for (String f in statusList) {
      if (f != "Info" && f != "Completed") return false;
    }
    return true;
  }

  Future<void> refreshStatus() async {
    // Use cached offline state instead of querying DB again
    if (_isOfflineMode) {
      final snapshot = await _repository.loadSnapshot(widget.id);
      if (snapshot != null) {
        debugPrint('FormView.refreshStatus: Using cached snapshot data');
        // Build ResponseValue from snapshot
        final sections = snapshot['sections'] as List<dynamic>;
        final formList = sections.map((s) {
          return formModel.Form((b) => b
            ..ppmTaskSectionId = ''
            ..ppmTaskSectionName = s['ppmTaskSectionName'] ?? ''
            ..ppmTaskId = widget.id
            ..ppmTaskSectionStatus = s['ppmTaskSectionStatus'] ?? ''
            ..checkParts = s['checkParts'] ?? ''
            ..checkAdditionalReport = s['checkAdditionalReport'] ?? '');
        }).toList();

        setState(() {
          responseValue = ResponseValue((b) => b
            ..success = true
            ..error = ''
            ..errmsg = ''
            ..result = 'cached'
            ..statusList = ListBuilder(formList));
          var result = responseValue!.statusList != null
              ? responseValue!.statusList!.map((f) => f.ppmTaskSectionStatus).toList()
              : [];
          statusList = result.cast<String>();
        });
        return;
      }
    }

    // Fallback to API call
    try {
      var value = await provider.fetch();
      setState(() {
        responseValue = value;
        var result = responseValue!.statusList != null
            ? responseValue!.statusList!.map((f) => f.ppmTaskSectionStatus).toList()
            : [];
        statusList = result.cast<String>();
      });
    } catch (err) {
      // If API fails and we're in offline mode, try to load snapshot
      if (_isOfflineMode) {
        final snapshot = await _repository.loadSnapshot(widget.id);
        if (snapshot != null) {
          debugPrint('FormView.refreshStatus: API failed, using cached snapshot');
          final sections = snapshot['sections'] as List<dynamic>;
          final formList = sections.map((s) {
            return formModel.Form((b) => b
              ..ppmTaskSectionId = ''
              ..ppmTaskSectionName = s['ppmTaskSectionName'] ?? ''
              ..ppmTaskId = widget.id
              ..ppmTaskSectionStatus = s['ppmTaskSectionStatus'] ?? ''
              ..checkParts = s['checkParts'] ?? ''
              ..checkAdditionalReport = s['checkAdditionalReport'] ?? '');
          }).toList();

          setState(() {
            responseValue = ResponseValue((b) => b
              ..success = true
              ..error = ''
              ..errmsg = ''
              ..result = 'cached'
              ..statusList = ListBuilder(formList));
            var result = responseValue!.statusList != null
                ? responseValue!.statusList!.map((f) => f.ppmTaskSectionStatus).toList()
                : [];
            statusList = result.cast<String>();
          });
          return;
        }
      }
      rethrow;
    }
  }
}

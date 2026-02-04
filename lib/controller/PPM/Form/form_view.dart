import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:built_collection/built_collection.dart';
import 'package:intl/intl.dart';
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
  int _rebuildCounter = 0; // Force FutureBuilder to rebuild
  
  // Task completion tracking
  DateTime? _taskStartTime;
  DateTime? _taskEndTime;
  Duration? _taskDuration;
  bool _taskIsCompleted = false;

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
    
    // Check if task is already completed (from pending actions)
    _checkCompletionStatus();
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
      // Check connectivity before making API call
      final isOnline = await _checkConnectivity();
      
      if (!isOnline || _isOfflineMode) {
        // When offline or in offline mode, create a default ExecutionModel
        debugPrint('FormView._loadExecutionInfo: Using default execution info (offline)');
        final model = ExecutionModel(
          '-', // max
          '-', // min
          false, // exceed
          '-', // current
          '-', // execute
          '-', // assignTime
          '-', // responseTimeDue
          '-', // completionTimeDue
          '-', // responseTimeSla
          '-', // completionTimeSla
          false, // completionTimeExceeded
          false, // responseTimeExceeded
        );
        
        if (mounted) {
          _timeFuture = Future.value(model);
        }
        return;
      }
      
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
      // Set a default model so the UI doesn't break
      if (mounted) {
        final model = ExecutionModel(
          '-', // max
          '-', // min
          false, // exceed
          '-', // current
          '-', // execute
          '-', // assignTime
          '-', // responseTimeDue
          '-', // completionTimeDue
          '-', // responseTimeSla
          '-', // completionTimeSla
          false, // completionTimeExceeded
          false, // responseTimeExceeded
        );
        _timeFuture = Future.value(model);
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

  /// Check if device has internet connectivity
  Future<bool> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _checkCompletionStatus() async {
    try {
      // Check pending actions for completion action (submit_ppm or legacy complete_ppm_task)
      final pendingActions = await _repository.getPendingActions(ppmTaskId: widget.id);
      for (final action in pendingActions) {
        if (action.action == 'submit_ppm' || action.action == 'complete_ppm_task') {
          final payload = json.decode(action.payloadJson);
          final endTimeStr = payload['endTime'] as String?;
          if (endTimeStr != null) {
            setState(() {
              _taskEndTime = DateTime.parse(endTimeStr);
              _taskIsCompleted = true;
              fieldDisable = true;
            });
          }
          break;
        }
      }
    } catch (e) {
      debugPrint('Error checking completion status: $e');
    }
  }

  Future<void> _toggleOfflineMode(bool enable) async {
    if (_offlineToggleInFlight) return;
    
    // If disabling offline mode, check for pending actions and confirm
    if (!enable) {
      final pendingCount = await _repository.getPendingActionsCount(widget.id);
      
      if (pendingCount > 0) {
        // Show confirmation dialog
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Sync Pending Changes?'),
              content: Text(
                'You have $pendingCount pending changes that haven\'t been synced yet.\n\n'
                'Disabling offline mode will automatically sync these changes to the server.\n\n'
                'Continue?'
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text('Sync & Disable'),
                ),
              ],
            );
          },
        );
        
        if (confirmed != true) return; // User cancelled
      }
    }
    
    setState(() {
      _offlineToggleInFlight = true;
    });
    
    try {
      if (!enable) {
        final pendingCount = await _repository.getPendingActionsCount(widget.id);
        
        if (pendingCount > 0) {
          // Show syncing message
          Toast.show(
            'Syncing $pendingCount pending changes...',
            duration: Toast.lengthLong,
            gravity: Toast.bottom,
          );
        }
      }
      
      await _repository.setOfflineMode(
        ppmTaskId: widget.id,
        enabled: enable,
      );
      if (mounted) {
        setState(() {
          _isOfflineMode = enable;
        });
        
        // Get final pending count to show appropriate message
        final finalPendingCount = await _repository.getPendingActionsCount(widget.id);
        
        Toast.show(
          enable
              ? 'Offline mode enabled. Updates will be stored locally.'
              : finalPendingCount > 0
                  ? 'Offline mode disabled. Note: $finalPendingCount changes could not be synced (network issue). They will sync when online.'
                  : 'Offline mode disabled. All changes synced successfully.',
          duration: Toast.lengthLong,
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

  void _showPendingActionsModal(BuildContext context) async {
    final summary = await _repository.getPendingActionsSummary(widget.id);
    
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.3,
            maxChildSize: 0.8,
            expand: false,
            builder: (context, scrollController) {
              return Column(
                children: [
                  // Handle bar
                  Container(
                    margin: EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Title
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.pending_actions, color: Colors.amber.shade700),
                        SizedBox(width: 12),
                        Text(
                          'Pending Changes',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.dark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1),
                  // Content
                  Expanded(
                    child: summary.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 64,
                                  color: Colors.green,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No pending changes',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView(
                            controller: scrollController,
                            padding: EdgeInsets.all(16),
                            children: [
                              Text(
                                'These changes will be synced when you\'re back online:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 16),
                              ...summary.entries.map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.amber[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.amber.shade200,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: Colors.amber,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${entry.value}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                entry.key,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.dark,
                                                ),
                                              ),
                                              SizedBox(height: 2),
                                              Text(
                                                '${entry.value} ${entry.value == 1 ? 'change' : 'changes'} pending',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.sync,
                                          color: Colors.amber.shade700,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                              SizedBox(height: 16),
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline, size: 20, color: Colors.blue[700]),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Changes will sync automatically when you have internet connection.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue[900],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                  // Close button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Close',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _endPPMTask() async {
    // Task must be started before it can be ended
    if (_taskStartTime == null) {
      Toast.show(
        'Start the task before ending it.',
        duration: Toast.lengthShort,
        gravity: Toast.bottom,
      );
      return;
    }

    // Ensure every section is marked as completed before ending the task
    final incompleteSections = <String>[];
    const requiredSections = {'C', 'D', 'E', 'F', 'G', 'H', 'I'};

    if (responseValue?.statusList != null && responseValue!.statusList!.isNotEmpty) {
      for (final section in responseValue!.statusList!) {
        final status = section.ppmTaskSectionStatus;
        final sectionName = section.ppmTaskSectionName;

        if (!requiredSections.contains(sectionName)) {
          continue; // Sections A & B are informational, ignore others not in the set
        }

        if (status != 'Completed') {
          final displayName = sectionName.isNotEmpty ? 'Section $sectionName' : 'a section';
          incompleteSections.add(displayName);
        }
      }
    }

    if (incompleteSections.isNotEmpty) {
      Toast.show(
        'Complete ${incompleteSections.join(', ')} before ending the task.',
        duration: Toast.lengthShort,
        gravity: Toast.bottom,
      );
      return;
    }

    // Confirm with user before ending task
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('End PPM Task'),
        content: const Text(
          'Are you sure you want to end this PPM task? This will record the completion time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('End Task'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Record end time
      final endTime = DateTime.now();

      // Call repository to complete task (handles online/offline automatically)
      final result = await _repository.completeTask(
        ppmTaskId: widget.id,
        endTime: endTime,
      );

      if (!mounted) return;

      // Update completion status
      setState(() {
        _taskEndTime = endTime;
        _taskIsCompleted = true;
        if (_taskStartTime != null) {
          _taskDuration = endTime.difference(_taskStartTime!);
        }
        fieldDisable = true; // Lock all sections after completion
      });

      if (result == PPMActionResult.success) {
        Toast.show(
          'PPM task completed successfully!',
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
        );
      } else {
        // PPMActionResult.queued
        Toast.show(
          'Task end time recorded. Will sync when online.',
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
        );
      }

      // Refresh status to update UI
      await refreshStatus();

      // Navigate back to task list after a short delay
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).pop();
        widget.refresh();
      }
    } catch (err) {
      debugPrint('Error ending PPM task: $err');
      if (mounted) {
        Toast.show(
          'Failed to end task: $err',
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
        );
      }
    }
  }

  // Helper methods for completion status UI
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.green[700]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.green[800],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '$hours hour${hours > 1 ? 's' : ''} $minutes min${minutes > 1 ? 's' : ''}';
    }
    return '$minutes minute${minutes > 1 ? 's' : ''}';
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
                child: FutureBuilder<int>(
                  future: _repository.getPendingActionsCount(widget.id),
                  builder: (context, pendingSnapshot) {
                    final pendingCount = pendingSnapshot.data ?? 0;
                    final hasPendingActions = pendingCount > 0;
                    
                    return Card(
                      elevation: 2,
                      color: hasPendingActions 
                          ? Colors.amber[50] 
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: hasPendingActions
                            ? BorderSide(color: Colors.amber.shade300, width: 1.5)
                            : BorderSide.none,
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
                                  child: Row(
                                    children: [
                                      Text(
                                        'Offline mode',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.dark,
                                        ),
                                      ),
                                      if (hasPendingActions) ...[
                                        SizedBox(width: 8),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.amber,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.pending_actions,
                                                size: 12,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'Pending Sync',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
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
                                            child: Row(
                                              children: [
                                                Text(
                                                  '${sections.length} sections available offline',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: AppColors.dark.withValues(alpha: 0.7),
                                                  ),
                                                ),
                                                if (hasPendingActions) ...[
                                                  Text(
                                                    ' • ',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: AppColors.dark.withValues(alpha: 0.7),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () => _showPendingActionsModal(context),
                                                    child: Text(
                                                      'View pending changes',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.amber.shade700,
                                                        fontWeight: FontWeight.w600,
                                                        decoration: TextDecoration.underline,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
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
                    );
                  },
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

              // Task Completion Status Card
              if (_taskIsCompleted || _taskEndTime != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: FutureBuilder<ExecutionModel>(
                    future: _timeFuture,
                    builder: (context, snapshot) {
                      final String? maxTime = snapshot.data?.max;
                      final Duration? maxDuration = maxTime != null && maxTime != '-' 
                          ? Duration(hours: int.tryParse(maxTime) ?? 0) 
                          : null;
                      final bool isWithinSLA = _taskDuration != null && maxDuration != null 
                          ? _taskDuration! <= maxDuration 
                          : true;
                      
                      final cardColor = isWithinSLA ? Colors.green[50] : Colors.orange[50];
                      final borderColor = isWithinSLA ? Colors.green : Colors.orange;
                      final iconColor = isWithinSLA ? Colors.green : Colors.orange;
                      final textColor = isWithinSLA ? Colors.green[800] : Colors.orange[800];
                      
                      return Card(
                        color: cardColor,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: borderColor, width: 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isWithinSLA ? Icons.check_circle : Icons.warning,
                                    color: iconColor,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Task Completed',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                        ),
                                        if (!isWithinSLA)
                                          Text(
                                            'Exceeded SLA',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.orange[600],
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (!isWithinSLA)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'OVER SLA',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (_taskStartTime != null) ...[
                                _buildInfoRow(
                                  Icons.play_circle_outline,
                                  'Start Time',
                                  _formatDateTime(_taskStartTime!),
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (_taskEndTime != null) ...[
                                _buildInfoRow(
                                  Icons.stop_circle_outlined,
                                  'End Time',
                                  _formatDateTime(_taskEndTime!),
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (_taskDuration != null) ...[
                                _buildInfoRow(
                                  Icons.timer_outlined,
                                  'Duration',
                                  _formatDuration(_taskDuration!),
                                ),
                                if (maxDuration != null) ...[
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                    Icons.schedule,
                                    'Max Allocated',
                                    _formatDuration(maxDuration),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // End PPM Button (show when task is in progress, NOT completed, and OFFLINE MODE is enabled)
              FutureBuilder<bool>(
                future: _repository.isOfflineModeEnabled(widget.id),
                builder: (context, offlineSnapshot) {
                  final isOfflineEnabled = offlineSnapshot.data ?? false;
                  
                  if (!widget.viewer && 
                      !_taskIsCompleted && 
                      _taskEndTime == null &&
                      isOfflineEnabled &&
                      responseValue?.statusList != null && 
                      responseValue!.statusList!.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle, color: Colors.white),
                        label: const Text('End PPM Task', 
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () async {
                          await _endPPMTask();
                        },
                      ),
                    );
                  }
                  return const SizedBox.shrink();
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
    return FutureBuilder<Map<String, int>>(
      key: ValueKey('tile_${item}_$_rebuildCounter'), // Force rebuild when counter changes
      future: _isOfflineMode ? _repository.getPendingActionsSummary(widget.id) : Future.value({}),
      builder: (context, pendingSnapshot) {
        final pendingActions = pendingSnapshot.data ?? {};
        
        // Check if this section has pending changes (completed offline but not synced)
        final sectionKey = 'Section ${item.toUpperCase()}';
        final hasPendingChanges = pendingActions.containsKey(sectionKey) && pendingActions[sectionKey]! > 0;
        
        // If offline mode and has pending changes, treat as completed (use secondary color)
        final effectiveStatus = (_isOfflineMode && hasPendingChanges) ? 'Completed' : statusDesc;
        
        final Color accent = _getStatusColor(effectiveStatus);
        final Color bgColor = _getStatusCardColor(effectiveStatus);
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
                      Row(
                        children: [
                          Text(
                            effectiveStatus,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: accent,
                            ),
                          ),
                          if (_isOfflineMode && hasPendingChanges) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Pending Sync',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
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
      },
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
    // Increment rebuild counter to force FutureBuilder widgets to rebuild
    setState(() {
      _rebuildCounter++;
    });
    
    // Refresh pending sync count immediately so banner reflects current state
    await _pendingSync?.refreshPendingCount();
    
    // Check connectivity first
    final isOnline = await _checkConnectivity();
    // If there are pending (unsynced) actions for this task, prefer cached snapshot
    // so the UI shows the user's offline-entered values until sync completes.
    try {
      final pendingCount = await _repository.getPendingActionsCount(widget.id);
      if (pendingCount > 0) {
        debugPrint('FormView.refreshStatus: Detected $pendingCount pending actions - using cached snapshot');
        final snapshot = await _repository.loadSnapshot(widget.id);
        if (snapshot != null) {
          // Use cached snapshot and return early
          debugPrint('FormView.refreshStatus: Using cached snapshot due to pending actions');
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

          if (mounted) {
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
          }
          return;
        }
        // If no snapshot exists, fall through to connectivity checks below
      }
    } catch (err) {
      debugPrint('FormView.refreshStatus: Error while checking pending count: $err');
      // proceed normally
    }
    
    // If offline mode is enabled OR no internet connection, load from cache
    if (_isOfflineMode || !isOnline) {
      final snapshot = await _repository.loadSnapshot(widget.id);
      if (snapshot != null) {
        debugPrint('FormView.refreshStatus: ${_isOfflineMode ? "Offline mode" : "No internet"} - Using cached snapshot data');
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
      } else {
        // No cached data available
        debugPrint('FormView.refreshStatus: No cached data available for offline mode');
        setState(() {
          responseValue = ResponseValue((b) => b
            ..success = false
            ..error = 'NO_CACHE'
            ..errmsg = 'No cached data available. Please enable offline mode when connected to internet.'
            ..result = ''
            ..statusList = ListBuilder([]));
          statusList = [];
        });
        return;
      }
    }

    // Online and not in offline mode - fetch from API
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
      debugPrint('FormView.refreshStatus: API call failed: $err');
      // API failed, try to use cache as fallback
      final snapshot = await _repository.loadSnapshot(widget.id);
      if (snapshot != null) {
        debugPrint('FormView.refreshStatus: API failed, using cached snapshot as fallback');
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
      rethrow;
    }
  }
}

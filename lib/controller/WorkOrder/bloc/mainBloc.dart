import 'dart:async';

import 'package:flutter/material.dart';
import 'package:GEMS/controller/WorkOrder/complaintSectionResponseImage.dart';
import 'package:GEMS/controller/WorkOrder/pending_sync.dart';
import 'package:GEMS/data/repository/work_order_detail_repository.dart';
import 'package:GEMS/model/execution.dart';
import 'package:GEMS/model/workorder.dart';
import 'package:rxdart/rxdart.dart';

import '../addTechnician.dart';
import '../complaintPDF.dart';
import '../complaintSectionA.dart';
import '../complaintSectionB_Assign.dart';
import '../complaintSectionB_Remark.dart';
import '../complaintSectionC.dart';
import '../complaintSectionD.dart';
import '../complaintSectionD_material.dart';

enum MutationFeedbackType { success, queued, error }

class MutationFeedback {
  const MutationFeedback({
    required this.message,
    this.type = MutationFeedbackType.success,
  });

  final String message;
  final MutationFeedbackType type;
}

class MainBloc {
  // -- VARIABLES
  int checkpoint = 0;
  final WorkOrderDetailRepository _repository;
  final String _id;
  final String _status;
  final String _taskNo;
  final String _taskCategory;

  // -- STATE SUBJECTS
  final BehaviorSubject<List<WorkOrderStatus>> _sections =
    BehaviorSubject<List<WorkOrderStatus>>.seeded(const []);
  final BehaviorSubject<bool> _enableSubmit =
      BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<bool> _loading = BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<ExecutionModel> _execution =
      BehaviorSubject<ExecutionModel>();
  final BehaviorSubject<int> _pendingActions =
    BehaviorSubject<int>.seeded(0);
  final BehaviorSubject<bool> _offlineMode =
    BehaviorSubject<bool>.seeded(false);
  final PublishSubject<MutationFeedback> _feedback =
    PublishSubject<MutationFeedback>();

  // -- INITIALIZER
  MainBloc(
      {required String id,
      String status = '',
      required String taskNo,
      required BuildContext context,
      required String woTaskCategory})
      : _id = id,
        _status = status,
        _taskNo = taskNo,
        _taskCategory = woTaskCategory,
        _repository = WorkOrderDetailRepository() {
    setCheckpoint(_status);
    _initialize();
  }

  // -- DISPOSE
  void dispose() {
    _sections.close();
    _enableSubmit.close();
    _loading.close();
    _execution.close();
    _pendingActions.close();
    _offlineMode.close();
    _feedback.close();
  }

  // -- GETTERS
  Stream<List<WorkOrderStatus>> get sections$ => _sections.stream;
  Stream<bool> get enable$ => _enableSubmit.stream;
  Stream<bool> get loading$ => _loading.stream;
  Stream<ExecutionModel> get execution$ => _execution.stream;
  Stream<int> get pendingActions$ => _pendingActions.stream;
  Stream<bool> get offlineMode$ => _offlineMode.stream;
  Stream<MutationFeedback> get feedback$ => _feedback.stream;
  String get id => _id;

  // -- SETTERS
  set sections(List<WorkOrderStatus> values) => _sections.sink.add(values);
  set enable(bool value) => _enableSubmit.sink.add(value);
  set loading(bool value) => _loading.sink.add(value);
  set execution(Map<String, dynamic> v) =>
      _execution.sink.add(ExecutionModel.fromJson(v));
  set context(BuildContext context) {}

  // -- METHODS
  Future<void> refresh() async {
    await _load(forceRefresh: true);
  }

  void _initialize() {
    unawaited(_load(forceRefresh: false));
    unawaited(_refreshPendingCount());
    unawaited(_refreshOfflineState());
  }

  Future<void> _load({required bool forceRefresh}) async {
    await _refreshOfflineState();
    final forcedOffline = _offlineMode.value;
    if (!forcedOffline) {
      await _repository.syncPendingActions();
    }
    await _refreshPendingCount();

    try {
      final data = await _repository.getSections(
        workOrderId: _id,
        currentStatus: _status,
        forceRefresh: forceRefresh && !forcedOffline,
        onRemoteUpdate: (updated) {
          _updateSections(updated);
        },
      );
      _updateSections(data);
    } catch (err) {
      debugPrint('Failed to load sections: $err');
      if (_sections.valueOrNull == null) {
        _sections.add(const []);
      }
    }

    try {
      final execution = await _repository.getExecution(
        workOrderId: _id,
        forceRefresh: forceRefresh && !forcedOffline,
        onRemoteUpdate: (model) {
          _execution.sink.add(model);
        },
      );
      if (execution != null) {
        _execution.sink.add(execution);
      }
    } catch (err) {
      debugPrint('Failed to load execution info: $err');
    }
  }

  void _updateSections(List<WorkOrderStatus> values) {
    sections = values;
    enable = enableSubmit();
  }

  Future<void> _refreshPendingCount() async {
    final count = await _repository.pendingActionCount(workOrderId: _id);
    _pendingActions.add(count);
  }

  Future<void> _refreshOfflineState() async {
    final isOffline = await _repository.isOfflineModeEnabled(_id);
    _offlineMode.add(isOffline);
  }

  Future<void> retryPendingSync() async {
    await _repository.syncPendingActions();
    await _refreshPendingCount();
    await _load(forceRefresh: true);
  }

  Future<void> enableOfflineMode() async {
    try {
      await _repository.setOfflineMode(
        workOrderId: _id,
        enabled: true,
        currentStatus: _status,
      );
      await _refreshOfflineState();
      await _refreshPendingCount();
      await _load(forceRefresh: false);
      _feedback.add(
        const MutationFeedback(
          message:
              'Offline mode enabled. We will store your updates locally until you sync.',
          type: MutationFeedbackType.success,
        ),
      );
    } catch (err) {
      _handleActionError('enableOfflineMode error: $err', err);
    }
  }

  Future<void> disableOfflineMode() async {
    try {
      await _repository.setOfflineMode(
        workOrderId: _id,
        enabled: false,
      );
      await _refreshOfflineState();
      await _refreshPendingCount();
      await _load(forceRefresh: true);
      _feedback.add(
        const MutationFeedback(
          message: 'Offline mode disabled. You are back to live updates.',
          type: MutationFeedbackType.success,
        ),
      );
    } catch (err) {
      _handleActionError('disableOfflineMode error: $err', err);
    }
  }

  Future<void> syncOfflineChanges() async {
    try {
      await retryPendingSync();
    } catch (err) {
      _handleActionError('syncOfflineChanges error: $err', err);
    }
  }

  Future<void> _handleActionResult({
    required WorkOrderActionResult result,
    required String successMessage,
    required String queuedMessage,
    bool refreshOnSuccess = false,
  }) async {
    loading = false;
    if (result == WorkOrderActionResult.queued) {
      _feedback.add(
        MutationFeedback(
          message: queuedMessage,
          type: MutationFeedbackType.queued,
        ),
      );
    } else {
      if (successMessage.isNotEmpty) {
        _feedback.add(
          MutationFeedback(
            message: successMessage,
            type: MutationFeedbackType.success,
          ),
        );
      }
      if (refreshOnSuccess) {
        await refresh();
      }
    }
    await _refreshPendingCount();
  }

  void _handleActionError(String message, Object err) {
    debugPrint(message);
    _feedback.add(
      MutationFeedback(
        message: 'We could not complete the request. Please try again.',
        type: MutationFeedbackType.error,
      ),
    );
  }

  void setCheckpoint(String status) {
    debugPrint('Setting checkpoint for status: $status');
    if (status == "Verify") {
      checkpoint = 1;
    } else if (status == "WR Check") {
      checkpoint = 4;
      // } else if (status == "WR Re-Open") {
      //   checkpoint = 4;
    } else if (status == "WR Verified") {
      checkpoint = 5;
    } else if (status == "Check") {
      checkpoint = 6;
    } else if (status == "Assign" && _taskCategory == "Client Complaint") {
      checkpoint = 7;
    }
  }

  bool enableSubmit() {
    // If no section value exists, return false.
    if (_sections.valueOrNull == null) return false;

    final List<WorkOrderStatus> list = _sections.value;
    for (final element in list) {
      final state = element.sectionStatus;
      if (state == "Invalid" || state == "Pending" || state == "Valid") {
        return false;
      }
    }
    return true;
  }

  Future<WorkOrderActionResult> submit() async {
    loading = true;
    try {
      final result = await _repository.submitAssign(_id);
      await _handleActionResult(
        result: result,
        successMessage: 'Assignation submitted successfully.',
        queuedMessage:
            'Assignation queued offline. We will sync it once you are back online.',
        refreshOnSuccess: true,
      );
      return result;
    } catch (err) {
      loading = false;
      _handleActionError('submit error: $err', err);
      rethrow;
    }
  }

  Future<WorkOrderActionResult> attendanceApprove(String remarks) async {
    loading = true;
    try {
      final result = await _repository.submitVerified(_id, remarks, 0);
      await _handleActionResult(
        result: result,
        successMessage: 'Ticket marked as Approved.',
        queuedMessage:
            'Approval queued offline. It will sync when you are back online.',
        refreshOnSuccess: true,
      );
      return result;
    } catch (err) {
      loading = false;
      _handleActionError('attendanceApprove error: $err', err);
      rethrow;
    }
  }

  Future<WorkOrderActionResult> attendanceOutOfScope(String remarks) async {
    loading = true;
    try {
      final result = await _repository.submitVerified(_id, remarks, 1);
      await _handleActionResult(
        result: result,
        successMessage: 'Ticket marked as Out-of-Scope.',
        queuedMessage:
            'Out-of-scope response queued. We will sync it when you are back online.',
        refreshOnSuccess: true,
      );
      return result;
    } catch (err) {
      loading = false;
      _handleActionError('attendanceOutOfScope error: $err', err);
      rethrow;
    }
  }

  Future<WorkOrderActionResult> reject(String value) async {
    final result = await _repository.reject(_status, _id, value);
    await _handleActionResult(
      result: result,
      successMessage: 'Request submitted successfully.',
      queuedMessage:
          'Request queued offline. It will sync automatically when online.',
      refreshOnSuccess: true,
    );
    return result;
  }

  Future<WorkOrderActionResult> reOpen(String value) async {
    final result = await _repository.reOpenWorkOrder(_status, _id, value);
    await _handleActionResult(
      result: result,
      successMessage: 'Work order re-opened successfully.',
      queuedMessage:
          'Re-open request queued. It will sync when connectivity returns.',
      refreshOnSuccess: true,
    );
    return result;
  }

  Future<WorkOrderActionResult> returnOutOfScope(String value) async {
    final result = await _repository.rejectOutOfScope(_id, value);
    await _handleActionResult(
      result: result,
      successMessage: 'Ticket marked as Out-of-Scope.',
      queuedMessage:
          'Out-of-scope request queued. It will sync automatically once online.',
      refreshOnSuccess: true,
    );
    return result;
  }

  void openScreen(BuildContext context, WorkOrderStatus order,
    {bool viewOnly = false, PendingSyncController? pendingSync}) {
    String named = order.sectionName ?? '';
    String desc = order.sectionDesc ?? '';
    Object? object;

    if (named == "A") {
      object = ComplaintSectionA(
        id: _id,
        viewer: viewOnly,
        pendingSync: pendingSync,
      );
    } else if (named == "B") {
      if (_status == "Assign" ||
          _status == "Revisit" ||
          _status == "WR Reassign") {
        object = ComplaintAssign(
          id: _id,
          viewer: viewOnly ? true : (checkpoint == 1),
          pendingSync: pendingSync,
        );
      } else if (_status == "WR Check" ||
          _status == "Rejected" ||
          _status == "WR Verified" ||
          _status == "WR Re-Open") {
        object =
            ComplaintSectionResponseImage(
              woTaskId: _id,
              disable: viewOnly,
              pendingSync: pendingSync,
            );
      } else {
        object = ComplaintAssign(id: _id, viewer: true);
      }
    } else if (named == "C") {
      if (_status == "Rejected" ||
          _status == "WR Verified" ||
          _status == "WR Re-Open") {
        object = ComplaintSectionE(order.comment ?? "", named);
      } else {
        object = ComplaintSectionB(
          id: _id,
          viewer: viewOnly ? true : (checkpoint == 1),
          name: named,
          pendingSync: pendingSync,
        );
      }
    } else if (named == "D") {
      debugPrint("Checkpoint: $checkpoint");
      debugPrint("View Only: $viewOnly");
      debugPrint("Status: $_status");
      debugPrint("Section Status: ${order.sectionStatus}");
      object = ComplaintSectionC(
        _id,
        viewOnly ? true : (checkpoint == 1),
        pendingSync: pendingSync,
      );
    } else if (named == "E" && desc == "Asset No") {
      object = ComplaintSectionD(
        id: _id,
        viewer: viewOnly ? true : (checkpoint == 1),
        name: named,
        pendingSync: pendingSync,
      );
    } else if (named == "F" && desc == "Assistants") {
      object = AddTechnicianCheckList(
        id: _id,
        viewer: viewOnly ? true : (checkpoint == 1),
        pendingSync: pendingSync,
      );
    } else if (named == "G" && desc == "Material / Spare Parts") {
      final String statusMaterial = order.sectionStatusMaterial ?? '';
      object = ComplaintSectionDMaterial(
        _id,
        enableSubmit: (statusMaterial == "Request Approval" ||
            statusMaterial == "" ||
            statusMaterial == "Request Parts"),
        enableReset: order.sectionStatusMaterial == "Rejected",
        viewer: viewOnly ? true : (checkpoint == 1),
        comment: order.comment ?? '',
        pendingSync: pendingSync,
      );
    }
    // Fallback if object is still null or when section is "Comment"
    if (object == null || desc == "Comment") {
      object = ComplaintSectionE(
        order.comment ?? "",
        named,
        pendingSync: pendingSync,
      );
    }

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => object as Widget))
        .whenComplete(refresh);
  }

  void openComplaint(BuildContext context, {bool viewOnly = false}) {
    final page = ComplaintPDF(
      id: _id,
      transactionNo: _taskNo,
      viewer: viewOnly,
      checkpoint: checkpoint,
      taskCategory: _taskCategory,
    );

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) => page))
        .whenComplete(refresh);
  }
}

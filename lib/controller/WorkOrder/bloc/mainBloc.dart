import 'dart:async';

import 'package:flutter/material.dart';
import 'package:GEMS/controller/WorkOrder/complaintSectionResponseImage.dart';
import 'package:GEMS/controller/WorkOrder/repository/provider.dart';
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

import '../../../../main.dart';

class MainBloc {
  // -- VARIABLES
  int checkpoint = 0;
  late WOProvider _provider;
  final String _id;
  final String _status;
  final String _taskNo;

  // -- STATE SUBJECTS
  final BehaviorSubject<List<WorkOrderStatus>> _sections =
      BehaviorSubject<List<WorkOrderStatus>>();
  final BehaviorSubject<bool> _enableSubmit =
      BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<bool> _loading =
      BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<ExecutionModel> _execution =
      BehaviorSubject<ExecutionModel>();

  // -- INITIALIZER
  MainBloc({required String id, String status = '', required String taskNo, required BuildContext context})
      : _id = id,
        _status = status,
        _taskNo = taskNo {
    _provider = WOProvider(context: navigatorKey.currentContext!);
    setCheckpoint(_status);
    refresh();
  }

  // -- DISPOSE
  void dispose() {
    _sections.close();
    _enableSubmit.close();
    _loading.close();
    _execution.close();
  }

  // -- GETTERS
  Stream<List<WorkOrderStatus>> get sections$ => _sections.stream;
  Stream<bool> get enable$ => _enableSubmit.stream;
  Stream<bool> get loading$ => _loading.stream;
  Stream<ExecutionModel> get execution$ => _execution.stream;
  String get id => _id;

  // -- SETTERS
  set sections(List<WorkOrderStatus> values) => _sections.sink.add(values);
  set enable(bool value) => _enableSubmit.sink.add(value);
  set loading(bool value) => _loading.sink.add(value);
  set execution(Map<String, dynamic> v) =>
      _execution.sink.add(ExecutionModel.fromJson(v));
  set context(BuildContext context) =>
      _provider = WOProvider(context: navigatorKey.currentContext!);

  // -- METHODS
  Future<void> refresh() async {
    await fetch(_status, _id);
    enable = enableSubmit();
  }

  void setCheckpoint(String status) {
    if (status == "Verify") {
      checkpoint = 1;
    } else if (status == "WR Check") {
      checkpoint = 4;
    } else if (status == "WR Re-Open") {
      checkpoint = 4;
    } else if (status == "WR Verified") {
      checkpoint = 5;
    } else if (status == "Check") {
      checkpoint = 6;
    }
  }

  Future<void> fetch(String status, String id) async {
    // Use different lists for assign and WR statuses
    final List<String> listAssign = ["Assign", "Revisit", "Rejected", "WR Reassign"];
    final List<String> listWR = ["WR Check", "WR Verified", "WR Re-Open"];

    String url = "/api/m_wo.php?type=section_status";
    String urlExecution = "/wo_v2/section_assign/";

    if (listAssign.contains(status)) {
      url += "_assign";
      url += "&woTaskId=";
    } else if (listWR.contains(status)) {
      url += "_wr";
      url += "&woTaskId=";
    } else {
      url = urlExecution;
    }

    debugPrint("URL: $url");

    try {
      final result = await _provider.fetch(url, id);
      debugPrint("Result Section: $result");
      sections = result;
      _provider.fetchExecution(id).then((value) {
        execution = value;
      });
    } catch (err) {
      print(err);
    }
  }

  bool enableSubmit() {
    // If no section value exists, return false.
    if (_sections.valueOrNull == null) return false;

    final List<WorkOrderStatus> list = _sections.value;
    for (final element in list) {
      final state = element.sectionStatus;
      if (state == "Invalid" ||
          state == "Pending" ||
          state == "Valid") {
        return false;
      }
    }
    return true;
  }

  Future<void> submit() async {
    loading = true;
    try {
      await _provider.submit(_id);
      loading = false;
    } catch (err) {
      print(err);
      loading = false;
    }
  }

  Future<bool> attendanceApprove(String remarks) async {
    loading = true;
    try {
      await _provider.submitVerified(_id, remarks, 0);
      loading = false;
      return true;
    } catch (err) {
      print(err);
      loading = false;
      return false;
    }
  }

  Future<void> attendanceOutOfScope(String remarks) async {
    loading = true;
    try {
      await _provider.submitVerified(_id, remarks, 1);
      loading = false;
    } catch (err) {
      print(err);
      loading = false;
    }
  }

  Future<void> reject(String value) {
    return _provider.reject(_status, _id, value);
  }

  void openScreen(BuildContext context, WorkOrderStatus order,
      {bool viewOnly = false}) {
    String named = order.sectionName ?? '';
    String desc = order.sectionDesc ?? '';
    Object? object;

    if (named == "A") {
      object = ComplaintSectionA(id: _id, viewer: viewOnly);
    } else if (named == "B") {
      if (_status == "Assign" ||
          _status == "Revisit" ||
          _status == "WR Reassign") {
        object = ComplaintAssign(id: _id, viewer: viewOnly ? true : (checkpoint == 1));
      } else if (_status == "WR Check" ||
          _status == "Rejected" ||
          _status == "WR Verified" ||
          _status == "WR Re-Open") {
        object = ComplaintSectionResponseImage(woTaskId: _id, disable: viewOnly);
      } else {
        object = ComplaintAssign(id: _id, viewer: true);
      }
    } else if (named == "C") {
      if(_status == "Rejected" ||
          _status == "WR Verified" ||
          _status == "WR Re-Open") {
        object = ComplaintSectionE(order.comment ?? "", named);
      } else {
        object = ComplaintSectionB(
          id: _id,
          viewer: viewOnly ? true : (checkpoint == 1),
          name: named,
        );
      }
    } else if (named == "D") {
      debugPrint("Checkpoint: $checkpoint");
      debugPrint("View Only: $viewOnly");
      debugPrint("Status: $_status");
      debugPrint("Section Status: ${order.sectionStatus}");
      object = ComplaintSectionC(_id, viewOnly ? true : (checkpoint == 1));
    } else if (named == "E" && desc == "Asset No") {
      object = ComplaintSectionD(
        id: _id,
        viewer: viewOnly ? true : (checkpoint == 1),
        name: named,
      );
    } else if (named == "F" && desc == "Assistants") {
      object = AddTechnicianCheckList(
        id: _id,
        viewer: viewOnly ? true : (checkpoint == 1),
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
      );
    }
    // Fallback if object is still null or when section is "Comment"
    if (object == null || desc == "Comment") {
      object = ComplaintSectionE(order.comment ?? "", named);
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
    );

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) => page))
        .whenComplete(refresh);
  }
}

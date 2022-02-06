import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/WorkOrder/repository/provider.dart';
import 'package:gfm_gems/model/execution.dart';
import 'package:gfm_gems/model/workorder.dart';
import 'package:rxdart/subjects.dart';

import '../addTechnician.dart';
import '../complaintPDF.dart';
import '../complaintSectionA.dart';
import '../complaintSectionB_Assign.dart';
import '../complaintSectionB_Remark.dart';
import '../complaintSectionC.dart';
import '../complaintSectionD.dart';
import '../complaintSectionD_material.dart';

class MainBloc {
  // -- VARIABLES
  int checkpoint = 0;
  WOProvider _provider = WOProvider();
  final String _id;
  final String _status;
  final String _taskNo;

  // -- STATES SUBJECTS
  final BehaviorSubject<List<WorkOrderStatus>> _sections =
      BehaviorSubject<List<WorkOrderStatus>>();
  final BehaviorSubject<bool> _enableSubmit =
      BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<bool> _loading = BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<ExecutionModel> _execution =
      BehaviorSubject<ExecutionModel>();

  // -- INITIALIZER
  MainBloc({@required String id, String status, @required String taskNo})
      : this._id = id,
        this._status = status,
        this._taskNo = taskNo {
    setCheckpoint(status);
    refresh();
  }

  // -- DISPOSE
  void dispose() {
    _sections.close();
    _enableSubmit.close();
    _loading.close();
    _execution.close();
  }

  // -- GET
  Stream get sections$ => _sections.stream;
  Stream get enable$ => _enableSubmit.stream;
  Stream get loading$ => _loading.stream;
  Stream get execution$ => _execution.stream;

  // -- SINK
  set sections(List values) => _sections.sink.add(values);
  set enable(bool value) => _enableSubmit.sink.add(value);
  set loading(bool value) => _loading.sink.add(value);
  set execution(Map v) => _execution.sink.add(ExecutionModel.fromJson(v));
  set context(BuildContext context) => _provider = WOProvider(context: context);

  // -- METHODS
  Future<void> refresh() =>
      fetch(_status, _id).whenComplete(() => enable = enableSubmit());

  void setCheckpoint(String status) {
    if (status == "Verify") {
      checkpoint = 1;
    } else if (status == "WR Check") {
      checkpoint = 4;
    } else if (status == "WR Re-Open") {
      checkpoint = 4;
    } else if (status == "WR Verify") {
      checkpoint = 5;
    }
  }

  Future<void> fetch(String status, String id) async {
    final listAssign = ["Assign", "Revisit", "Rejected", "WR Reassign"];
    final listWR = ["WR Check", "WR Verified", "WR Re-Open"];

    String url = "/api/m_wo.php?type=section_status";
    String urlExecution = "/wo_v2/section_assign/";

    if (listAssign.contains(status)) {
      url += "_assign";
      url += "&woTaskId=";
    } else if (listAssign.contains(status)) {
      url += "_wr";
      url += "&woTaskId=";
    } else {
      url = urlExecution;
    }

    try {
      final result = await _provider.fetch(url, id);
      sections = result;
      _provider.fetchExecution(id).then((value) => execution = value);

      return;
    } catch (err) {
      print(err);
    }
  }

  bool enableSubmit() {
    final List<WorkOrderStatus> list = _sections.value;

    for (var i = 0; i < list.length; i++) {
      final element = list[i];

      final state = element.sectionStatus;

      if (state == "Invalid") {
        return false;
      } else if (state == "Pending") {
        return false;
      } else if (state == "Valid") {
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
      return;
    } catch (err) {
      print(err);
    }
  }

  Future<void> reject(String value) {
    return _provider.reject(_status, _id, value);
  }

  void openScreen(BuildContext context, WorkOrderStatus order,
      {bool viewOnly = false}) {
    String named = order.sectionName;
    String desc = order.sectionDesc;
    Object object;

    if (named == "A") {
      object = ComplaintSectionA(id: _id, viewer: viewOnly);
    } else if (named == "B") {
      if (_status == "Assign" ||
          _status == "Revisit" ||
          _status == "WR Reassign") {
        object =
            ComplaintAssign(id: _id, viewer: viewOnly ? true : checkpoint == 1);
      } else if (_status == "Rejected" ||
          _status == "WR Verified" ||
          _status == "WR Re-Open") {
        ComplaintSectionE(order.comment, named);
      } else {
        object = ComplaintAssign(id: _id, viewer: true);
        // object = ComplaintSectionB(
        // id: _id, viewer: viewOnly ? true : checkpoint == 1, name: named);
      }
    }
    if (named == "C") {
      object = ComplaintSectionB(
        id: _id,
        viewer: viewOnly ? true : checkpoint == 1,
        name: named,
      );
    }
    if (named == "D") {
      object = ComplaintSectionC(_id, viewOnly ? true : checkpoint == 1);
    } else if (named == "E" && desc == "Asset No") {
      object = ComplaintSectionD(
        id: _id,
        viewer: viewOnly ? true : checkpoint == 1,
        name: named,
      );
    } else if (named == "F" && desc == "Assistants") {
      object = AddTechnicianCheckList(
        id: _id,
        viewer: viewOnly ? true : checkpoint == 1,
      );
    } else if (named == "G" && desc == "Material / Spare Parts") {
      final status = order.sectionStatusMaterial;
      object = ComplaintSectionDMaterial(
        _id,
        enableSubmit: (status == "Request Approval" ||
            status == "" ||
            status == "Request Parts"),
        enableReset: order.sectionStatusMaterial == "Rejected",
        viewer: viewOnly ? true : checkpoint == 1,
        comment: order.comment,
      );
    } else if (object == null) {
      object = ComplaintSectionE(order.comment ?? "", named);
    }

    if (desc == "Comment") {
      object = ComplaintSectionE(order.comment ?? "", named);
    }

    Navigator.of(context)
        .push(new MaterialPageRoute(builder: (_) => object))
        .whenComplete(refresh);
  }

  void openComplaint(BuildContext context, {bool viewOnly = false}) {
    var page = new ComplaintPDF(
      id: _id,
      transactionNo: _taskNo,
      viewer: viewOnly,
      checkpoint: checkpoint,
    );

    Navigator.of(context)
        .push(new MaterialPageRoute(builder: (BuildContext context) => page))
        .whenComplete(refresh);
  }
}

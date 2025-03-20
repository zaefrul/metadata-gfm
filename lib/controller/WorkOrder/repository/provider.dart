import 'package:flutter/material.dart';
import 'package:gfm_gems/model/responseValue.dart';
import 'package:gfm_gems/model/workorder.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';

class WOProvider {
  final Provider _provider;

  WOProvider({BuildContext context}) : this._provider = Provider() {
    _provider.context = context;
  }

  Future<void> reject(String status, String id, String remark) {
    var body = UploadItem(
      action: status == "Assign"
          ? "reject_complaint"
          : status == "WR Verified"
              ? "return_by_verifier"
              : "return_by_technician",
      id: id,
      remark: remark,
    );

    Provider provider = Provider();

    return provider.post(url: "/api/m_wo.php", body: body.body);
  }

  Future<void> submit(String id) {
    Provider provider = Provider();
    return provider.post(
      url: "/api/m_wo.php",
      body: {"action": "submit_assign", "woTaskId": id},
    );
  }

  Future<List<WorkOrderStatus>> fetch(String url, String id) async {
    Provider provider = Provider(fetchURL: url, taskID: id);
    try {
      final ResponseValue responseValue = await provider.fetch();
      final result = responseValue.wostatusList;

      return result.toList();
    } catch (err) {
      throw err;
    }
  }

  Future<Map<String, dynamic>> fetchExecution(String id) async {
    Provider _provider =
        Provider(fetchURL: "/wo_v2/execution_info/", taskID: id);

    final result = await _provider.getJson();
    return result as Map<String, dynamic>;
  }
}

class UploadItem extends Upload {
  final String remark;

  UploadItem({
    String id,
    String action,
    this.remark,
  }) : super(ppmTaskId: id, action: action);

  @override
  Map<String, dynamic> get body => {
        "action": action,
        "woTaskId": ppmTaskId,
        "remark": remark,
      };
}

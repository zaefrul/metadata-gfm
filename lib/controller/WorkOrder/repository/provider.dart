import 'package:flutter/material.dart';
import 'package:GEMS/model/responseValue.dart';
import 'package:GEMS/model/workorder.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/utils/reference.dart';

class WOProvider {
  final Provider _provider;

  WOProvider({required BuildContext context}) : _provider = Provider(fetchURL: "") {
    _provider.context = context;
  }

  Future<void> reject(String status, String id, String remark) {
    debugPrint('The status is: $status');
    var body = UploadItem(
      action: status == "Assign"
          ? "reject_complaint"
          : status == "WR Verified" || status == "Check"
              ? "return_by_verifier"
              : "return_by_technician",
      id: id,
      remark: remark,
    );

    debugPrint("======================== THE BODY IS ========================");
    debugPrint(body.body.toString());
    debugPrint("=============================================================");

    Provider provider = Provider(fetchURL: "/api/m_wo.php");

    return provider.post(url: "/api/m_wo.php", body: body.body);
  }

  Future<void> submit(String id) {
    Provider provider = Provider(fetchURL: "/api/m_wo.php");
    return provider.post(
      url: "/api/m_wo.php",
      body: {"action": "submit_assign", "woTaskId": id},
    );
  }

  Future<void> submitVerified(String id, String remarks, int isRejected) {
    Provider provider = Provider(fetchURL: "/api/m_wo.php");
    return provider.post(
      url: "/api/m_wo.php",
      body: {"action": "submit_wr_verified", "woTaskId": id, "remarks": remarks, "isRejected": isRejected.toString()},
    );
  }

  Future<List<WorkOrderStatus>> fetch(String url, String id) async {
    Provider provider = Provider(fetchURL: url, taskID: id);
    try {
      final ResponseValue responseValue = await provider.fetch();
      final result = responseValue.wostatusList;

      return result?.toList() ?? [];
    } catch (err) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchExecution(String id) async {
    Provider provider =
        Provider(fetchURL: "/wo_v2/execution_info/", taskID: id);

    final result = await provider.getJson(url: "/wo_v2/execution_info/");
    return result as Map<String, dynamic>;
  }
}

class UploadItem extends Upload {
  final String remark;

  UploadItem({
    required String id,
    required super.action,
    required this.remark,
  }) : super(ppmTaskId: id);

  @override
  Map<String, dynamic> get body => {
        "action": action,
        "woTaskId": ppmTaskId,
        "remark": remark,
      };
}

import 'dart:ui';

import 'package:GEMS/controller/Storekeeper/utils/bloc/bloc.dart';
import 'package:GEMS/model/complaint.dart';
import 'package:GEMS/model/material.dart';
import 'package:GEMS/model/serializers.dart';
import 'package:GEMS/utils/network.dart';
import 'package:rxdart/subjects.dart';

import '../constant.dart';

class MaterialTask extends Bloc {
  // Variables
  final BehaviorSubject<List<Material>> _materials =
      BehaviorSubject<List<Material>>.seeded([]);
  final BehaviorSubject<RequestTask> _detail = BehaviorSubject<RequestTask>();
  final Request _request;
  final Map<String, String> _statuses = {
    "-1": "Loading",
    "32": "Request Parts",
    "33": "Request Approval",
    "34": "Reserved",
    "38": "Checkout",
    "36": "Parts Collected",
    "47": "Need to Order",
    "48": "Waiting for Purchase"
  };
  final Map<String, Color> _statusesColor = {
    "-1": colorNull,
    "32": colorNull,
    "33": colorTheme2,
    "34": colorTheme3,
    "38": colorTheme5,
    "36": colorTheme1,
    "47": colorTheme4,
    "48": colorTheme4
  };

  MaterialTask({
    required String requestId,
    String? workOrderId,
  }) : _request = Request(
          requestId: requestId,
          workOrderId: workOrderId,
        ) {
    refresh();
  }

  // Dispose
  @override
  void dispose() {
    _materials.close();
    _detail.close();
    super.dispose();
  }

  // Get
  Stream<List<Material>> get materials$ => _materials.stream;
  Stream<RequestTask> get detail$ => _detail.stream;
  bool get _isReviewerTask =>
      (_detail.hasValue && (_detail.value.checkpointDesc == 'MR Reviewer'));

  String titleButton(String id, {bool isApproval = false}) {
    // For status 33 (pending approval), show different text for storekeeper vs technician
    if (id == "33" && isApproval) {
      return _isReviewerTask ? "Recommend" : "Approve";
    }
    return _statuses[id] ?? "Unknown Status";
  }

  Color colorButton(String id) => _statusesColor[id] ?? colorNull;
  // Set
  set materials(List<Material> values) => _materials.sink.add(values);
  set detail(RequestTask value) => _detail.sink.add(value);

  // Method
  Future<void> refresh() async {
    checker(() async {
      final info = await _request.info;
      detail = info;
      final woTaskId = info.woTaskId;
      final mats = await _request.materials(workOrderId: woTaskId);
      materials = mats;
    }());
  }

  Future<void> onclick(bool isApproval) {
    if (isApproval && _detail.value.statusId == "33") {
      return submit();
    } else if (isApproval && _detail.value.statusId != "33") {
      errMsg = "No Action Needed";
      throw "No Action Needed";
    } else if (_detail.value.statusId == "34") {
      return reserved();
    } else if (_detail.value.statusId == "38") {
      return checkout();
    }
    errMsg = "No Action Needed";
    throw "No Action Needed";
  }

  Future<void> submit() =>
      checker(_request.submit(isReviewer: _isReviewerTask));
  Future<void> reserved() => checker(_request.reserved);
  Future<void> order() => checker(_request.order);
  Future<void> checkout() => checker(_request.checkout);
  Future<void> reject(String value) =>
      checker(_request.reject(value, isReviewer: _isReviewerTask));
}

class Request extends _Utils {
  final String _requestId;
  final String? _initialWorkOrderId;
  final Provider _providerINFO;
  final Provider _providerSUBMIT;
  final Provider _providerRECOMMEND;
  final Provider _providerRESERVED;
  final Provider _providerORDER;
  final Provider _providerCHECKOUT;
  final Provider _providerREJECT;
  final Provider _providerNOT_RECOMMEND;

  Request({
    required String requestId,
    String? workOrderId,
  })  : _requestId = requestId,
        _initialWorkOrderId = workOrderId,
        _providerINFO = Provider(
          fetchURL: "/wo_request/request_details/",
          taskID: workOrderId ?? requestId,
        ),
        _providerSUBMIT = Provider(
          fetchURL: "/wo_request/approve_request/",
          taskID: requestId,
        ),
        _providerRECOMMEND = Provider(
          fetchURL: "/wo_request/recommend_request/",
          taskID: requestId,
        ),
        _providerRESERVED = Provider(
          fetchURL: "/wo_request/reserve_request/",
          taskID: requestId,
        ),
        _providerORDER = Provider(fetchURL: "/wo_request/order_request/"),
        _providerCHECKOUT = Provider(
          fetchURL: "/wo_request/check_out_request/",
          taskID: requestId,
        ),
        _providerREJECT = Provider(
          fetchURL: "/wo_request/reject_request/",
          taskID: requestId,
        ),
        _providerNOT_RECOMMEND = Provider(
          fetchURL: "/wo_request/not_recommend_request/",
          taskID: requestId,
        );

  Future<RequestTask> get info => _providerINFO
      .getJson(url: "/wo_request/request_details/")
      .then((value) => _Utils.task(value));

  Future<List<Material>> materials({String? workOrderId}) {
    final effectiveId = _resolveWorkOrderId(workOrderId);
    final provider = Provider(
      fetchURL: "/wo_parts/wo_parts_list/",
      taskID: effectiveId,
    );
    return provider
        .getJson(url: "/wo_parts/wo_parts_list/")
        .then((value) => _Utils.material(value));
  }

  String _resolveWorkOrderId(String? override) {
    String? candidate = override?.trim();
    if (candidate != null && candidate.isNotEmpty) {
      return candidate;
    }
    candidate = _initialWorkOrderId?.trim();
    if (candidate != null && candidate.isNotEmpty) {
      return candidate;
    }
    return _requestId;
  }

  Future<void> get order => _providerORDER.post(url: "");
  Future<void> submit({required bool isReviewer}) {
    if (isReviewer) {
      return _providerRECOMMEND.put();
    }
    return _providerSUBMIT.put();
  }

  Future<void> get reserved => _providerRESERVED.put();
  Future<void> get checkout => _providerCHECKOUT.put();

  Future<void> reject(String value, {required bool isReviewer}) {
    if (isReviewer) {
      return _providerNOT_RECOMMEND.put(body: {"comment": value});
    }
    return _providerREJECT.put(body: {"comment": value});
  }
}

class _Utils {
  static List<Material> material(dynamic value) =>
      deserializeListOf<Material>(value).toList();
  static RequestTask task(Map value) =>
      RequestTask.fromJson(value.cast<String, dynamic>());
}

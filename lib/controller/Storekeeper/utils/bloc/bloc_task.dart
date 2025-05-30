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

  MaterialTask(String id) : _request = Request(id) {
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
  String titleButton(String id) => _statuses[id] ?? "Unknown Status";
  Color colorButton(String id) => _statusesColor[id] ?? colorNull;
  // Set
  set materials(List<Material> values) => _materials.sink.add(values);
  set detail(RequestTask value) => _detail.sink.add(value);

  // Method
  Future<void> refresh() async {
    checker(_request.materials.then((value) {
      materials = value;
      return _request.info;
    }).then((value) => detail = value));
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

  Future<void> submit() => checker(_request.submit);
  Future<void> reserved() => checker(_request.reserved);
  Future<void> order() => checker(_request.order);
  Future<void> checkout() => checker(_request.checkout);
  Future<void> reject(String value) => checker(_request.reject(value));
}

class Request extends _Utils {
  final Provider _providerGET;
  final Provider _providerINFO;
  final Provider _providerSUBMIT;
  final Provider _providerRESERVED;
  final Provider _providerORDER;
  final Provider _providerCHECKOUT;
  final Provider _providerREJECT;

  Request(String id)
      : _providerGET =
            Provider(fetchURL: "/wo_parts/wo_parts_list/", taskID: id),
        _providerINFO =
            Provider(fetchURL: "/wo_request/request_details/", taskID: id),
        _providerSUBMIT =
            Provider(fetchURL: "/wo_request/approve_request/", taskID: id),
        _providerRESERVED =
            Provider(fetchURL: "/wo_request/reserve_request/", taskID: id),
        _providerORDER = Provider(fetchURL: "/wo_request/order_request/"),
        _providerCHECKOUT =
            Provider(fetchURL: "/wo_request/check_out_request/", taskID: id),
        _providerREJECT =
            Provider(fetchURL: "/wo_request/reject_request/", taskID: id);

  Future<RequestTask> get info =>
      _providerINFO.getJson(url: "/wo_request/request_details/").then((value) => _Utils.task(value));
  Future<List<Material>> get materials =>
      _providerGET.getJson(url: "/wo_request/request_details/").then((value) => _Utils.material(value));

  Future<void> get order => _providerORDER.post(url: "");
  Future<void> get submit => _providerSUBMIT.put();
  Future<void> get reserved => _providerRESERVED.put();
  Future<void> get checkout => _providerCHECKOUT.put();
  Future<void> reject(String value) =>
      _providerREJECT.put(body: {"comment": value});
}

class _Utils {
  static List<Material> material(dynamic value) =>
      deserializeListOf<Material>(value).toList();
  static RequestTask task(Map value) => RequestTask.fromJson(value.cast<String, dynamic>());
}

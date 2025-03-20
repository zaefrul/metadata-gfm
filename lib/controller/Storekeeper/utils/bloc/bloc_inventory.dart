
import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/bloc/bloc.dart';
import 'package:gfm_gems/model/serializers.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:rxdart/subjects.dart';
import 'package:gfm_gems/model/complaint.dart';

import '../constant.dart';

const List<String> statuses = [
  'All Status',
  "Request Parts	",
  "Request Approval",
  "Stock Request",
  "Ready For Collection",
  "Parts Collected",
  "Need to Order",
  "Waiting for Purchase",
];

class BlocInventory extends Bloc {
  final _selectedFilter = BehaviorSubject<String>.seeded(statuses.first);
  final _requestCart = BehaviorSubject<Material>();
  final _myView = BehaviorSubject<String>.seeded("My Task");
  final _myStock = BehaviorSubject<List<Stock>>();
  final BehaviorSubject<List<RequestTask>> _tasks =
      BehaviorSubject<List<RequestTask>>.seeded([]);
  final Request _request;
  final BehaviorSubject<List<ComplaintDStore>> _stores =
      BehaviorSubject.seeded([]);
  final BehaviorSubject<List<ComplaintDGroupStore>> _materials =
      BehaviorSubject.seeded([]);
  final BehaviorSubject<ComplaintDStore> _store = BehaviorSubject();
  List<RequestTask> _tasksOriginal = [];

  final Map<String, String> _statuses = {
    "32": "Request Parts	",
    "33": "Request Approval",
    "34": "Stock Request",
    "38": "Ready For Collection",
    "36": "Parts Collected",
    "47": "Need to Order",
    "48": "Waiting for Purchase",
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

  Stream get selected$ => _selectedFilter.stream;
  Stream get material$ => _requestCart.stream;
  Stream get view$ => _myView.stream;
  Stream get stock$ => _myStock.stream;
  Stream get task$ => _tasks.stream;

  Function get setSelected => _selectedFilter.sink.add;
  Function get setView => _myView.sink.add;

  set store(ComplaintDStore value) => _store.sink.add(value);
  set stores(List values) => _stores.sink.add(values);
  set materials(List values) => _materials.sink.add(values);
  get stores$ => _stores.stream;
  get materials$ => _materials.stream;
  get store$ => _store.stream;

  BlocInventory(BuildContext context) : this._request = Request() {
    _request.refresh.then((value) {
      _tasks.sink.add(value);
      _tasksOriginal = value;
    });

    _myStock
        .add(['A', 'B', 'C'].map((f) => Stock(group: "Category $f")).toList());

    getStore(context);
    _store.listen((event) {
      getStock(context, event.itemId);
    });

    _selectedFilter.listen((event) {
      if (event == statuses.first)
        _tasks.sink.add(_tasksOriginal);
      else {
        final List<RequestTask> filtered = _tasksOriginal
            .where((element) => element.statusDesc == event)
            .toList();
        _tasks.sink.add(filtered);
      }
    });
  }

  Future<void> refresh() => _request.refresh.then((value) {
        // value.sort((a, b) => a.requestTime.compareTo(b.requestTime));
        _tasks.sink.add(value);
        _tasksOriginal = value;
        setSelected(_selectedFilter.value);
      });
  String status(String id) => _statuses[id];
  Color color(String id) => _statusesColor[id];

  Future<void> getStore(BuildContext context) async {
    final Provider _provider =
        Provider(fetchURL: "/store/purchase_option_store");
    _provider.context = context;

    final result = await _provider.getJson();
    final values = deserializeListOf<ComplaintDStore>(result).toList();

    stores = values;
    store = values.first;
  }

  void getStock(BuildContext context, String id) async {
    final Provider _provider =
        Provider(fetchURL: "/part/part_tree_category/", taskID: id);
    _provider.context = context;

    final result = await _provider.getJson() as List<dynamic>;
    final values = deserializeListOf<ComplaintDGroupStore>(result).toList();
    materials = values;
  }

  @override
  void dispose() {
    _tasks.close();
    _selectedFilter.close();
    _requestCart.close();
    _myView.close();
    _myStock.close();
    _stores.close();
    _materials.close();
    super.dispose();
  }
}

enum RequestStatus {
  Processing,
  Requested,
  Reserved,
}

class Material extends Bloc {
  final _controllerThreshold = BehaviorSubject<int>.seeded(10);
  final String issuedBy;
  final String group;
  final String subgroup;
  final String name;
  final String desc;
  double price;
  int quantity;

  void get addThreshold =>
      _controllerThreshold.sink.add(_controllerThreshold.value + 1);
  void get minusThreshold =>
      _controllerThreshold.sink.add(_controllerThreshold.value - 1);

  Material({
    @required this.issuedBy,
    @required this.group,
    @required this.subgroup,
    @required this.name,
    @required this.desc,
    @required this.quantity,
    this.price,
  });

  void addQuantity() {
    quantity += 1;
  }

  void minusQuantity() {
    if (quantity > 0) quantity -= 1;
  }

  Stream<int> get threshold => _controllerThreshold.stream;

  @override
  void dispose() {
    _controllerThreshold.close();
  }
}

class Stock {
  final String group;
  final List<Group> subgroups;

  Stock({@required this.group, subgroups})
      : this.subgroups = subgroups ??
            ['A', 'B', 'C']
                .map((f) => Group(subgroup: "Type $f", group: group))
                .toList();

  String get quantity => subgroups.length.toString();
}

class Group {
  final String subgroup;
  final List<Material> materials;

  Group({@required this.subgroup, @required group, materials})
      : this.materials = materials ??
            ['A', 'B', 'C']
                .map((f) => Material(
                      issuedBy: "Muhammad Nabil",
                      group: group,
                      subgroup: subgroup,
                      name: "Item $f",
                      desc: null,
                      quantity: 10,
                    ))
                .toList();

  String get quantity => materials.length.toString();
}

class Request {
  final Provider _providerGET;

  Request() : _providerGET = Provider(fetchURL: "/wo_request/pending_task");

  Future<List<RequestTask>> get refresh async {
    try {
      final result = await _providerGET.getJson();

      return deserializeListOf<RequestTask>(result).toList();
    } catch (err) {
      throw err;
    }
  }
}

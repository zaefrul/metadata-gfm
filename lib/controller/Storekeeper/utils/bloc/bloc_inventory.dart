import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/bloc/bloc.dart';
import 'package:gfm_gems/model/serializers.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/model/complaint.dart';
import '../constant.dart';

const List<String> statuses = [
  'All Status',
  "Request Parts",
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
      BehaviorSubject<List<ComplaintDStore>>.seeded([]);
  final BehaviorSubject<List<ComplaintDGroupStore>> _materials =
      BehaviorSubject<List<ComplaintDGroupStore>>.seeded([]);
  final BehaviorSubject<ComplaintDStore> _store =
      BehaviorSubject<ComplaintDStore>();

  List<RequestTask> _tasksOriginal = [];

  final Map<String, String> _statuses = {
    "32": "Request Parts",
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
    "48": colorTheme4,
  };

  Stream<String> get selected$ => _selectedFilter.stream;
  Stream<Material> get material$ => _requestCart.stream;
  Stream<String> get view$ => _myView.stream;
  Stream<List<Stock>> get stock$ => _myStock.stream;
  Stream<List<RequestTask>> get task$ => _tasks.stream;

  Function(String) get setSelected => _selectedFilter.sink.add;
  Function(String) get setView => _myView.sink.add;

  set store(ComplaintDStore value) => _store.sink.add(value);
  set stores(List<ComplaintDStore> values) => _stores.sink.add(values);
  set materials(List<ComplaintDGroupStore> values) => _materials.sink.add(values);
  Stream<List<ComplaintDStore>> get stores$ => _stores.stream;
  Stream<List<ComplaintDGroupStore>> get materials$ => _materials.stream;
  Stream<ComplaintDStore> get store$ => _store.stream;

  BlocInventory(BuildContext context) : _request = Request() {
    _request.refresh.then((value) {
      _tasks.sink.add(value);
      _tasksOriginal = value;
    });

    _myStock.add(
        ['A', 'B', 'C'].map((f) => Stock(group: "Category $f")).toList());

    getStore(context);
    _store.listen((event) {
      if (event.itemId != null) {
        getStock(context, event.itemId!);
      }
    });

    _selectedFilter.listen((event) {
      if (event == statuses.first) {
        _tasks.sink.add(_tasksOriginal);
      } else {
        final List<RequestTask> filtered = _tasksOriginal
            .where((element) => element.statusDesc == event)
            .toList();
        _tasks.sink.add(filtered);
      }
    });
  }

  Future<void> refresh() async {
    final value = await _request.refresh;
    _tasks.sink.add(value);
    _tasksOriginal = value;
    setSelected(_selectedFilter.value);
  }

  String status(String id) => _statuses[id] ?? "";
  Color color(String id) => _statusesColor[id] ?? Colors.grey;

  Future<void> getStore(BuildContext context) async {
    final Provider _provider =
        Provider(fetchURL: "/store/purchase_option_store");
    _provider.context = context;

    final result = await _provider.getJson(url: "/store/purchase_option_store");
    final values = deserializeListOf<ComplaintDStore>(result).toList();

    stores = values;
    if (values.isNotEmpty) {
      store = values.first;
    }
  }

  Future<void> getStock(BuildContext context, String id) async {
    final Provider _provider =
        Provider(fetchURL: "/part/part_tree_category/", taskID: id);
    _provider.context = context;

    final result = await _provider.getJson(url: "/part/part_tree_category/") as List<dynamic>;
    final values =
        deserializeListOf<ComplaintDGroupStore>(result).toList();
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
    _store.close();
    super.dispose();
  }
}

enum RequestStatus { Processing, Requested, Reserved }

class Material extends Bloc {
  final BehaviorSubject<int> _controllerThreshold =
      BehaviorSubject<int>.seeded(10);
  final String issuedBy;
  final String group;
  final String subgroup;
  final String name;
  final String? desc;
  double price;
  int quantity;

  Material({
    required this.issuedBy,
    required this.group,
    required this.subgroup,
    required this.name,
    this.desc,
    required this.quantity,
    this.price = 0.0,
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

  Stock({required this.group, List<Group>? subgroups})
      : subgroups = subgroups ??
            ['A', 'B', 'C']
                .map((f) => Group(subgroup: "Type $f", group: group))
                .toList();

  String get quantity => subgroups.length.toString();
}

class Group {
  final String subgroup;
  final List<Material> materials;

  Group({required this.subgroup, required String group, List<Material>? materials})
      : materials = materials ??
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
      final result = await _providerGET.getJson(url: "/wo_request/pending_task");
      return deserializeListOf<RequestTask>(result).toList();
    } catch (err) {
      throw err;
    }
  }
}

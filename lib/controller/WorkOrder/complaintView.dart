import 'package:flutter/material.dart';
import 'package:GEMS/data/repository/work_order_repository.dart';
import 'package:GEMS/model/workorder.dart';

import 'complaintList.dart';

class ComplaintView extends StatefulWidget {
  final int index;
  // ignore: unused_field
  final String url;
  final Widget? headers;

  const ComplaintView(this.url, this.headers, this.index, {super.key});

  @override
  _ComplaintViewState createState() => _ComplaintViewState();
}

class _ComplaintViewState extends State<ComplaintView> {
  String dropdownValue = "All Status";
  String dropdownType = "All Type";
  List<WorkOrderTask> _listTask = [];
  List<WorkOrderTask> _filterTask = [];
  late final WorkOrderRepository _repository;
  late Future<List<WorkOrderTask>> _loadFuture;

  @override
  void initState() {
    super.initState();
    _repository = WorkOrderRepository();
    _loadFuture = _load();
  }

  WorkOrderListType get _listType =>
      widget.index == 0 ? WorkOrderListType.submittedWo : WorkOrderListType.pendingTask;

  Future<List<WorkOrderTask>> _load({bool forceRefresh = false}) async {
    final tasks = await _repository.getWorkOrders(
      type: _listType,
      forceRefresh: forceRefresh,
    );
    _listTask = tasks;
    _filterTask = _applyFilters(tasks);
    return _filterTask;
  }

  List<WorkOrderTask> _applyFilters(List<WorkOrderTask> source) {
    Iterable<WorkOrderTask> filtered = source;

    if (dropdownValue != "All Status") {
      filtered = filtered.where((task) => task.woTaskStatus == dropdownValue);
    }

    if (dropdownType != "All Type") {
      filtered = filtered.where((task) {
        final typeCode = dropdownType == "Work Order" ? "WO" : "WR";
        return task.woTaskTypeInit == typeCode || task.woTaskType == dropdownType;
      });
    }

    return filtered.toList();
  }

  Future<void> _refresh() async {
    final future = _load(forceRefresh: true);
    setState(() {
      _loadFuture = future;
    });
    await future;
  }

  Widget get _filter => DropdownButton<String>(
        underline: Container(),
        value: dropdownValue,
        onChanged: (String? newValue) {
          setState(() {
            dropdownValue = newValue ?? "All Status";
            _filterTask = _applyFilters(_listTask);
          });
        },
        items: <String>[
          'All Status',
          'Assign',
          "WR Check",
          "WR Verified",
          'In Progress',
          'Verify',
          'Re-Open',
          'Completed',
          'Out of Scope',
        ].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      );

  Widget get _filterType => DropdownButton<String>(
        underline: Container(),
        value: dropdownType,
        onChanged: (String? newValue) {
          setState(() {
            dropdownType = newValue ?? "All Type";
            _filterTask = _applyFilters(_listTask);
          });
        },
        items: <String>[
          'All Type',
          'Work Request',
          'Work Order',
        ].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      );

  Widget get _header => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: widget.headers == null
            ? <Widget>[
                _filter,
                _filterType,
              ]
            : <Widget>[
                _filter,
                _filterType,
                widget.headers!,
              ],
      );

  @override
  Widget build(BuildContext context) {
    Widget loadingWidget = Container(
      color: Colors.black.withOpacity(0.3),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );

    Widget body(List<WorkOrderTask> value) => Container(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _header,
              ),
              const Divider(),
              Expanded(
                child: ComplaintList(
                  list: value,
                  viewer: widget.index == 0,
                  refresh: _refresh,
                ),
              ),
            ],
          ),
        );

    return FutureBuilder<List<WorkOrderTask>>(
      future: _loadFuture,
      builder: (context, AsyncSnapshot<List<WorkOrderTask>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget;
        }

        if (snapshot.hasError) {
          return body(_filterTask);
        }

        final data = snapshot.hasData ? _filterTask : <WorkOrderTask>[];
        return body(data);
      },
    );
  }
}

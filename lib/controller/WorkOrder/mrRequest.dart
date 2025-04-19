import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/constant.dart';
import 'package:gfm_gems/model/complaint.dart';
import 'package:gfm_gems/model/serializers.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:rxdart/rxdart.dart';

class MRTaskList extends StatelessWidget {
  final Controller controller;
  final Map<String, String> _statuses = {
    "32": "Request Parts",
    "33": "Request Approval",
    "34": "Stock Request",
    "38": "Ready For Collection",
    "36": "Parts Collected",
    "47": "Need to Order",
    "48": "Waiting for Purchase"
  };

  MRTaskList({Key? key})
      : controller = Controller(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: _filter,
          ),
          StreamBuilder<List<RequestTask>>(
            stream: controller.filteredTaskStream,
            builder: (ctx, snapshot) {
              final tasks = snapshot.data ?? [];
              return RefreshIndicator(
                onRefresh: controller.refresh,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  itemBuilder: (ctx, index) => _Tile(
                      _statuses[tasks[index].statusId] ?? "Unknown",
                      tasks[index]),
                  itemCount: tasks.length,
                  separatorBuilder: (ctx, index) => const Divider(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget get _filter => StreamBuilder<String>(
      stream: controller.dropdownValueStream,
      builder: (context, snapshot) {
        String currentValue = snapshot.data ?? 'All Status';
        return DropdownButton<String>(
          underline: Container(),
          value: currentValue,
          onChanged: controller.filter,
          items: <String>[
            'All Status',
            'Stock Request',
            'Request Approval',
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        );
      });
}

class _Tile extends StatelessWidget {
  final String status;
  final RequestTask task;

  const _Tile(this.status, this.task, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        task.woTaskRequestNo ?? 'Unknown Request No',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _text(value: task.requestBy ?? 'Unknown Requester', top: 8.0),
          _text(value: task.requestTime ?? 'Unknown Time'),
          _text(value: task.woTaskNo ?? 'Unknown Task No'),
        ],
      ),
      trailing: state,
      onTap: () {
        Navigator.pushNamed(context, routeMateralRequest, arguments: task);
      },
    );
  }

  Widget _text({required String value, double top = 3.0}) {
    return Padding(
      padding: EdgeInsets.only(top: top),
      child: Text(
        value,
        style: TextStyle(color: colorTheme3),
      ),
    );
  }

  Widget get state {
    return Container(
      height: 40,
      width: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colors,
      ),
      child: Center(
        child: Text(
          status,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  Color get colors {
    Map<String, Color> colorMap = {
      "-1": colorNull,
      "32": colorNull,
      "33": colorTheme2,
      "34": colorTheme3,
      "38": colorTheme5,
      "36": colorTheme1,
      "47": colorTheme4,
      "48": colorTheme4,
    };
    return colorMap[task.statusId] ?? Colors.grey;
  }
}

class Controller {
  final BehaviorSubject<List<RequestTask>> _tasks =
      BehaviorSubject<List<RequestTask>>.seeded([]);
  final BehaviorSubject<List<RequestTask>> _filteredTask =
      BehaviorSubject<List<RequestTask>>.seeded([]);
  final BehaviorSubject<String> _dropdownValue =
      BehaviorSubject<String>.seeded('All Status');
  final Request _request;

  Controller() : _request = Request() {
    _tasks.listen((event) {
      _filteredTask.add(event);
    });
    _request.refresh.then((value) => _tasks.sink.add(value));
  }

  Stream<List<RequestTask>> get filteredTaskStream => _filteredTask.stream;
  Stream<String> get dropdownValueStream => _dropdownValue.stream;

  Future<void> refresh() async {
    List<RequestTask> value = await _request.refresh;
    _tasks.sink.add(value);
    _dropdownValue.add('All Status');
  }

  void filter(String? value) {
    if (value == null) return;
    _dropdownValue.add(value);
    if (value == 'All Status') {
      _filteredTask.add(_tasks.value);
    } else {
      final list =
          _tasks.value.where((event) => event.statusDesc == value).toList();
      _filteredTask.add(list);
    }
  }

  void dispose() {
    _tasks.close();
    _filteredTask.close();
    _dropdownValue.close();
  }
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

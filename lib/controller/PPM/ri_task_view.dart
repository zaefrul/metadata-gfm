import 'package:flutter/material.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:GEMS/view/gems_chrome.dart';

import '../../model/task.dart';
import 'Form/form_view.dart';

import '../../main.dart';

class RITaskView extends StatefulWidget {
  final _TaskViewStateRI view;

  RITaskView({super.key, int index = 0}) : view = _TaskViewStateRI(index);

  void update(String text) => view.fetch(text);
  void updateQR(String text) => view.fetchQR(text);
  void updateQRAll(String text) => view.fetchQRAll(text);
  void updateAll(String text) => view.fetchAll(text);

  @override
  _TaskViewStateRI createState() => view;
}

class _TaskViewStateRI extends State<RITaskView>
    with AutomaticKeepAliveClientMixin<RITaskView> {
  String dropdownValue = "All";
  List<Widget> children = [];
  List<Task> _listTask = [];
  List<Widget> tiles = [];
  late Provider _provider;
  bool builded = false;
  final int index;
  bool viewer = true;

  _TaskViewStateRI(this.index) {
    _refresh();
  }

  List<Widget> fetchGenerate(List<Task> listTask) {
    List<Widget> values = [];
    if (listTask.isNotEmpty) {
      values = List.generate(listTask.length, (item) => tile(listTask[item]));
    }
    values.insert(0, filter);
    return values;
  }

  void fetch(String? text) {
    String url = "/api/m_ppm.php?type=pending_task";
    if (text == null) {
      url += "&isRoutine=true";
    } else {
      url += "_search&isRoutine=true&assetNo=$text";
    }
    _fetch(url);
  }

  void fetchQR(String? text) {
    String url = "/api/m_ppm.php?type=pending_task";
    if (text == null) {
      url += "&isRoutine=true";
    } else {
      url += "_scan_asset&isRoutine=true&assetNo=$text";
    }
    _fetch(url);
  }

  void fetchQRAll(String? text) {
    String url = "/api/m_ppm.php?type=all_task";
    if (text == null) {
      url += "&isRoutine=true";
    } else {
      url += "_scan_asset&isRoutine=true&assetNo=$text";
    }
    _fetch(url);
  }

  void fetchAll(String? text) {
    String url = "/api/m_ppm.php?type=all_task";
    if (text == null) {
      url += "&isRoutine=true";
    } else {
      url += "_search&isRoutine=true&searchTxt=$text";
    }
    _fetch(url);
  }

  void _fetch(String url) {
    _provider = Provider(fetchURL: url);
    _provider.fetch().then((value) {
      _listTask = value.taskList?.toList() ?? [];
      tiles = fetchGenerate(_listTask);
      children = tiles;
      if (builded) setState(() {});
    }).catchError((err) {
      tiles = fetchGenerate([]);
      children = tiles;
      if (builded) setState(() {});
    });
  }

  Future<void> _refresh() {
    if (index == 0) {
      fetchAll(null);
    } else if (index == 1) {
      fetch(null);
      viewer = false;
    }
    return Future.value();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    _provider.context = context;
    builded = true;
    return children.isNotEmpty
        ? RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: children.length,
              itemBuilder: (context, idx) => children[idx],
              separatorBuilder: (context, idx) => const Divider(),
            ))
        : Container(
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
  }

  Widget getTitle(String text, {bool bold = false}) => Container(
        alignment: Alignment.centerLeft,
        child: Text(text,
            style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      );

  Widget status(String value) {
    var text = value;
    var color = colorTheme1;
    if (text == "In Progress") {
      color = colorTheme5;
    } else if (text == "Closed") {
      color = colorTheme4;
    } else if (text == "Check") {
      color = colorTheme2;
    } else if (text == "Verify") {
      color = colorTheme3;
    }
    return Container(
        alignment: Alignment.center,
        height: 30.0,
        width: 100.0,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(20.0)),
        child: Text(text, style: const TextStyle(color: Colors.white)));
  }

  ListTile tile(Task task) {
    final statusStyle = GemsStatusStyle.forPpm(task.statusDesc);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: GemsAccentCard(
        margin: const EdgeInsets.only(bottom: 10),
        accent: statusStyle.foreground,
        onTap: () {
          final page = FormView(
            id: task.ppmTaskId,
            siteName: task.siteName,
            taskNo: task.transactionNo,
            taskStatus: task.statusDesc,
            refresh: () => fetch(null),
            viewer: viewer,
          );
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => page))
              .then((_) {
            if (index == 1) fetch(null);
          }).whenComplete(_refresh);
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.transactionNo, style: GemsChrome.body(size: 15, weight: FontWeight.w600)),
                    Text(task.assetTypeName, style: GemsChrome.body(size: 13, color: GemsChrome.textSoft)),
                    Text(task.assetNo, style: GemsChrome.body(size: 12, color: GemsChrome.textSoft)),
                    Text(task.taskDateDue, style: GemsChrome.body(size: 12, color: GemsChrome.textSoft)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusStyle.background,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  task.statusDesc,
                  style: GemsChrome.body(size: 11, weight: FontWeight.w600, color: statusStyle.foreground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DropdownButton<String> get filter => DropdownButton<String>(
        underline: Container(),
        value: dropdownValue,
        onChanged: (String? newValue) {
          setState(() {
            dropdownValue = newValue!;
            if (newValue != "All") {
              var tempList = _listTask.where((test) => test.statusDesc == newValue).toList();
              children = [];
              children.addAll(ListTile.divideTiles(
                      context: navigatorKey.currentContext!,
                      tiles: List.generate(
                          tempList.length, (index) => tile(tempList[index])))
                  .toList());
              children.insert(0, filter);
            } else {
              children = tiles;
            }
          });
        },
        items: <String>[
          'All',
          'Open',
          'In Progress',
          'Check',
          'Verify',
          'Re-Open',
          'Completed'
        ].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      );
}

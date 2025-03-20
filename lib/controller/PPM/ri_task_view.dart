import 'package:flutter/material.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';

import '../../model/task.dart';
import 'Form/form_view.dart';

class RITaskView extends StatefulWidget {
  final _TaskViewStateRI view;

  RITaskView({int index = 0}) : view = _TaskViewStateRI(index);

  update(String text) => view.fetch(text);
  updateQR(String text) => view.fetchQR(text);
  updateQRAll(String text) => view.fetchQRAll(text);
  updateAll(String text) => view.fetchAll(text);

  @override
  _TaskViewStateRI createState() => view;
}

class _TaskViewStateRI extends State<RITaskView>
    with AutomaticKeepAliveClientMixin<RITaskView> {
  String dropdownValue = "All";
  List<Widget> children = List<Widget>();
  List<Task> _listTask = List<Task>();
  List<Widget> tiles = List<Widget>();
  Provider _provider;
  bool builded = false;
  final int index;
  bool viewer = true;

  _TaskViewStateRI(this.index) {
    _refresh();
  }

  List<Widget> fetchGenerate(List<Task> _listTask) {
    List<Widget> values = List<Widget>();
    values = List.generate(_listTask.length, (item) => tile(_listTask[item]));

    values.insert(0, filter);

    return values;
  }

  fetch(String text) {
    String _url = "/api/m_ppm.php?type=pending_task";
    _url += "_search&isRoutine=true&assetNo=$text";

    _fetch(_url);
  }

  fetchQR(String text) {
    String _url = "/api/m_ppm.php?type=pending_task";
    _url += "_scan_asset&isRoutine=true&assetNo=$text";

    _fetch(_url);
  }

  fetchQRAll(String text) {
    String _url = "/api/m_ppm.php?type=all_task";
    _url += "_scan_asse&isRoutine=truet&assetNo=$text";

    _fetch(_url);
  }

  fetchAll(String text) {
    String _url = "/api/m_ppm.php?type=all_task";
    _url += "_search&isRoutine=true&searchTxt=$text";

    _fetch(_url);
  }

  void _fetch(String url) {
    _provider = Provider(fetchURL: url);

    _provider.fetch().then((value) {
      _listTask = value.taskList.toList();
      tiles = fetchGenerate(_listTask);
      children = tiles;
      if (builded) setState(() {});
    }).catchError((err) {
      tiles = fetchGenerate(null);
      children = tiles;
      if (builded) setState(() {});
    });
  }

  Future<void> _refresh() {
    if (index == 0)
      fetchAll(null);
    else if (index == 1) {
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
    return children.length > 0
        ? RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: EdgeInsets.all(12),
              itemCount: children.length,
              itemBuilder: (context, index) => children[index],
              separatorBuilder: (context, index) {
                return Divider();
              },
            ))
        : Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }

  Widget getTitle(String text, {bold = false}) => new Container(
        alignment: Alignment.centerLeft,
        child: new Text(text,
            style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      );

  Widget status(String value) {
    var text = value;
    var color = colorTheme1;
    if (text == "In Progress")
      color = colorTheme5;
    else if (text == "Closed")
      color = colorTheme4;
    else if (text == "Check") {
      color = colorTheme2;
    } else if (text == "Verify") {
      color = colorTheme3;
    }
    return new Container(
        alignment: Alignment.center,
        height: 30.0,
        width: 100.0,
        decoration: BoxDecoration(
            color: color, borderRadius: new BorderRadius.circular(20.0)),
        child: new Text(text,
            style: TextStyle(
              color: Colors.white,
            )));
  }

  ListTile tile(Task task) => new ListTile(
        contentPadding: EdgeInsets.all(12),
        title: new Row(
          children: <Widget>[
            new Expanded(
                child: new Column(
              children: <Widget>[
                getTitle(task.transactionNo, bold: true),
                getTitle(task.assetTypeName),
                getTitle(task.assetNo),
                getTitle(task.technician),
                getTitle(task.taskDateDue),
              ],
            )),
            status(task.statusDesc)
          ],
        ),
        onTap: () {
          Object page = new FormView(
            id: task.ppmTaskId,
            siteName: task.siteName,
            taskNo: task.transactionNo,
            taskStatus: task.statusDesc,
            refresh: fetch,
            viewer: this.viewer,
          );
          Navigator.of(context)
              .push(new MaterialPageRoute(
            builder: (BuildContext context) => page,
          ))
              .then((onValue) {
            if (index == 1) fetch(null);
          }).whenComplete(_refresh);
        },
      );

  DropdownButton get filter => DropdownButton<String>(
        underline: new Container(),
        value: dropdownValue,
        onChanged: (String newValue) {
          setState(() {
            dropdownValue = newValue;
            if (newValue != "All") {
              var tempList = _listTask
                  .where((test) => test.statusDesc == newValue)
                  .toList();
              children = List<Widget>();
              children.addAll(ListTile.divideTiles(
                      context: context,
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

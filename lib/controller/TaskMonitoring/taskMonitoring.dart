import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/TaskMonitoring/searchMonitorTask.dart';
import 'package:gfm_gems/controller/TaskMonitoring/task_detail.dart';
import 'package:gfm_gems/model/monitor.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:gfm_gems/view/bar.dart';
import 'package:gfm_gems/view/drawer.dart';
import '../../main.dart';

class TaskMonitoring extends StatefulWidget {
  @override
  _TaskMonitoringState createState() => _TaskMonitoringState();
}

class _TaskMonitoringState extends State<TaskMonitoring> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Provider _provider;
  bool _isOpened = false;
  bool _loading = true;
  String id = "1";
  late String dropdownValue;
  List<MonitorTask> _tasks = [];
  List<Widget> _children = [];

  @override
  void initState() {
    super.initState();
    dropdownValue = "Planned Preventive Maintenance";
    tasks();
  }

  @override
  Widget build(BuildContext context) {
    _provider.context = context;
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: bar(
          _scaffoldKey,
          text: "Track Monitoring",
          search: true,
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SearchTaskMonitoring())),
          dimmer: _isOpened,
        ),
      ),
      drawer: BuildDrawer(() => Navigator.pop(context)),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: RefreshIndicator(
                onRefresh: tasks,
                child: ListView(
                  children: _children,
                ),
              ),
            ),
    );
  }

  Widget getTitle(String text, {bool bold = false}) => Container(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal),
        ),
      );

  Widget status(String value) {
    var text = value;
    var color = colorTheme1;
    if (text == "In Progress")
      color = colorTheme5;
    else if (text == "Closed")
      color = colorTheme4;
    else if (text == "Check")
      color = colorTheme2;
    else if (text == "Verify")
      color = colorTheme3;
    else if (text == "Rejected") color = colorTheme4;
    return Container(
        alignment: Alignment.center,
        height: 30.0,
        width: 100.0,
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(20.0)),
        child: Text(text, style: const TextStyle(color: Colors.white)));
  }

  ListTile tile(MonitorTask task) => ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Row(
          children: <Widget>[
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                getTitle(task.transactionNo, bold: true),
                getTitle(task.flowName),
                getTitle(task.checkpointName),
                getTitle(id == "1" ? (task.userFullName ?? 'Unknown') : (task.currentTaskOwner ?? 'Unknown')),
                getTitle(task.transactionTimeCreated),
              ],
            )),
            status(task.transactionStatus)
          ],
        ),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => TaskInformation(task: task),
          ));
        },
      );

  Widget get _filter => DropdownButton<String>(
        underline: Container(),
        value: dropdownValue,
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              dropdownValue = newValue;
              tasks();
            });
          }
        },
        items: <String>[
          "Planned Preventive Maintenance",
          "Work Order"
        ].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      );

  void generateTile(List<MonitorTask> tasks) {
    _children = [];
    _children.addAll(ListTile.divideTiles(
            context: navigatorKey.currentContext!,
            tiles: List.generate(_tasks.length, (index) => tile(_tasks[index])))
        .toList());
    _children.insert(0, _filter);
    _children.insert(0, const SizedBox(height: 16.0));
    setState(() {
      _loading = false;
    });
  }

  Future<void> tasks() async {
    setState(() => _loading = true);
    id = dropdownValue == "Work Order" ? "2" : "1";
    _provider = Provider(fetchURL: "/api/m_ppm.php?flowId=$id&type=tnm_list");
    try {
      var response = await _provider.fetch();
      _tasks = response.monitorTaskList?.toList() ?? [];
      generateTile(_tasks);
    } catch (err) {
      _tasks = [];
      generateTile(_tasks);
      print(err);
    }
  }
}

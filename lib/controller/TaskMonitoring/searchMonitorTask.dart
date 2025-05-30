import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:GEMS/controller/TaskMonitoring/task_detail.dart';
import 'package:GEMS/model/monitor.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:toast/toast.dart';
import 'package:flutter/services.dart';
import '../../main.dart';

class SearchTaskMonitoring extends StatefulWidget {
  const SearchTaskMonitoring({super.key});

  @override
  _SearchTaskMonitoringState createState() => _SearchTaskMonitoringState();
}

class _SearchTaskMonitoringState extends State<SearchTaskMonitoring> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController controller = TextEditingController();
  late Provider _provider;
  bool _loading = true;
  int flowId = 1;
  String keyword = "";
  String searchText = "";
  String _dropdownValue = "Planned Preventive Maintenance";
  List<MonitorTask> _tasks = <MonitorTask>[];
  List<Widget> _children = <Widget>[];

  @override
  void initState() {
    super.initState();
    _provider = Provider(fetchURL: "/api/m_ppm.php?flowId=$flowId&type=tnm_list");
    tasks; // Trigger the asynchronous getter to load tasks
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    _provider.context = context;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: IconThemeData(color: colorTheme3),
        backgroundColor: Colors.white,
        title: TextField(
          controller: controller,
          style: TextStyle(fontFamily: 'Avenir', color: colorTheme3),
          autofocus: true,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Search",
            hintStyle: TextStyle(color: Color(0xcc022c41)),
          ),
          onChanged: (text) => setState(() => keyword = text),
          textInputAction: TextInputAction.search,
          onSubmitted: (value) {
            Toast.show("Loading", duration: 2);
            if (controller.text != searchText) {
              searchText = controller.text;
              allTask(controller.text);
            }
          },
        ),
        actions: <Widget>[
          GestureDetector(
            onTap: scan,
            child: Icon(
              Icons.camera,
              color: colorTheme3,
              size: 30,
            ),
          ),
          SizedBox(width: 20),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView(
                children: _children,
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
    String text = value;
    Color color = colorTheme1;
    if (text == "In Progress") {
      color = colorTheme5;
    } else if (text == "Closed")
      color = colorTheme4;
    else if (text == "Check")
      color = colorTheme2;
    else if (text == "Verify") 
      color = colorTheme3;

    return Container(
        alignment: Alignment.center,
        height: 30.0,
        width: 100.0,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(20.0)),
        child: Text(text, style: TextStyle(color: Colors.white)));
  }

  ListTile tile(MonitorTask task) => ListTile(
        contentPadding: EdgeInsets.all(12),
        title: Row(
          children: <Widget>[
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                getTitle(task.transactionNo, bold: true),
                getTitle(task.flowName),
                getTitle(task.checkpointName),
                getTitle(task.userFullName ?? "-"),
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

  DropdownButton<String> get filter => DropdownButton<String>(
        underline: Container(),
        value: _dropdownValue,
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              if (_dropdownValue != newValue) {
                _dropdownValue = newValue;
                flowId = newValue == "Work Order" ? 2 : 1;
                _provider = Provider(
                    fetchURL: "/api/m_ppm.php?flowId=$flowId&type=tnm_list");
                tasks; // Reload tasks
              }
            });
          }
        },
        items: <String>['Planned Preventive Maintenance', 'Work Order']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      );

  void generateTile(List<MonitorTask>? tasksList) {
    _children = <Widget>[];
    if (tasksList != null && tasksList.isNotEmpty) {
      _children.addAll(ListTile.divideTiles(
              context: navigatorKey.currentContext!,
              tiles: List.generate(
                  tasksList.length, (index) => tile(tasksList[index])))
          .toList());
    }
    _children.insert(0, filter);
    _children.insert(0, SizedBox(height: 16.0));
    setState(() => _loading = false);
  }

  Future<void> scan() async {
    try {
      var barcode = await BarcodeScanner.scan();
      keyword = "Success";
      controller.text = searchText = barcode.rawContent;
      // Optionally call qrTask if needed:
      // qrTask(barcode.rawContent);
      allTask(controller.text);
      Toast.show("Loading", duration: 2);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(
            () => keyword = 'The user did not grant the camera permission!');
      } else {
        setState(() => keyword = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => keyword = 'Cancel');
    } catch (e) {
      setState(() => keyword = 'Unknown error: $e');
    }
    Toast.show(keyword);
  }

  void allTask(String text) {
    String url = "/api/m_ppm.php?flowId=$flowId&type=tnm_list";
    url += "_search&searchTxt=$text";
    _provider = Provider(fetchURL: url);
    _provider.context = context;
    tasks; // Reload tasks with search filter
  }

  void qrTask(String text) {
    String url = "/api/m_ppm.php?flowId=$flowId&type=tnm_list";
    url += "_scan_asset&assetNo=$text";
    _provider = Provider(fetchURL: url);
    _provider.context = context;
    tasks; // Reload tasks with scan result
  }

  Future<void> get tasks async {
    setState(() => _loading = true);
    try {
      var response = await _provider.fetch();
      _tasks = response.monitorTaskList?.toList() ?? <MonitorTask>[];
      generateTile(_tasks);
    } catch (err) {
      _tasks = <MonitorTask>[];
      generateTile(null);
      print(err);
    }
  }
}

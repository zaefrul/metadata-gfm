import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/TaskMonitoring/task_detail.dart';
import 'package:gfm_gems/model/monitor.dart';
import 'package:gfm_gems/model/task.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:toast/toast.dart';
import 'package:flutter/services.dart';

class SearchTaskMonitoring extends StatefulWidget {
  @override
  _SearchTaskMonitoringState createState() => _SearchTaskMonitoringState();
}

class _SearchTaskMonitoringState extends State<SearchTaskMonitoring> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextEditingController controller = TextEditingController();
  Provider _provider;
  bool _loading = true;
  int flowId = 1;
  String keyword = "";
  String searchText = "";
  String _dropdownValue = "Planned Preventive Maintenance";
  List<MonitorTask> _tasks = List<MonitorTask>();
  List<Widget> _children = List<Widget>();

  @override
  void initState() {
    super.initState();

    _provider =
        new Provider(fetchURL: "/api/m_ppm.php?flowId=$flowId&type=tnm_list");

    tasks;
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
          title: new TextField(
              controller: controller,
              style: new TextStyle(fontFamily: 'Avenir', color: colorTheme3),
              autofocus: true,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Search",
                  hintStyle: TextStyle(color: Color(0xcc022c41))),
              onChanged: (text) => setState(() => keyword = text),
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                Toast.show("Loading", duration: 2);
                if (controller.text != searchText) {
                  searchText = controller.text;
                  allTask(controller.text);
                }
              }),
          actions: <Widget>[
            new GestureDetector(
                child: Icon(
                  Icons.camera,
                  color: colorTheme3,
                  size: 30,
                ),
                onTap: scan),
            new SizedBox(width: 20),
          ],
        ),
        body: _loading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView(
                  children: _children,
                )));
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
    else if (text == "Check")
      color = colorTheme2;
    else if (text == "Verify") color = colorTheme3;

    return new Container(
        alignment: Alignment.center,
        height: 30.0,
        width: 100.0,
        decoration: BoxDecoration(
            color: color, borderRadius: new BorderRadius.circular(20.0)),
        child: new Text(text, style: TextStyle(color: Colors.white)));
  }

  ListTile tile(MonitorTask task) => new ListTile(
        contentPadding: EdgeInsets.all(12),
        title: new Row(
          children: <Widget>[
            new Expanded(
                child: new Column(
              children: <Widget>[
                getTitle(task.transactionNo, bold: true),
                getTitle(task.flowName),
                getTitle(task.checkpointName),
                getTitle(task.userFullName == null ? "-" : task.userFullName),
                getTitle(task.transactionTimeCreated),
              ],
            )),
            status(task.transactionStatus)
          ],
        ),
        onTap: () {
          Navigator.of(context).push(new MaterialPageRoute(
            builder: (BuildContext context) => TaskInformation(task: task),
          ));
        },
      );

  DropdownButton get filter => DropdownButton<String>(
        underline: new Container(),
        value: _dropdownValue,
        onChanged: (String newValue) {
          setState(() {
            if (_dropdownValue != newValue) {
              _dropdownValue = newValue;
              flowId = newValue == "Work Order" ? 2 : 1;
              _provider = new Provider(
                  fetchURL: "/api/m_ppm.php?flowId=$flowId&type=tnm_list");
              tasks;
            }
            //   if (newValue != "All") {
            //     var tempList = _tasks
            //         .where((test) => test.transactionStatus == newValue)
            //         .toList();
            //     generateTile(tempList);
            //   } else generateTile(_tasks);
          });
        },
        items: <String>['Planned Preventive Maintenance', 'Work Order']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      );

  void generateTile(List<MonitorTask> tasks) {
    _children = List<Widget>();
    _children.addAll(ListTile.divideTiles(
            context: context,
            tiles: List.generate(_tasks.length, (index) => tile(_tasks[index])))
        .toList());
    _children.insert(0, filter);
    _children.insert(
        0,
        SizedBox(
          height: 16.0,
        ));
    setState(() => _loading = false);
  }

  Future scan() async {
    try {
      var barcode = await BarcodeScanner.scan();
      keyword = "Success";

      controller.text = this.searchText = barcode.rawContent;
      // qrTask(barcode.rawContent);

      allTask(controller.text);

      Toast.show("Loading", duration: 2);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied)
        setState(() =>
            this.keyword = 'The user did not grant the camera permission!');
      else
        setState(() => this.keyword = 'Unknown error: $e');
    } on FormatException {
      setState(() => this.keyword = 'Cancel');
    } catch (e) {
      setState(() => this.keyword = 'Unknown error: $e');
    }

    Toast.show(this.keyword);
  }

  allTask(String text) {
    String _url = "/api/m_ppm.php?flowId=$flowId&type=tnm_list";
    if (text != null) _url += "_search&searchTxt=$text";

    _provider = new Provider(fetchURL: _url);
    _provider.context = context;

    tasks;
  }

  qrTask(String text) {
    String _url = "/api/m_ppm.php?flowId=$flowId&type=tnm_list";
    if (text != null) _url += "_scan_asset&assetNo=$text";

    _provider = new Provider(fetchURL: _url);
    _provider.context = context;

    tasks;
  }

  Future get tasks async {
    setState(() => _loading = true);
    try {
      var response = await _provider.fetch();
      _tasks = response.monitorTaskList.toList();
      generateTile(_tasks);
    } catch (err) {
      _tasks = List<MonitorTask>();
      generateTile(null);
      print(err);
    }
  }
}

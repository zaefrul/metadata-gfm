import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/PPM/Form/form_view.dart';
import 'package:gfm_gems/controller/WorkOrder/complaintSection_v2.dart';
import 'package:gfm_gems/model/monitor.dart';
import 'package:gfm_gems/model/task.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:percent_indicator/percent_indicator.dart';

class TaskInformation extends StatelessWidget {
  final MonitorTask task;
  final Provider _provider;

  TaskInformation({this.task})
      : _provider = Provider(
            fetchURL:
                "/api/m_ppm.php?type=tnm_details&transactionId=${task.transactionId}");

  @override
  Widget build(BuildContext context) {
    _provider.context = context;
    return Scaffold(
        appBar: AppBar(
          title: new Text(
            "Task Information",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          centerTitle: true,
        ),
        body: FutureBuilder(
          future: fetch,
          builder: (context, AsyncSnapshot<MonitorDetail> snapshot) {
            if (snapshot.error != null)
              return Center(
                child: new Text(snapshot.error.toString()),
              );
            return snapshot.data == null
                ? Center(child: CircularProgressIndicator())
                : body(snapshot.data, context);
          },
        ));
  }

  Widget title(String text, {color = Colors.black}) => new Text(text,
      style: TextStyle(fontWeight: FontWeight.bold, color: color));
  Widget desc(String text) => new Text(text,
      style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal));
  Widget info(String textTitle, String textDesc) =>
      new Column(children: <Widget>[
        title(textTitle),
        SizedBox(height: 8.0),
        desc(textDesc),
        SizedBox(height: 16.0)
      ], crossAxisAlignment: CrossAxisAlignment.start);
  Widget padding(Widget child) => new Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0), child: child);
  Widget number(String num) => new Container(
        decoration: BoxDecoration(
          color: colorTheme2,
          shape: BoxShape.circle,
        ),
        child: Center(child: title(num, color: Colors.white)),
        height: 24.0,
        width: 24.0,
      );
  Widget openform(id, status, siteName, transactionNo, context) =>
      GestureDetector(
        child: new Container(
            alignment: Alignment.center,
            height: 30.0,
            width: 100.0,
            decoration: BoxDecoration(
                color: colorTheme1,
                borderRadius: new BorderRadius.circular(20.0)),
            child:
                new Text("Open Form", style: TextStyle(color: Colors.white))),
        onTap: () {
          Object page = new FormView(
            id: id,
            siteName: siteName,
            taskNo: transactionNo,
            taskStatus: status,
            refresh: null,
            viewer: true,
          );
          Navigator.of(context).push(new MaterialPageRoute(
            builder: (BuildContext context) => page,
          ));
        },
      );

  Widget openWO(id, status, siteName, transactionNo, context) =>
      GestureDetector(
        child: new Container(
            alignment: Alignment.center,
            height: 30.0,
            width: 100.0,
            decoration: BoxDecoration(
                color: colorTheme1,
                borderRadius: new BorderRadius.circular(20.0)),
            child:
                new Text("Open Form", style: TextStyle(color: Colors.white))),
        onTap: () {
          Object page = new ComplaintSection(
            id: id,
            siteName: siteName,
            taskNo: transactionNo,
            taskStatus: status,
            viewer: true,
          );
          Navigator.of(context).push(new MaterialPageRoute(
            builder: (BuildContext context) => page,
          ));
        },
      );

  Widget body(MonitorDetail data, context) {
    var children = [
      SizedBox(
        height: 24.0,
      ),
      padding(info("Flow Name", data.flowName)),
      Padding(
        child: Row(
          children: <Widget>[
            Column(
              children: <Widget>[
                info("Task No", data.transactionNo),
                info("Initiated By", data.initiateBy),
                info("Initiated Time", data.initiateTimeCreated),
                info("Current User", data.currentUser),
                info("Flow Status", data.flowStatus),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
            SizedBox(
              width: 12.0,
            ),
            Column(
              children: <Widget>[
                info("Current Checkpoint", data.currentStatus),
                info("Initiated By Group", data.initiateByGroup),
                info("Task Status", data.taskStatus),
                info("Received Time", data.receivedTime),
                info("Flow Due Date", data.flowDueDate)
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            )
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.0),
      ),
      SizedBox(
        height: 12.0,
      ),
      data.ppmTaskId == null
          ? new Container()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 120.0),
              child: openform(data.ppmTaskId, data.taskStatus, data.siteName,
                  data.transactionNo, context),
            ),
      data.woTaskId == null
          ? new Container()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 120.0),
              child: openWO(data.woTaskId, data.flowStatus, data.flowName,
                  data.transactionNo, context),
            ),
      SizedBox(
        height: 12.0,
      ),
      Divider(),
      padding(new Text("Transaction History",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0))),
      statusView(data.checkpointId, data.flowName == "Work Order"),
      SizedBox(
        height: 16.0,
      ),
      Divider(),
    ];

    var historyWidget = List.generate(data.taskHistory.length, (index) {
      return taskView(data.taskHistory[index], (index + 1));
    });

    children.addAll(historyWidget);

    return new ListView(
      children: children,
    );
  }

  Widget statusView(String status, bool woModule) {
    int percentage = 0;
    var imageDuring = "AssignPPM";
    var imageCheck = "CheckPPM";
    var imageVerify = "Complete";
    var imageClosed = "VerifyPPM";

    if (status == "4" || status == "15") {
      imageDuring += "_after";
      imageCheck += "_after";
      imageVerify += "_after";
      imageClosed += "_after";
      percentage = 100;
    } else if (status == "3" || status == "14" || status == "16") {
      imageDuring += "_after";
      imageCheck += "_after";
      imageVerify += "_after";
      percentage = 75;
    } else if (status == "2" || status == "13") {
      imageDuring += "_after";
      imageCheck += "_after";
      percentage = 50;
    } else if (status == "1" || status == "12") {
      imageDuring += "_after";
      percentage = 25;
    }

    imageDuring += ".png";
    imageCheck += ".png";
    imageVerify += ".png";
    imageClosed += ".png";

    Widget statusView(Widget status, String textDesc) =>
        new Column(children: <Widget>[
          status,
          SizedBox(height: 16.0),
          Text(textDesc,
              style: TextStyle(
                  color: Colors.black, fontWeight: FontWeight.normal)),
        ]);

    Container row = Container(
        // width: 200.0,
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            statusView(
                Image.asset(
                  "assets/" + imageDuring,
                  height: 48,
                ),
                woModule ? "Assign WO" : "Execute PPM"),
            statusView(Image.asset("assets/" + imageCheck, height: 48),
                woModule ? "Execute WO" : "Check PPM"),
            statusView(Image.asset("assets/" + imageVerify, height: 48),
                woModule ? "Verify WO" : "Verify PPM"),
            statusView(Image.asset("assets/" + imageClosed, height: 48),
                woModule ? "Closed" : "Complete"),
          ]),
    ));

    LinearPercentIndicator linearPercentIndicator = LinearPercentIndicator(
      lineHeight: 8.0,
      percent: percentage / 100,
      backgroundColor: Colors.grey,
      progressColor: colorTheme2,
    );

    return Column(children: <Widget>[
      SizedBox(
        height: 16.0,
      ),
      row,
      SizedBox(
        height: 12.0,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: linearPercentIndicator,
      )
    ]);
  }

  Widget taskView(MonitorHistory task, int index) {
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

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                number(index.toString()),
                SizedBox(
                  width: 16.0,
                ),
                Expanded(
                    child: Column(
                  children: <Widget>[
                    info("Checkpoint: ", task.checkpointId),
                    info(
                        "Due Date: ",
                        task.taskDateDue.length == 0
                            ? "null"
                            : task.taskDateDue),
                    info(
                        "Time Submitted:",
                        task.taskTimeSubmit == ""
                            ? "None"
                            : task.taskTimeSubmit),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                )),
                Expanded(
                    child: Column(children: <Widget>[
                  info("User:", task.taskClaimedUser),
                  info(
                      "Time Created:",
                      task.taskTimeCreated == ""
                          ? "None"
                          : task.taskTimeCreated),
                  status(task.taskStatus),
                ], crossAxisAlignment: CrossAxisAlignment.start)),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  height: 24.0,
                  width: 24.0,
                ),
                SizedBox(
                  width: 16.0,
                ),
                Expanded(
                  child: info("Remark:",
                      task.taskRemark.length == 0 ? '-' : task.taskRemark),
                ),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      ),
    );
  }

  Future<MonitorDetail> get fetch async {
    try {
      var response = await _provider.fetch();
      return response.monitorDetail;
    } catch (err) {
      return Future.error(err);
    }
  }
}

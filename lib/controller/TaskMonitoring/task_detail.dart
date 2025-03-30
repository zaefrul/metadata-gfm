import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/PPM/Form/form_view.dart';
import 'package:gfm_gems/controller/WorkOrder/complaintSection_v2.dart';
import 'package:gfm_gems/model/monitor.dart';
import 'package:gfm_gems/model/responseValue.dart';
import 'package:gfm_gems/model/task.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:convert';

class TaskInformation extends StatelessWidget {
  final MonitorTask task;
  final Provider _provider;

  TaskInformation({super.key, required this.task})
      : _provider = Provider(
            fetchURL:
                "/api/m_ppm.php?type=tnm_details&transactionId=${task.transactionId}");

  @override
  Widget build(BuildContext context) {
    _provider.context = context;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Task Information",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: FutureBuilder<MonitorDetail>(
        future: fetch,
        builder: (context, AsyncSnapshot<MonitorDetail> snapshot) {
          if (snapshot.error != null) {
            return Center(child: Text(snapshot.error.toString()));
          }
          return snapshot.data == null
              ? Center(child: CircularProgressIndicator())
              : body(snapshot.data!, context);
        },
      ),
    );
  }

  // Helper widget methods
  Widget title(String text, {Color color = Colors.black}) =>
      Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: color));
  Widget desc(String text) =>
      Text(text, style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal));
  Widget info(String textTitle, String textDesc) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          title(textTitle),
          SizedBox(height: 8.0),
          desc(textDesc),
          SizedBox(height: 16.0)
        ],
      );
  Widget padding(Widget child) =>
      Padding(padding: EdgeInsets.symmetric(horizontal: 20.0), child: child);
  Widget number(String num) => Container(
        decoration: BoxDecoration(
          color: colorTheme2,
          shape: BoxShape.circle,
        ),
        height: 24.0,
        width: 24.0,
        child: Center(child: title(num, color: Colors.white)),
      );

  // openform now returns a Widget directly.
  Widget openform(String id, String status, String siteName, String transactionNo, BuildContext context) {
    return GestureDetector(
      child: Container(
          alignment: Alignment.center,
          height: 30.0,
          width: 100.0,
          decoration: BoxDecoration(
              color: colorTheme1,
              borderRadius: BorderRadius.circular(20.0)),
          child: Text("Open Form", style: TextStyle(color: Colors.white))),
      onTap: () {
        // Directly create a FormView widget.
        Widget page = FormView(
          id: id,
          siteName: siteName,
          taskNo: transactionNo,
          taskStatus: status,
          refresh: () {},
          viewer: true,
        );
        Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => page));
      },
    );
  }

  // openWO now returns a Widget directly.
  Widget openWO(String id, String status, String siteName, String transactionNo, BuildContext context) {
    return GestureDetector(
      child: Container(
          alignment: Alignment.center,
          height: 30.0,
          width: 100.0,
          decoration: BoxDecoration(
              color: colorTheme1,
              borderRadius: BorderRadius.circular(20.0)),
          child: Text("Open Form", style: TextStyle(color: Colors.white))),
      onTap: () {
        Widget page = ComplaintSection(
          id: id,
          siteName: siteName,
          taskNo: transactionNo,
          taskStatus: status,
          viewer: true,
        );
        Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => page));
      },
    );
  }

  Widget body(MonitorDetail data, BuildContext context) {
    List<Widget> children = [
      SizedBox(height: 24.0),
      padding(info("Flow Name", data.flowName)),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                info("Task No", data.transactionNo),
                info("Initiated By", data.initiateBy),
                info("Initiated Time", data.initiateTimeCreated),
                info("Current User", data.currentUser),
                info("Flow Status", data.flowStatus),
              ],
            ),
            SizedBox(width: 12.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                info("Current Checkpoint", data.currentStatus),
                info("Initiated By Group", data.initiateByGroup),
                info("Task Status", data.taskStatus),
                info("Received Time", data.receivedTime),
                info("Flow Due Date", data.flowDueDate)
              ],
            )
          ],
        ),
      ),
      SizedBox(height: 12.0),
      data.ppmTaskId == null
          ? Container()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 120.0),
              child: openform(data.ppmTaskId ?? '', data.taskStatus, data.siteName ?? '', data.transactionNo, context),
            ),
      data.woTaskId == null
          ? Container()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 120.0),
              child: openWO(data.woTaskId ?? '', data.flowStatus, data.flowName, data.transactionNo, context),
            ),
      SizedBox(height: 12.0),
      Divider(),
      padding(Text("Transaction History",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0))),
      statusView(data.checkpointId, data.flowName == "Work Order"),
      SizedBox(height: 16.0),
      Divider(),
    ];

    List<Widget> historyWidget = List.generate(data.taskHistory.length, (index) {
      return taskView(data.taskHistory[index], index + 1);
    });

    children.addAll(historyWidget);

    return ListView(children: children);
  }

  Widget statusView(String status, bool woModule) {
    int percentage = 0;
    String imageDuring = "AssignPPM";
    String imageCheck = "CheckPPM";
    String imageVerify = "Complete";
    String imageClosed = "VerifyPPM";

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

    Widget statusViewWidget(Widget statusWidget, String textDesc) => Column(
          children: <Widget>[
            statusWidget,
            SizedBox(height: 16.0),
            Text(textDesc,
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.normal)),
          ],
        );

    Widget row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            statusViewWidget(
                Image.asset("assets/$imageDuring", height: 48),
                woModule ? "Assign WO" : "Execute PPM"),
            statusViewWidget(
                Image.asset("assets/$imageCheck", height: 48),
                woModule ? "Execute WO" : "Check PPM"),
            statusViewWidget(
                Image.asset("assets/$imageVerify", height: 48),
                woModule ? "Verify WO" : "Verify PPM"),
            statusViewWidget(
                Image.asset("assets/$imageClosed", height: 48),
                woModule ? "Closed" : "Complete"),
          ]),
    );

    LinearPercentIndicator linearPercentIndicator = LinearPercentIndicator(
      lineHeight: 8.0,
      percent: percentage / 100,
      backgroundColor: Colors.grey,
      progressColor: colorTheme2,
    );

    return Column(
      children: <Widget>[
        SizedBox(height: 16.0),
        row,
        SizedBox(height: 12.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: linearPercentIndicator,
        )
      ],
    );
  }

  Widget taskView(MonitorHistory task, int index) {
    Widget status(String value) {
      String text = value;
      Color color = colorTheme1;

      if (text == "In Progress")
        color = colorTheme5;
      else if (text == "Closed")
        color = colorTheme4;
      else if (text == "Check")
        color = colorTheme2;
      else if (text == "Verify") color = colorTheme3;

      return Container(
          alignment: Alignment.center,
          height: 30.0,
          width: 100.0,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(20.0)),
          child: Text(text, style: TextStyle(color: Colors.white)));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                number(index.toString()),
                SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      info("Checkpoint: ", task.checkpointId),
                      info("Due Date: ", task.taskDateDue.isEmpty ? "null" : task.taskDateDue),
                      info("Time Submitted:", task.taskTimeSubmit.isEmpty ? "None" : task.taskTimeSubmit),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      info("User:", task.taskClaimedUser),
                      info("Time Created:", task.taskTimeCreated.isEmpty ? "None" : task.taskTimeCreated),
                      status(task.taskStatus),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 24.0, width: 24.0),
                SizedBox(width: 16.0),
                Expanded(
                  child: info("Remark:", task.taskRemark.isEmpty ? '-' : task.taskRemark),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<MonitorDetail> get fetch async {
    try {
      // Step 1: Fetch the raw response.
      debugPrint("step 1. Fetching raw response");
      var rawResponse = await _provider.fetch();
      debugPrint("step 1. Raw response: $rawResponse");
      if (rawResponse is! Map<String, dynamic> && rawResponse is! ResponseValue) {
        throw Exception("Unexpected rawResponse type: ${rawResponse.runtimeType}");
      }

      // Step 2: Extract the 'monitorDetail' field from the response.
      debugPrint("step 2. Extracting monitorDetail field");
      var detailField = rawResponse.monitorDetail;
      if (detailField == null) {
        throw Exception("MonitorDetail is null");
      }

      if (detailField is! MonitorDetail) {
        try
        {
          // Step 3: Convert the monitorDetail Map to a JSON string.
          debugPrint("step 3. Converting monitorDetail to JSON string");
          String jsonString = jsonEncode(detailField);

          // Step 4: Parse the JSON string using MonitorDetail.fromJson.
          debugPrint("step 4. Parsing JSON string to MonitorDetail object");
          MonitorDetail detail = MonitorDetail.fromJson(jsonString);
          return detail;
        } catch (e) {
          debugPrint("Error parsing monitorDetail: $e");
          throw Exception("Expected monitorDetail as a Map but got ${detailField.runtimeType}");
        }
      }

      return detailField;

    } catch (err) {
      return Future.error(err);
    }
  }
}

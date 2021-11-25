import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/PPM/Form/pdf.dart';
import 'package:gfm_gems/model/responseValue.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:toast/toast.dart';

import 'formA.dart';
import 'formB.dart';
import 'formC.dart';
import 'formD.dart';
import 'formE.dart';
import 'formF.dart';
import 'formG.dart';
import 'formH.dart';

class FormView extends StatefulWidget {
  final String id;
  final String siteName;
  final String taskNo;
  final String taskStatus;
  final Function refresh;
  final bool viewer;

  FormView(
      {this.id,
      this.siteName,
      this.taskNo,
      this.taskStatus,
      this.refresh,
      this.viewer = false});

  @override
  _FormViewState createState() => _FormViewState(id: this.id);
}

class _FormViewState extends State<FormView> {
  List<String> allStatus;
  List<String> titles = [
    "A. Asset Details",
    "B. Safety Precaution / General Guidline prior to maintenance activity",
    "C. Qualitative Task",
    "D. Quantitative Task",
    "E. Spare Parts / Material Used",
    "F. Additional Reports",
    "G. Comments / Remarks",
    "H. Maintenance Image"
  ];

  Provider provider;
  final String id;
  bool verified = true;
  bool fieldDisable = true;
  ResponseValue responseValue;
  List<String> statusList;
  int checkpoint = 1;

  _FormViewState({this.id});

  @override
  void initState() {
    super.initState();

    if (widget.taskStatus == "Check") checkpoint = 2;
    if (widget.taskStatus == "Verify") checkpoint = 3;
    if (widget.taskStatus == "Closed") checkpoint = 4;

    if (widget.taskStatus == "Open") {
      fieldDisable = true;
      verified = false;
    }
    if (widget.taskStatus == "In Progress" || widget.taskStatus == "Re-Open") {
      fieldDisable = false;
    }

    if (widget.viewer) fieldDisable = true;

    provider = Provider(
        taskID: widget.id,
        fetchURL: "/api/m_ppm.php?type=ppm_section_status&ppmTaskId=");

    refreshStatus();
  }

  @override
  Widget build(BuildContext context) {
    provider.context = context;
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(
            color: colorTheme3,
          ),
          title: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(child: getTitle(widget.siteName, bold: true)),
                Text(
                  widget.taskNo,
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.left,
                ),
              ])),
      body: responseValue == null
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: refreshStatus,
              child: ListView.separated(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  separatorBuilder: (context, index) =>
                      Divider(color: Colors.black),
                  itemCount: 9,
                  itemBuilder: (context, item) {
                    if (item < 8) {
                      var value = responseValue.statusList[item];
                      return tile(item, value.ppmTaskSectionStatus,
                          value.checkParts, value.checkAdditionalReport);
                    }
                    return new SizedBox(height: 10);
                  })),
      floatingActionButton: new FloatingActionButton.extended(
        label: new Text(widget.viewer ? "View Form" : "Submit"),
        backgroundColor:
            (widget.viewer || enableSubmit) ? colorTheme2 : colorTheme3,
        onPressed: (widget.viewer || enableSubmit)
            ? () {
                var page = new PDF(
                    id: widget.id,
                    transactionNo: widget.taskNo,
                    viewer: widget.viewer,
                    checkpoint: checkpoint,
                    submitted: () {
                      widget.refresh();
                      fieldDisable = true;
                    });
                Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) => page,
                ));
              }
            : () {
                if (!verified)
                  Toast.show(
                      "To get started, you need to scan the QR code of the asset from section A. Asset Details.",
                      context,
                      duration: 3);
                else
                  Toast.show(
                      "All sections must be completed before submit", context,
                      duration: 1);
              },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget getTitle(String text, {bold = false, double size}) => new Container(
        padding: EdgeInsets.only(top: 3),
        alignment: Alignment.centerLeft,
        child: new Text(text,
            style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: colorTheme3)),
      );

  Widget status(String text) {
    var color;
    if (text == "Info")
      color = colorTheme2;
    else if (text == "Pending")
      color = colorTheme4;
    else if (text == "In Progress")
      color = colorTheme1;
    else
      color = colorTheme3;

    return new Container(
        alignment: Alignment.center,
        height: 30.0,
        width: 100.0,
        decoration: BoxDecoration(
            color: color, borderRadius: new BorderRadius.circular(20.0)),
        child: new Text(text,
            style: TextStyle(color: Colors.white, fontFamily: 'Avenir')));
  }

  Widget tile(int item, String statusDesc, String parts, String report) =>
      ListTile(
          title: new Row(children: <Widget>[
            new Expanded(child: getTitle(titles[item])),
            status(statusDesc)
          ]),
          trailing: new Icon(Icons.arrow_right),
          onTap: () {
            Object object;

            if (item == 0)
              object = new FormA(id, verification: (bool status) {
                setState(() {
                  verified = status;
                  fieldDisable = !status;
                });
              }, viewer: widget.viewer, verified: verified);
            else if (item == 1)
              object = new FormB(id);
            else if (item == 2)
              object = new FormC(id, verified, refreshStatus, fieldDisable);
            else if (item == 3)
              object = new FormD(id, verified, refreshStatus, fieldDisable);
            else if (item == 4)
              object =
                  new FormE(id, verified, refreshStatus, fieldDisable, parts);
            else if (item == 5)
              object =
                  new FormF(id, verified, refreshStatus, fieldDisable, report);
            else if (item == 6)
              object = new FormG(id, verified, refreshStatus, fieldDisable);
            else if (item == 7)
              object = new FormH(id, verified, refreshStatus, fieldDisable);

            Navigator.of(context).push(new MaterialPageRoute(
              builder: (BuildContext context) => object,
            ));
          });

  bool get enableSubmit {
    bool check = true;
    if (statusList != null)
      for (String f in statusList) {
        if (f != "Info") if (f != "Completed") return false;
      }
    else
      check = false;

    return check;
  }

  Future<void> refreshStatus() async {
    var value = await provider.fetch();

    setState(() {
      responseValue = value;
      var result =
          responseValue.statusList.map((f) => f.ppmTaskSectionStatus).toList();
      statusList = result;
    });

    return Future.value();
  }
}

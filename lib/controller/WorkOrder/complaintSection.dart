import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/WorkOrder/complaintSectionA.dart';
import 'package:gfm_gems/controller/WorkOrder/complaintSectionC.dart';
import 'package:gfm_gems/controller/WorkOrder/complaintSectionB_Assign.dart';
import 'package:gfm_gems/model/responseValue.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:gfm_gems/view/dialog.dart';
import 'package:toast/toast.dart';

import 'complaintPDF.dart';
import 'complaintSectionB_Remark.dart';
import 'complaintSectionD.dart';

class ComplaintSection extends StatefulWidget {
  final String taskNo;
  final String siteName;
  final String taskStatus;
  final bool viewer;
  final String id;
  final bool isComplaintProgress;
  final bool isAssign;

  ComplaintSection({
    this.id,
    this.taskNo,
    this.siteName,
    this.taskStatus,
    this.viewer,
    this.isAssign = false,
    this.isComplaintProgress = false,
  });

  @override
  _ComplaintSectionState createState() => _ComplaintSectionState();
}

class _ComplaintSectionState extends State<ComplaintSection> {
  List<String> allStatus;
  ResponseValue responseValue;
  int checkpoint = 0;
  List<String> titles;
  List<String> listStatus = ["Info", "Pending", "Pending"];
  String comment = "";
  bool loadingAssign = false;

  @override
  void initState() {
    super.initState();
    if (widget.taskStatus == "Verify") {
      checkpoint = 1;
      titles = [
        "A. Complaint Details",
        "B. Description of Repair Work",
        "C. Image",
      ];
    }
    if (widget.taskStatus == "Assign" ||
        widget.taskStatus == "Rejected" ||
        widget.taskStatus == "Revisit" ||
        widget.taskStatus == "WR Reassign") {
      titles = [
        "A. Complaint Details",
      ];

      if (widget.taskStatus != "Rejected") titles.add("B. Assign Executor");
    } else {
      titles = [
        "A. Complaint Details",
        "B. Description of Repair Work",
        "C. Image",
        "D. Asset No",
      ];
      // if (widget.taskStatus == "In Progress") titles.add("D. Asset No");
    }

    if (widget.taskStatus == "WR Check" ||
        widget.taskStatus == "WR Verified" ||
        widget.taskStatus == "WR Re-Open") {
      titles = [
        "A. Complaint Details",
      ];
      if (widget.taskStatus == "WR Check" || widget.taskStatus == "WR Re-Open")
        checkpoint = 4;
      if (widget.taskStatus == "WR Verified") checkpoint = 5;
    }

    if (widget.taskStatus == "WR Check" ||
        widget.taskStatus == "WR Verify" ||
        widget.taskStatus == "WR Re-Open") {
      titles = [
        "A. Complaint Details",
      ];
      if (widget.taskStatus == "WR Check" || widget.taskStatus == "WR Re-Open")
        checkpoint = 4;
      if (widget.taskStatus == "WR Verify") checkpoint = 5;
    }

    _fetch();
  }

  Future<void> _fetch() async {
    Provider provider = Provider(
        fetchURL:
            "/api/m_wo.php?type=section_status${widget.taskStatus == "Assign" || widget.taskStatus == "Revisit" || widget.taskStatus == "Rejected" || widget.taskStatus == "WR Reassign" ? "_assign" : widget.taskStatus == "WR Check" || widget.taskStatus == "WR Verified" || widget.taskStatus == "WR Re-Open" ? "_wr" : ""}&woTaskId=",
        taskID: widget.id);
    try {
      responseValue = await provider.fetch();
      setState(() {
        listStatus =
            responseValue.wostatusList.map((f) => f.sectionStatus).toList();
        var lastSection = responseValue.wostatusList.last.sectionName;
        if (lastSection == "C" && widget.taskStatus == "Rejected") {
          listStatus.removeAt(1);
        }
        if (titles.length < listStatus.length &&
            (lastSection == "E" ||
                lastSection == "D" ||
                lastSection == "C" ||
                lastSection == "B")) {
          comment = responseValue.wostatusList.last.comment;
          titles.add("${responseValue.wostatusList.last.sectionName}. Comment");
        }
      });
    } catch (err) {
      print(err);
    }
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    var rejectButton = FloatingActionButton.extended(
        heroTag: "reject_button",
        label: new Text(widget.taskStatus == "Assign"
            ? "Reject"
            : widget.taskStatus == "WR Verified"
                ? "Re-Open"
                : "Revisit"),
        backgroundColor: Colors.red,
        onPressed: () {
          var dialog = CustomDialog(
            rootPage: "/workorder",
            title: "Remark",
            description: "Remark",
            buttonText: "Okay",
            secondButton: false,
            cancel: true,
            okayTapped: () {
              Navigator.pop(context);
              Navigator.pop(context);
              // post(text);
            },
            image: Image.asset(
              "assets/icon_trans.png",
              height: 40,
            ),
            remarkTapped: (text) {
              Navigator.pop(context);
              postReject(text);
            },
          );

          showDialog(
              context: context, builder: (BuildContext context) => dialog);
        });
    var floatingButton = FloatingActionButton.extended(
        heroTag: "accept_button",
        label: loadingAssign
            ? new CircularProgressIndicator()
            : new Text(widget.viewer ? "View Form" : "Submit"),
        backgroundColor:
            (widget.viewer || enableSubmit) ? colorTheme2 : colorTheme3,
        onPressed: () {
          if (widget.viewer) {
            var page = new ComplaintPDF(
                id: widget.id,
                transactionNo: widget.taskNo,
                viewer: widget.viewer,
                checkpoint: checkpoint);
            Navigator.of(context)
                .push(new MaterialPageRoute(
                  builder: (BuildContext context) => page,
                ))
                .then((value) => _fetch());
          } else if (widget.taskStatus == "Assign" ||
              widget.taskStatus == "Revisit" ||
              widget.taskStatus == "WR Reassign") {
            if (enableSubmit) {
              setState(() => loadingAssign = true);
              Provider provider = Provider();
              provider
                  .post(
                      url: "/api/m_wo.php",
                      body: {"action": "submit_assign", "woTaskId": widget.id})
                  .then((_) {
                    var dialog = CustomDialog(
                      rootPage: "/workorder",
                      title: "Assignation Completed",
                      description:
                          "Assignation technician has succesful updated.",
                      buttonText: "Okay",
                      image: Image.asset(
                        "assets/icon_trans.png",
                        height: 40,
                      ),
                    );

                    showDialog(
                        context: context,
                        builder: (BuildContext context) => dialog);
                  })
                  .catchError((err) => Toast.show(err))
                  .whenComplete(() => setState(() => loadingAssign = true));
            } else {
              Toast.show("All sections must be completed before submit",
                  duration: 1);
            }
          } else {
            if (enableSubmit) {
              var page = new ComplaintPDF(
                  id: widget.id,
                  transactionNo: widget.taskNo,
                  viewer: widget.viewer,
                  checkpoint: checkpoint);
              Navigator.of(context)
                  .push(new MaterialPageRoute(
                    builder: (BuildContext context) => page,
                  ))
                  .then((value) => _fetch());
            } else {
              Toast.show("All sections must be completed before submit",
                  duration: 1);
            }
          }
        });
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
                getTitle(widget.siteName, bold: true),
                Text(
                  widget.taskNo,
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.left,
                ),
              ])),
      body: responseValue == null
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetch,
              child: ListView.separated(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  separatorBuilder: (context, index) =>
                      Divider(color: Colors.black),
                  itemCount: titles.length,
                  itemBuilder: (context, item) {
                    var value = listStatus[item];
                    return tile(item, value);
                  })),
      floatingActionButton: (widget.viewer == false && checkpoint != 1)
          ? Padding(
              padding: EdgeInsets.all(8),
              child: widget.isComplaintProgress || widget.isAssign
                  ? floatingButton
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        widget.viewer ? Container() : rejectButton,
                        if (widget.taskStatus == "") SizedBox(width: 12),
                        floatingButton
                      ],
                    ),
            )
          : floatingButton,
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

  Widget tile(int item, String statusDesc) => ListTile(
      title: new Row(children: <Widget>[
        new Expanded(child: getTitle(titles[item])),
        status(statusDesc)
      ]),
      trailing: new Icon(Icons.arrow_right),
      onTap: () {
        Object object;

        if (item == 0)
          object = ComplaintSectionA(
            id: widget.id,
            viewer: widget.viewer,
          );
        else if (widget.taskStatus == "Rejected" ||
            widget.taskStatus == "WR Verified" ||
            widget.taskStatus == "WR Re-Open")
          object = ComplaintSectionE(comment, "C");
        else if (item == 1 &&
            (widget.taskStatus == "Assign" ||
                widget.taskStatus == "Revisit" ||
                widget.taskStatus == "WR Reassign"))
          object = ComplaintAssign(
            id: widget.id,
            viewer: widget.viewer ? true : checkpoint == 1,
          );
        else if (item == 1 && widget.taskStatus != "Assign")
          object = ComplaintSectionB(
            id: widget.id,
            viewer: widget.viewer ? true : checkpoint == 1,
          );
        else if (widget.taskStatus == "Revisit" ||
            widget.taskStatus == "WR Reassign")
          object = ComplaintSectionE(comment, "C");
        else if (item == 2)
          object = ComplaintSectionC(
            widget.id,
            widget.viewer ? true : checkpoint == 1,
          );
        else if (item == 3 && titles[item] == "D. Asset No")
          object = ComplaintSectionD(
            id: widget.id,
            viewer: widget.viewer ? true : checkpoint == 1,
          );
        else
          object = ComplaintSectionE(comment ?? "", "C");

        Navigator.of(context)
            .push(new MaterialPageRoute(
          builder: (BuildContext context) => object,
        ))
            .then((_) {
          _fetch();
        });
      });

  void postReject(String text) {
    var body = UploadItem(
        action: widget.taskStatus == "Assign"
            ? "reject_complaint"
            : widget.taskStatus == "WR Verified"
                ? "return_by_verifier"
                : "return_by_technician",
        id: widget.id,
        remark: text);

    Provider provider = Provider();

    provider.context = context;

    provider
        .post(url: "/api/m_wo.php", body: body.body)
        .then((value) => alert(value))
        .catchError((err) => alert(err));
  }

  void alert(String txt) {
    showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
            rootPage: "/workorder",
            description: txt,
            buttonText: "Okay",
            image: Image.asset(
              "assets/icon_trans.png",
              height: 40,
            )));
  }

  bool get enableSubmit {
    // var statusList = responseValue.statusList;
    // var list = statusList.map((f)=> f.ppmTaskSectionStatus).toList();
    bool check = true;
    for (String f in listStatus) {
      if (f != "Info" && f != "Invalid" && f != "Valid" && f != "Completed")
        return false;
    }

    return check;
  }
}

class UploadItem extends Upload {
  final String remark;

  UploadItem({
    String id,
    String action,
    this.remark,
  }) : super(ppmTaskId: id, action: action);

  @override
  Map<String, dynamic> get body => {
        "action": action,
        "woTaskId": ppmTaskId,
        "remark": remark,
      };
}

import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/WorkOrder/complaintSection_v2.dart';
import 'package:gfm_gems/model/workorder.dart';
import 'package:gfm_gems/utils/reference.dart';

typedef Future<void> VoidCallback();

class ComplaintList extends StatelessWidget {
  final VoidCallback refresh;
  final bool viewer;
  final List<WorkOrderTask> list;

  ComplaintList({required this.refresh, required this.viewer, required this.list});

  @override
  Widget build(BuildContext context) {
    Widget getTitle(String text, {bold = false}) => new Container(
        alignment: Alignment.centerLeft,
        child: new Text(text,
            style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal)));

    Widget status(String value) {
      var text = value;
      var color = colorTheme1;

      if (text == "In Progress")
        color = colorTheme5;
      else if (text == "Assign")
        color = colorTheme1;
      else if (text == "Completed")
        color = colorTheme2;
      else if (text == "Verify")
        color = colorTheme3;
      else if (text == "Rejected") color = colorTheme4;

      return new Container(
          alignment: Alignment.center,
          height: 30.0,
          width: 140.0,
          decoration: BoxDecoration(
              color: color, borderRadius: new BorderRadius.circular(20.0)),
          child: new Text(text,
              style: TextStyle(
                color: Colors.white,
              )));
    }

    ListTile tile(WorkOrderTask task) => new ListTile(
          contentPadding: EdgeInsets.all(12),
          title: new Row(
            children: <Widget>[
              new Expanded(
                  child: new Column(
                children: <Widget>[
                  getTitle(task.woTaskNo, bold: true),
                  getTitle(task.woTaskType),
                  getTitle(task.woTaskTimeCreated),
                  getTitle(task.reportedBy),
                  getTitle(task.woTaskSeverity),
                ],
              )),
              status(task.woTaskStatus)
            ],
          ),
          onTap: () {
            Widget page = new ComplaintSection(
              id: task.woTaskId,
              siteName: task.reportedBy,
              taskNo: task.woTaskNo,
              taskStatus: task.woTaskStatus,
              viewer: this.viewer,
              isComplaintProgress: (task.woTaskType == "Client Complaint" &&
                  task.woTaskStatus == "In Progress"),
              isAssign: (task.woTaskStatus == "Assign" ||
                  task.woTaskStatus == "Revisit" ||
                  task.woTaskStatus == "WR Reassign"),
            );

            Navigator.of(context)
                .push(new MaterialPageRoute(
                    builder: (BuildContext context) => page))
                .then((onValue) => refresh);
          },
        );

    return RefreshIndicator(
        onRefresh: refresh,
        child: ListView.separated(
          padding: EdgeInsets.all(12),
          itemCount: list.length,
          itemBuilder: (context, index) => tile(list[index]),
          separatorBuilder: (context, index) {
            return Divider();
          },
        ));
  }
}

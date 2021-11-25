import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/WorkOrder/bloc/mainBloc.dart';
import 'package:gfm_gems/model/workorder.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:gfm_gems/view/dialog.dart';
import 'package:toast/toast.dart';

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
  _ComplaintSectionState createState() =>
      _ComplaintSectionState(id, taskStatus, taskNo);
}

class _ComplaintSectionState extends State<ComplaintSection> {
  final MainBloc _bloc;

  _ComplaintSectionState(String id, String status, String taskNo)
      : this._bloc = MainBloc(id: id, status: status, taskNo: taskNo);

  @override
  Widget build(BuildContext context) {
    final button = _BuildStandardButton(
      _bloc,
      widget.viewer,
      widget.taskStatus,
    );

    final viewButton = _BuildViewButton(
      widget.isComplaintProgress,
      widget.isAssign,
      widget.viewer,
      widget.taskStatus,
      button,
      _bloc.reject,
      alert,
    );

    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: colorTheme3),
          backgroundColor: Colors.white,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.siteName),
              Text(widget.taskNo, style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
        body: StreamBuilder<List<WorkOrderStatus>>(
          stream: _bloc.sections$,
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: _bloc.refresh,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 12),
                itemCount: snapshot.data.length,
                separatorBuilder: (_, __) => Divider(),
                itemBuilder: (_, index) => _buildTile(
                  snapshot.data[index],
                  () => _bloc.openScreen(
                    context,
                    snapshot.data[index],
                    viewOnly: widget.viewer,
                  ),
                ),
              ),
            );
          },
        ),
        floatingActionButton: widget.viewer == false && _bloc.checkpoint != 1
            ? viewButton
            : button);
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
}

// ignore: camel_case_types
class _buildTile extends StatelessWidget {
  final WorkOrderStatus object;
  final Function openScreen;

  const _buildTile(this.object, this.openScreen);

  @override
  Widget build(BuildContext context) {
    final status = object.sectionStatus;
    var color;
    if (status == "Info")
      color = colorTheme2;
    else if (status == "Pending")
      color = colorTheme4;
    else if (status == "In Progress")
      color = colorTheme1;
    else
      color = colorTheme3;

    return ListTile(
      title: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text(
          object.sectionName + ". ",
          style: TextStyle(fontWeight: FontWeight.normal, color: colorTheme3),
        ),
        Expanded(
          child: Text(
            object.sectionDesc,
            style: TextStyle(fontWeight: FontWeight.normal, color: colorTheme3),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          alignment: Alignment.center,
          height: 30.0,
          width: 130.0,
          decoration: BoxDecoration(
            color: color,
            borderRadius: new BorderRadius.circular(20.0),
          ),
          child: Text(
            status == "Pending"
                ? (object.sectionStatusMaterial ?? "") == ""
                    ? status
                    : object.sectionStatusMaterial
                : status,
            style: TextStyle(color: Colors.white, fontFamily: 'Avenir'),
            overflow: TextOverflow.clip,
          ),
        ),
      ]),
      trailing: Icon(Icons.arrow_right),
      onTap: openScreen,
    );
  }
}

class _BuildViewButton extends StatelessWidget {
  final bool progress;
  final bool viewer;
  final bool isAssign;
  final String status;
  final Widget button;
  final Function(String) alert;
  final Future<void> Function(String) reject;

  _BuildViewButton(
    this.progress,
    this.isAssign,
    this.viewer,
    this.status,
    this.button,
    this.reject,
    this.alert,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: progress || isAssign
          ? button
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                viewer
                    ? Container()
                    : _BuildRejectButton(status, reject, alert),
                // if (status == "")
                SizedBox(width: 12),
                button
              ],
            ),
    );
  }
}

// ignore: unused_element
class _BuildRejectButton extends StatelessWidget {
  final String label;
  final Function(String) alert;
  final Future<void> Function(String) reject;

  _BuildRejectButton(String s, this.reject, this.alert)
      : this.label = s == "Assign"
            ? "Reject"
            : s == "WR Verified"
                ? "Re-Open"
                : "Revisit";

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
        heroTag: "reject_button",
        label: new Text(label),
        backgroundColor: Colors.red,
        onPressed: () => showDialog(context: context, builder: _buildDialog));
  }

  Widget _buildDialog(BuildContext context) {
    return CustomDialog(
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
      image: Image.asset("assets/icon_trans.png", height: 40),
      remarkTapped: (text) {
        Navigator.pop(context);
        reject(text).then(alert).catchError(alert);
      },
    );
  }
}

class _BuildStandardButton extends StatelessWidget {
  final MainBloc bloc;
  final bool viewOnly;
  final String mainStatus;

  _BuildStandardButton(this.bloc, this.viewOnly, this.mainStatus);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: bloc.enable$,
        builder: (context, snapshot) {
          return FloatingActionButton.extended(
              heroTag: "accept_button",
              label: StreamBuilder(
                stream: bloc.loading$,
                builder: (_, loadingSnapshot) => loadingSnapshot.data == false
                    ? new Text(viewOnly ? "View Form" : "Submit")
                    : new CircularProgressIndicator(),
              ),
              backgroundColor: (viewOnly || (snapshot.data ?? false))
                  ? colorTheme2
                  : colorTheme3,
              onPressed: () {
                if (viewOnly) {
                  bloc.openComplaint(context, viewOnly: viewOnly);
                } else if (mainStatus == "Assign" ||
                    mainStatus == "Revisit" ||
                    mainStatus == "WR Reassign") {
                  if (snapshot.data) {
                    bloc.submit().then((_) {
                      showDialog(context: context, builder: _buildDialog);
                    }).catchError((err) => Toast.show(err, context));
                  } else {
                    Toast.show(
                        "All sections must be completed before submit", context,
                        duration: 1);
                  }
                } else {
                  if (snapshot.data) {
                    bloc.openComplaint(context, viewOnly: viewOnly);
                  } else {
                    Toast.show(
                      "All sections must be completed before submit",
                      context,
                      duration: 1,
                    );
                  }
                }
              });
        });
  }

  Widget _buildDialog(_) {
    return CustomDialog(
      rootPage: "/workorder",
      title: "Assignation Completed",
      description: "Assignation technician has succesful updated.",
      buttonText: "Okay",
      image: Image.asset(
        "assets/icon_trans.png",
        height: 40,
      ),
    );
  }
}

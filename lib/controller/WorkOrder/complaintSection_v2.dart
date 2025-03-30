import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/WorkOrder/bloc/mainBloc.dart';
import 'package:gfm_gems/model/execution.dart';
import 'package:gfm_gems/model/user.dart';
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

  const ComplaintSection({
    Key? key,
    required this.id,
    required this.taskNo,
    required this.siteName,
    required this.taskStatus,
    required this.viewer,
    this.isAssign = false,
    this.isComplaintProgress = false,
  }) : super(key: key);

  @override
  _ComplaintSectionState createState() =>
      _ComplaintSectionState();
}

class _ComplaintSectionState extends State<ComplaintSection> {
  late final MainBloc _bloc;
  bool showtime = false;
  bool _blocInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize the bloc once, now that context is available.
    if (!_blocInitialized) {
      _bloc = MainBloc(
        id: widget.id,
        status: widget.taskStatus,
        taskNo: widget.taskNo,
        context: context,
      );
      _blocInitialized = true;
      // Now do your user preference check.
      User.getPrefUser.then((value) {
        final User user = User.fromMap(value);
        final List<String> roles = user.roles.map((role) => role.desc).toList();
        if (roles.contains("WO Executor") && mounted) {
          setState(() {
            showtime = true;
          });
        }
      });
    }
  }

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
            Text(
              widget.siteName,
              style: TextStyle(color: colorTheme3),
            ),
            Text(
              widget.taskNo,
              style: TextStyle(fontSize: 16, color: colorTheme3),
            ),
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
              padding: EdgeInsets.only(top: 12, bottom: 120),
              itemCount: snapshot.data!.length + (showtime ? 1 : 0),
              separatorBuilder: (_, __) => Divider(),
              itemBuilder: (_, index) {
                if (index == 0 && showtime) {
                  return _TimeDuration(stream: _bloc.execution$);
                }
                final int dataIndex = index - (showtime ? 1 : 0);
                return _buildTile(
                  snapshot.data![dataIndex],
                  () => _bloc.openScreen(
                    context,
                    snapshot.data![dataIndex],
                    viewOnly: widget.viewer,
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: (!widget.viewer && _bloc.checkpoint != 1)
          ? viewButton
          : button,
    );
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

    final String materialStatus = object.sectionStatusMaterial ?? "";
    final String displayStatus = (status == "Pending"
        ? (materialStatus.isEmpty ? status : materialStatus)
        : status) as String;

    return ListTile(
      title: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text(
          object.sectionName ?? '' + ". ",
          style: TextStyle(fontWeight: FontWeight.normal, color: colorTheme3),
        ),
        Expanded(
          child: Text(
            object.sectionDesc ?? '',
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
            displayStatus,
            style: TextStyle(color: Colors.white, fontFamily: 'Avenir'),
            overflow: TextOverflow.clip,
          ),
        ),
      ]),
      trailing: Icon(Icons.arrow_right),
      onTap: openScreen as void Function()?,
    );
  }
}

class _buildTempTile extends StatelessWidget {
  final String title;
  final String status;
  final Function openScreen;

  const _buildTempTile(this.title, this.status, this.openScreen);

  @override
  Widget build(BuildContext context) {
    var color = colorTheme4;

    return ListTile(
      title: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text(
          "F. ",
          style: TextStyle(fontWeight: FontWeight.normal, color: colorTheme3),
        ),
        Expanded(
          child: Text(
            title,
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
            status,
            style: TextStyle(color: Colors.white, fontFamily: 'Avenir'),
            overflow: TextOverflow.clip,
          ),
        ),
      ]),
      trailing: Icon(Icons.arrow_right),
      onTap: openScreen as void Function()?,
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
        reject(text).then((_) => alert("Operation successful")).catchError(alert);
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
    ToastContext().init(context);
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
                  if (snapshot.data != null && snapshot.data!) {
                    bloc.submit().then((_) {
                      showDialog(context: context, builder: _buildDialog);
                    }).catchError((err) => Toast.show(err));
                  } else {
                    Toast.show("All sections must be completed before submit",
                        duration: 1);
                  }
                } else {
                  if (snapshot.data != null && snapshot.data!) {
                    bloc.openComplaint(context, viewOnly: viewOnly);
                  } else {
                    Toast.show("All sections must be completed before submit",
                        duration: 1);
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

class _TimeDuration extends StatelessWidget {
  final Stream<ExecutionModel> stream;
  _TimeDuration({required Stream<ExecutionModel> stream})
      : this.stream = stream;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: StreamBuilder<ExecutionModel>(
          stream: stream,
          builder: (context, snapshot) {
            final String maxReponse = snapshot.data?.responseTimeSla ?? "0";
            final String remainReponse = snapshot.data?.responseTimeDue ?? "0";
            final String assignTime = snapshot.data?.assignTime ?? "0";
            final String executeTime = snapshot.data?.execute ?? "0";
            final String maxCompletion =
                snapshot.data?.completionTimeSla ?? "0";
            final String remainCompletion =
                snapshot.data?.completionTimeDue ?? "0";
            final bool exceedResponse =
                snapshot.data?.responseTimeExceeded ?? false;
            final bool exceedCompletion =
                snapshot.data?.completionTimeExceeded ?? false;
            return Table(
              children: [
                TableRow(children: [
                  _text("Response Time", isBold: true),
                  _text("Completion Time", isBold: true),
                ]),
                TableRow(children: [
                  _text("SLA Time :", isTitle: true),
                  _text("SLA Time :", isTitle: true),
                ]),
                TableRow(children: [
                  _text(maxReponse, isRed: exceedResponse),
                  _text(maxCompletion, isRed: exceedCompletion),
                ]),
                TableRow(children: [
                  _text("Time Due :", isTitle: true),
                  _text("Time Due :", isTitle: true),
                ]),
                TableRow(children: [
                  _text(remainReponse, isRed: exceedResponse),
                  _text(remainCompletion, isRed: exceedCompletion),
                ]),
                TableRow(children: [
                  _text("Assigned Time :", isTitle: true),
                  _text("Execute Time :", isTitle: true),
                ]),
                TableRow(children: [
                  _text(assignTime, isRed: exceedResponse),
                  _text(executeTime, isRed: exceedCompletion),
                ]),
              ],
            );
          }),
    );
  }

  Widget _text(String value,
      {bool isBold = false, bool isRed = false, isTitle = false}) {
    return TableCell(
      child: Padding(
        padding: EdgeInsets.only(
          top: isTitle ? 12 : 3,
          left: 3,
          right: 3,
          bottom: 3,
        ),
        child: Text(
          value,
          style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isRed ? colorTheme4 : colorTheme3),
        ),
      ),
    );
  }
}

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
  _ComplaintSectionState createState() => _ComplaintSectionState();
}

class _ComplaintSectionState extends State<ComplaintSection> {
  late final MainBloc _bloc;
  bool showtime = false;
  bool _blocInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize the bloc only once since context is now available.
    if (!_blocInitialized) {
      debugPrint("Bloc initialized");
      debugPrint("ID: ${widget.id}");
      debugPrint("Status: ${widget.taskStatus}");
      debugPrint("Task No: ${widget.taskNo}");
      debugPrint("Viewer: ${widget.viewer}");
      _bloc = MainBloc(
        id: widget.id,
        status: widget.taskStatus,
        taskNo: widget.taskNo,
        context: context,
      );
      _blocInitialized = true;
      // Check user preferences to decide if the time view should be shown.
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
    final Widget standardButton = _BuildStandardButton(
      _bloc,
      widget.viewer,
      widget.taskStatus,
    );

    final Widget viewButton = _BuildViewButton(
      widget.isComplaintProgress,
      widget.isAssign,
      widget.viewer,
      widget.taskStatus,
      standardButton,
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
            child: ListView.builder(
              padding: EdgeInsets.only(top: 12, bottom: 120),
              itemCount: snapshot.data!.length + (showtime ? 1 : 0),
              // separatorBuilder: (_, __) => Divider(),
              itemBuilder: (_, index) {
                if (index == 0 && showtime) {
                  return _TimeDuration(stream: _bloc.execution$);
                }
                final int dataIndex = index - (showtime ? 1 : 0);
                return BuildTile(
                  workOrderStatus: snapshot.data![dataIndex],
                  onTap: () => _bloc.openScreen(
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
      // Toggle between view button and standard button based on viewer flag and checkpoint
      floatingActionButton: (!widget.viewer && _bloc.checkpoint != 1)
          ? viewButton
          : standardButton,
    );
  }

  void alert(String txt) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        rootPage: "/workorder",
        description: txt,
        buttonText: "Okay",
        image: Image.asset("assets/icon_trans.png", height: 40),
      ),
    );
  }
}

///
/// A refined list item that shows a complaint/section using a Card and Chip
///
class BuildTile extends StatelessWidget {
  final WorkOrderStatus workOrderStatus;
  final VoidCallback onTap;

  const BuildTile({
    Key? key,
    required this.workOrderStatus,
    required this.onTap,
  }) : super(key: key);

  // Map your status to the primary status color
  Color _getStatusColor(String? status) {
    switch (status) {
      case "Info":
        return colorTheme2;
      case "Pending":
        return colorTheme4;
      case "In Progress":
        return colorTheme1;
      default:
        return colorTheme3;
    }
  }

  Color _getBgStatusColor(String? status) {
    switch (status) {
      case "Info":
        return colorTheme2Light;
      case "Pending":
        return colorTheme4Light;
      case "In Progress":
        return colorTheme1;
      default:
        return colorTheme3Light;
    }
  }

  // Handle Pending → Material override
  String _getDisplayStatus(String? status, String? materialStatus) {
    if (status == "Pending" && materialStatus != null && materialStatus.isNotEmpty)
      return materialStatus;
    return status ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final String status = _getDisplayStatus(
      workOrderStatus.sectionStatus,
      workOrderStatus.sectionStatusMaterial,
    );
    final Color statusColor = _getStatusColor(workOrderStatus.sectionStatus);
    // Light tint for the card background
    final Color cardColor = _getBgStatusColor(workOrderStatus.sectionStatus);

    // Build the “B. Assign Executor” style title
    final String title = [
      if (workOrderStatus.sectionName != null) "${workOrderStatus.sectionName}.",
      if (workOrderStatus.sectionDesc != null) workOrderStatus.sectionDesc
    ].join(' ');

    return Card(
      color: cardColor,
      borderOnForeground: true,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Leading icon tinted by status
              Icon(Icons.assignment, color: statusColor),
              const SizedBox(width: 12),

              // Title + Status vertically stacked
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bigger, bold title

                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorTheme3,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Smaller status text
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Keep the arrow for affordance
              const Icon(Icons.arrow_right, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }
}

///
/// A temporary tile that follows a similar style as BuildTile (if needed).
///
class _BuildTempTile extends StatelessWidget {
  final String title;
  final String status;
  final VoidCallback onTap;

  const _BuildTempTile(
    this.title,
    this.status,
    this.onTap, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color statusColor = colorTheme4;
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Text(
                "F. ",
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  color: colorTheme3,
                ),
              ),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: colorTheme3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Chip(
                label: Text(
                  status,
                  style: TextStyle(color: Colors.white, fontFamily: 'Avenir'),
                ),
                backgroundColor: statusColor,
              ),
              const Icon(
                Icons.arrow_right,
                color: Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

///
/// The view button widget which conditionally displays a reject button alongside the standard button.
///
class _BuildViewButton extends StatelessWidget {
  final bool progress;
  final bool isAssign;
  final bool viewer;
  final String status;
  final Widget button;
  final Future<void> Function(String) reject;
  final Function(String) alert;

  const _BuildViewButton(
    this.progress,
    this.isAssign,
    this.viewer,
    this.status,
    this.button,
    this.reject,
    this.alert, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: progress || isAssign
          ? button
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (!viewer) _BuildRejectButton(status, reject, alert),
                const SizedBox(width: 12.0),
                button,
              ],
            ),
    );
  }
}

///
/// A floating action button allowing the user to reject/revisit a complaint.
///
class _BuildRejectButton extends StatelessWidget {
  final String label;
  final Function(String) alert;
  final Future<void> Function(String) reject;

  _BuildRejectButton(
    String status,
    this.reject,
    this.alert, {
    Key? key,
  })  : label = status == "Assign"
            ? "Reject"
            : status == "WR Verified"
                ? "Re-Open"
                : "Revisit",
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: "reject_button",
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.red,
      onPressed: () => showDialog(
        context: context,
        builder: _buildDialog,
      ),
    );
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
      },
      image: Image.asset("assets/icon_trans.png", height: 40),
      remarkTapped: (text) {
        Navigator.pop(context);
        reject(text)
            .then((_) => alert("Operation successful"))
            .catchError(alert);
      },
    );
  }
}

///
/// The standard button widget which toggles between a loading indicator and text depending on the stream.
///
class _BuildStandardButton extends StatelessWidget {
  final MainBloc bloc;
  final bool viewOnly;
  final String mainStatus;

  const _BuildStandardButton(
    this.bloc,
    this.viewOnly,
    this.mainStatus, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return StreamBuilder<bool>(
      stream: bloc.enable$,
      builder: (context, snapshot) {
        return FloatingActionButton.extended(
          heroTag: "accept_button",
          label: StreamBuilder<bool>(
            stream: bloc.loading$,
            builder: (_, loadingSnapshot) => loadingSnapshot.data == false
                ? Text(
                    viewOnly ? "View Form" : "Submit",
                    style: const TextStyle(color: Colors.white),
                  )
                : const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
          ),
          backgroundColor:
              (viewOnly || (snapshot.data ?? false)) ? colorTheme2 : colorTheme3,
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
          },
        );
      },
    );
  }

  Widget _buildDialog(BuildContext context) {
    return CustomDialog(
      rootPage: "/workorder",
      title: "Assignation Completed",
      description: "Assignation technician has successfully updated.",
      buttonText: "Okay",
      image: Image.asset(
        "assets/icon_trans.png",
        height: 40,
      ),
    );
  }
}

///
/// A widget that displays time details in a table layout.
///
class _TimeDuration extends StatelessWidget {
  final Stream<ExecutionModel> stream;
  const _TimeDuration({Key? key, required this.stream}) : super(key: key);

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
          final String maxCompletion = snapshot.data?.completionTimeSla ?? "0";
          final String remainCompletion = snapshot.data?.completionTimeDue ?? "0";
          final bool exceedResponse = snapshot.data?.responseTimeExceeded ?? false;
          final bool exceedCompletion = snapshot.data?.completionTimeExceeded ?? false;
          return Table(
            children: [
              TableRow(children: [
                _buildTableText("Response Time", isBold: true),
                _buildTableText("Completion Time", isBold: true),
              ]),
              TableRow(children: [
                _buildTableText("SLA Time :", isTitle: true),
                _buildTableText("SLA Time :", isTitle: true),
              ]),
              TableRow(children: [
                _buildTableText(maxReponse, isRed: exceedResponse),
                _buildTableText(maxCompletion, isRed: exceedCompletion),
              ]),
              TableRow(children: [
                _buildTableText("Time Due :", isTitle: true),
                _buildTableText("Time Due :", isTitle: true),
              ]),
              TableRow(children: [
                _buildTableText(remainReponse, isRed: exceedResponse),
                _buildTableText(remainCompletion, isRed: exceedCompletion),
              ]),
              TableRow(children: [
                _buildTableText("Assigned Time :", isTitle: true),
                _buildTableText("Execute Time :", isTitle: true),
              ]),
              TableRow(children: [
                _buildTableText(assignTime, isRed: exceedResponse),
                _buildTableText(executeTime, isRed: exceedCompletion),
              ]),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTableText(String value,
      {bool isBold = false, bool isRed = false, bool isTitle = false}) {
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
            color: isRed ? colorTheme4 : colorTheme3,
          ),
        ),
      ),
    );
  }
}

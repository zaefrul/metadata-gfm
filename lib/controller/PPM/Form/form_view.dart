import 'package:flutter/material.dart';
import 'package:GEMS/controller/PPM/Form/pdf.dart';
import 'package:GEMS/model/execution.dart';
import 'package:GEMS/model/responseValue.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:toast/toast.dart';
import 'package:GEMS/model/form.dart' as formModel;

import 'add_technician.dart';
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
  final VoidCallback refresh;
  final bool viewer;

  const FormView({
    required this.id,
    required this.siteName,
    required this.taskNo,
    required this.taskStatus,
    required this.refresh,
    this.viewer = false,
    super.key,
  });

  @override
  _FormViewState createState() => _FormViewState(id: id);
}

class _FormViewState extends State<FormView> {
  List<String> allStatus = [];
  final Map<String, String> titles = {
    "A": "A. Asset Details",
    "B":
        "B. Safety Precaution / General Guidline prior to maintenance activity",
    "C": "C. Qualitative Task",
    "D": "D. Quantitative Task",
    "E": "E. Spare Parts / Material Used",
    "F": "F. Additional Reports",
    "G": "G. Comments / Remarks",
    "H": "H. Maintenance Image",
    "I": "I. Executor",
  };

  late Provider provider;
  final String id;
  bool verified = true;
  bool fieldDisable = true;
  ResponseValue? responseValue;
  List<String> statusList = [];
  int checkpoint = 1;

  _FormViewState({required this.id});

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
    if (widget.taskStatus == "In Progress" ||
        widget.taskStatus == "Re-Open") {
      fieldDisable = false;
    }

    if (widget.viewer) fieldDisable = true;

    provider = Provider(
      taskID: widget.id,
      fetchURL: "/ppm_v2/ppm_section_status/",
    );

    refreshStatus();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    provider.context = context;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: colorTheme3),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            getTitle(widget.siteName, bold: true),
            Text(
              widget.taskNo,
              style: TextStyle(fontSize: 16, color: colorTheme3),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
      body: responseValue == null
    ? Center(child: CircularProgressIndicator())
    : RefreshIndicator(
        onRefresh: refreshStatus,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: statusList.length + 1,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, item) {
                  if (item == 0) {
                    return FutureBuilder<ExecutionModel>(
                      future: _time,
                      builder: (context, snapshot) {
                        final String max = snapshot.data?.max ?? "0";
                        final String min = snapshot.data?.min ?? "0";
                        final bool exceed = snapshot.data?.exceed ?? false;
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Min Time Allocated : $min",
                                style: TextStyle(color: exceed ? Colors.red : Colors.black),
                              ),
                              SizedBox(height: 12),
                              Text("Max Time Allocated : $max"),
                            ],
                          ),
                        );
                      },
                    );
                  }

                  formModel.Form form = responseValue?.statusList != null
                      ? responseValue!.statusList![item - 1]
                      : formModel.Form();
                  return tile(
                    form.ppmTaskSectionName,
                    form.ppmTaskSectionStatus,
                    form.checkParts,
                    form.checkAdditionalReport,
                  );
                },
              ),

              // Bottom Submit Button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                child: ElevatedButton.icon(
                  icon: Icon(widget.viewer ? Icons.visibility : Icons.send, 
                      color: (widget.viewer || enableSubmit)
                        ? AppColors.white
                        : AppColors.dark),
                  label: Text(widget.viewer ? "View Form" : "Submit", 
                      style: TextStyle(color: (widget.viewer || enableSubmit)
                        ? AppColors.white
                        : AppColors.dark)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (widget.viewer || enableSubmit)
                        ? AppColors.primary
                        : AppColors.secondaryLight,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: (widget.viewer || enableSubmit)
                      ? () {
                          var page = PDF(
                            id: widget.id,
                            transactionNo: widget.taskNo,
                            viewer: widget.viewer,
                            checkpoint: checkpoint,
                            submitted: () {
                              widget.refresh();
                              fieldDisable = true;
                            },
                          );
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => page,
                          ));
                        }
                      : () {
                          if (!verified) {
                            Toast.show(
                              "To get started, you need to scan the QR code of the asset from section A. Asset Details.",
                              duration: 3,
                            );
                          } else {
                            Toast.show(
                              "All sections must be completed before submit",
                              duration: 1,
                            );
                          }
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getTitle(String text, {bool bold = false, double? size}) => Container(
        padding: EdgeInsets.only(top: 3),
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: colorTheme3,
          ),
        ),
      );

  Widget status(String text) {
    Color color;
    if (text == "Info") {
      color = colorTheme2;
    } else if (text == "Pending") {
      color = colorTheme4;
    } else if (text == "In Progress") {
      color = colorTheme1;
    } else {
      color = colorTheme3;
    }

    return Container(
      alignment: Alignment.center,
      height: 30.0,
      width: 100.0,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontFamily: 'Avenir'),
      ),
    );
  }

  Widget tile(String item, String statusDesc, String parts, String report) {
    final Color accent = _getStatusColor(statusDesc);
    final Color bgColor = _getStatusCardColor(statusDesc);
    final String title = titles[item] ?? 'Section';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: InkWell(
        onTap: () => _openFormSection(item, parts, report),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            // Accent stripe
            Container(
              width: 6,
              height: 72,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Section icon
            Icon(Icons.assignment, color: accent),
            const SizedBox(width: 12),

            // Title and Status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusDesc,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: accent,
                    ),
                  ),
                ],
              ),
            ),

            Icon(Icons.chevron_right, color: Colors.black38),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case "Info":
        return AppColors.info;
      case "Pending":
        return AppColors.danger;
      case "In Progress":
        return AppColors.primary;
      case "Completed":
        return AppColors.success;
      default:
        return AppColors.secondary;
    }
  }

  Color _getStatusCardColor(String? status) {
    switch (status) {
      case "Info":
        return AppColors.infoLight;
      case "Pending":
        return AppColors.dangerLight;
      case "In Progress":
        return AppColors.primaryLight;
      case "Completed":
        return AppColors.successLight;
      default:
        return AppColors.secondaryLight;
    }
  }

  void _openFormSection(String item, String parts, String report) {
    Object object = Container(); // default fallback

    if (item == "A") {
      object = FormA(
        id,
        verification: (bool status) {
          setState(() {
            verified = status;
            fieldDisable = !status;
          });
        },
        viewer: widget.viewer,
        verified: verified,
      );
    } else if (item == "B") {
      object = FormB(id);
    } else if (item == "C") {
      object = FormC(id, verified, (_) => refreshStatus(), fieldDisable);
    } else if (item == "D") {
      object = FormD(id, verified, () => refreshStatus(), fieldDisable);
    } else if (item == "E") {
      object = FormE(id, verified, () => refreshStatus(), fieldDisable, parts);
    } else if (item == "F") {
      object = FormF(id, verified, () => refreshStatus(), fieldDisable, report);
    } else if (item == "G") {
      object = FormG(id, verified, (_) => refreshStatus(), fieldDisable);
    } else if (item == "H") {
      object = FormH(id, verified, (_) => refreshStatus(), fieldDisable);
    } else if (item == "I") {
      object = PPMAddTechnician(id, verified, () => refreshStatus(), fieldDisable);
    }

    Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => object as Widget))
      .whenComplete(() => refreshStatus());
  }

  bool get enableSubmit {
    for (String f in statusList) {
      if (f != "Info" && f != "Completed") return false;
    }
    return true;
  }

  Future<void> refreshStatus() async {
    var value = await provider.fetch();
    setState(() {
      responseValue = value;
      var result = responseValue!.statusList != null
          ? responseValue!.statusList!.map((f) => f.ppmTaskSectionStatus).toList()
          : [];
      statusList = result.cast<String>();
    });
  }

  Future<ExecutionModel> get _time async {
    try {
      final future = await Provider(
        fetchURL: '/ppm_v2/execution_info/',
        taskID: widget.id,
      ).getJson(url: '/ppm_v2/execution_info/');
      final model = ExecutionModel.fromJson(future);
      return model;
    } catch (err) {
      rethrow;
    }
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:gfm_gems/controller/PPM/Form/form_view.dart';
import 'package:gfm_gems/controller/WorkOrder/complaintSection_v2.dart';
import 'package:gfm_gems/model/monitor.dart';
// import 'package:gfm_gems/model/responseValue.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:gfm_gems/main.dart';

class TaskInformation extends StatelessWidget {
  final MonitorTask task;
  final Provider _provider;

  TaskInformation({Key? key, required this.task})
      : _provider = Provider(
          fetchURL:
              "/api/m_ppm.php?type=tnm_details&transactionId=${task.transactionId}",
        ),
        super(key: key);

  Future<MonitorDetail> get _detail async {
    _provider.context = navigatorKey.currentContext!;
    final raw = await _provider.fetch();
    final detail = raw.monitorDetail;
    if (detail == null) throw Exception("No monitorDetail");
    // sometimes it's a Map:
    if (detail is MonitorDetail) return detail;
    return MonitorDetail.fromJson(jsonEncode(detail));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Task Information",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: FutureBuilder<MonitorDetail>(
        future: _detail,
        builder: (ctx, snap) {
          if (snap.hasError) {
            return Center(child: Text(snap.error.toString()));
          }
          if (!snap.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return _buildBody(context, snap.data!);
        },
      ),
    );
  }

  Widget _buildProgressStepper(BuildContext context, int percent, bool isWO) {
    // 1) Define your steps
    final steps = [
      {
        "icon": isWO ? Icons.assignment_ind     : Icons.play_circle_fill,
        "label": isWO ? "Assign WO"              : "Execute PPM",
      },
      {
        "icon": isWO ? Icons.build               : Icons.check_circle_outline,
        "label": isWO ? "Execute WO"             : "Check PPM",
      },
      {
        "icon": isWO ? Icons.verified            : Icons.verified_user,
        "label": isWO ? "Verify WO"              : "Verify PPM",
      },
      {
        "icon": isWO ? Icons.flag                : Icons.task_alt,
        "label": isWO ? "Closed"                 : "Complete",
      },
    ];

    // figure out which step index we're on (0..3)
    final clamped = percent.clamp(0, 100);
    final currentStep = (clamped / (100 / (steps.length - 1))).floor().clamp(0, steps.length - 1);

    return Column(
      children: [
        // ── the circles + connectors ───────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: (16 * 2.5)),
          child: Row(
            children: [
              for (var i = 0; i < steps.length; i++) ...[
                //  a) the circle
                CircleAvatar(
                  radius: 20,
                  backgroundColor: i <= currentStep ? AppColors.primary : AppColors.secondaryLight,
                  child: Icon(
                    i < currentStep ? Icons.check : steps[i]["icon"] as IconData,
                    size: 18,
                    color: i <= currentStep ? Colors.white : colorTheme3,
                  ),
                ),

                // b) the connector line (except after last circle)
                if (i < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 4,
                      color: i < currentStep ? colorTheme2 : Colors.grey[300],
                    ),
                  ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 8),

        // ── the labels under each circle ────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: steps.map((step) {
              final idx = steps.indexOf(step);
              final done = idx <= currentStep;
              return Expanded(
                child: Text(
                  step["label"] as String,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: done ? colorTheme3 : Colors.grey[400],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, MonitorDetail d) {
    // compute progress
    int percent = 0;
    final st = d.checkpointId;
    if (["4", "15"].contains(st)) {
      percent = 100;
    } else if (["3", "14", "16"].contains(st)) {
      percent = 75;
    }
    else if (["2", "13"].contains(st)) {
      percent = 50;
    }
    else if (["1", "12"].contains(st)) {
      percent = 25;
    }

    return ListView(
      padding: EdgeInsets.symmetric(vertical: 24),
      children: [
        // — FLOW HEADER —
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            d.flowName,
            style: GoogleFonts.poppins(
                fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 16),

        // — TWO-COLUMN METADATA GRID —
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(
            runSpacing: 12,
            spacing: 20,
            children: [
              _metaItem("Task No", d.transactionNo),
              _metaItem("Checkpoint", d.currentStatus),
              _metaItem("Initiated By", d.initiateBy),
              _metaItem("By Group", d.initiateByGroup),
              _metaItem("Initiated At", d.initiateTimeCreated),
              _metaItem("Status", d.taskStatus),
              _metaItem("Current User", d.currentUser),
              _metaItem("Received At", d.receivedTime),
              _metaItem("Flow Status", d.flowStatus),
              _metaItem("Due Date", d.flowDueDate),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // — ACTION BUTTONS —
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (d.ppmTaskId != null)
              _pillButton(
                "Open PPM",
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FormView(
                      id: d.ppmTaskId!,
                      siteName: d.siteName ?? "",
                      taskNo: d.transactionNo,
                      taskStatus: d.taskStatus,
                      refresh: () {},
                      viewer: true,
                    ),
                  ),
                ),
              ),
            if (d.woTaskId != null)
              const SizedBox(width: 12),
            if (d.woTaskId != null)
              _pillButton(
                "Open Work Order",
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ComplaintSection(
                      id: d.woTaskId!,
                      siteName: d.flowName,
                      taskNo: d.transactionNo,
                      taskStatus: d.taskStatus,
                      viewer: true,
                    ),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 32),
        Divider(),
        const SizedBox(height: 16),

        // — PROGRESS INDICATOR —
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text("Transaction History",
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 16),
        _buildProgressStepper(context, percent, d.flowName == "Work Order"),
        const SizedBox(height: 24),

        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 20),
        //   child: LinearPercentIndicator(
        //     lineHeight: 8,
        //     percent: percent / 100,
        //     backgroundColor: Colors.grey[300]!,
        //     progressColor: colorTheme2,
        //   ),
        // ),

        const SizedBox(height: 16),

        // — HISTORY ITEMS —
        ...List.generate(d.taskHistory.length, (i) {
          return _historyCard(d.taskHistory[i], i + 1);
        }),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _metaItem(String label, String value) {
    return SizedBox(
      width: (MediaQueryData.fromWindow(WidgetsBinding.instance.window)
                  .size
                  .width -
              60) /
          2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.poppins(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _pillButton(String text, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        // primary: colorTheme1,
        backgroundColor: AppColors.primaryDark,
        shape: StadiumBorder(),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      ),
      child: Text(text, style: GoogleFonts.poppins(color: Colors.white)),
      onPressed: onTap,
    );
  }

  Widget _historyCard(MonitorHistory h, int idx) {
    Color statusColor = AppColors.primaryDark;
    debugPrint("The status is ${h.taskStatus}");
    switch (h.taskStatus) {
      case "In Progress":
        statusColor = AppColors.primary;
        break;
      case "Verify":
        statusColor = AppColors.warning;
        break;
      case "Complete":
        statusColor = AppColors.success;
        break;
      case "Rejected":
        statusColor = AppColors.danger;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // header
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primaryDark,
                    child: Text("$idx",
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(h.checkpointId,
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: statusColor, borderRadius: BorderRadius.circular(20)),
                    child: Text(h.taskStatus,
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontSize: 12)),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // two-column details
              Row(
                children: [
                  Expanded(
                    child: _labelValue("Due Date", h.taskDateDue.isEmpty ? "-" : h.taskDateDue),
                  ),
                  Expanded(
                    child: _labelValue("Created", h.taskTimeCreated),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _labelValue(
                        "Submitted", h.taskTimeSubmit.isEmpty ? "—" : h.taskTimeSubmit),
                  ),
                  Expanded(
                    child: _labelValue("User", h.taskClaimedUser),
                  ),
                ],
              ),

              if (h.taskRemark.isNotEmpty) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Remark",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(h.taskRemark, style: GoogleFonts.poppins()),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _labelValue(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.poppins(fontSize: 14)),
        ],
      ),
    );
  }
}

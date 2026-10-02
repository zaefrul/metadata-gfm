import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:GEMS/view/gems_chrome.dart';
import 'package:GEMS/controller/PPM/Form/form_view.dart';
import 'package:GEMS/controller/WorkOrder/complaintSection_v2.dart';
import 'package:GEMS/model/monitor.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/main.dart';

class TaskInformation extends StatelessWidget {
  final MonitorTask task;
  final Provider _provider;

  TaskInformation({super.key, required this.task})
      : _provider = Provider(
          fetchURL:
              "/api/m_ppm.php?type=tnm_details&transactionId=${task.transactionId}",
        );

  Future<MonitorDetail> get _detail async {
    _provider.context = navigatorKey.currentContext!;
    final raw = await _provider.fetch();
    final detail = raw.monitorDetail;
    if (detail == null) throw Exception("No monitorDetail");
    // sometimes it's a Map:
    return detail;
    return MonitorDetail.fromJson(jsonEncode(detail));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GemsChrome.page,
      appBar: gemsAppBar(
        title: const Text('Task Information'),
      ),
      body: FutureBuilder<MonitorDetail>(
        future: _detail,
        builder: (ctx, snap) {
          if (snap.hasError) {
            return Center(child: Text(snap.error.toString()));
          }
          if (!snap.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: GemsChrome.primary),
            );
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
                  radius: 18,
                  backgroundColor: i <= currentStep ? GemsChrome.primary : GemsChrome.neutralSoft,
                  child: Icon(
                    i < currentStep ? Icons.check : steps[i]["icon"] as IconData,
                    size: 18,
                    color: i <= currentStep ? Colors.white : GemsChrome.muted,
                  ),
                ),

                if (i < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 3,
                      color: i < currentStep ? GemsChrome.primary : GemsChrome.border,
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
                  style: GemsChrome.body(
                    size: 12,
                    weight: FontWeight.w600,
                    color: done ? GemsChrome.text : GemsChrome.muted,
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        GemsFormSection(
          title: d.flowName,
          icon: Icons.account_tree_outlined,
          child: Column(
            children: [
              _metaItem('Task No', d.transactionNo),
              if ((d.woTaskNo ?? '').isNotEmpty)
                _metaItem('Work Order', d.woTaskNo!),
              _metaItem('Checkpoint', d.currentStatus),
              _metaItem('Initiated By', d.initiateBy),
              _metaItem('By Group', d.initiateByGroup),
              _metaItem('Initiated At', d.initiateTimeCreated),
              _metaItem('Status', d.taskStatus),
              _metaItem('Current User', d.currentUser),
              _metaItem('Received At', d.receivedTime),
              _metaItem('Flow Status', d.flowStatus),
              _metaItem('Due Date', d.flowDueDate),
            ],
          ),
        ),

        const SizedBox(height: 16),

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
                      taskNo: (d.woTaskNo ?? '').isNotEmpty
                          ? d.woTaskNo!
                          : d.transactionNo,
                      taskStatus: d.taskStatus,
                      viewer: true,
                      woTaskType: "",
                      woTaskCategory: "",
                    ),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 24),

        Text('Transaction History', style: GemsChrome.heading(size: 16)),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GemsChrome.body(size: 12, color: GemsChrome.textSoft),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GemsChrome.body(size: 14, weight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pillButton(String text, VoidCallback onTap) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: GemsChrome.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GemsChrome.radius),
        ),
      ),
      onPressed: onTap,
      child: Text(text, style: GemsChrome.body(weight: FontWeight.w600, color: Colors.white)),
    );
  }

  GemsStatusStyle _historyStatus(String value) {
    switch (value) {
      case 'In Progress':
        return GemsStatusStyle.primary;
      case 'Verify':
        return GemsStatusStyle.warning;
      case 'Complete':
        return GemsStatusStyle.success;
      case 'Rejected':
        return GemsStatusStyle.danger;
      default:
        return GemsStatusStyle.neutral;
    }
  }

  Widget _historyCard(MonitorHistory h, int idx) {
    final status = _historyStatus(h.taskStatus);

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(GemsChrome.radius),
          border: Border.all(color: GemsChrome.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: GemsChrome.primarySoft,
                    child: Text(
                      '$idx',
                      style: GemsChrome.body(
                        size: 13,
                        weight: FontWeight.w700,
                        color: GemsChrome.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      h.checkpointId,
                      style: GemsChrome.body(size: 15, weight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: status.background,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      h.taskStatus,
                      style: GemsChrome.body(
                        size: 12,
                        weight: FontWeight.w600,
                        color: status.foreground,
                      ),
                    ),
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
                  child: Text('Remark', style: GemsChrome.body(weight: FontWeight.w600)),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(h.taskRemark, style: GemsChrome.body()),
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
          Text(label, style: GemsChrome.body(size: 12, color: GemsChrome.textSoft)),
          const SizedBox(height: 4),
          Text(value, style: GemsChrome.body(size: 14, weight: FontWeight.w500)),
        ],
      ),
    );
  }
}

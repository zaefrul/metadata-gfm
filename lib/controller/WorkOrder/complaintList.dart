// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:GEMS/controller/WorkOrder/complaintSection_v2.dart';
import 'package:GEMS/data/repository/work_order_repository.dart';
import 'package:GEMS/model/workorder.dart';
import 'package:GEMS/utils/reference.dart';

typedef VoidFutureCallback = Future<void> Function();

class ComplaintList extends StatelessWidget {
  final VoidFutureCallback refresh;
  final bool viewer;
  final List<WorkOrderListItem> list;

  const ComplaintList({
    super.key,
    required this.refresh,
    required this.viewer,
    required this.list,
  });

  @override
  Widget build(BuildContext context) {
    final hasOffline = list.any((item) => item.isOffline);
    final hasOnline = list.any((item) => !item.isOffline);

  final rows = <_ComplaintRow>[];
    bool insertedOfflineHeader = false;
    bool insertedOnlineHeader = false;

    for (final item in list) {
      if (item.isOffline && hasOffline && !insertedOfflineHeader) {
        rows.add(const _ComplaintRow.header(_ComplaintHeaderKind.offline));
        insertedOfflineHeader = true;
      }

      if (!item.isOffline && hasOffline && hasOnline && !insertedOnlineHeader) {
        rows.add(const _ComplaintRow.gap());
        rows.add(const _ComplaintRow.header(_ComplaintHeaderKind.online));
        insertedOnlineHeader = true;
      }

      rows.add(_ComplaintRow.item(item));
    }

    return RefreshIndicator(
      onRefresh: refresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: rows.length,
        itemBuilder: (context, idx) {
          final row = rows[idx];
          switch (row.type) {
            case _ComplaintRowType.header:
              return _SectionHeader(kind: row.headerKind!);
            case _ComplaintRowType.gap:
              return const SizedBox(height: 12);
            case _ComplaintRowType.item:
              final item = row.item!;
              final task = item.task;
              return _TaskCard(
                task: task,
                isOffline: item.isOffline,
                viewer: viewer,
                onTap: () {
                  final page = ComplaintSection(
                    id:            task.woTaskId,
                    siteName:      task.reportedBy,
                    taskNo:        task.woTaskNo,
                    taskStatus:    task.woTaskStatus,
                    viewer:        viewer,
                    isComplaintProgress: task.woTaskType == "Client Complaint" &&
                                         task.woTaskStatus == "In Progress",
                    isAssign:      task.woTaskStatus == "Assign" ||
                                   task.woTaskStatus == "Revisit" ||
                                   task.woTaskStatus == "WR Reassign",
                    woTaskType: task.woTaskTypeInit,
                    woTaskCategory: "",
                  );
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => page))
                      .then((_) => refresh());
                },
              );
          }
        },
      ),
    );
  }
}

/// A single task displayed in a rounded card
class _TaskCard extends StatelessWidget {
  final WorkOrderTask task;
  final bool isOffline;
  final bool viewer;
  final VoidCallback onTap;

  const _TaskCard({
    required this.task,
    required this.isOffline,
    required this.viewer,
    required this.onTap,
  });

  Color _statusColor() {
    switch (task.woTaskStatus) {
      case "Assign":
        return AppColors.warningDark;
      case "WR Check":
      case "Check":
        return AppColors.infoDark;
      case "WR Verified":
        return AppColors.successDark;
      case "In Progress":
        return AppColors.primaryDark;
      case "Verify":
        return AppColors.info;
      case "Re-Open":
        return AppColors.warning;
      case "Completed":
        return AppColors.success;
      case "Rejected":
        return AppColors.danger;
      default:
        return AppColors.secondary;
    }
  }

  Color _statusCardColor() {
    switch (task.woTaskStatus) {
      case "Assign":
        return AppColors.warningLight;
      case "WR Check":
      case "Check":
        return AppColors.infoLight;
      case "WR Verified":
        return AppColors.successLight;
      case "In Progress":
        return AppColors.primaryLight;
      case "Verify":
        return AppColors.infoLight;
      case "Re-Open":
        return AppColors.warningLight;
      case "Completed":
        return AppColors.successLight;
      case "Rejected":
        return AppColors.dangerLight;
      default:
        return AppColors.secondaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: _statusCardColor(),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.woTaskNo,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          task.woTaskType,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 16, color: Colors.black38),
                            const SizedBox(width: 4),
                            Text(
                              task.woTaskTimeCreated,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          task.reportedBy,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          task.woTaskSeverity,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _statusColor(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      task.woTaskStatus,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isOffline)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryDark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Offline',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

enum _ComplaintRowType { header, gap, item }

enum _ComplaintHeaderKind { offline, online }

class _ComplaintRow {
  const _ComplaintRow._(this.type, {this.item, this.headerKind});

  const _ComplaintRow.header(_ComplaintHeaderKind kind)
      : this._(_ComplaintRowType.header, headerKind: kind);

  const _ComplaintRow.gap() : this._(_ComplaintRowType.gap);

  const _ComplaintRow.item(WorkOrderListItem item)
      : this._(_ComplaintRowType.item, item: item);

  final _ComplaintRowType type;
  final WorkOrderListItem? item;
  final _ComplaintHeaderKind? headerKind;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.kind});

  final _ComplaintHeaderKind kind;

  @override
  Widget build(BuildContext context) {
    final isOffline = kind == _ComplaintHeaderKind.offline;
    final background = isOffline ? AppColors.secondaryLight : Colors.transparent;
    final foreground = isOffline ? AppColors.secondaryDark : Colors.black54;
    final label = isOffline ? 'Available offline' : 'Other tasks';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(isOffline ? 12 : 0),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isOffline ? 12 : 0,
              vertical: isOffline ? 6 : 0,
            ),
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: isOffline ? FontWeight.w700 : FontWeight.w500,
                color: foreground,
                letterSpacing: isOffline ? 0.2 : 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

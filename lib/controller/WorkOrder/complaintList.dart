// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:GEMS/controller/WorkOrder/complaintSection_v2.dart';
import 'package:GEMS/data/repository/work_order_repository.dart';
import 'package:GEMS/model/workorder.dart';
import 'package:GEMS/view/gems_chrome.dart';

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
      color: GemsChrome.primary,
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
                    id: task.woTaskId,
                    siteName: task.reportedBy,
                    taskNo: task.woTaskNo,
                    taskStatus: task.woTaskStatus,
                    viewer: viewer,
                    isComplaintProgress:
                        task.woTaskType == "Client Complaint" &&
                            task.woTaskStatus == "In Progress",
                    isAssign: task.woTaskStatus == "Assign" ||
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

  @override
  Widget build(BuildContext context) {
    final status = GemsStatusStyle.forWorkOrder(task.woTaskStatus);
    return GemsAccentCard(
      margin: const EdgeInsets.only(bottom: 10),
      accent: status.foreground,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    task.woTaskNo,
                    style: GemsChrome.body(
                      size: 15,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _StatusBadge(
                  label: task.woTaskStatus,
                  style: status,
                ),
              ],
            ),
            if (isOffline) ...[
              const SizedBox(height: 6),
              const _StatusBadge(
                label: 'Offline',
                style: GemsStatusStyle.neutral,
              ),
            ],
            const SizedBox(height: 4),
            Text(
              task.woTaskType,
              style: GemsChrome.body(size: 13, color: GemsChrome.textSoft),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time,
                    size: 14, color: GemsChrome.muted),
                const SizedBox(width: 4),
                Text(
                  task.woTaskTimeCreated,
                  style: GemsChrome.body(size: 12, color: GemsChrome.textSoft),
                ),
              ],
            ),
            if (task.reportedBy.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                task.reportedBy,
                style: GemsChrome.body(size: 12, color: GemsChrome.textSoft),
              ),
            ],
            if (task.woTaskSeverity.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                task.woTaskSeverity,
                style: GemsChrome.body(size: 12, color: GemsChrome.textSoft),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.style});

  final String label;
  final GemsStatusStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GemsChrome.body(
          size: 11,
          weight: FontWeight.w600,
          color: style.foreground,
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
    final label = isOffline ? 'Available offline' : 'Other tasks';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isOffline ? GemsChrome.neutralSoft : Colors.transparent,
            borderRadius: BorderRadius.circular(isOffline ? 6 : 0),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isOffline ? 10 : 0,
              vertical: isOffline ? 4 : 0,
            ),
            child: Text(
              label,
              style: GemsChrome.body(
                size: 12,
                weight: FontWeight.w600,
                color: GemsChrome.textSoft,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

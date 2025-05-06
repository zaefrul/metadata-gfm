import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gfm_gems/controller/WorkOrder/complaintSection_v2.dart';
import 'package:gfm_gems/model/workorder.dart';
import 'package:gfm_gems/utils/reference.dart';

typedef Future<void> VoidFutureCallback();

class ComplaintList extends StatelessWidget {
  final VoidFutureCallback refresh;
  final bool viewer;
  final List<WorkOrderTask> list;

  const ComplaintList({
    Key? key,
    required this.refresh,
    required this.viewer,
    required this.list,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // sort list by id descending
    list.sort((a, b) => b.woTaskId.compareTo(a.woTaskId));
    return RefreshIndicator(
      onRefresh: refresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: list.length,
        itemBuilder: (context, idx) {
          final task = list[idx];
          return _TaskCard(
            task: task,
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
              );
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => page))
                  .then((_) => refresh());
            },
          );
        },
      ),
    );
  }
}

/// A single task displayed in a rounded card
class _TaskCard extends StatelessWidget {
  final WorkOrderTask task;
  final bool viewer;
  final VoidCallback onTap;

  const _TaskCard({
    Key? key,
    required this.task,
    required this.viewer,
    required this.onTap,
  }) : super(key: key);

  Color _statusColor() {
    switch (task.woTaskStatus) {
      case "Assign":
        return AppColors.warningDark;
      case "WR Check":
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Left: task info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Task no
                    Text(
                      task.woTaskNo,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Type
                    Text(
                      task.woTaskType,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Created time + reporter
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.black38),
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

              // Right: status chip
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
      ),
    );
  }
}

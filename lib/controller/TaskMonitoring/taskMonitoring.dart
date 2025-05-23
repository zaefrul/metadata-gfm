// lib/controller/TaskMonitoring/task_monitoring_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:GEMS/controller/TaskMonitoring/searchMonitorTask.dart';
import 'package:GEMS/controller/TaskMonitoring/task_detail.dart';
import 'package:GEMS/model/monitor.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:GEMS/view/bar.dart';
import 'package:GEMS/view/drawer.dart';

class TaskMonitoringScreen extends StatefulWidget {
  @override
  _TaskMonitoringScreenState createState() => _TaskMonitoringScreenState();
}

class _TaskMonitoringScreenState extends State<TaskMonitoringScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Provider _provider;

  bool _loading = true;
  String _dropdownValue = "Planned Preventive Maintenance";
  String get _flowId => _dropdownValue == "Work Order" ? "2" : "1";

  List<MonitorTask> _tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    setState(() => _loading = true);
    _provider = Provider(
      fetchURL: "/api/m_ppm.php?flowId=$_flowId&type=tnm_list",
    );
    _provider.context = context;
    try {
      final resp = await _provider.fetch();
      _tasks = resp.monitorTaskList?.toList() ?? [];
    } catch (_) {
      _tasks = [];
    } finally {
      setState(() => _loading = false);
    }
  }

  Color _pillColor(String status) {
    switch (status) {
      case "In Progress":
        return AppColors.primaryDark;
      case "Rejected":
      case "WR Invalid":
        return AppColors.dangerDark;
      case "Out of Scope":
        return AppColors.danger;
      case "Check":
      case "WR Re-Open":
        return AppColors.infoDark;
      case "Completed":
        return AppColors.successDark;
      case "Assign":
      case "Verify":
      case "WR Check":
      case "WR Verified":
        return AppColors.warningDark;
      default:
        return AppColors.secondaryDark;
    }
  }

  Color _cardBgColor(String status) {
    switch (status) {
      case "In Progress":
        return AppColors.primaryLight;
      case "Rejected":
      case "WR Invalid":
      case "Out of Scope":
        return AppColors.dangerLight;
      case "Check":
      case "WR Re-Open":
        return AppColors.infoLight;
      case "Completed":
        return AppColors.successLight;
      case "Assign":
      case "Verify":
      case "WR Check":
      case "WR Verified":
        return AppColors.warningLight;
      default:
        return AppColors.secondaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: bar(
        _scaffoldKey,
        text: "Track Monitoring",
        search: true,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SearchTaskMonitoring()),
        ),
      ) as PreferredSizeWidget,
      drawer: BuildDrawer(() => Navigator.pop(context)),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _fetchTasks,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              children: [
                // — filter dropdown —
                DropdownButton<String>(
                  isExpanded: true,
                  value: _dropdownValue,
                  underline: Container(height: 1, color: AppColors.divider),
                  items: [
                    "Planned Preventive Maintenance",
                    "Work Order"
                  ].map((label) {
                    return DropdownMenuItem(
                      value: label,
                      child: Text(label, style: GoogleFonts.poppins()),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _dropdownValue = v);
                      _fetchTasks();
                    }
                  },
                ),
                const SizedBox(height: 12),

                // — task cards —
                ..._tasks.map((t) => _buildCard(context, t)).toList(),
                if (_tasks.isEmpty && !_loading)
                  Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: Center(
                      child: Text("No tasks found",
                          style: GoogleFonts.poppins(color: colorTheme3Light)),
                    ),
                  ),
              ],
            ),
          ),

          if (_loading)
            Container(
              color: Colors.black38,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext ctx, MonitorTask task) {
    final pillBg = _pillColor(task.transactionStatus);
    final pillFg = AppColors.white;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: _cardBgColor(task.transactionStatus),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(ctx).push(
            MaterialPageRoute(
              builder: (_) => TaskInformation(task: task),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // left column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.transactionNo,
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(task.flowName,
                        style: GoogleFonts.poppins(color: AppColors.gray700, fontWeight: FontWeight.w400)),
                    const SizedBox(height: 4),
                    Text(task.checkpointName,
                        style: GoogleFonts.poppins(color: AppColors.gray700, fontWeight: FontWeight.w400)),
                    const SizedBox(height: 4),
                    Text(
                      _flowId == "1"
                          ? (task.userFullName ?? '')
                          : (task.currentTaskOwner ?? ''),
                      style: GoogleFonts.poppins(),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: colorTheme3),
                        const SizedBox(width: 4),
                        Text(task.transactionTimeCreated,
                            style: GoogleFonts.poppins(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),

              // status pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: pillBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(task.transactionStatus,
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: pillFg)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

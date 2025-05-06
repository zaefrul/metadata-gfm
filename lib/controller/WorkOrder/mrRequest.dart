// lib/controller/Storekeeper/route/storekeeper/route_MR.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gfm_gems/model/complaint.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:rxdart/rxdart.dart';
import 'package:gfm_gems/model/serializers.dart';
import '../Storekeeper/utils/constant.dart'; // for routeMaterialRequestView

class MRTaskList extends StatefulWidget {
  // now initialized once on the widget
  static const Map<String,String> _statuses = {
    "32": "Request Parts",
    "33": "Request Approval",
    "34": "Stock Request",
    "38": "Ready For Collection",
    "36": "Parts Collected",
    "47": "Need to Order",
    "48": "Waiting for Purchase",
  };

  const MRTaskList({Key? key}) : super(key: key);
  @override _MRTaskListState createState() => _MRTaskListState();
}

class _MRTaskListState extends State<MRTaskList> {
  late final Controller controller;
  late final StreamSubscription<String> _filterSub;
  late final StreamSubscription<List<RequestTask>> _taskSub;

  bool _loading = true;
  String _currentFilter = 'All Status';
  List<RequestTask> _tasks = [];

  // statusId → label
  static const Map<String, String> _statuses = {
    "32": "Request Parts",
    "33": "Request Approval",
    "34": "Stock Request",
    "38": "Ready For Collection",
    "36": "Parts Collected",
    "47": "Need to Order",
    "48": "Waiting for Purchase",
  };

  @override
  void initState() {
    super.initState();
    controller = Controller();

    // 1) listen for filter changes
    _filterSub = controller.dropdownValueStream.listen((label) {
      setState(() => _currentFilter = label);
    });

    // 2) listen for task list changes
    _taskSub = controller.filteredTaskStream.listen((tasks) {
      setState(() {
        _tasks = tasks;
        _loading = false;
      });
    });

    // 3) kick off initial load
    controller.refresh();
  }

  @override
  void dispose() {
    _filterSub.cancel();
    _taskSub.cancel();
    controller.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    setState(() => _loading = true);
    await controller.refresh();
  }

  List<RequestTask> get _visibleTasks {
    if (_currentFilter == 'All Status') return _tasks;
    return _tasks
        .where((t) => MRTaskList._statuses[t.statusId] == _currentFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            // — filter dropdown —
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: DropdownButton<String>(
                isExpanded: true,
                value: _currentFilter,
                underline: Container(
                  height: 1,
                  color: AppColors.divider,
                ),
                items: [
                  'All Status',
                  ..._statuses.values,
                ]
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label,
                              style:
                                  GoogleFonts.poppins(fontSize: 14)),
                        ))
                    .toList(),
                onChanged: controller.filter,
              ),
            ),

            // — list of cards —
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _onRefresh,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  itemCount: _visibleTasks.length,
                  itemBuilder: (ctx, i) =>
                      _MRTaskCard(_visibleTasks[i]),
                ),
              ),
            ),
          ],
        ),

        // full-screen spinner overlay
        if (_loading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
                child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

/// One card per MR task
class _MRTaskCard extends StatelessWidget {
  final RequestTask task;

  const _MRTaskCard(this.task);

  @override
  Widget build(BuildContext context) {
    final statusLabel =
        MRTaskList._statuses[task.statusId] ?? 'Unknown';
    final color = _colorFor(task.statusId ?? "");
    final bg = _bgColorFor(task.statusId ?? "");

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.pushNamed(
          context,
          routeMaterialRequestView,
          arguments: task,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.woTaskRequestNo ?? '—',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.requestBy ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.schedule,
                            size: 14,
                            color:
                                AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          task.requestTime ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color:
                                AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // status pill
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius:
                      BorderRadius.circular(20),
                  border: Border.all(color: color),
                ),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _colorFor(String id) {
    switch (id) {
      case "32":
      case "47":
      case "48":
        return AppColors.warningDark;
      case "33":
        return AppColors.dangerDark;
      case "34":
        return AppColors.primaryDark;
      case "38":
        return AppColors.successDark;
      case "36":
        return AppColors.secondaryDark;
      default:
        return AppColors.secondaryDark;
    }
  }

  Color _bgColorFor(String id) {
    switch (id) {
      case "32":
      case "47":
      case "48":
        return AppColors.warningLight;
      case "33":
        return AppColors.dangerLight;
      case "34":
        return AppColors.primaryLight;
      case "38":
        return AppColors.successLight;
      case "36":
        return AppColors.secondaryLight;
      default:
        return AppColors.gray50;
    }
  }
}

/// Manages fetching & filtering
class Controller {
  final _tasks =
      BehaviorSubject<List<RequestTask>>.seeded([]);
  final _filtered =
      BehaviorSubject<List<RequestTask>>.seeded([]);
  final _dropdown =
      BehaviorSubject<String>.seeded('All Status');
  final Request _request = Request();

  Controller() {
    _tasks.listen((all) => _filtered.add(all));
    _request.refresh.then((list) => _tasks.add(list));
  }

  Stream<List<RequestTask>> get filteredTaskStream =>
      _filtered.stream;
  Stream<String> get dropdownValueStream =>
      _dropdown.stream;

  Future<void> refresh() async {
    final list = await _request.refresh;
    _tasks.add(list);
    _dropdown.add('All Status');
  }

  void filter(String? label) {
    if (label == null) return;
    _dropdown.add(label);
    final all = _tasks.value;
    if (label == 'All Status') {
      _filtered.add(all);
    } else {
      _filtered.add(all
          .where((t) =>
              MRTaskList._statuses[t.statusId] == label)
          .toList());
    }
  }

  void dispose() {
    _tasks.close();
    _filtered.close();
    _dropdown.close();
  }
}

/// Wraps your provider call
class Request {
  final Provider _provider =
      Provider(fetchURL: "/wo_request/pending_task");

  Future<List<RequestTask>> get refresh async {
    final raw = await _provider
        .getJson(url: "/wo_request/pending_task");
    return deserializeListOf<RequestTask>(raw).toList();
  }
}

// lib/controller/Storekeeper/route/storekeeper/route_MR.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:GEMS/model/complaint.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/view/gems_chrome.dart';
import 'package:rxdart/rxdart.dart';
import 'package:GEMS/model/serializers.dart';
import '../Storekeeper/utils/constant.dart'; // for MR approval routes

class MRTaskList extends StatefulWidget {
  // now initialized once on the widget
  static const Map<String, String> _statuses = {
    "32": "Request Parts",
    "33": "Request Approval",
    "34": "Stock Request",
    "38": "Ready For Collection",
    "36": "Parts Collected",
    "47": "Need to Order",
    "48": "Waiting for Purchase",
  };

  const MRTaskList({super.key});
  @override
  _MRTaskListState createState() => _MRTaskListState();
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

  String _statusLabelFor(RequestTask task) {
    // MR Reviewer tasks share statusId=33 with supervisors; differentiate via checkpoint.
    if (task.statusId == '33' && task.checkpointDesc == 'MR Reviewer') {
      return 'Review';
    }
    return _statuses[task.statusId] ?? 'Unknown';
  }

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
    return _tasks.where((t) => _statusLabelFor(t) == _currentFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            // — filter dropdown —
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(GemsChrome.radius),
                  border: Border.all(color: GemsChrome.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _currentFilter,
                    underline: const SizedBox.shrink(),
                    style: GemsChrome.body(size: 13),
                    items: [
                      'All Status',
                      ...{
                        ..._statuses.values,
                        'Review',
                      },
                    ]
                        .map((label) => DropdownMenuItem(
                              value: label,
                              child:
                                  Text(label, overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: controller.filter,
                  ),
                ),
              ),
            ),

            // — list of cards —
            Expanded(
              child: RefreshIndicator(
                color: GemsChrome.primary,
                onRefresh: _onRefresh,
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _visibleTasks.length,
                  itemBuilder: (ctx, i) => _MRTaskCard(_visibleTasks[i]),
                ),
              ),
            ),
          ],
        ),

        // full-screen spinner overlay
        if (_loading)
          const ColoredBox(
            color: Color(0xB8F1F5F9),
            child: Center(
              child: CircularProgressIndicator(color: GemsChrome.primary),
            ),
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
        (task.statusId == '33' && task.checkpointDesc == 'MR Reviewer')
            ? 'Review'
            : (MRTaskList._statuses[task.statusId] ?? 'Unknown');
    final status = _statusStyle(task.statusId ?? '');

    return GemsAccentCard(
      margin: const EdgeInsets.symmetric(vertical: 5),
      accent: status.foreground,
      onTap: () => Navigator.pushNamed(
        context,
        routeMateralRequest,
        arguments: task,
      ),
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
                    task.woTaskRequestNo ?? '—',
                    style: GemsChrome.body(
                      size: 15,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: status.background,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusLabel,
                    style: GemsChrome.body(
                      size: 11,
                      weight: FontWeight.w600,
                      color: status.foreground,
                    ),
                  ),
                ),
              ],
            ),
            if ((task.requestBy ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                task.requestBy ?? '',
                style: GemsChrome.body(
                  size: 13,
                  color: GemsChrome.textSoft,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.schedule,
                  size: 14,
                  color: GemsChrome.muted,
                ),
                const SizedBox(width: 4),
                Text(
                  task.requestTime ?? '',
                  style: GemsChrome.body(
                    size: 12,
                    color: GemsChrome.textSoft,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  GemsStatusStyle _statusStyle(String id) {
    switch (id) {
      case '32':
      case '47':
      case '48':
        return GemsStatusStyle.warning;
      case '33':
        return GemsStatusStyle.danger;
      case '34':
        return GemsStatusStyle.primary;
      case '38':
        return GemsStatusStyle.success;
      default:
        return GemsStatusStyle.neutral;
    }
  }
}

/// Manages fetching & filtering
class Controller {
  final _tasks = BehaviorSubject<List<RequestTask>>.seeded([]);
  final _filtered = BehaviorSubject<List<RequestTask>>.seeded([]);
  final _dropdown = BehaviorSubject<String>.seeded('All Status');
  final Request _request = Request();

  Controller() {
    _tasks.listen((all) => _filtered.add(all));
    _request.refresh.then((list) => _tasks.add(list));
  }

  Stream<List<RequestTask>> get filteredTaskStream => _filtered.stream;
  Stream<String> get dropdownValueStream => _dropdown.stream;

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
      _filtered.add(
          all.where((t) => MRTaskList._statuses[t.statusId] == label).toList());
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
  final Provider _provider = Provider(fetchURL: "/wo_request/pending_task");

  Future<List<RequestTask>> get refresh async {
    final raw = await _provider.getJson(url: "/wo_request/pending_task");
    return deserializeListOf<RequestTask>(raw).toList();
  }
}

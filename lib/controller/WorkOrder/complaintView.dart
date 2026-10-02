// ignore_for_file: file_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:GEMS/data/repository/work_order_repository.dart';
import 'package:GEMS/view/gems_chrome.dart';

import 'complaintList.dart';

class ComplaintView extends StatefulWidget {
  final int index;
  // ignore: unused_field
  final String url;
  final Widget? headers;

  const ComplaintView(this.url, this.headers, this.index, {super.key});

  @override
  ComplaintViewState createState() => ComplaintViewState();
}

class _OfflineNotice extends StatelessWidget {
  const _OfflineNotice({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GemsChrome.warningSoft,
        borderRadius: BorderRadius.circular(GemsChrome.radius),
        border: Border.all(color: GemsChrome.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: GemsChrome.warning, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "You're viewing offline data. Reconnect and pull to refresh to get the latest updates.",
              style: GemsChrome.body(size: 12, color: GemsChrome.text),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Retry',
              style: GemsChrome.body(
                size: 13,
                weight: FontWeight.w600,
                color: GemsChrome.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ComplaintViewState extends State<ComplaintView> {
  String dropdownValue = "All Status";
  String dropdownType = "All Type";
  List<WorkOrderListItem> _listTask = [];
  List<WorkOrderListItem> _filterTask = [];
  late final WorkOrderRepository _repository;
  late Future<List<WorkOrderListItem>> _loadFuture;
  WorkOrderDataSource? _lastSource;

  @override
  void initState() {
    super.initState();
    _repository = WorkOrderRepository();
    _loadFuture = _load();
  }

  WorkOrderListType get _listType => widget.index == 0
      ? WorkOrderListType.submittedWo
      : WorkOrderListType.pendingTask;

  Future<List<WorkOrderListItem>> _load({bool forceRefresh = false}) async {
    try {
      final result = await _repository.getWorkOrders(
        type: _listType,
        forceRefresh: forceRefresh,
      );
      final tasks = result.items;
      debugPrint('WorkOrder: fetched ${tasks.length} items for ${_listType.name} (forceRefresh=$forceRefresh, source=${result.source})');

      if (!mounted) {
        _lastSource = result.source;
        return tasks;
      }

      setState(() {
        _listTask = tasks;
        _filterTask = _applyFilters(tasks);
        _lastSource = result.source;
      });

      if (result.source == WorkOrderDataSource.cacheWarm && !forceRefresh) {
        unawaited(_repository.refreshWorkOrders(_listType).then((fresh) {
          if (!mounted) return;
          debugPrint('WorkOrder: remote refresh completed with ${fresh.items.length} items for ${_listType.name}');
          setState(() {
            _listTask = fresh.items;
            _filterTask = _applyFilters(fresh.items);
            _lastSource = fresh.source;
          });
        }).catchError((error, stack) {
          debugPrint('WorkOrder: background refresh failed: $error');
          debugPrint('$stack');
        }));
      }

      return _filterTask;
    } catch (error, stack) {
      debugPrint('WorkOrder: failed to load ${_listType.name}: $error');
      debugPrint('$stack');
      rethrow;
    }
  }

  List<WorkOrderListItem> _applyFilters(List<WorkOrderListItem> source) {
    Iterable<WorkOrderListItem> filtered = source;

    if (dropdownValue != "All Status") {
      filtered = filtered.where((item) => item.task.woTaskStatus == dropdownValue);
    }

    if (dropdownType != "All Type") {
      filtered = filtered.where((item) {
        final taskNo = item.task.woTaskNo.toUpperCase();
        if (dropdownType == "Work Order") {
          return taskNo.startsWith("WO");
        } else {
          return taskNo.startsWith("WR");
        }
      });
    }

    return filtered.toList();
  }

  Future<void> _refresh() async {
    final future = _load(forceRefresh: true);
    setState(() {
      _loadFuture = future;
    });
    await future;
  }

  Widget get _filter => DropdownButton<String>(
        isExpanded: true,
        underline: const SizedBox.shrink(),
        style: GemsChrome.body(size: 13),
        value: dropdownValue,
        onChanged: (String? newValue) {
          setState(() {
            dropdownValue = newValue ?? "All Status";
            _filterTask = _applyFilters(_listTask);
          });
        },
        items: <String>[
          'All Status',
          'Assign',
          "WR Check",
          "WR Verified",
          'In Progress',
          'Verify',
          'Re-Open',
          'Completed',
          'Out of Scope',
        ].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
      );

  Widget get _filterType => DropdownButton<String>(
        isExpanded: true,
        underline: const SizedBox.shrink(),
        style: GemsChrome.body(size: 13),
        value: dropdownType,
        onChanged: (String? newValue) {
          setState(() {
            dropdownType = newValue ?? "All Type";
            _filterTask = _applyFilters(_listTask);
          });
        },
        items: <String>[
          'All Type',
          'Work Request',
          'Work Order',
        ].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
      );

  Widget _filterBox(Widget child) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(GemsChrome.radius),
        border: Border.all(color: GemsChrome.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: child,
      ),
    );
  }

  Widget get _header => Row(
        children: [
          Expanded(child: _filterBox(_filter)),
          const SizedBox(width: 8),
          Expanded(child: _filterBox(_filterType)),
          if (widget.headers != null) ...[
            const SizedBox(width: 8),
            widget.headers!,
          ],
        ],
      );

  @override
  Widget build(BuildContext context) {
    const Widget loadingWidget = ColoredBox(
      color: GemsChrome.page,
      child: Center(
        child: CircularProgressIndicator(color: GemsChrome.primary),
      ),
    );

    Widget body(List<WorkOrderListItem> value) {
      final showOfflineBanner =
          _lastSource == WorkOrderDataSource.cacheFallback && value.isNotEmpty;
      return Column(
        children: <Widget>[
          if (showOfflineBanner)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _OfflineNotice(onRetry: _refresh),
            )
          else
            const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _header,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ComplaintList(
              list: value,
              viewer: widget.index == 0,
              refresh: _refresh,
            ),
          ),
        ],
      );
    }

    return FutureBuilder<List<WorkOrderListItem>>(
      future: _loadFuture,
      builder: (context, AsyncSnapshot<List<WorkOrderListItem>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          if (_filterTask.isNotEmpty) {
            return body(_filterTask);
          }
          return loadingWidget;
        }

        if (snapshot.hasError) {
          if (_filterTask.isNotEmpty) {
            return body(_filterTask);
          }
          return body(const []);
        }

        return body(_filterTask);
      },
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

import 'package:GEMS/controller/WorkOrder/pending_sync.dart';
import 'package:GEMS/controller/WorkOrder/widgets/pending_sync_banner.dart';
import 'package:GEMS/data/repository/work_order_detail_repository.dart';
import 'package:GEMS/utils/reference.dart';

class AddTechnicianCheckList extends StatefulWidget {
  final String id;
  final bool viewer;
  final PendingSyncController? pendingSync;
  final Stream<WorkOrderSnapshotData?>? snapshotStream;
  final WorkOrderSnapshotData? initialSnapshot;

  const AddTechnicianCheckList({
    super.key,
    required this.id,
    required this.viewer,
    this.pendingSync,
    this.snapshotStream,
    this.initialSnapshot,
  });

  @override
  _AddTechnicianCheckListState createState() => _AddTechnicianCheckListState();
}

class _AddTechnicianCheckListState extends State<AddTechnicianCheckList> {
  final TextEditingController _searchCtr = TextEditingController();
  late final WorkOrderDetailRepository _repository;

  List<WorkOrderAssistant> _options = const <WorkOrderAssistant>[];
  List<WorkOrderAssistant> _filtered = const <WorkOrderAssistant>[];
  List<WorkOrderAssistant> _selected = const <WorkOrderAssistant>[];

  int _maxAssistants = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _initialSnapshotApplied = false;

  StreamSubscription<WorkOrderSnapshotData?>? _snapshotSub;
  StreamSubscription<int>? _pendingSubscription;
  int? _lastPendingCount;

  @override
  void initState() {
    super.initState();
    ToastContext().init(context);
    _repository = WorkOrderDetailRepository();
    _searchCtr.addListener(_applySearch);
    _applySnapshot(widget.initialSnapshot);
    _loadAssistants();
    _listenToSnapshots();
    _watchPendingSync();
  }

  @override
  void didUpdateWidget(covariant AddTechnicianCheckList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pendingSync != widget.pendingSync) {
      _pendingSubscription?.cancel();
      _watchPendingSync();
    }
    if (oldWidget.snapshotStream != widget.snapshotStream) {
      _snapshotSub?.cancel();
      _listenToSnapshots();
    }
  }

  @override
  void dispose() {
    _snapshotSub?.cancel();
    _pendingSubscription?.cancel();
    _searchCtr.removeListener(_applySearch);
    _searchCtr.dispose();
    super.dispose();
  }

  void _listenToSnapshots() {
    final stream = widget.snapshotStream;
    if (stream == null) return;
    _snapshotSub = stream.listen((snapshot) {
      if (!mounted) return;
      _applySnapshot(snapshot);
    });
  }

  void _applySnapshot(WorkOrderSnapshotData? snapshot) {
    if (snapshot == null) {
      return;
    }
    final options = snapshot.assistantOptions;
    final selected = snapshot.selectedAssistants;
    final max = snapshot.maxAssistants ??
        _parseMaxFromAssignment(snapshot.assignment?.woTaskMaxAssistant);

    final pendingSelections =
        _selected.where((item) => item.isPending).toList(growable: false);

    final mergedOptions = List<WorkOrderAssistant>.from(options);
    for (final pending in pendingSelections) {
      if (!mergedOptions.any((item) => item.userId == pending.userId)) {
        mergedOptions.add(pending);
      }
    }

    final mergedSelected = List<WorkOrderAssistant>.from(selected);
    for (final pending in pendingSelections) {
      if (!mergedSelected.any((item) => item.userId == pending.userId)) {
        mergedSelected.add(pending);
      }
    }

    setState(() {
      _options = mergedOptions;
      _filtered = _filterAssistants(_searchCtr.text, _options);
      _selected = mergedSelected;
      if (max != null) {
        _maxAssistants = max;
      }
      _isLoading = false;
      _initialSnapshotApplied = true;
    });
  }

  int? _parseMaxFromAssignment(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return int.tryParse(raw);
  }

  Future<void> _loadAssistants({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final pendingSelections =
          _selected.where((item) => item.isPending).toList(growable: false);
      final data = await _repository.getAssistantData(
        workOrderId: widget.id,
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;

      final mergedOptions = List<WorkOrderAssistant>.from(data.options);
      for (final pending in pendingSelections) {
        if (!mergedOptions.any((item) => item.userId == pending.userId)) {
          mergedOptions.add(pending);
        }
      }

      final mergedSelected = List<WorkOrderAssistant>.from(data.selected);
      for (final pending in pendingSelections) {
        if (!mergedSelected.any((item) => item.userId == pending.userId)) {
          mergedSelected.add(pending);
        }
      }

      setState(() {
        _options = mergedOptions;
        _filtered = _filterAssistants(_searchCtr.text, _options);
        _selected = mergedSelected;
        if (data.maxAssistants != null) {
          _maxAssistants = data.maxAssistants!;
        }
        _isLoading = false;
        _initialSnapshotApplied = true;
      });
    } catch (err, st) {
      debugPrint('Failed to load assistant data: $err\n$st');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      if (!_initialSnapshotApplied) {
        Toast.show('Assistant data unavailable offline');
      }
    }
  }

  void _applySearch() {
    setState(() {
      _filtered = _filterAssistants(_searchCtr.text, _options);
    });
  }

  List<WorkOrderAssistant> _filterAssistants(
    String query,
    List<WorkOrderAssistant> source,
  ) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      return List<WorkOrderAssistant>.from(source);
    }
    return source
        .where(
          (item) =>
              item.userFullName.toLowerCase().contains(trimmed) ||
              item.userId.toLowerCase().contains(trimmed),
        )
        .toList(growable: false);
  }

  void _watchPendingSync() {
    final controller = widget.pendingSync;
    if (controller == null) return;
    _pendingSubscription = controller.pendingCount$.listen((count) {
      final previous = _lastPendingCount;
      _lastPendingCount = count;
      if (!mounted) return;
      if ((previous ?? 0) > 0 && count == 0) {
        _loadAssistants(forceRefresh: true);
      }
    });
  }

  bool get _hasSelectionLimit => _maxAssistants > 0;

  Future<void> _onToggle(WorkOrderAssistant assistant, bool select) async {
    if (select) {
      await _handleAdd(assistant);
    } else {
      await _handleRemove(assistant);
    }
  }

  Future<void> _handleAdd(WorkOrderAssistant assistant) async {
    if (_hasSelectionLimit && _selected.length >= _maxAssistants) {
      Toast.show(
        'Maximum of $_maxAssistants technicians allowed',
        duration: Toast.lengthLong,
        gravity: Toast.bottom,
      );
      return;
    }
    if (_selected.any((item) => item.userId == assistant.userId)) {
      return;
    }

    setState(() {
      _selected = List<WorkOrderAssistant>.from(_selected)
        ..add(assistant.copyWith(isPending: true));
    });

    try {
      final result = await _repository.addAssistant(
        workOrderId: widget.id,
        userId: assistant.userId,
        userFullName: assistant.userFullName,
      );
      if (!mounted) return;
      if (result == WorkOrderActionResult.success) {
        await _loadAssistants(forceRefresh: true);
        Toast.show('Assistant added');
      } else {
        Toast.show('Assistant queued for sync');
      }
    } catch (err, st) {
      debugPrint('Failed to add assistant: $err\n$st');
      if (!mounted) return;
      setState(() {
        _selected = _selected
            .where((item) => item.userId != assistant.userId)
            .toList(growable: false);
      });
      Toast.show('Failed to add technician');
    }
  }

  Future<void> _handleRemove(WorkOrderAssistant assistant) async {
    WorkOrderAssistant? existing;
    for (final item in _selected) {
      if (item.userId == assistant.userId) {
        existing = item;
        break;
      }
    }
    if (existing == null) {
      return;
    }

    setState(() {
      _selected = _selected
          .where((item) => item.userId != assistant.userId)
          .toList(growable: false);
    });

    try {
      final result = await _repository.removeAssistant(
        workOrderId: widget.id,
        assistantId: existing.assistantId,
        userId: existing.userId,
      );
      if (!mounted) return;
      if (result == WorkOrderActionResult.success &&
          (existing.assistantId?.isNotEmpty ?? false)) {
        await _loadAssistants(forceRefresh: true);
        Toast.show('Assistant removed');
      } else {
        Toast.show('Removal queued for sync');
      }
    } catch (err, st) {
      debugPrint('Failed to remove assistant: $err\n$st');
      if (!mounted) return;
      setState(() {
        _selected = List<WorkOrderAssistant>.from(_selected)..add(existing!);
      });
      Toast.show('Failed to remove technician');
    }
  }

  bool _isSelected(String userId) {
    return _selected.any((item) => item.userId == userId);
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      backgroundColor: AppColors.gray100,
      appBar: AppBar(
        title: Text(
          'Add Technician Assistant',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.bgAppBar,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primary),
        centerTitle: false,
      ),
      body: Column(
        children: [
          if (widget.pendingSync != null)
            PendingSyncIndicator(controller: widget.pendingSync!),
          _buildSearchCard(),
          const SizedBox(height: 8),
          _buildSelectionInfo(),
          const SizedBox(height: 8),
          Expanded(
            child: Stack(
              children: [
                _buildContent(),
                if (_isLoading)
                  Container(
                    alignment: Alignment.center,
                    color: Colors.black12,
                    child: const CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
          if (!widget.viewer) _buildDoneButton(),
        ],
      ),
    );
  }

  Widget _buildSearchCard() {
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.search, color: AppColors.primary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchCtr,
                decoration: InputDecoration(
                  hintText: 'Search technicians...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: AppColors.textHint),
                ),
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionInfo() {
    final limitLabel =
        _hasSelectionLimit ? '/$_maxAssistants' : '';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.info, size: 18),
          const SizedBox(width: 8),
          Text(
            'Selected ${_selected.length}$limitLabel',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_off, size: 48, color: AppColors.gray400),
            const SizedBox(height: 16),
            Text(
              'No technicians found',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            if (_searchCtr.text.isNotEmpty)
              TextButton(
                onPressed: () {
                  _searchCtr.clear();
                  _applySearch();
                },
                child: Text(
                  'Clear search',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        indent: 72,
        color: AppColors.gray200,
      ),
      itemBuilder: (_, index) {
        final assistant = _filtered[index];
        final isSelected = _isSelected(assistant.userId);
        return _buildAssistantTile(assistant, isSelected);
      },
    );
  }

  Widget _buildAssistantTile(
    WorkOrderAssistant assistant,
    bool isSelected,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primaryLight : AppColors.gray200,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: widget.viewer ? null : () => _onToggle(assistant, !isSelected),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assistant.userFullName,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isSelected)
                      Text(
                        assistant.isPending ? 'Pending sync' : 'Selected',
                        style: TextStyle(
                          fontSize: 12,
                          color: assistant.isPending
                              ? AppColors.warning
                              : AppColors.success,
                        ),
                      ),
                  ],
                ),
              ),
              if (!widget.viewer)
                Checkbox(
                  value: isSelected,
                  onChanged: (value) => _onToggle(assistant, value ?? false),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.primary;
                    }
                    return AppColors.gray300;
                  }),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoneButton() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          onPressed: _isSubmitting
              ? null
              : () async {
                  setState(() => _isSubmitting = true);
                  try {
                    final result =
                        await _repository.submitAssistantList(widget.id);
                    if (!mounted) return;
                    if (result == WorkOrderActionResult.success) {
                      Toast.show('Assistant list submitted');
                    } else {
                      Toast.show('Submission queued for sync');
                    }
                    Navigator.of(context).pop(_selected);
                  } catch (err, st) {
                    debugPrint('Failed to submit assistant list: $err\n$st');
                    if (mounted) {
                      Toast.show('Failed to submit changes');
                    }
                  } finally {
                    if (mounted) {
                      setState(() => _isSubmitting = false);
                    }
                  }
                },
          child: Text(_isSubmitting ? 'Submitting...' : 'Done'),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';

import 'package:GEMS/controller/Storekeeper/utils/constant.dart';
import 'package:GEMS/controller/WorkOrder/pending_sync.dart';
import 'package:GEMS/controller/WorkOrder/widgets/pending_sync_banner.dart';
import 'package:GEMS/data/repository/work_order_detail_repository.dart';
import 'package:GEMS/model/complaint.dart';
import 'package:GEMS/utils/reference.dart';

import 'complaintAdd.dart';
import 'material_arguments.dart';

class ComplaintSectionDMaterial extends StatefulWidget {
  const ComplaintSectionDMaterial(
    this.id, {
    super.key,
    this.enableSubmit = false,
    this.viewer = false,
    this.enableReset = false,
    this.comment = '',
    this.pendingSync,
    this.snapshotStream,
    this.initialSnapshot,
  });

  final String id;
  final bool enableSubmit;
  final bool enableReset;
  final bool viewer;
  final String comment;
  final PendingSyncController? pendingSync;
  final Stream<WorkOrderSnapshotData?>? snapshotStream;
  final WorkOrderSnapshotData? initialSnapshot;

  @override
  State<ComplaintSectionDMaterial> createState() =>
      _ComplaintSectionDMaterialState();
}

class _ComplaintSectionDMaterialState extends State<ComplaintSectionDMaterial> {
  late final WorkOrderDetailRepository _repository;
  bool _loading = true;
  bool _busy = false;
  List<ComplaintD> _materials = const [];
  List<PendingMaterialAction> _pending = const [];
  StreamSubscription<int>? _pendingSubscription;
  int? _lastPendingCount;
  StreamSubscription<WorkOrderSnapshotData?>? _snapshotSubscription;

  @override
  void initState() {
    super.initState();
    _repository = WorkOrderDetailRepository();
    _applySnapshot(widget.initialSnapshot);
    _loadInitial();
    _watchPendingSync();
    _listenToSnapshots();
  }

  @override
  void didUpdateWidget(covariant ComplaintSectionDMaterial oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pendingSync != widget.pendingSync) {
      _pendingSubscription?.cancel();
      _watchPendingSync();
    }
  }

  @override
  void dispose() {
    _pendingSubscription?.cancel();
    _snapshotSubscription?.cancel();
    super.dispose();
  }

  void _listenToSnapshots() {
  final stream = widget.snapshotStream;
    if (stream == null) return;
    _snapshotSubscription = stream.listen((snapshot) {
      if (!mounted) return;
      _applySnapshot(snapshot);
    });
  }

  void _applySnapshot(WorkOrderSnapshotData? snapshot) {
    if (snapshot == null) return;
    setState(() {
      _materials = snapshot.materials;
      _loading = false;
    });
  }

  Future<void> _loadInitial() async {
    await Future.wait<void>([
      _loadMaterials(),
      _loadPending(),
    ]);
  }

  Future<void> _loadMaterials({bool forceRefresh = false}) async {
    setState(() {
      _loading = true;
    });
    try {
      final items = await _repository.getMaterials(
        workOrderId: widget.id,
        forceRefresh: forceRefresh,
        onRemoteUpdate: (latest) {
          if (!mounted) return;
          setState(() {
            _materials = latest;
          });
        },
      );
      if (!mounted) return;
      setState(() {
        _materials = items;
      });
    } catch (err, st) {
      debugPrint('Failed to load materials: $err\n$st');
      if (mounted) {
        Toast.show('Unable to load materials');
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadPending() async {
    try {
      final pending = await _repository.getPendingMaterials(widget.id);
      if (!mounted) return;
      setState(() {
        _pending = pending;
      });
    } catch (err, st) {
      debugPrint('Failed to load pending materials: $err\n$st');
    }
  }

  void _watchPendingSync() {
    final controller = widget.pendingSync;
    if (controller == null) return;
    _pendingSubscription = controller.pendingCount$.listen((count) {
      final previous = _lastPendingCount;
      _lastPendingCount = count;
      _loadPending();
      if ((previous ?? 0) > 0 && count == 0) {
        _loadMaterials(forceRefresh: true);
      }
    });
  }

  Future<void> _refreshAll({bool force = false}) async {
    await Future.wait<void>([
      _loadMaterials(forceRefresh: force),
      _loadPending(),
    ]);
  }

  Future<void> _openAddMaterial() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ComplaintAdd(
          MaterialAddArguments(workOrderId: widget.id),
        ),
      ),
    );
    if (changed == true) {
      await _refreshAll(force: true);
    }
  }

  Future<void> _openMaterialDetail(ComplaintD item) async {
    if (item.woTaskPartsId == null) {
      return;
    }
    final changed = await Navigator.pushNamed<bool>(
      context,
      routeMaterial,
      arguments: MaterialEditArguments(
        workOrderId: widget.id,
        material: item,
      ),
    );
    if (changed == true) {
      await _refreshAll(force: true);
    }
  }

  Future<void> _onDelete(ComplaintD item) async {
    if (item.woTaskPartsId == null || _busy) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove material'),
        content: Text(
          'Are you sure you want to remove "${item.itemDescription ?? 'this material'}"?\nThis action will be queued if you are offline.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _busy = true;
    });

    try {
      final result = await _repository.deleteMaterial(
        workOrderId: widget.id,
        materialId: item.woTaskPartsId!,
        itemDescription: item.itemDescription,
        quantity: item.woTaskPartsQuantity,
        assetGroupName: item.assetGroupName,
        itemTypeDesc: item.itemTypeDesc,
      );
      _showResultToast(
        result,
        successMessage: 'Material removed successfully.',
        queuedMessage: 'Removal queued and will sync when online.',
      );
      await _refreshAll();
    } catch (err, st) {
      debugPrint('Failed to delete material: $err\n$st');
      Toast.show('Failed to remove material');
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _onSubmit() async {
    if (_busy) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit material request'),
        content: const Text(
          'Submit material usage for approval? This may be queued if offline.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _busy = true;
    });

    try {
      final result = await _repository.submitMaterialRequest(widget.id);
      _showResultToast(
        result,
        successMessage: 'Material request submitted.',
        queuedMessage: 'Submit queued and will sync later.',
      );
      await _refreshAll(force: result == WorkOrderActionResult.success);
    } catch (err, st) {
      debugPrint('Failed to submit material request: $err\n$st');
      Toast.show('Failed to submit request');
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _onReset() async {
    if (_busy) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Re-apply request'),
        content: const Text(
          'Re-apply the material request? Pending actions will sync when online.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Re-Apply'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _busy = true;
    });

    try {
      final result = await _repository.resetMaterialRequest(widget.id);
      _showResultToast(
        result,
        successMessage: 'Material request re-applied.',
        queuedMessage: 'Re-apply queued and will sync later.',
      );
      await _refreshAll(force: result == WorkOrderActionResult.success);
    } catch (err, st) {
      debugPrint('Failed to reset material request: $err\n$st');
      Toast.show('Failed to re-apply request');
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  void _showResultToast(
    WorkOrderActionResult result, {
    required String successMessage,
    required String queuedMessage,
  }) {
    switch (result) {
      case WorkOrderActionResult.success:
        Toast.show(successMessage, duration: 3);
        break;
      case WorkOrderActionResult.queued:
        Toast.show(queuedMessage, duration: 3);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);

    final pendingDeletes = _pending
        .where((p) =>
            p.type == PendingMaterialActionType.delete && p.materialId != null)
        .map((p) => p.materialId)
        .whereType<String>()
        .toSet();

    final pendingUpdates = {
      for (final action in _pending)
        if (action.type == PendingMaterialActionType.update &&
            action.materialId != null)
          action.materialId!: action,
    };

    final visibleMaterials = _materials
        .where((item) => !pendingDeletes.contains(item.woTaskPartsId))
        .toList();

    final hasContent = visibleMaterials.isNotEmpty ||
        _pending.isNotEmpty ||
        widget.comment.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.gray100,
      appBar: AppBar(
        title: Text(
          'Spare Parts / Material User',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.bgAppBar,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        actions: [
          if (widget.enableReset)
            TextButton(
              onPressed: _busy ? null : _onReset,
              child: Text(
                'Re-Apply',
                style: GoogleFonts.poppins(
                  color: _busy ? AppColors.secondary : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          if (widget.pendingSync != null)
            PendingSyncIndicator(controller: widget.pendingSync!),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _refreshAll(force: true),
              child: Stack(
                children: [
                  ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                    children: [
                      if (widget.comment.isNotEmpty) _buildCommentCard(),
                      if (_pending.isNotEmpty) ...[
                        ..._pending.map(
                          (action) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: PendingMaterialCard(action: action),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (!hasContent)
                        _buildEmptyState()
                      else ...[
                        for (final item in visibleMaterials)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: MaterialItemCard(
                              item: item,
                              pendingUpdate: pendingUpdates[item.woTaskPartsId],
                              enableEdit: widget.enableSubmit && !widget.viewer,
                              onTap: widget.enableSubmit && !widget.viewer
                                  ? () => _openMaterialDetail(item)
                                  : null,
                              onDelete: widget.enableSubmit && !widget.viewer
                                  ? () => _onDelete(item)
                                  : null,
                            ),
                          ),
                        const SizedBox(height: 80),
                      ],
                    ],
                  ),
                  if (_loading || _busy)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.1),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: !widget.viewer && widget.enableSubmit
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'add',
                  backgroundColor:
                      _busy ? AppColors.secondary : AppColors.primary,
                  onPressed: _busy ? null : _openAddMaterial,
                  child: const Icon(Icons.add, color: AppColors.onPrimary),
                ),
                const SizedBox(width: 12),
                FloatingActionButton.extended(
                  heroTag: 'submit',
                  backgroundColor:
                      _busy ? AppColors.secondary : AppColors.primary,
                  icon: const Icon(Icons.send, color: AppColors.onPrimary),
                  label: Text(
                    'Submit',
                    style: GoogleFonts.poppins(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: _busy ? null : _onSubmit,
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildCommentCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.gray200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          widget.comment,
          style: GoogleFonts.poppins(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Icon(Icons.inventory_outlined,
              color: AppColors.secondary, size: 48),
          const SizedBox(height: 16),
          Text(
            'No materials yet',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add the parts you plan to use so we can keep track.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class MaterialItemCard extends StatelessWidget {
  const MaterialItemCard({
    super.key,
    required this.item,
    this.pendingUpdate,
    this.enableEdit = false,
    this.onTap,
    this.onDelete,
  });

  final ComplaintD item;
  final PendingMaterialAction? pendingUpdate;
  final bool enableEdit;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final content = InkWell(
      onTap: enableEdit ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.scale,
              label: 'Quantity',
              value: item.woTaskPartsQuantity ?? 'N/A',
            ),
            _buildDetailRow(
              icon: Icons.category_outlined,
              label: 'Group',
              value: item.assetGroupName ?? 'N/A',
            ),
            _buildDetailRow(
              icon: Icons.type_specimen_outlined,
              label: 'Type',
              value: item.itemTypeDesc ?? 'N/A',
            ),
            if ((item.woTaskPartsRemark ?? '').isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Remark',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.woTaskPartsRemark ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: onDelete != null
          ? Slidable(
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) => onDelete?.call(),
                    backgroundColor: AppColors.danger,
                    foregroundColor: AppColors.onDanger,
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
                ],
              ),
              child: content,
            )
          : content,
    );
  }

  Widget _buildHeader() {
    final title = item.itemDescription ?? 'No description available';
    final chips = <Widget>[];
    final status = item.statusDesc;
    if (status != null && status.isNotEmpty) {
      chips.add(
        Chip(
          label: Text(
            status,
            style: GoogleFonts.poppins(
              color: AppColors.onPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: _getStatusColor(status),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    }
    if (pendingUpdate != null) {
      final label = pendingUpdate!.type == PendingMaterialActionType.update
          ? 'Pending update → ${pendingUpdate!.quantity ?? '-'}'
          : 'Pending change';
      chips.add(
        Chip(
          label: Text(
            label,
            style: GoogleFonts.poppins(
              color: AppColors.warningDark,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppColors.warningLight,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (chips.isNotEmpty) const SizedBox(width: 12),
        if (chips.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: chips,
          ),
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return AppColors.success;
      case 'pending':
      case 'request approval':
        return AppColors.warning;
      case 'rejected':
        return AppColors.danger;
      default:
        return AppColors.secondary;
    }
  }
}

class PendingMaterialCard extends StatelessWidget {
  const PendingMaterialCard({
    super.key,
    required this.action,
  });

  final PendingMaterialAction action;

  @override
  Widget build(BuildContext context) {
    final ui = _PendingMaterialUi.from(action.type);
    if (ui == null) {
      return const SizedBox.shrink();
    }

    final description = _buildDescription(action);

    return Container(
      decoration: BoxDecoration(
        color: ui.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ui.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(ui.icon, color: ui.iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  ui.title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ui.titleColor,
                  ),
                ),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.schedule,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                _formatTimestamp(action.createdAt),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _buildDescription(PendingMaterialAction action) {
    final material = action.material;
    final description =
        material?.itemDescription ?? action.assetGroupName ?? '';
    final quantity = action.quantity ??
        material?.woTaskPartsQuantity ??
        action.previousQuantity ??
        '';
    final remark = action.remark ?? material?.woTaskPartsRemark ?? '';

    switch (action.type) {
      case PendingMaterialActionType.add:
        final qtyLabel = quantity.isEmpty ? '' : ' (Qty: $quantity)';
        return 'Adding ${description.isEmpty ? 'a material' : description}$qtyLabel${_formatRemark(remark)}';
      case PendingMaterialActionType.update:
        final previous =
            action.previousQuantity ?? material?.woTaskPartsQuantity ?? '-';
        return 'Updating ${description.isEmpty ? 'material' : description}: $previous → $quantity${_formatRemark(remark)}';
      case PendingMaterialActionType.delete:
        final qtyLabel = quantity.isEmpty ? '' : ' (Qty: $quantity)';
        return 'Removing ${description.isEmpty ? 'a material' : description}$qtyLabel';
      case PendingMaterialActionType.submit:
        return 'Submitting material request for approval.';
      case PendingMaterialActionType.reset:
        return 'Re-applying material request.';
      case PendingMaterialActionType.unknown:
        return '';
    }
  }

  String _formatRemark(String? remark) {
    if (remark == null || remark.isEmpty) return '';
    return '\nRemark: $remark';
  }
}

class _PendingMaterialUi {
  const _PendingMaterialUi({
    required this.icon,
    required this.title,
    required this.background,
    required this.border,
    required this.iconColor,
    required this.titleColor,
  });

  final IconData icon;
  final String title;
  final Color background;
  final Color border;
  final Color iconColor;
  final Color titleColor;

  static _PendingMaterialUi? from(PendingMaterialActionType type) {
    switch (type) {
      case PendingMaterialActionType.add:
        return _PendingMaterialUi(
          icon: Icons.add_circle_outline,
          title: 'Pending add',
          background: AppColors.primary50,
          border: AppColors.primary200,
          iconColor: AppColors.primary,
          titleColor: AppColors.primaryDark,
        );
      case PendingMaterialActionType.update:
        return _PendingMaterialUi(
          icon: Icons.edit_outlined,
          title: 'Pending update',
          background: AppColors.warningLight,
          border: AppColors.warning,
          iconColor: AppColors.warningDark,
          titleColor: AppColors.warningDark,
        );
      case PendingMaterialActionType.delete:
        return _PendingMaterialUi(
          icon: Icons.delete_outline,
          title: 'Pending removal',
          background: AppColors.dangerLight,
          border: AppColors.danger,
          iconColor: AppColors.danger,
          titleColor: AppColors.dangerDark,
        );
      case PendingMaterialActionType.submit:
        return _PendingMaterialUi(
          icon: Icons.send_outlined,
          title: 'Submit queued',
          background: AppColors.infoLight,
          border: AppColors.info,
          iconColor: AppColors.info,
          titleColor: AppColors.infoDark,
        );
      case PendingMaterialActionType.reset:
        return _PendingMaterialUi(
          icon: Icons.refresh_outlined,
          title: 'Re-apply queued',
          background: AppColors.secondary50,
          border: AppColors.secondary,
          iconColor: AppColors.secondary,
          titleColor: AppColors.secondaryDark,
        );
      case PendingMaterialActionType.unknown:
        return null;
    }
  }
}

String _formatTimestamp(DateTime timestamp) {
  return DateFormat('dd MMM yyyy • HH:mm').format(timestamp.toLocal());
}

// lib/controller/Storekeeper/route/storekeeper/route_MR.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:GEMS/view/gems_chrome.dart';
import 'package:toast/toast.dart';
import 'package:GEMS/controller/Storekeeper/utils/bloc/bloc_task.dart';
import 'package:GEMS/controller/Storekeeper/utils/constant.dart'
  as storekeeper_constants;
import 'package:GEMS/controller/Storekeeper/utils/widget/dialog.dart';
import 'package:GEMS/controller/WorkOrder/complaintAdd.dart';
import 'package:GEMS/controller/WorkOrder/material_arguments.dart';
import 'package:GEMS/model/complaint.dart';
import 'package:GEMS/model/material.dart' as item;

class MaterialRequestScreen extends StatefulWidget {
  final RequestTask value;
  final bool isApproval;
  final bool isCheckout;

  const MaterialRequestScreen({
    required this.value,
    this.isApproval = false,
    this.isCheckout = false,
    super.key,
  });

  @override
  _MaterialRequestScreenState createState() => _MaterialRequestScreenState();
}

class _MaterialRequestScreenState extends State<MaterialRequestScreen> {
  late final MaterialTask _bloc;
  bool _loading = false;
  StreamSubscription<bool>? _loadingSub;
  StreamSubscription<String>? _errorSub;

  @override
  void initState() {
    super.initState();
    _bloc = MaterialTask(
      requestId: widget.value.woTaskRequestId ?? '',
      workOrderId: widget.value.woTaskId,
    );
    ToastContext().init(context);

    _loadingSub = _bloc.loadingState$.listen((isLoading) {
      if (!mounted) return;
      setState(() => _loading = isLoading);
    });
    _errorSub = _bloc.err$.listen((err) {
      if (!mounted || err.isEmpty) return;
      Toast.show(err, duration: Toast.lengthLong, gravity: Toast.bottom);
    });
  }

  @override
  void dispose() {
    _loadingSub?.cancel();
    _errorSub?.cancel();
    _bloc.dispose();
    super.dispose();
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: GemsChrome.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GemsChrome.body(size: 12, color: GemsChrome.textSoft),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GemsChrome.body(size: 14, weight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _resolveWorkOrderId(RequestTask? task) {
    final value = task?.woTaskId ?? widget.value.woTaskId;
    if (value == null || value.isEmpty) return null;
    return value;
  }

  bool _isRejected(RequestTask? task) {
    final desc = task?.statusDesc ?? widget.value.statusDesc;
    if (desc == null) return false;
    return desc.toLowerCase().contains('reject');
  }

  bool _canAddMaterials(RequestTask? task, String? workOrderId) {
    if (!widget.isApproval) return false;
    if (_isRejected(task)) return false;
    return workOrderId != null && workOrderId.isNotEmpty;
  }

  Future<void> _openEditMaterial({
    required item.Material material,
    required String woTaskId,
  }) async {
    final editable = ComplaintD((b) => b
      ..woTaskPartsId = material.woTaskPartsId
      ..woTaskRequestId = material.woTaskRequestId
      ..partId = material.partId
      ..woTaskPartsQuantity = material.woTaskPartsQuantity
      ..woTaskPartsRemark = material.woTaskPartsRemark
      ..woTaskPartsStatus = material.woTaskPartStatus
      ..itemDescription = material.itemDescription
      ..itemTypeDesc = material.itemTypeDesc
      ..assetGroupName = material.assetGroupName
      ..statusDesc = material.statusDesc
      ..images = material.images?.toBuilder());

    final changed = await Navigator.pushNamed(
      context,
      storekeeper_constants.routeMaterial,
      arguments: MaterialEditArguments(
        workOrderId: woTaskId,
        material: editable,
      ),
    ) as bool?;

    if (changed == true) {
      await _bloc.refresh();
    }
  }

  Future<void> _openAddMaterial(String woTaskId) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ComplaintAdd(
          MaterialAddArguments(workOrderId: woTaskId),
        ),
      ),
    );

    if (changed == true) {
      await _bloc.refresh();
    }
  }

  Widget _buildEmptyState({required bool canAdd, VoidCallback? onAdd}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(GemsChrome.radius),
        border: Border.all(color: GemsChrome.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 40, color: GemsChrome.muted),
          const SizedBox(height: 12),
          Text(
            'No materials yet',
            style: GemsChrome.heading(size: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Add the parts you plan to use so we can keep track.',
            textAlign: TextAlign.center,
            style: GemsChrome.body(size: 13, color: GemsChrome.textSoft),
          ),
          if (canAdd && onAdd != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(
                'Add material',
                style: GemsChrome.body(weight: FontWeight.w600, color: GemsChrome.primary),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: GemsChrome.primary,
                side: const BorderSide(color: GemsChrome.primary),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GemsChrome.radius),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddFab(VoidCallback onPressed) {
    return FloatingActionButton(
      heroTag: 'mr_add_material',
      onPressed: onPressed,
      backgroundColor: GemsChrome.primary,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  Widget? _buildPrimaryActions(String statusId) {
    if (widget.isApproval && statusId != "33") {
      return null;
    }

    final List<Widget> children = [];
    if (widget.isApproval && statusId == "33") {
      children.add(
        _BuildRejectButton(
          (v) => _bloc
              .reject(v)
              .then((_) => Navigator.pop(context))
              .catchError((e) => Toast.show(e)),
          (e) => Toast.show(e),
        ),
      );
      children.add(const SizedBox(width: 12));
    }

    children.add(
      FloatingActionButton.extended(
        heroTag: "approve_submit_button",
        foregroundColor: Colors.white,
        label: Text(
          _bloc.titleButton(statusId, isApproval: widget.isApproval),
          style: GemsChrome.body(weight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: GemsChrome.primary,
        onPressed: () => _bloc
            .onclick(widget.isApproval)
            .then((_) => Navigator.pop(context))
            .catchError((e) => Toast.show(e)),
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GemsChrome.page,
      appBar: gemsAppBar(
        title: const Text('Material Requisition'),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _bloc.refresh,
            child: StreamBuilder<RequestTask>(
              stream: _bloc.detail$.cast<RequestTask>(),
              builder: (ctx, snap) {
                final data = snap.data;
                final status = GemsStatusStyle.forInventory(data?.statusDesc);
                return ListView(
                  padding: const EdgeInsets.only(bottom: 100),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: GemsFormSection(
                        title: 'Request',
                        icon: Icons.assignment_outlined,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if ((data?.statusDesc ?? '').isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: status.background,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  data!.statusDesc!,
                                  style: GemsChrome.body(
                                    size: 12,
                                    weight: FontWeight.w600,
                                    color: status.foreground,
                                  ),
                                ),
                              ),
                            _infoRow(Icons.tag_outlined, 'MR No', data?.woTaskRequestNo ?? '-'),
                            _infoRow(Icons.calendar_today_outlined, 'Request date', data?.requestTime ?? '-'),
                            _infoRow(Icons.person_outline, 'Requested by', data?.requestBy ?? '-'),
                            _infoRow(Icons.receipt_long_outlined, 'WO No', data?.woTaskNo ?? '-'),
                            _infoRow(Icons.priority_high, 'Priority', data?.woSeverityDesc ?? '-'),
                            _infoRow(Icons.location_on_outlined, 'Location', data?.siteName ?? '-'),
                            if ((data?.collectTime ?? '').isNotEmpty)
                              _infoRow(Icons.check_circle_outline, 'Checkout date', data!.collectTime!),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: Text('Materials', style: GemsChrome.heading(size: 16)),
                    ),

                    // Materials list
                    StreamBuilder<List<item.Material>>(
                      stream: _bloc.materials$,
                      builder: (c, msnap) {
                        final mats = msnap.data ?? [];
                        final String? woTaskId = _resolveWorkOrderId(data);
                        final bool canAdd = _canAddMaterials(data, woTaskId);
                        final bool canEdit =
                          widget.isApproval && !_isRejected(data) && woTaskId != null;
                        final String? editableWoTaskId = canEdit ? woTaskId : null;
                        final VoidCallback? addHandler =
                          (canAdd && woTaskId != null)
                            ? () => _openAddMaterial(woTaskId)
                            : null;
                        if (mats.isEmpty) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: _buildEmptyState(
                              canAdd: addHandler != null,
                              onAdd: addHandler,
                            ),
                          );
                        }
                        return Column(
                          children: mats
                              .map((m) => _MaterialCard(
                                    mat: m,
                                    isApproval: widget.isApproval,
                                    onTap: editableWoTaskId != null
                                        ? () => _openEditMaterial(
                                              material: m,
                                              woTaskId: editableWoTaskId,
                                            )
                                      : null,
                                  ))
                              .toList(),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),

          // global loading overlay
          if (_loading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: GemsChrome.primary),
              ),
            ),
        ],
      ),

      floatingActionButton: StreamBuilder<RequestTask>(
        stream: _bloc.detail$.cast<RequestTask>(),
        builder: (ctx, snap) {
          final data = snap.data;
          final statusId = data?.statusId ?? widget.value.statusId ?? "-1";
          final woTaskId = _resolveWorkOrderId(data);
          final canAdd = _canAddMaterials(data, woTaskId);

          Widget? addButton;
          if (canAdd && woTaskId != null) {
            addButton = _buildAddFab(() => _openAddMaterial(woTaskId));
          }

          Widget? actionRow;
          if (!widget.isCheckout) {
            actionRow = _buildPrimaryActions(statusId);
          }

          if (addButton == null && actionRow == null) {
            return const SizedBox.shrink();
          }

          final children = <Widget>[
            if (addButton != null) addButton,
            if (addButton != null && actionRow != null)
              const SizedBox(height: 12),
            if (actionRow != null) actionRow,
          ];

          return Padding(
            padding: const EdgeInsets.only(bottom: 16, right: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: children,
            ),
          );
        },
      ),
    );
  }
}

class _MaterialCard extends StatelessWidget {
  final item.Material mat;
  final bool isApproval;
  final VoidCallback? onTap;

  const _MaterialCard({
    required this.mat,
    required this.isApproval,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final int qty = int.tryParse(mat.woTaskPartsQuantity ?? "") ?? 0;
    final int threshold = int.tryParse(mat.partThreshold ?? "") ?? 0;
    final int available = int.tryParse(mat.partAvailable ?? "") ?? 0;

    final bool isError = available < threshold;
    final bool isWarning = available == threshold;
    final bool isSuccess = available > qty;

    final Color accent = isError
        ? GemsChrome.danger
        : isWarning
            ? GemsChrome.warning
            : isSuccess
                ? GemsChrome.success
                : GemsChrome.primary;

    final body = Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mat.itemDescription ?? '',
            style: GemsChrome.body(size: 14, weight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            '${mat.assetGroupName}  |  ${mat.itemTypeDesc}',
            style: GemsChrome.body(size: 13, color: GemsChrome.textSoft),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _infoChip('Qty', '$qty'),
              _infoChip('Threshold', '$threshold'),
              _infoChip(
                'Available',
                '$available',
                isError: isError,
                isWarning: isWarning,
                isSuccess: isSuccess,
              ),
            ],
          ),
          if (onTap != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text(
                  'Edit quantity',
                  style: GemsChrome.body(weight: FontWeight.w600, color: GemsChrome.primary),
                ),
                style: TextButton.styleFrom(foregroundColor: GemsChrome.primary),
              ),
            ),
          ],
          if (isApproval) ...[
            const SizedBox(height: 8),
            const Divider(height: 1, color: GemsChrome.border),
            const SizedBox(height: 8),
            Text('Remark', style: GemsChrome.body(weight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              mat.woTaskPartsRemark ?? '-',
              style: GemsChrome.body(size: 14),
            ),
          ],
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GemsChrome.radius),
          side: const BorderSide(color: GemsChrome.border),
        ),
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ColoredBox(color: accent, child: const SizedBox(width: 5)),
                Expanded(child: body),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoChip(
    String label,
    String value, {
    bool isError = false,
    bool isWarning = false,
    bool isSuccess = false,
  }) {
    late final Color bg;
    late final Color fg;

    if (isError) {
      bg = GemsChrome.dangerSoft;
      fg = GemsChrome.dangerFg;
    } else if (isWarning) {
      bg = GemsChrome.warningSoft;
      fg = GemsChrome.warning;
    } else if (isSuccess) {
      bg = GemsChrome.successSoft;
      fg = GemsChrome.success;
    } else {
      bg = GemsChrome.primarySoft;
      fg = GemsChrome.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: GemsChrome.body(size: 12, color: fg)),
          Text(
            value,
            style: GemsChrome.body(size: 14, weight: FontWeight.w600, color: fg),
          ),
        ],
      ),
    );
  }
}

class _BuildRejectButton extends StatelessWidget {
  final Future<void> Function(String) reject;
  final Function(String) alert;

  const _BuildRejectButton(this.reject, this.alert, {super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: "reject_button",
      foregroundColor: Colors.white,
      label: Text(
        'Reject',
        style: GemsChrome.body(weight: FontWeight.w600, color: Colors.white),
      ),
      backgroundColor: GemsChrome.danger,
      onPressed: () => showDialog(
        context: context,
        builder: (_) => CustomDialog(
          rootPage: "/workorder",
          title: "Remark",
          description: "Please enter reject remark",
          buttonText: "Okay",
          secondButton: false,
          image: Image.asset("assets/icon_trans.png", height: 40),
          remarkTapped: (text) {
            Navigator.pop(context);
            reject(text);
          },
        ),
      ),
    );
  }
}

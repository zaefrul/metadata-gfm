// lib/controller/Storekeeper/route/storekeeper/route_MR.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toast/toast.dart';
import 'package:GEMS/utils/reference.dart';
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

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: colorTheme2),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
          Text(value, style: GoogleFonts.poppins()),
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

    final changed = await Navigator.pushNamed<bool>(
      context,
      storekeeper_constants.routeMaterial,
      arguments: MaterialEditArguments(
        workOrderId: woTaskId,
        material: editable,
      ),
    );

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
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inventory_2_outlined,
              size: 48, color: AppColors.gray400),
          const SizedBox(height: 12),
          Text(
            'No materials yet',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add the parts you plan to use so we can keep track.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          if (canAdd && onAdd != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text('Add material',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.add, color: AppColors.white),
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
        label: Text(
          _bloc.titleButton(statusId, isApproval: widget.isApproval),
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: _bloc.colorButton(statusId),
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
      appBar: AppBar(
        title: Text("Material Requisition",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600, color: colorTheme3)),
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: IconThemeData(color: colorTheme3),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _bloc.refresh,
            child: StreamBuilder<RequestTask>(
              stream: _bloc.detail$.cast<RequestTask>(),
              builder: (ctx, snap) {
                final data = snap.data;
                return ListView(
                  padding: const EdgeInsets.only(bottom: 100),
                  children: [
                    _row(Icons.request_page, "MR No",
                        data?.woTaskRequestNo ?? "-"),
                    Divider(height: 1, color: colorTheme1Light),
                    _row(Icons.calendar_today, "Request Date",
                        data?.requestTime ?? "-"),
                    Divider(height: 1, color: colorTheme1Light),
                    _row(Icons.person, "Requested By",
                        data?.requestBy ?? "-"),
                    Divider(height: 1, color: colorTheme1Light),
                    _row(Icons.receipt, "WO No", data?.woTaskNo ?? "-"),
                    Divider(height: 1, color: colorTheme1Light),
                    _row(Icons.priority_high, "Priority",
                        data?.woSeverityDesc ?? "-"),
                    Divider(height: 1, color: colorTheme1Light),
                    _row(Icons.location_on, "Location",
                        data?.siteName ?? "-"),
                    if ((data?.collectTime ?? "").isNotEmpty) ...[
                          Divider(height: 1, color: colorTheme1Light),
                      _row(Icons.check_circle, "Checkout Date",
                          data!.collectTime!),
                    ],

                    // Section title
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 24),
                      child: Text("Materials",
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                    ),

                    // Materials list
                    StreamBuilder<List<item.Material>>(
                      stream: _bloc.materials$,
                      builder: (c, msnap) {
                        final mats = msnap.data ?? [];
                        final String? woTaskId = _resolveWorkOrderId(data);
                        final bool canAdd = _canAddMaterials(data, woTaskId);
                        final bool canEdit = !_isRejected(data) && woTaskId != null;
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
              child: const Center(child: CircularProgressIndicator()),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mat.itemDescription ?? "",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${mat.assetGroupName}  |  ${mat.itemTypeDesc}",
                    style: GoogleFonts.poppins(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _infoChip("Qty", "$qty"),
                      _infoChip("Threshold", "$threshold"),
                      _infoChip(
                        "Available",
                        "$available",
                        isError: isError,
                        isWarning: isWarning,
                        isSuccess: isSuccess,
                      ),
                    ],
                  ),
                  if (isApproval) ...[
                    const SizedBox(height: 12),
                    Divider(color: AppColors.divider),
                    const SizedBox(height: 8),
                    Text(
                      "Remark",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mat.woTaskPartsRemark ?? "-",
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ],
                ],
              ),
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
      bg = AppColors.dangerLight;
      fg = AppColors.danger;
    } else if (isWarning) {
      bg = AppColors.warningLight;
      fg = AppColors.warningDark;
    } else if (isSuccess) {
      bg = AppColors.successLight;
      fg = AppColors.successDark;
    } else {
      bg = AppColors.primaryLight;
      fg = AppColors.primaryDark;
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
          Text(label,
              style: GoogleFonts.poppins(fontSize: 12, color: fg)),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w600, color: fg)),
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
      label: const Text("Reject", style: TextStyle(color: AppColors.white)),
      backgroundColor: colorTheme4,
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

// lib/controller/Storekeeper/route/storekeeper/route_MR.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toast/toast.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/bloc/bloc_task.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/widget/dialog.dart';
import 'package:gfm_gems/model/complaint.dart';
import 'package:gfm_gems/model/material.dart' as item;

class MaterialRequestScreen extends StatefulWidget {
  final RequestTask value;
  final bool isApproval;
  final bool isCheckout;

  const MaterialRequestScreen({
    required this.value,
    this.isApproval = false,
    this.isCheckout = false,
    Key? key,
  }) : super(key: key);

  @override
  _MaterialRequestScreenState createState() => _MaterialRequestScreenState();
}

class _MaterialRequestScreenState extends State<MaterialRequestScreen> {
  late final MaterialTask _bloc;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _bloc = MaterialTask(widget.value.woTaskRequestId ?? '');
    ToastContext().init(context);

    _bloc.loadingState$.listen((isLoading) {
      if (mounted) setState(() => _loading = isLoading);
    });
    _bloc.err$.listen((err) {
      Toast.show(err, duration: Toast.lengthLong, gravity: Toast.bottom);
    });
  }

  @override
  void dispose() {
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
                        if (mats.isEmpty) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: Text("No materials requested",
                                style: GoogleFonts.poppins(
                                    color: colorTheme3Light)),
                          );
                        }
                        return Column(
                          children: mats
                              .map((m) => _MaterialCard(
                                    mat: m,
                                    isApproval: widget.isApproval,
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

      floatingActionButton: widget.isCheckout
          ? null
          : StreamBuilder<RequestTask>(
              stream: _bloc.detail$.cast<RequestTask>(),
              builder: (ctx, snap) {
                final statusId = snap.data?.statusId ?? "-1";
                if (widget.isApproval && statusId != "33") return SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16, right: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (statusId == "33") ...[
                        _BuildRejectButton(
                          (v) => _bloc
                              .reject(v)
                              .then((_) => Navigator.pop(context))
                              .catchError((e) => Toast.show(e)),
                          (e) => Toast.show(e),
                        ),
                        const SizedBox(width: 12),
                      ],
                      FloatingActionButton.extended(
                        label: Text(_bloc.titleButton(statusId),
                            style: GoogleFonts.poppins(color: Colors.white)),
                        backgroundColor: _bloc.colorButton(statusId),
                        onPressed: () => _bloc
                            .onclick(widget.isApproval)
                            .then((_) => Navigator.pop(context))
                            .catchError((e) => Toast.show(e)),
                      ),
                    ],
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

  const _MaterialCard({
    required this.mat,
    required this.isApproval,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // parse your ints (fallback to 0 if parsing fails)
    final int qty =
        int.tryParse(mat.woTaskPartsQuantity ?? '') ?? 0;
    final int threshold =
        int.tryParse(mat.partThreshold ?? '') ?? 0;
    final int available =
        int.tryParse(mat.partAvailable ?? '') ?? 0;

    // compute the three‐state flags
    final bool isError = available < threshold;   // below threshold
    final bool isWarning = available == threshold; // exactly at threshold
    final bool isSuccess = available > qty;       // more than requested

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mat.itemDescription ?? "",
                style: GoogleFonts.poppins(
                    fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              "${mat.assetGroupName}  |  ${mat.itemTypeDesc}",
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),

            // responsive chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _infoChip("Qty", "$qty"),
                _infoChip("Threshold", "$threshold"),
                _infoChip("Available", "$available",
                    isError: isError,
                    isWarning: isWarning,
                    isSuccess: isSuccess),
              ],
            ),

            if (isApproval) ...[
              const SizedBox(height: 12),
              Divider(color: AppColors.divider),
              const SizedBox(height: 8),
              Text("Remark",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 4),
              Text(mat.woTaskPartsRemark ?? "-",
                  style: GoogleFonts.poppins(fontSize: 14)),
            ],
          ],
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

  const _BuildRejectButton(this.reject, this.alert, {Key? key})
      : super(key: key);

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

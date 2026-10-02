import 'dart:async';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';
import 'package:GEMS/data/repository/work_order_detail_repository.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/view/gems_chrome.dart';
import 'package:GEMS/view/dialog.dart';
import 'package:GEMS/main.dart';
import 'package:GEMS/controller/WorkOrder/pending_sync.dart';
import 'package:GEMS/controller/WorkOrder/widgets/pending_sync_banner.dart';

class ComplaintSectionD extends StatefulWidget {
  final String id;
  final bool viewer;
  final String name;
  final PendingSyncController? pendingSync;
  final Stream<WorkOrderSnapshotData?>? snapshotStream;
  final WorkOrderSnapshotData? initialSnapshot;

  const ComplaintSectionD({
    super.key,
    this.name = "D",
    required this.id,
    required this.viewer,
    this.pendingSync,
    this.snapshotStream,
    this.initialSnapshot,
  });

  @override
  _ComplaintSectionDState createState() => _ComplaintSectionDState();
}

class _ComplaintSectionDState extends State<ComplaintSectionD> {
  bool _loading = false;
  String _assetNo = "";
  late Provider _provider;
  late final WorkOrderDetailRepository _repository;
  final TextEditingController _controller = TextEditingController();
  String _scanError = "";
  StreamSubscription<WorkOrderSnapshotData?>? _snapshotSub;

  @override
  void initState() {
    super.initState();
    _provider = Provider(
      fetchURL: "/api/m_wo.php?type=complaint_details&woTaskId=",
      taskID: widget.id,
    );
    _repository = WorkOrderDetailRepository();
    _applySnapshot(widget.initialSnapshot);
    _loadExisting();
    _listenToSnapshots();
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
    final detail = snapshot?.complaintDetail;
    if (detail == null) return;
    final asset = detail.assetNo ?? '';
    if (asset.isEmpty) return;
    if (!mounted) return;
    if (_assetNo == asset) return;
    setState(() {
      _assetNo = asset;
      _controller.text = asset;
    });
  }

  Future<void> _loadExisting() async {
    if (!mounted) return;
    setState(() => _loading = true);
    _provider.context = context;
    try {
      final resp = await _provider.fetch();
      final fetchedAssetNo = resp.woDetail?.assetNo ?? "";
      if (!mounted) return;
      setState(() {
        _assetNo = fetchedAssetNo;
        _controller.text = fetchedAssetNo;
      });
    } catch (_) {
      // ignore
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _snapshotSub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);

    return Scaffold(
      backgroundColor: GemsChrome.page,
      appBar: gemsAppBar(
        title: Text("${widget.name}. Asset No"),
        actions: widget.viewer
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.photo_camera_outlined),
                  onPressed: _scanBarcode,
                )
              ],
      ),
      body: Column(
        children: [
          if (widget.pendingSync != null)
            PendingSyncIndicator(controller: widget.pendingSync!),
          Expanded(
            child: Stack(
              children: [
                _buildBody(),
                if (_loading)
                  const ColoredBox(
                    color: Color(0xB8F1F5F9),
                    child: Center(
                      child: CircularProgressIndicator(color: GemsChrome.primary),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter the asset number, or scan it from the camera.',
            style: GemsChrome.body(size: 13, color: GemsChrome.textSoft),
          ),
          const SizedBox(height: 16),
          GemsFormSection(
            title: 'Asset number',
            icon: Icons.confirmation_number_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Asset No',
                  style: GemsChrome.body(size: 13, weight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: _controller,
                  enabled: !widget.viewer,
                  style: GemsChrome.body(size: 14),
                  decoration: gemsFieldDecoration(enabled: !widget.viewer).copyWith(
                    hintText: 'Enter or scan asset no',
                  ),
                  onChanged: (v) => _assetNo = v,
                ),
                if (_scanError.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    _scanError,
                    style: GemsChrome.body(size: 12, color: GemsChrome.danger),
                  ),
                ],
              ],
            ),
          ),
          if (!widget.viewer) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: gemsPrimaryButton(),
                onPressed: _loading ? null : _saveAssetNo,
                child: Text(
                  'Save',
                  style: GemsChrome.body(
                    size: 15,
                    weight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _scanBarcode() async {
    try {
      var result = await BarcodeScanner.scan();
      if (!mounted) return;
      setState(() {
        _assetNo = result.rawContent;
        _controller.text = _assetNo;
        _scanError = "";
      });
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() {
        _scanError = e.code == BarcodeScanner.cameraAccessDenied
            ? "Camera permission denied"
            : "Scan failed, try again";
      });
    } on FormatException {
      if (!mounted) return;
      setState(() {
        _scanError = "Scan cancelled";
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _scanError = "Unknown error scanning";
      });
    }
    if (_scanError.isNotEmpty) Toast.show(_scanError);
  }

  Future<void> _saveAssetNo() async {
    if (_loading) return;
    // Commented out the asset number check as per the original code
    // if (_assetNo.isEmpty) {
    //   Toast.show("Please enter or scan an asset number");
    //   return;
    // }
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final result = await _repository.saveAssetNumber(widget.id, _assetNo);
      if (!mounted) return;
      if (result == WorkOrderActionResult.success) {
        _showAlert('Asset number saved successfully.', backOne: true);
      } else {
        _showAlert(
          "You're offline right now. We'll sync this asset number once you're back online.",
          backOne: true,
        );
      }
    } catch (err) {
      _showAlert(err.toString());
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _showAlert(String txt, {bool backOne = false}) {
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (_) => CustomDialog(
        goBackOnDismiss: backOne,
        description: txt,
        buttonText: "Okay",
        image: Image.asset("assets/icon_trans.png", height: 40),
      ),
    );
  }

}

/// Simple full‑screen comments viewer
class ComplaintSectionE extends StatelessWidget {
  final String text;
  final String sect;
  final PendingSyncController? pendingSync;

  const ComplaintSectionE(this.text, this.sect, {super.key, this.pendingSync});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GemsChrome.page,
      appBar: gemsAppBar(
        title: Text("$sect. Comment"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (pendingSync != null)
            PendingSyncIndicator(controller: pendingSync!),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: GemsFormSection(
                title: 'Comment',
                icon: Icons.notes_outlined,
                child: Text(
                  text,
                  style: GemsChrome.body(size: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

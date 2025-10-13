import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';
import 'package:GEMS/data/repository/work_order_detail_repository.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:GEMS/view/dialog.dart';
import 'package:GEMS/main.dart';
import 'package:GEMS/controller/WorkOrder/pending_sync.dart';
import 'package:GEMS/controller/WorkOrder/widgets/pending_sync_banner.dart';

class ComplaintSectionD extends StatefulWidget {
  final String id;
  final bool viewer;
  final String name;
  final PendingSyncController? pendingSync;

  const ComplaintSectionD({
    super.key,
    this.name = "D",
    required this.id,
    required this.viewer,
    this.pendingSync,
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

  @override
  void initState() {
    super.initState();
    _provider = Provider(
      fetchURL: "/api/m_wo.php?type=complaint_details&woTaskId=",
      taskID: widget.id,
    );
    _repository = WorkOrderDetailRepository();
    _loadExisting();
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
  Widget build(BuildContext context) {
    ToastContext().init(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: colorTheme3),
        title: Text(
          "${widget.name}. Asset No",
          style: TextStyle(color: colorTheme3, fontWeight: FontWeight.bold),
        ),
        actions: widget.viewer
            ? null
            : [
                IconButton(
                  icon: Icon(Icons.camera_alt, color: colorTheme3),
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
                  Container(
                    color: Colors.black38,
                    child: Center(child: CircularProgressIndicator()),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _row(
            icon: Icons.confirmation_number,
            label: "Asset No",
            child: TextField(
              controller: _controller,
              enabled: !widget.viewer,
              decoration: InputDecoration(
                hintText: "Enter or scan asset no",
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              onChanged: (v) => _assetNo = v,
            ),
          ),
          if (_scanError.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_scanError,
                  style: TextStyle(color: Colors.red, fontSize: 12)),
            ),
          const SizedBox(height: 40),
          if (!widget.viewer)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  backgroundColor: colorTheme2,
                ),
                onPressed: _saveAssetNo,
                child: Text("Save", style: TextStyle(color: Colors.white)),
              ),
            ),
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

  Widget _row({
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: colorTheme2),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(label,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          ),
          Expanded(flex: 3, child: child),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
      appBar: AppBar(
        title: Text("$sect. Comment"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          if (pendingSync != null)
            PendingSyncIndicator(controller: pendingSync!),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Text(text, style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

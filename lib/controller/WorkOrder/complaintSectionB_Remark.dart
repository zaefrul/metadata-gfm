import 'package:flutter/material.dart';
import 'package:GEMS/data/repository/work_order_detail_repository.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:GEMS/view/dialog.dart';
import 'package:toast/toast.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../main.dart';
import 'package:GEMS/controller/WorkOrder/pending_sync.dart';
import 'package:GEMS/controller/WorkOrder/widgets/pending_sync_banner.dart';

class ComplaintSectionB extends StatefulWidget {
  final String id;
  final bool viewer;
  final String name;           // re‑add this
  final PendingSyncController? pendingSync;

  const ComplaintSectionB({
    super.key,
    this.name = "B",           // default “B”
    required this.id,
    this.viewer = false,
    this.pendingSync,
  });

  @override
  _ComplaintSectionBState createState() => _ComplaintSectionBState();
}

class _ComplaintSectionBState extends State<ComplaintSectionB> {
  bool _loading = true;
  String _remark = "";
  late Provider _provider;
  late final WorkOrderDetailRepository _repository;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  _repository = WorkOrderDetailRepository();
    _provider = Provider(
      taskID: widget.id,
      fetchURL: "/api/m_wo.php?type=wo_repair_work&woTaskId=",
    );
    // fetch existing remark
    _provider.context = context;
    _provider
      .fetch()
      .then((resp) {
        final text = resp.result ?? "";
        if (!mounted) return;
        setState(() {
          _remark = text;
          _controller.text = text;
        });
      })
      .catchError((e) {
        debugPrint(e.toString());
        return null;
      })
      .whenComplete(() {
        if (mounted) {
          setState(() => _loading = false);
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (_remark.trim().length < 2) {
      Toast.show("Please enter at least 2 characters", duration: Toast.lengthShort);
      return;
    }
    setState(() => _loading = true);
    _repository
        .saveRepairWork(widget.id, _remark)
        .then((result) {
      if (!mounted) return;
      if (result == WorkOrderActionResult.success) {
        _showAlert('Repair work saved successfully.');
      } else {
        _showAlert('You\'re offline right now. We\'ll sync this repair note once you\'re back online.');
      }
    }).catchError((e) {
      _showAlert(e.toString());
    }).whenComplete(() {
      if (mounted) {
        setState(() => _loading = false);
      }
    });
  }

  void _showAlert(String txt) {
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (_) => CustomDialog(
        goBackOnDismiss: true,
        description: txt,
        buttonText: "Okay",
        image: Image.asset("assets/icon_trans.png", height: 40),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: colorTheme3),
        title: Text(
          "B. Description of Repair Work",
          style: GoogleFonts.poppins(
            color: colorTheme3,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          if (widget.pendingSync != null)
            PendingSyncIndicator(controller: widget.pendingSync!),
          Expanded(
            child: Stack(
              children: [
                if (_loading)
                  Center(child: CircularProgressIndicator()),
                // even when loading, show the field underneath a dim overlay
                Opacity(
                  opacity: _loading ? 0.5 : 1.0,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Your Repair Notes",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: colorTheme3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            child: TextField(
                              enabled: !widget.viewer,
                              controller: _controller,
                              style: GoogleFonts.poppins(fontSize: 14),
                              maxLines: null,
                              maxLength: 1000,
                              decoration: InputDecoration(
                                hintText: "Describe the repair work here…",
                                border: InputBorder.none,
                                counterText: "",
                              ),
                              onChanged: (val) => _remark = val,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.viewer
          ? null
          : AnimatedPadding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: (MediaQuery.of(context).viewInsets.bottom > 0
                        ? MediaQuery.of(context).viewInsets.bottom + 16
                        : 16),
                top: 16,
              ),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: SafeArea(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: colorTheme2,
                  ),
                  onPressed: _save,
                  child: Text(
                    "Save",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

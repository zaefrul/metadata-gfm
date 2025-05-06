import 'package:flutter/material.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:gfm_gems/view/dialog.dart';
import 'package:toast/toast.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../main.dart';

class ComplaintSectionB extends StatefulWidget {
  final String id;
  final bool viewer;
  final String name;           // re‑add this

  const ComplaintSectionB({
    Key? key,
    this.name = "B",           // default “B”
    required this.id,
    this.viewer = false,
  }) : super(key: key);

  @override
  _ComplaintSectionBState createState() => _ComplaintSectionBState();
}

class _ComplaintSectionBState extends State<ComplaintSectionB> {
  bool _loading = true;
  String _remark = "";
  late Provider _provider;

  @override
  void initState() {
    super.initState();
    _provider = Provider(
      taskID: widget.id,
      fetchURL: "/api/m_wo.php?type=wo_repair_work&woTaskId=",
    );
    // fetch existing remark
    _provider.context = context;
    _provider
      .fetch()
      .then((resp) => setState(() => _remark = resp.result ?? ""))
      .catchError((e) => print(e))
      .whenComplete(() => setState(() => _loading = false));
  }

  void _save() {
    if (_remark.trim().length < 2) {
      Toast.show("Please enter at least 2 characters", duration: Toast.lengthShort);
      return;
    }
    setState(() => _loading = true);
    _provider
      .post(url: "/api/m_wo.php", body: {
        "action": "save_wo_repair_work",
        "woTaskId": widget.id,
        "repairWork": _remark,
      })
      .then((msg) => _showAlert(msg))
      .catchError((e) => _showAlert(e.toString()))
      .whenComplete(() => setState(() => _loading = false));
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
      body: Stack(
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
                        controller: TextEditingController(text: _remark),
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
      bottomNavigationBar: widget.viewer
          ? null
          : Padding(
              padding: const EdgeInsets.all(16),
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
    );
  }
}

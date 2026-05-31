import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:GEMS/utils/biometric_lock_manager.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/view/dialog.dart';
import 'package:GEMS/view/signature.dart';
import 'package:GEMS/utils/reference.dart';
import 'dart:io';
import '../../../main.dart';

class PDF extends StatefulWidget {
  final bool viewer;
  final String id;
  final String transactionNo;
  final VoidCallback? submitted;
  final int checkpoint;

  const PDF({
    required this.id,
    required this.transactionNo,
    this.submitted,
    required this.checkpoint,
    this.viewer = false,
    super.key,
  });

  @override
  State<PDF> createState() => _PDFState();
}

class _PDFState extends State<PDF> {
  String assetPDFPath = "";
  CustomDialog? dialog;
  String src = "";

  @override
  void initState() {
    super.initState();
    Provider provider = Provider(
      fetchURL: "/api/m_ppm.php?type=preview_pdf&ppmTaskId=${widget.id}",
    );

    provider.fetch().then((value) {
      debugPrint('Fetch response: ${value.toString()}'); // Log the response
      if (value.result == null || value.result is! String) {
        debugPrint("Invalid or missing result in fetch response");
        return Future.error("Invalid PDF URL");
      }
      src = "http:${value.result}";
      return createFileOfPdfUrl(src);
    }).then((file) {
      setState(() => assetPDFPath = file.path);
    }).catchError((err) {
      debugPrint("Error in fetch or file creation: $err");
    });
  }

  Future<File> createFileOfPdfUrl(String url) async {
    final filename = url.substring(url.lastIndexOf("/") + 1);
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    final dir = (await getApplicationDocumentsDirectory()).path;
    File file = File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    String submitText = "Complete";
    if (widget.checkpoint == 2) submitText = "Check";
    if (widget.checkpoint == 3) submitText = "Verify";

    return Scaffold(
      appBar: AppBar(
        title: title(widget.transactionNo),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: colorTheme3),
        actions: widget.viewer
            ? null
            : [
                if (widget.checkpoint > 1)
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        dialog = CustomDialog(
                          title: "Remark",
                          description: "Remark",
                          buttonText: "Okay",
                          cancel: true,
                          image: Image.asset(
                            "assets/icon_trans.png",
                            height: 40,
                          ),
                          remarkTapped: (text) {
                            Navigator.pop(context);
                            post(text);
                          },
                        );

                        showDialog(
                          context: navigatorKey.currentContext!,
                          builder: (_) => dialog!,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.0),
                          color: Colors.redAccent,
                        ),
                        width: 80,
                        child: Center(child: title("Re-Open", bold: false)),
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SignatureView(
                            id: widget.id,
                            result: "Check",
                            checkpoint: widget.checkpoint.toString(),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.0),
                        color: colorTheme2,
                      ),
                      width: 80,
                      child: Center(child: title(submitText, bold: false)),
                    ),
                  ),
                ),
              ],
      ),
      body: assetPDFPath.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.picture_as_pdf, size: 72, color: Colors.black54),
                    const SizedBox(height: 16),
                    const Text(
                      'PDF ready. Open it with your device viewer.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Open PDF'),
                      onPressed: openPdfFile,
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text("Open File"),
        onPressed: openPdfFile,
      ),
    );
  }

  Widget title(String text, {bool bold = true}) => Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: bold ? colorTheme3 : Colors.white,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      );

  void post(String text) {
    var body = UploadItem(
      checkpoint: widget.checkpoint.toString(),
      id: widget.id,
      remark: text,
    );

    Provider provider = Provider(fetchURL: "/api/m_ppm.php");
    provider.context = context;
    provider
        .post(url: "/api/m_ppm.php", body: body.body)
        .then((value) => alert(value))
        .catchError((err) => alert(err.toString()));
  }

  Future<void> openPdfFile() async {
    if (assetPDFPath.isEmpty) {
      return;
    }

    final uri = Uri.file(assetPDFPath);
    final launched = await BiometricLockManager.launchExternalUrl(uri);
    if (!launched && src.isNotEmpty) {
      await BiometricLockManager.launchExternalUrlString(src);
    }
  }

  void alert(String txt) {
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (_) => CustomDialog(
        rootPage: "/ppm",
        description: txt,
        buttonText: "Okay",
        image: Image.asset("assets/icon_trans.png", height: 40),
      ),
    );
  }
}

class UploadItem extends Upload {
  final String checkpoint;
  final String remark;

  UploadItem({
    required String id,
    required this.checkpoint,
    required this.remark,
  }) : super(ppmTaskId: id, action: "submit_ppm");

  @override
  Map<String, dynamic> get body => {
        "action": action,
        "ppmTaskId": ppmTaskId,
        "checkpoint": checkpoint,
        "result": "2",
        "remark": remark,
        "fileUpload[name]": "",
        "fileUpload[filename]": "",
        "fileUpload[size]": "",
        "fileUpload[type]": "",
        "fileUpload[data]": "",
      };
}

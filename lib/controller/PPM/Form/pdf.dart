import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/view/dialog.dart';
import 'package:gfm_gems/view/signature.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'dart:io';

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
    Key? key,
  }) : super(key: key);

  @override
  _PDFState createState() => _PDFState();
}

class _PDFState extends State<PDF> {
  String assetPDFPath = "";
  bool pdfReady = false;
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
                          context: context,
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
          ? Center(child: CircularProgressIndicator())
          : PDFView(
              filePath: assetPDFPath,
              autoSpacing: true,
              enableSwipe: true,
              pageSnap: true,
              swipeHorizontal: true,
              nightMode: false,
              onError: (e) => debugPrint("PDF Error: $e"),
              onRender: (_) => setState(() => pdfReady = true),
              onPageChanged: (_, __) {},
              onPageError: (_, e) => debugPrint("Page Error: $e"),
            ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text("Open File"),
        onPressed: () async {
          final uri = Uri.parse(src);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          } else {
            debugPrint('Could not launch $src');
          }
        },
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

  void alert(String txt) {
    showDialog(
      context: context,
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

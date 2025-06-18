import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:GEMS/utils/network.dart';
import 'package:GEMS/view/dialog.dart';
import 'package:GEMS/utils/reference.dart';

import 'complaintSign.dart';

import '../../main.dart';

class ComplaintPDF extends StatefulWidget {
  final bool viewer;
  final String id;
  final String transactionNo;
  final Function? submitted;
  final int checkpoint;
  final String taskCategory;

  const ComplaintPDF({
    super.key,
    required this.viewer,
    required this.id,
    required this.transactionNo,
    this.submitted,
    required this.checkpoint,
    required this.taskCategory,
  });

  @override
  _ComplaintPDFState createState() => _ComplaintPDFState();
}

class _ComplaintPDFState extends State<ComplaintPDF> {
  String assetPDFPath = "";
  bool pdfReady = false;
  late CustomDialog dialog; // Initialize with a default value
  late String src;

  @override
  void initState() {
    super.initState();

    Provider provider = Provider(
        fetchURL: "/api/m_wo.php?type=preview_pdf&woTaskId=${widget.id}");
    provider.context = context;

    provider.fetch().then((value) {
      debugPrint(value.toString());
      src = "http:${value.result ?? ""}";
      return createFileOfPdfUrl(src);
    }).then((file) {
      setState(() => assetPDFPath = file.path);
    }).catchError((err) {
      print(err);
    });

    // Initialize dialog with a default value to avoid LateInitializationError
    dialog = CustomDialog(
      rootPage: "/workorder",
      title: "",
      description: "",
      buttonText: "Okay",
      image: Image.asset(
        "assets/icon_trans.png",
        height: 40,
      ),
    );
  }

  Future<File> createFileOfPdfUrl(String url) async {
    final filename = url.substring(url.lastIndexOf("/") + 1);
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  @override
  void dispose() {
    // Dispose dialog's controller only if it has been initialized
    dialog.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Checkpoint are : ${widget.checkpoint}');
    String submitText = "Complete";
    if (widget.checkpoint == 1 || widget.checkpoint == 5) submitText = "Verify";
    if (widget.checkpoint == 2 || widget.checkpoint == 4 || widget.checkpoint == 6) submitText = "Check";
    if (widget.checkpoint == 3) submitText = "Complete";

    return Scaffold(
      appBar: AppBar(
        title: title(widget.transactionNo),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: colorTheme3,
        ),
        actions: widget.viewer
            ? null
            : <Widget>[
                widget.checkpoint == 1 && submitText != "Verify"
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            dialog = CustomDialog(
                              rootPage: "/workorder",
                              title: "Remark",
                              description: "Remark",
                              buttonText: "Okay",
                              cancel: true,
                              secondButton: false,
                              image: Image.asset(
                                "assets/icon_trans.png",
                                height: 40,
                              ),
                              remarkTapped: (String text) {
                                Navigator.pop(context);
                                post(text);
                              },
                            );
                            showDialog(
                                context: navigatorKey.currentContext!,
                                builder: (BuildContext context) => dialog);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(6.0)),
                              color: Colors.redAccent,
                            ),
                            width: 80,
                            child: Center(child: title("Re-Open", bold: false)),
                          ),
                        ),
                      )
                    : Container(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ComplaintSignature(
                                    id: widget.id,
                                    result: "Check",
                                    checkpoint: widget.checkpoint,
                                    taskCategory: widget.taskCategory,
                                  )));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(6.0)),
                          color: colorTheme2),
                      width: 80,
                      child: Center(child: title(submitText, bold: false)),
                    ),
                  ),
                ),
              ],
      ),
      body: Container(
        child: assetPDFPath.isEmpty
            ? Center(child: CircularProgressIndicator())
            : PDFView(
                filePath: assetPDFPath,
                autoSpacing: true,
                enableSwipe: true,
                pageSnap: true,
                swipeHorizontal: true,
                nightMode: false,
                onError: (error) {
                  print("PDFView error: $error");
                },
                onRender: (pages) {
                  setState(() {
                    pdfReady = true;
                  });
                },
                onPageChanged: (int? page, int? total) {
                  // Handle page change if needed.
                },
                onPageError: (page, error) {
                  print("Error on page $page: $error");
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text("Open File"),
        onPressed: () async {
          if (await canLaunch(src)) {
            await launch(src);
          } else {
            print("Could not launch file url");
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
    var body = UploadItem(action: "return_verify", id: widget.id, remark: text);

    Provider provider = Provider(fetchURL: "/api/m_wo.php");
    provider.context = context;
    provider
        .post(url: "/api/m_wo.php", body: body.body)
        .then((value) => alert(value))
        .catchError((err) => alert(err.toString()));
  }

  void alert(String txt) {
    showDialog(
        context: navigatorKey.currentContext!,
        builder: (BuildContext context) => CustomDialog(
              rootPage: "/workorder",
              description: txt,
              buttonText: "Okay",
              image: Image.asset(
                "assets/icon_trans.png",
                height: 40,
              ),
            ));
  }
}

class UploadItem extends Upload {
  final String remark;

  UploadItem({required String id, required super.action, required this.remark})
      : super(ppmTaskId: id);

  @override
  Map<String, dynamic> get body => {
        "action": action,
        "woTaskId": ppmTaskId,
        "remark": remark,
      };
}

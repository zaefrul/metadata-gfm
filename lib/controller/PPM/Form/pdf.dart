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
  final Function submitted;
  final int checkpoint;

  PDF(
      {this.id,
      this.transactionNo,
      this.submitted,
      this.checkpoint,
      this.viewer});

  @override
  _PDFState createState() => _PDFState();
}

class _PDFState extends State<PDF> {
  String assetPDFPath = "";
  bool pdfReady = false;
  CustomDialog dialog;
  String src;

  @override
  void initState() {
    super.initState();

    Provider provider = Provider(
        fetchURL: "/api/m_ppm.php?type=preview_pdf&ppmTaskId=${widget.id}");
    provider
        .fetch()
        .then((value) {
          src = "http:" + value.result;
          return createFileOfPdfUrl(src);
        })
        .then((value) => setState(() => assetPDFPath = value.path))
        .catchError((err) => print(err));
  }

  Future<File> createFileOfPdfUrl(String url) async {
    final filename = url.substring(url.lastIndexOf("/") + 1);
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  @override
  void dispose() {
    super.dispose();
    dialog.controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var submitText = "Complete";
    if (widget.checkpoint == 2) submitText = "Check";
    if (widget.checkpoint == 3) submitText = "Verify";

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
                widget.checkpoint > 1
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
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
                                });

                            showDialog(
                                context: context,
                                builder: (BuildContext context) => dialog);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: new BorderRadius.all(
                                    new Radius.circular(6.0)),
                                color: Colors.redAccent),
                            width: 80,
                            child: Center(child: title("Re-Open", bold: false)),
                          ),
                        ),
                      )
                    : new Container(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignatureView(
                                    id: widget.id,
                                    result: "Check",
                                    checkpoint: "${widget.checkpoint}",
                                  )));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius:
                              new BorderRadius.all(new Radius.circular(6.0)),
                          color: colorTheme2),
                      width: 80,
                      child: Center(child: title(submitText, bold: false)),
                    ),
                  ),
                ),
              ],
      ),
      body: Container(
        child: assetPDFPath == ""
            ? Center(child: CircularProgressIndicator())
            : PDFView(
                filePath: assetPDFPath,
                autoSpacing: true,
                enableSwipe: true,
                pageSnap: true,
                swipeHorizontal: true,
                nightMode: false,
                onError: (e) {
                  print("err" + e);
                },
                onRender: (_pages) {
                  setState(() {
                    pdfReady = true;
                  });
                },
                onPageChanged: (int page, int total) {
                  setState(() {});
                },
                onPageError: (page, e) {},
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: new Text("Open File"),
        onPressed: () {
          launch(src);
        },
      ),
    );
  }

  Widget title(text, {bold = true}) => new Text(text,
      textAlign: TextAlign.center,
      style: TextStyle(
          color: bold ? colorTheme3 : Colors.white,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal));

  post(String text) {
    var body = UploadItem(
        checkpoint: "${widget.checkpoint}", id: widget.id, remark: text);

    Provider provider = Provider();
    provider.context = context;
    provider
        .post(url: "/api/m_ppm.php", body: body.body)
        .then((value) => alert(value))
        .catchError((err) => alert(err));
  }

  void alert(String txt) {
    showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
            rootPage: "/ppm",
            description: txt,
            buttonText: "Okay",
            image: Image.asset(
              "assets/icon_trans.png",
              height: 40,
            )));
  }
}

class UploadItem extends Upload {
  final String checkpoint;
  final String remark;

  UploadItem({
    String id,
    this.checkpoint,
    this.remark,
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

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:toast/toast.dart';
import '../utils/reference.dart';
import 'dialog.dart';
import 'package:signature/signature.dart';

class SignatureView extends StatefulWidget {
  final String id;
  final String result;
  final String checkpoint;

  const SignatureView({
    Key? key,
    required this.id,
    required this.result,
    required this.checkpoint,
  }) : super(key: key);

  @override
  SignatureViewState createState() => SignatureViewState();
}

class SignatureViewState extends State<SignatureView> {
  bool loading = false;

  late final SignatureController _controller;
  late final Signature _signatureCanvas;

  SignatureViewState() {
    _controller = SignatureController();
    _signatureCanvas = Signature(
      controller: _controller,
      height: 300,
      backgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      backgroundColor: colorTheme3,
      appBar: AppBar(
        title: title("Signature"),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: colorTheme3,
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                _controller.clear();
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(6.0)),
                  color: Colors.redAccent,
                ),
                width: 80,
                child: Center(child: title("Reset", bold: false)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () async {
                showDialog(
                    context: context,
                    builder: (context) => CustomDialog(
                          cancel: true,
                          description: "Do you confirm want to submit?",
                          buttonText: "Yes",
                          image: Image.asset(
                            "assets/icon_trans.png",
                            height: 40,
                          ),
                          okayTapped: () {
                            Navigator.pop(context);
                            post(context);
                          },
                        ));
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(6.0)),
                  color: colorTheme2,
                ),
                width: 80,
                child: Center(child: title("Submit", bold: false)),
              ),
            ),
          ),
        ],
      ),
      body: loading
          ? Stack(
              children: <Widget>[
                _signatureCanvas,
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              ],
            )
          : Center(child: _signatureCanvas),
    );
  }

  Widget title(String text, {bool bold = true}) => Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: bold ? colorTheme3 : Colors.white,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal),
      );

  Widget titleSign(String text) => Text(
        text,
        textAlign: TextAlign.left,
        style: TextStyle(
          color: colorTheme3,
          fontFamily: 'Avenir',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        ),
      );

  Future<void> post(BuildContext context) async {
    if (_controller.isEmpty) {
      Toast.show("Please sign first before submit");
      setState(() => loading = false);
      return;
    }

    setState(() => loading = true);

    final pngBytes = await _controller.toPngBytes();
    if (pngBytes == null) {
      setState(() => loading = false);
      Toast.show("Error generating signature image");
      return;
    }
    String size = pngBytes.length.toString();
    String base64Image = base64Encode(pngBytes);

    var body = UploadItem(
      id: widget.id,
      checkpoint: widget.checkpoint,
      name: "Signature",
      filename: "Signature.png",
      size: size,
      type: "data:image/png;base64",
      data: base64Image,
    );

    Provider provider = Provider(fetchURL: "/api/m_ppm.php");
    provider.context = context;

    provider.post(url: "/api/m_ppm.php", body: body.body).then((value) {
      setState(() => loading = false);
      alert(value);
    }).catchError((err) => alert(err.toString()));
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
              ),
            ));
  }
}

class UploadItem extends Upload {
  final String checkpoint;
  final String name;
  final String filename;
  final String size;
  final String type;
  final String data;

  UploadItem({
    required String id,
    required this.checkpoint,
    required this.name,
    required this.filename,
    required this.size,
    required this.type,
    required this.data,
  }) : super(ppmTaskId: id, action: "submit_ppm");

  @override
  Map<String, dynamic> get body => {
        "action": action,
        "ppmTaskId": ppmTaskId,
        "checkpoint": checkpoint,
        "result": "1",
        "remark": "",
        "fileUpload[name]": name,
        "fileUpload[filename]": filename,
        "fileUpload[size]": size,
        "fileUpload[type]": type,
        "fileUpload[data]": data,
      };
}

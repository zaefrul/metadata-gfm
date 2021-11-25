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

  SignatureView({this.id, this.result, this.checkpoint});
  SignatureViewState createState() => new SignatureViewState();
}

class SignatureViewState extends State<SignatureView> {
  bool loading = false;
  var _signatureCanvas = Signature(
    height: 300,
    backgroundColor: Colors.white,
  );

  Widget build(BuildContext context) {
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
                  _signatureCanvas.clear();
                },
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius:
                          new BorderRadius.all(new Radius.circular(6.0)),
                      color: Colors.redAccent),
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
                      borderRadius:
                          new BorderRadius.all(new Radius.circular(6.0)),
                      color: colorTheme2),
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
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                    color: Colors.black.withOpacity(0.5),
                  )
                ],
              )
            : new Center(
                child: _signatureCanvas,
              ));
  }

  Widget title(text, {bold = true}) => new Text(text,
      textAlign: TextAlign.center,
      style: TextStyle(
          color: bold ? colorTheme3 : Colors.white,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal));

  Widget titleSign(text) => new Text(text,
      textAlign: TextAlign.left,
      style: TextStyle(
          color: colorTheme3,
          fontFamily: 'Avenir',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline));

  post(BuildContext context) async {
    if (_signatureCanvas.isEmpty) {
      Toast.show("Please sign first before submit", context);
      setState(() => loading = false);
      return;
    }

    setState(() => loading = true);

    var data = await _signatureCanvas.exportBytes();
    var pngBytes = data.buffer.asUint8List();
    String size = pngBytes.length.toString();
    String base64Image = base64Encode(pngBytes);

    var body = UploadItem(
        id: widget.id,
        checkpoint: widget.checkpoint,
        name: "Signature",
        filename: "Signature.png",
        size: size,
        type: "data:image/png;base64",
        data: base64Image);

    Provider provider = Provider();

    if (context != null) provider.context = context;

    provider.post(url: "/api/m_ppm.php", body: body.body).then((value) {
      setState(() => loading = false);
      alert(value);
    }).catchError((err) => alert(err));
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
  final String name;
  final String filename;
  final String size;
  final String type;
  final String data;

  UploadItem(
      {String id,
      this.checkpoint,
      this.name,
      this.filename,
      this.size,
      this.type,
      this.data})
      : super(ppmTaskId: id, action: "submit_ppm");

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

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:toast/toast.dart';
import '../../utils/reference.dart';
import '../../view/dialog.dart';

import 'package:signature/signature.dart';

class ComplaintFormSignature extends StatefulWidget {
  final Map<String, String> map;

  ComplaintFormSignature({this.map});
  ComplaintFormSignatureState createState() =>
      new ComplaintFormSignatureState();
}

class ComplaintFormSignatureState extends State<ComplaintFormSignature> {
  bool loading = false;

  final SignatureController _controller;
  Signature _signatureCanvas;
  ComplaintFormSignatureState() : _controller = SignatureController() {
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
    if (_controller.isEmpty) {
      Toast.show("Please sign first before submit");
      setState(() => loading = false);
      return;
    }

    setState(() => loading = true);

    var pngBytes = await _controller.toPngBytes();
    String size = pngBytes.length.toString();
    String base64Image = base64Encode(pngBytes);

    var body = widget.map;
    body["signature[name]"] = "Complaint signiture";
    body["signature[filename]"] = "signature.png";
    body["signature[size]"] = size;
    body["signature[type]"] = "data:image/png;base64";
    body["signature[data]"] = base64Image;

    Provider provider = Provider();

    provider.context = context;

    provider.post(url: "/api/m_wo.php", body: body).then((value) {
      setState(() => loading = false);
      alert(txt: value);
    }).catchError((err) {
      print(err);
      alert(err: err);
    }).whenComplete(() => setState(() => loading = false));
  }

  void alert({String txt, String err}) {
    showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
            rootPage: err != null ? null : "/workorder",
            description: err != null ? err : txt,
            buttonText: "Okay",
            image: Image.asset(
              "assets/icon_trans.png",
              height: 40,
            )));
  }
}

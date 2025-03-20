import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/constant.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/widget/dialog.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:toast/toast.dart';

import 'package:signature/signature.dart';

class SignatureView extends StatefulWidget {
  final String id;

  SignatureView({this.id});
  SignatureViewState createState() => new SignatureViewState();
}

class SignatureViewState extends State<SignatureView> {
  bool loading = false;

  final SignatureController _controller;
  Signature _signatureCanvas;
  SignatureViewState() : _controller = SignatureController() {
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
        iconTheme: IconThemeData(color: colorTheme3),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: _controller.clear,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: new BorderRadius.all(new Radius.circular(6.0)),
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
              onTap: submitDialog,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: new BorderRadius.all(new Radius.circular(6.0)),
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
                  child: Center(child: CircularProgressIndicator()),
                  color: Colors.black.withOpacity(0.5),
                )
              ],
            )
          : new Center(child: _signatureCanvas),
    );
  }

  Widget title(text, {bold = true}) {
    return new Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: bold ? colorTheme3 : Colors.white,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget titleSign(text) {
    return new Text(
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
  }

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

    var body = UploadItem(size: size, data: base64Image);

    Provider provider = Provider();

    provider.context = context;

    provider
        .post(url: "/user_signature/${widget.id}", body: body.body)
        .then((value) {
      setState(() => loading = false);
      alert(value);
    }).catchError((err) => alert(err));
  }

  void alert(String txt) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        rootPage: "/homepage",
        description: txt,
        buttonText: "Okay",
        image: Image.asset("assets/icon_trans.png", height: 40),
      ),
    );
  }

  void submitDialog() {
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
      ),
    );
  }
}

class UploadItem {
  final String width = "533";
  final String height = "300";
  final String name = "User Signature";
  final String filename = "signature.png";
  final String type = "data:image/png;base64";
  final String data;
  final String size;

  UploadItem({
    this.size,
    this.data,
  });

  @override
  Map<String, dynamic> get body => {
        "name": name,
        "filename": filename,
        "size": size,
        "type": type,
        "data": data,
      };
}

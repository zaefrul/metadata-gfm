import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:GEMS/controller/Storekeeper/utils/constant.dart';
import 'package:GEMS/controller/Storekeeper/utils/widget/dialog.dart';
import 'package:GEMS/utils/network.dart';
import 'package:toast/toast.dart';
import 'package:signature/signature.dart';
import '../../main.dart';

class SignatureView extends StatefulWidget {
  final String id;

  const SignatureView({required this.id, Key? key}) : super(key: key);

  @override
  SignatureViewState createState() => SignatureViewState();
}

class SignatureViewState extends State<SignatureView> {
  bool loading = false;

  final SignatureController _controller;
  late Signature _signatureCanvas;

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

  @override
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
              onTap: submitDialog,
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
                  child: Center(child: CircularProgressIndicator()),
                  color: Colors.black.withOpacity(0.5),
                )
              ],
            )
          : Center(child: _signatureCanvas),
    );
  }

  Widget title(String text, {bool bold = true}) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: bold ? colorTheme3 : Colors.white,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget titleSign(String text) {
    return Text(
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

  Future<void> post(BuildContext context) async {
    if (_controller.isEmpty) {
      Toast.show("Please sign first before submit");
      setState(() => loading = false);
      return;
    }

    setState(() => loading = true);

    var pngBytes = await _controller.toPngBytes();
    String size = (pngBytes?.length ?? 0).toString();
    String base64Image = base64Encode(pngBytes ?? Uint8List(0));

    var body = UploadItem(size: size, data: base64Image);

    Provider provider = Provider(fetchURL: "/user_signature/${widget.id}");
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
      context: navigatorKey.currentContext!,
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
      context: navigatorKey.currentContext!,
      builder: (context) => CustomDialog(
        rootPage: "/homepage",
        cancel: true,
        description: "Do you confirm want to submit?",
        buttonText: "Yes",
        image: Image.asset("assets/icon_trans.png", height: 40),
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

  UploadItem({required this.size, required this.data});

  Map<String, dynamic> get body => {
        "name": name,
        "filename": filename,
        "size": size,
        "type": type,
        "data": data,
      };
}

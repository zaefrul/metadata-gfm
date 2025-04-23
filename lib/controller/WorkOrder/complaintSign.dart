import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:gfm_gems/utils/network.dart';
import 'package:toast/toast.dart';
import 'package:rating_dialog/rating_dialog.dart';
import '../../utils/reference.dart';
import '../../view/dialog.dart';
import 'package:signature/signature.dart';
import '../../main.dart';

class ComplaintSignature extends StatefulWidget {
  final String id;
  final String result;
  final int checkpoint;

  const ComplaintSignature({
    Key? key,
    required this.id,
    required this.result,
    required this.checkpoint,
  }) : super(key: key);

  @override
  ComplaintSignatureState createState() => ComplaintSignatureState();
}

class ComplaintSignatureState extends State<ComplaintSignature> {
  bool loading = false;
  bool withVerifier = false;
  Map<String, dynamic> withVerifierBody = {};

  final SignatureController _controller;
  late final Signature _signatureCanvas;

  ComplaintSignatureState() : _controller = SignatureController() {
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
                  context: navigatorKey.currentContext!,

                  builder: (context) => withVerifier
                      ? CustomDialog(
                          title: "Remark",
                          description: "Please select the action?",
                          useDescription: true,
                          buttonText: "Submit",
                          secondButton: true,
                          buttonText2: "Invalid",
                          image: Image.asset(
                            "assets/icon_trans.png",
                            height: 40,
                          ),
                          remarkTapped: (text) {
                            Navigator.pop(context);
                            post(context);
                          },
                          secondTapped: () {
                            Navigator.pop(context);
                            withVerifierBody["isVerified"] = "2";
                            post(context);
                          },
                        )
                      : CustomDialog(
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
                  child: Center(child: CircularProgressIndicator()),
                ),
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
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
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
      if (!mounted) return; // Ensure widget is still mounted
      setState(() => loading = false);
      return;
    }

    final Uint8List? pngBytes = await _controller.toPngBytes();
    if (pngBytes == null) {
      Toast.show("Error generating signature");
      if (!mounted) return; // Ensure widget is still mounted
      setState(() => loading = false);
      return;
    }
    String size = pngBytes.length.toString();
    String base64Image = base64Encode(pngBytes);

    String action;
    if (widget.checkpoint == 1)
      action = "submit_verify";
    else if (widget.checkpoint == 4)
      action = "submit_wr_check";
    else if (widget.checkpoint == 5)
      action = "submit_wr_verified";
    else
      action = "submit_repair";

    Map<String, dynamic> body = {
      "action": action,
      "woTaskId": widget.id,
      "signature[name]": "Complaint signiture",
      "signature[filename]": "signature.png",
      "signature[size]": size,
      "signature[type]": "data:image/png;base64",
      "signature[data]": base64Image,
    };

    ratingDialog(body);
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
      ),
    );
  }

  void ratingDialog(Map<String, dynamic> body) {
    void upload() {
      Provider provider = Provider(fetchURL: "/api/m_wo.php");
      provider.context = navigatorKey.currentContext!;
      provider
          .post(url: "/api/m_wo.php", body: body)
          .then((value) {
            alert(value);
          })
          .catchError((err) {
            debugPrint('Error: $err');
            alert(err.toString());
          });
    }

    void dialogConfirmation() {
      showDialog(
        context: navigatorKey.currentContext!,
        barrierDismissible: true,
        builder: (context) => CustomDialog(
          title: "Remark",
          description: "Please select the action?",
          useDescription: true,
          buttonText: "Submit",
          secondButton: true,
          buttonText2: "Invalid",
          image: Image.asset(
            "assets/icon_trans.png",
            height: 40,
          ),
          remarkTapped: (text) {
            Navigator.pop(context);
            upload();
          },
          secondTapped: () {
            body["isVerified"] = "3";
            upload();
            Navigator.pop(context);
          },
        ),
      );
    }

    if (widget.checkpoint == 4) {
      if (!withVerifier) {
        showDialog(
          context: navigatorKey.currentContext!,
          barrierDismissible: true,
          builder: (context) => CustomDialog(
            title: "Remark",
            description: "Remark",
            buttonText: "Verifier Attend",
            secondButton: true,
            buttonText2: "No Verifier",
            image: Image.asset(
              "assets/icon_trans.png",
              height: 40,
            ),
            remarkTapped: (text) {
              Navigator.pop(context);
              setState(() {
                withVerifier = true;
              });
              _controller.clear();
              body["remark"] = text;
              body["isVerified"] = "1";
              withVerifierBody.addAll(body);
              if (mounted) {
                setState(() => loading = false); // Ensure widget is still mounted
              }
              Toast.show("Please Refill Signature field for verifier",
                  duration: 2);
            },
            secondTapped: (text) {
              body["remark"] = text;
              body["isVerified"] = "0";
              Navigator.pop(context);
              dialogConfirmation();
            },
          ),
        );
      } else {
        withVerifierBody["signatureVerifier[name]"] =
            body["signature[name]"] + " verifier";
        withVerifierBody["signatureVerifier[filename]"] =
            "verifier_" + body["signature[filename]"];
        withVerifierBody["signatureVerifier[size]"] = body["signature[size]"];
        withVerifierBody["signatureVerifier[type]"] = body["signature[type]"];
        withVerifierBody["signatureVerifier[data]"] = body["signature[data]"];
        body = withVerifierBody;
        upload();
      }
    } else if (widget.checkpoint != 1) {
      upload();
    } else {
      showDialog(
        context: navigatorKey.currentContext!,
        barrierDismissible: true,
        builder: (context) => RatingDialog(
          image: Material(
            elevation: 6.0,
            child: Padding(
              padding: const EdgeInsets.all(Consts.padding),
              child: Image.asset(
                "assets/icon_trans.png",
                height: 40,
              ),
            ),
            shape: CircleBorder(),
            color: Colors.white,
          ),
          title: const Text("Rate It"),
          message: const Text("Rate technician work your complaint."),
          submitButtonText: "SUBMIT",
          onSubmitted: (response) {
            body["rating"] = response.rating.toString();
            upload();
          },
        ),
      );
    }
  }
}

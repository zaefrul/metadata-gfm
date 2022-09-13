import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:toast/toast.dart';
import 'package:rating_dialog/rating_dialog.dart';
import '../../utils/reference.dart';
import '../../view/dialog.dart';

import 'package:signature/signature.dart';

class ComplaintSignature extends StatefulWidget {
  final String id;
  final String result;
  final int checkpoint;

  ComplaintSignature({this.id, this.result, this.checkpoint});
  ComplaintSignatureState createState() => new ComplaintSignatureState();
}

class ComplaintSignatureState extends State<ComplaintSignature> {
  bool loading = false;
  bool withVerifier = false;
  Map<String, dynamic> withVerifierBody = Map<String, dynamic>();
  var _signatureCanvas = Signature(
    height: 300,
    backgroundColor: Colors.white,
  );

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
      Toast.show("Please sign first before submit");
      setState(() => loading = false);
      return;
    }

    var data = await _signatureCanvas.exportBytes();
    var pngBytes = data.buffer.asUint8List();
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

    var body = {
      "action": action,
      "woTaskId": widget.id,
      "signature[name]": "Complaint signiture",
      "signature[filename]": "signature.png",
      "signature[size]": size,
      "signature[type]": "data:image/png;base64",
      "signature[data]": base64Image
    };

    ratingDialog(body);
  }

  void alert(String txt) {
    showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
            rootPage: "/workorder",
            description: txt,
            buttonText: "Okay",
            image: Image.asset(
              "assets/icon_trans.png",
              height: 40,
            )));
  }

  void ratingDialog(Map<String, dynamic> body) {
    void upload() {
      setState(() => loading = true);
      Provider provider = Provider();

      if (context != null) provider.context = context;

      provider.post(url: "/api/m_wo.php", body: body).then((value) {
        setState(() => loading = false);
        alert(value);
      }).catchError((err) => alert(err));
    }

    void dialogConfirmation() {
      showDialog(
        context: context,
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
            upload();
            Navigator.pop(context);
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
      if (withVerifier == false) {
        showDialog(
            context: context,
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
                    withVerifier = true;
                    _signatureCanvas.clear();
                    body["remark"] = text;
                    body["isVerified"] = "1";
                    withVerifierBody.addAll(body);

                    setState(() => loading = false);
                    Toast.show("Please Refill Signature field for verifier",
                        duration: 2);
                  },
                  secondTapped: (text) {
                    body["remark"] = text;
                    body["isVerified"] = "0";
                    Navigator.pop(context);
                    dialogConfirmation();
                  },
                ));
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
    } else if (widget.checkpoint != 1)
      upload();
    else
      showDialog(
          context: context,
          barrierDismissible:
              true, // set to false if you want to force a rating
          builder: (context) {
            return RatingDialog(
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
              ), // set your own image/icon widget
              title: Text("Rate It"),
              message: Text("Rate technician work your complaint."),
              submitButtonText: "SUBMIT",

              onSubmitted: (response) {
                body["rating"] = response.rating.toString();
                upload();
              },
            );
          });
  }
}

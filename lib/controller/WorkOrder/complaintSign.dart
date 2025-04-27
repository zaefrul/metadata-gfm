// lib/controller/WorkOrder/complaint_sign.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:signature/signature.dart';

import '../../utils/reference.dart';
import '../../view/dialog.dart';

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
    return Scaffold(
      backgroundColor: colorTheme3,
      appBar: AppBar(
        title: title("Signature"),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppColors.primary),
        actions: [
          // Reset
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: _controller.clear,
              child: Container(
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(child: title("Reset", bold: false)),
              ),
            ),
          ),
          // Submit
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () => _showInitialSubmitDialog(context),
              child: Container(
                width: 80,
                decoration: BoxDecoration(
                  color: colorTheme2,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(child: title("Submit", bold: false)),
              ),
            ),
          ),
        ],
      ),
      body: loading
          ? Stack(
              children: [
                _signatureCanvas,
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ],
            )
          : Center(child: _signatureCanvas),
    );
  }

  /// Step 1: Simple confirmation or second-step dialog
  void _showInitialSubmitDialog(BuildContext ctx) {
    showDialog<void>(
      context: ctx,
      builder: (dialogCtx) {
        if (withVerifier) {
          // 2nd-step: after verifier has signed
          return CustomDialog(
            title: "Remark",
            description: "Please select the action?",
            useDescription: true,
            buttonText: "Submit",
            secondButton: true,
            buttonText2: "Invalid",
            image: Image.asset("assets/icon_trans.png", height: 40),
            remarkTapped: (_) {
              Navigator.of(dialogCtx).pop();
              _post(ctx);
            },
            secondTapped: () {
              Navigator.of(dialogCtx).pop();
              withVerifierBody["isVerified"] = "2";
              _post(ctx);
            },
          );
        } else {
          // 1st-step confirm
          return CustomDialog(
            cancel: true,
            description: "Do you confirm want to submit?",
            buttonText: "Yes",
            image: Image.asset("assets/icon_trans.png", height: 40),
            okayTapped: () {
              Navigator.of(dialogCtx).pop();
              _post(ctx);
            },
          );
        }
      },
    );
  }

  /// Step 2: Capture signature, encode, decide action, then _ratingDialog
  Future<void> _post(BuildContext ctx) async {
    debugPrint("Masuk POST");
    if (_controller.isEmpty) {
      debugPrint("Tak SIGN INs");
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text("Please sign first before submit")),
      );
      return;
    }

    final Uint8List? png = await _controller.toPngBytes();
    if (png == null) {
      debugPrint("X BOLE NAK GENERATE SIGNATURE");
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text("Error generating signature")),
      );
      return;
    }

    final size = png.length.toString();
    final data = base64Encode(png);

    late String action;
    switch (widget.checkpoint) {
      case 1:
        action = "submit_verify";
        break;
      case 4:
        action = "submit_wr_check";
        break;
      case 5:
        action = "submit_wr_verified";
        break;
      default:
        action = "submit_repair";
    }

    final body = {
      "action": action,
      "woTaskId": widget.id,
      "signature[name]": "Complaint signature",
      "signature[filename]": "signature.png",
      "signature[size]": size,
      "signature[type]": "data:image/png;base64",
      "signature[data]": data,
    };

    debugPrint("DAH NAK MASUK _RATING DIALOG");
    _ratingDialog(ctx, body);
  }

  /// Simple OK-dialog after network call
  void _alert(BuildContext ctx, String msg) {
    showDialog<void>(
      context: ctx,
      builder: (_) => CustomDialog(
        rootPage: "/workorder",
        description: msg,
        buttonText: "Okay",
        image: Image.asset("assets/icon_trans.png", height: 40),
      ),
    );
  }

  /// Performs HTTP POST and toggles loading spinner
  void _upload(BuildContext ctx, Map<String, dynamic> body) {
    debugPrint("DALAM _UPLOAD : mounted = $mounted");
    if (!mounted) return;
    setState(() => loading = true);

    final provider = Provider(fetchURL: "/api/m_wo.php")..context = ctx;
    provider.post(url: "/api/m_wo.php", body: body).then((resp) {
      if (!mounted) return;
      setState(() => loading = false);
      _alert(ctx, resp);
    }).catchError((err) {
      if (!mounted) return;
      setState(() => loading = false);
      debugPrint("Upload failed: $err");
      _alert(ctx, err.toString());
    });
  }

  /// Step 3: Rating dialog or two-step verifier flow
  void _ratingDialog(
    BuildContext ctx,
    Map<String, dynamic> body,
  ) {
    debugPrint('the checkpoint is : ${widget.checkpoint}');

    // helper for “No Verifier” → second remark dialog
    void dialogConfirmation() {
      debugPrint("Dah dalam dialog confirmation");
      showDialog<void>(
        context: ctx,
        builder: (dialogCtx) => CustomDialog(
          title: "Remark",
          description: "Please select the action?",
          useDescription: true,
          buttonText: "Submit",
          secondButton: true,
          buttonText2: "Invalid",
          image: Image.asset("assets/icon_trans.png", height: 40),
          remarkTapped: (_) {
            Navigator.of(dialogCtx).pop();
            _upload(ctx, body);
          },
          secondTapped: () {
            Navigator.of(dialogCtx).pop();
            body["isVerified"] = "3";
            _upload(ctx, body);
          },
        ),
      );
    }

    if (widget.checkpoint == 4) {
      // Two-step verifier
      if (!withVerifier) {
        // inside your _ratingDialog, FIRST step (checkpoint==4 && !withVerifier):
        showDialog<void>(
          context: ctx,
          builder: (dialogCtx) => CustomDialog(
            title: "Remark",
            description: "Remark",
            buttonText: "Verifier Attend",
            secondButton: true,
            buttonText2: "No Verifier",
            image: Image.asset("assets/icon_trans.png", height: 40),
            remarkTapped: (remark) {
              debugPrint("➡️ remarkTapped invoked");

              // 1) Are we still in the tree?
              if (!mounted) {
                debugPrint("⛔️ State not mounted – popping dialog and returning");
                Navigator.of(dialogCtx).pop();
                return;
              }
              debugPrint("✅ State is mounted");

              // 2) Clear the old signature
              debugPrint("🧹 Clearing signature controller");
              _controller.clear();
              debugPrint("✅ Controller.clear() done");

              // 3) Update local state
              debugPrint("🔄 Calling setState to flip withVerifier=true");
              setState(() {
                withVerifier = true;
                loading = false;
              });
              debugPrint("✅ setState complete: withVerifier=$withVerifier, loading=$loading");

              // 4) Dismiss just the remark dialog
              debugPrint("🚪 Popping remark dialog");
              Navigator.of(dialogCtx).pop();
              debugPrint("✅ Dialog popped");

              // 5) Show a SnackBar to prompt re-sign
              debugPrint("🔔 Showing SnackBar");
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text("Please refill signature field for verifier")),
              );
              debugPrint("✅ SnackBar.shown");

              // 6) Finally—schedule the next dialog open after this frame
              debugPrint("⏱ Scheduling re-open of the submit dialog");
              WidgetsBinding.instance.addPostFrameCallback((_) {
                debugPrint("🕒 addPostFrameCallback triggered");
                if (!mounted) {
                  debugPrint("⛔️ State not mounted in callback, aborting");
                  return;
                }
                debugPrint("🚀 Re-opening initial submit dialog (withVerifier now true)");
                _showInitialSubmitDialog(ctx);
              });
            },
            secondTapped: (remark) {
              Navigator.of(dialogCtx).pop();
              body["remark"]     = remark;
              body["isVerified"] = "0";
              dialogConfirmation(); // your second-step helper
            },
          ),
        );
      } else {
        // SECOND: merge verifier signature and upload
        debugPrint("SECOND: merge verifier signature and upload");
        withVerifierBody["signatureVerifier[name]"] =
            "${body["signature[name]"]} verifier";
        withVerifierBody["signatureVerifier[filename]"] =
            "verifier_${body["signature[filename]"]}";
        withVerifierBody["signatureVerifier[size]"] =
            body["signature[size]"];
        withVerifierBody["signatureVerifier[type]"] =
            body["signature[type]"];
        withVerifierBody["signatureVerifier[data]"] =
            body["signature[data]"];
        _upload(ctx, withVerifierBody);
      }

    } else if (widget.checkpoint != 1) {
      // non-rating, non-verifier
      _upload(ctx, body);

    } else {
      // checkpoint 1: show RatingDialog
      showDialog<void>(
        context: ctx,
        builder: (dialogCtx) => RatingDialog(
          image: Material(
            elevation: 6,
            shape: const CircleBorder(),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(Consts.padding),
              child: Image.asset("assets/icon_trans.png", height: 40),
            ),
          ),
          title: const Text("Rate It"),
          message:
              const Text("Rate technician work your complaint."),
          submitButtonText: "SUBMIT",
          onSubmitted: (resp) {
            Navigator.of(dialogCtx).pop();
            body["rating"] = resp.rating.toString();
            _upload(ctx, body);
          },
        ),
      );
    }
  }

  Widget title(String text, {bool bold = true}) => Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: bold ? colorTheme3 : Colors.white,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      );
}

// lib/controller/WorkOrder/complaint_sign.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:GEMS/utils/network.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:signature/signature.dart';

import '../../utils/reference.dart';
import '../../view/dialog.dart';

class ComplaintSignature extends StatefulWidget {
  final String id;
  final String result;
  final int checkpoint;
  final String taskCategory;

  const ComplaintSignature({
    super.key,
    required this.id,
    required this.result,
    required this.checkpoint,
    required this.taskCategory,
  });

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
              // Pass the ComplaintSignature's context (this.context)
              _post(context); // MODIFIED
            },
            secondTapped: () {
              Navigator.of(dialogCtx).pop();
              withVerifierBody["isVerified"] = "2";
              // Pass the ComplaintSignature's context (this.context)
              _post(context); // MODIFIED
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
              // Pass the ComplaintSignature's context (this.context)
              _post(context); // MODIFIED
            },
          );
        }
      },
    );
  }

  /// Step 2: Capture signature, encode, decide action, then _ratingDialog
  Future<void> _post(BuildContext ctx) async {
    // IMPORTANT: 'ctx' here is now consistently the ComplaintSignature's context,
    // passed from _showInitialSubmitDialog or _ratingDialog.
    // Use it for displaying snackbars or final navigation.

    if (_controller.isEmpty) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text("Please sign first before submit")),
      );
      return;
    }

    final Uint8List? png = await _controller.toPngBytes();
    if (png == null) {
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
      case 6:
        action = "submit_check";
        break;
      default:
        action = "submit_repair";
    }

    debugPrint('Action: $action');

    final body = {
      "action": action,
      "woTaskId": widget.id,
      "signature[name]": "Complaint signature",
      "signature[filename]": "signature.png",
      "signature[size]": size,
      "signature[type]": "data:image/png;base64",
      "signature[data]": data,
    };

    debugPrint('taskType: ${widget.taskCategory}');

    if(widget.checkpoint != 6 && (widget.taskCategory != "Self Finding" && widget.taskCategory != "Public Complaint")) {
      // Pass the ComplaintSignature's context (this.context)
      _ratingDialog(context, body); // MODIFIED
    }
    else {
      // For checkpoint 6, directly upload without rating dialog
      // Pass the ComplaintSignature's context (this.context)
      _upload(context, body); // MODIFIED
    }
  }

  /// Simple OK-dialog after network call
  void _alert(BuildContext scaffoldCtx, String msg) {
    // This 'scaffoldCtx' is now the ComplaintSignature's context,
    // which is stable for showing this final dialog and for navigation.
    showDialog<void>(
      context: scaffoldCtx,
      barrierDismissible: false,
      builder: (_) => CustomDialog(
        rootPage: "/workorder",
        description: msg,
        buttonText: "Okay",
        image: Image.asset("assets/icon_trans.png", height: 40),
      ),
    );
  }

  /// Performs HTTP POST and toggles loading spinner
  void _upload(BuildContext ctxForNetwork, Map<String, dynamic> body) {
    // 'ctxForNetwork' is the context of the dialog that *triggered* the upload,
    // which is needed for the Provider setup.
    // However, for the final _alert and navigation, we'll use the ComplaintSignature's context.

    if (!mounted) return;
    setState(() => loading = true);
    debugPrint("==============Uploading with body: $body");

    // Use ctxForNetwork for the Provider if it needs the context where it was initiated
    final provider = Provider(fetchURL: "/api/m_wo.php")..context = ctxForNetwork;
    provider.post(url: "/api/m_wo.php", body: body).then((resp) {
      if (mounted) {
        setState(() => loading = false);
        // Use the ComplaintSignatureState's context for the final alert and navigation
        _alert(context, resp); // MODIFIED
      }
    }).catchError((err) {
      if (mounted) setState(() => loading = false);
      // Use the ComplaintSignatureState's context for the final alert and navigation
      _alert(context, err.toString()); // MODIFIED
    });
  }

  /// Step 3: Rating dialog or two-step verifier flow
  void _ratingDialog(
    BuildContext dialogHostCtx, // This 'dialogHostCtx' is the context from where this dialog is launched (e.g., ComplaintSignature's context)
    Map<String, dynamic> body,
  ) {
    // helper for “No Verifier” → second remark dialog
    void dialogConfirmation() {
      showDialog<void>(
        context: dialogHostCtx, // Use the provided context to show this dialog
        barrierDismissible: false,
        builder: (dialogCtx) => CustomDialog(
          title: "Remark",
          rootPage: "/workorder",
          description: "Please select the action?",
          useDescription: true,
          buttonText: "Submit",
          secondButton: true,
          buttonText2: "Invalid",
          image: Image.asset("assets/icon_trans.png", height: 40),
          remarkTapped: (_) {
            Navigator.of(dialogCtx).pop();
            // Pass the ComplaintSignature's context (this.context)
            _upload(context, body); // MODIFIED
          },
          secondTapped: () {
            Navigator.of(dialogCtx).pop();
            body["isVerified"] = "3";
            // Pass the ComplaintSignature's context (this.context)
            _upload(context, body); // MODIFIED
          },
        ),
      );
    }

    if (widget.checkpoint == 4) {
      if (!withVerifier) {
        // FIRST step for checkpoint 4
        showDialog<void>(
          context: dialogHostCtx, // Use the provided context to show this dialog
          barrierDismissible: false,
          builder: (dialogCtx) => CustomDialog(
            title: "Remark",
            description: "Remark",
            buttonText: "Verifier Attend",
            secondButton: true,
            buttonText2: "No Verifier",
            image: Image.asset("assets/icon_trans.png", height: 40),
            remarkTapped: (remark) {
              // 1) stash original body with remark and isVerified flag
              withVerifierBody
                ..addAll(body)
                ..['remark'] = remark
                ..['isVerified'] = "1";
              // 2) clear canvas to allow new signature
              _controller.clear();
              // 3) flip the flag & reset loading
              setState(() {
                withVerifier = true;
                loading = false;
              });
              // 4) close this dialog
              Navigator.of(dialogCtx).pop();
              // 5) prompt for re-sign
              ScaffoldMessenger.of(context).showSnackBar( // Use this.context for SnackBar
                const SnackBar(content: Text("Please refill signature field for verifier")),
              );
              // 6) reopen the initial submit dialog using current ComplaintSignature's context
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                _showInitialSubmitDialog(context); // MODIFIED
              });
            },
            secondTapped: (remark) {
              Navigator.of(dialogCtx).pop();
              body["remark"] = remark;
              body["isVerified"] = "0";
              dialogConfirmation(); // This calls _upload with `context` already
            },
          ),
        );
      } else {
        // SECOND step: merge verifier signature & upload
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
        // Pass the ComplaintSignature's context (this.context)
        _upload(context, withVerifierBody); // MODIFIED
      }
    } else if (widget.checkpoint != 1) {
      // non-rating, non-verifier
      // Pass the ComplaintSignature's context (this.context)
      _upload(context, body); // MODIFIED
    } else {
      // checkpoint 1: show RatingDialog
      showDialog<void>(
        context: dialogHostCtx, // Use the provided context to show this dialog
        barrierDismissible: false,
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
          message: const Text("Rate technician work your complaint."),
          submitButtonText: "SUBMIT",
          onSubmitted: (resp) {
            Navigator.of(dialogCtx).pop();
            body["rating"] = resp.rating.toString();
            // Pass the ComplaintSignature's context (this.context)
            _upload(context, body); // MODIFIED
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
// lib/controller/WorkOrder/complaint_sign.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:GEMS/data/repository/work_order_detail_repository.dart';
import 'package:GEMS/data/repository/work_order_repository.dart';
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
  final WorkOrderDetailRepository _repository = WorkOrderDetailRepository();
  final WorkOrderRepository _listRepository = WorkOrderRepository();

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

  void _showInitialSubmitDialog(BuildContext ctx) {
    showDialog<void>(
      context: ctx,
      builder: (dialogCtx) {
        if (withVerifier) {
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
              _post(context);
            },
            secondTapped: () {
              Navigator.of(dialogCtx).pop();
              withVerifierBody["isVerified"] = "2";
              _post(context);
            },
          );
        } else {
          return CustomDialog(
            cancel: true,
            description: "Do you confirm want to submit?",
            buttonText: "Yes",
            image: Image.asset("assets/icon_trans.png", height: 40),
            okayTapped: () {
              Navigator.of(dialogCtx).pop();
              _post(context);
            },
          );
        }
      },
    );
  }

  Future<void> _post(BuildContext ctx) async {
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

    final body = {
      "woTaskId": widget.id,
      "signature[name]": "Complaint signature",
      "signature[filename]": "signature.png",
      "signature[size]": size,
      "signature[type]": "data:image/png;base64",
      "signature[data]": data,
    };

    debugPrint('taskType: ${widget.taskCategory}, checkpoint: ${widget.checkpoint}');

    if (widget.checkpoint != 6 &&
        widget.taskCategory != "Self Finding" &&
        widget.taskCategory != "Public Complaint") {
      _ratingDialog(context, body);
    } else {
      await _upload(body);
    }
  }

  Future<WorkOrderActionResult> _submitBody(Map<String, dynamic> body) {
    switch (widget.checkpoint) {
      case 1:
        return _repository.submitVerify(widget.id, body);
      case 4:
        return _repository.submitSignatureAction(widget.id, {
          'action': 'submit_wr_check',
          ...body,
        });
      case 5:
        return _repository.submitWrVerifiedFromSignature(widget.id, body);
      case 6:
        return _repository.submitCheck(widget.id, body);
      default:
        return _repository.submitRepair(widget.id, body);
    }
  }

  Future<void> _upload(Map<String, dynamic> body) async {
    if (!mounted) return;
    setState(() => loading = true);
    debugPrint('Submitting signature for woTaskId=${widget.id}');

    try {
      final result = await _submitBody(body);
      if (!mounted) return;
      setState(() => loading = false);

      if (result == WorkOrderActionResult.success) {
        try {
          await _listRepository.refreshWorkOrders(
            WorkOrderListType.pendingTask,
          );
        } catch (err) {
          debugPrint('Failed to refresh My Task list after submit: $err');
        }
        _alert(
          context,
          'Request submitted successfully.',
        );
      } else {
        _alert(
          context,
          'Saved. Will sync when you are back online.',
        );
      }
    } catch (err) {
      if (!mounted) return;
      setState(() => loading = false);
      _alert(context, err.toString());
    }
  }

  void _alert(BuildContext scaffoldCtx, String msg) {
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

  void _ratingDialog(
    BuildContext dialogHostCtx,
    Map<String, dynamic> body,
  ) {
    void dialogConfirmation() {
      showDialog<void>(
        context: dialogHostCtx,
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
            _upload(body);
          },
          secondTapped: () {
            Navigator.of(dialogCtx).pop();
            body["isVerified"] = "3";
            _upload(body);
          },
        ),
      );
    }

    if (widget.checkpoint == 4) {
      if (!withVerifier) {
        showDialog<void>(
          context: dialogHostCtx,
          barrierDismissible: false,
          builder: (dialogCtx) => CustomDialog(
            title: "Remark",
            description: "Remark",
            buttonText: "Verifier Attend",
            secondButton: true,
            buttonText2: "No Verifier",
            image: Image.asset("assets/icon_trans.png", height: 40),
            remarkTapped: (remark) {
              withVerifierBody
                ..addAll(body)
                ..['remark'] = remark
                ..['isVerified'] = "1";
              _controller.clear();
              setState(() {
                withVerifier = true;
                loading = false;
              });
              Navigator.of(dialogCtx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Please refill signature field for verifier"),
                ),
              );
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                _showInitialSubmitDialog(context);
              });
            },
            secondTapped: (remark) {
              Navigator.of(dialogCtx).pop();
              body["remark"] = remark;
              body["isVerified"] = "0";
              dialogConfirmation();
            },
          ),
        );
      } else {
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
        _upload(withVerifierBody);
      }
    } else if (widget.checkpoint != 1) {
      _upload(body);
    } else {
      showDialog<void>(
        context: dialogHostCtx,
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
            _upload(body);
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

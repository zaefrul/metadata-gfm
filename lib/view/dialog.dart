// lib/view/dialog.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'button.dart';
import 'package:toast/toast.dart';
import '../utils/reference.dart';

class Consts {
  Consts._();
  static const double padding = 16.0;
  static const double avatarRadius = 40.0;
}

typedef CustomVoidCallback = FutureOr<void> Function(String text);

class CustomDialog extends StatelessWidget {
  final CustomVoidCallback? remarkTapped;
  final String? title;
  final String description;
  final String buttonText;
  final String? buttonText2;
  final Image? image;
  final bool cancel;
  final bool useDescription;
  final bool secondButton;
  final String? rootPage;
  final bool? goBackOnDismiss;
  String remark;
  final Function? okayTapped;
  final Function? secondTapped;
  bool showError;

  final TextEditingController controller = TextEditingController();

  CustomDialog({
    super.key,
    this.title,
    required this.description,
    required this.buttonText,
    this.useDescription = false,
    this.buttonText2,
    this.cancel = false,
    this.image,
    this.rootPage,
    this.goBackOnDismiss,
    this.remarkTapped,
    this.okayTapped,
    this.secondButton = false,
    this.secondTapped,
    this.showError = false,
    this.remark = "",
  }) {
    controller.addListener(_updateRemark);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Consts.padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: title == "Remark"
          ? remarkDialogContent(context)
          : dialogContent(context),
    );
  }

  Widget dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            top: Consts.avatarRadius + Consts.padding,
            bottom: Consts.padding,
            left: Consts.padding,
            right: Consts.padding,
          ),
          margin: const EdgeInsets.only(top: Consts.avatarRadius),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(Consts.padding),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              if (title != null) ...[
                Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16.0),
              ],
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (cancel)
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  _SingleFireButton(
                    text: buttonText,
                    color: colorTheme2,
                    onPressed: () async {
                      if (okayTapped != null) {
                        final result = okayTapped!.call();
                        if (result is Future) {
                          await result;
                          if (!context.mounted) return;
                        }
                      }
                      // only pop here if we didn't already pop via okayTapped
                      else if (rootPage == null && goBackOnDismiss != true) {
                        Navigator.of(context).pop();
                      }

                      // existing rootPage / goBackOnDismiss logic remains intact:
                      if (rootPage != null) {
                        Navigator.popUntil(
                          context,
                          ModalRoute.withName(rootPage!),
                        );
                      }
                      if (goBackOnDismiss == true) {
                        // pop dialog then page
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          left: Consts.padding,
          right: Consts.padding,
          child: Material(
            elevation: 6.0,
            shape: const CircleBorder(),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(Consts.padding),
              child: image ?? Container(),
            ),
          ),
        ),
      ],
    );
  }

  void _updateRemark() {
    remark = controller.text;
  }

  Widget remarkDialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            top: Consts.avatarRadius + Consts.padding,
            bottom: Consts.padding,
            left: Consts.padding,
            right: Consts.padding,
          ),
          margin: const EdgeInsets.only(top: Consts.avatarRadius),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(Consts.padding),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (!useDescription)
                Text(
                  title ?? "",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              const SizedBox(height: 16.0),
              if (useDescription)
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16.0),
                )
              else
                TextField(
                  maxLength: 60,
                  controller: controller,
                ),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (cancel)
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (secondButton)
                    _SingleFireButton(
                      text: buttonText2 ?? "",
                      textButton: true,
                      onPressed: () async {
                        if (useDescription) {
                          final result = secondTapped?.call();
                          if (result is Future) await result;
                        } else if (controller.text.isEmpty) {
                          Toast.show(
                              "Please enter remark before submit.",
                              duration: Toast.lengthShort,
                              gravity: Toast.bottom);
                        } else if (controller.text.length <= 60) {
                          final result = secondTapped?.call(controller.text);
                          if (result is Future) await result;
                        } else {
                          Toast.show("Maximum 60 character",
                              duration: Toast.lengthShort,
                              gravity: Toast.bottom);
                        }
                      },
                    ),
                  _SingleFireButton(
                    text: buttonText,
                    color: colorTheme2,
                    onPressed: () async {
                      if (useDescription) {
                        final result = remarkTapped?.call("");
                        if (result is Future) await result;
                      } else if (controller.text.isEmpty) {
                        Toast.show("Please enter remark before submit.",
                            duration: Toast.lengthShort,
                            gravity: Toast.bottom);
                      } else if (controller.text.length <= 60) {
                        final result = remarkTapped?.call(controller.text);
                        if (result is Future) await result;
                      } else {
                        Toast.show("Maximum 60 character",
                            duration: Toast.lengthShort,
                            gravity: Toast.bottom);
                      }
                    },
                  ),
                ],
              )
            ],
          ),
        ),
        Positioned(
          left: Consts.padding,
          right: Consts.padding,
          child: Material(
            elevation: 6.0,
            shape: const CircleBorder(),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(Consts.padding),
              child: image ?? Container(),
            ),
          ),
        ),
      ],
    );
  }
}

/// Ignores further taps until [onPressed] finishes, including async API calls.
class _SingleFireButton extends StatefulWidget {
  final String text;
  final Color? color;
  final bool textButton;
  final Future<void> Function() onPressed;

  const _SingleFireButton({
    required this.text,
    required this.onPressed,
    this.color,
    this.textButton = false,
  });

  @override
  State<_SingleFireButton> createState() => _SingleFireButtonState();
}

class _SingleFireButtonState extends State<_SingleFireButton> {
  bool _busy = false;

  Future<void> _handle() async {
    if (_busy) return;
    _busy = true;
    if (mounted) setState(() {});
    try {
      await widget.onPressed();
    } finally {
      if (mounted) {
        _busy = false;
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.textButton) {
      return TextButton(
        onPressed: _busy ? null : _handle,
        child: Text(
          widget.text,
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return Button(
      text: widget.text,
      color: widget.color,
      onPressed: _busy ? null : _handle,
    );
  }
}

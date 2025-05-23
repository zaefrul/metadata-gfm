import 'package:flutter/material.dart';
import 'package:GEMS/controller/Storekeeper/utils/widget/button.dart';
import 'package:GEMS/controller/Storekeeper/utils/constant.dart';
import 'package:toast/toast.dart';

class Consts {
  Consts._();

  static const double padding = 16.0;
  static const double avatarRadius = 40.0;
}

typedef RemarkCallback = void Function(String text);
typedef VoidCallbackNoParam = void Function();

class CustomDialog extends StatelessWidget {
  final RemarkCallback? remarkTapped;
  final String? title;
  final String description;
  final String buttonText;
  final String? buttonText2;
  final Image? image;
  final bool cancel;
  final bool useDescription;
  final bool secondButton;
  final String rootPage;
  String remark = '';
  final VoidCallbackNoParam? okayTapped;
  final RemarkCallback? secondTapped;
  final bool showError = false;

  final TextEditingController controller = TextEditingController();

  CustomDialog({
    this.title,
    required this.description,
    required this.buttonText,
    this.useDescription = false,
    this.buttonText2,
    this.cancel = false,
    this.image,
    required this.rootPage,
    this.remarkTapped,
    this.okayTapped,
    this.secondButton = false,
    this.secondTapped,
    Key? key,
  }) : super(key: key) {
    controller.addListener(_updateRemark);
  }

  void _updateRemark() {
    remark = controller.text;
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
          margin: EdgeInsets.only(top: Consts.avatarRadius),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(Consts.padding),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              title == null
                  ? Container()
                  : Text(
                      title!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
              const SizedBox(height: 16.0),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  cancel
                      ? TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // To close the dialog
                          },
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : Container(),
                  Button(
                    text: buttonText,
                    onPressed: () {
                      if (okayTapped != null) {
                        okayTapped!();
                      }
                      Navigator.popUntil(
                          context, ModalRoute.withName(rootPage));
                    },
                    color: colorTheme2,
                  ),
                  if (secondButton) const SizedBox(width: 12),
                  if (secondButton)
                    Button(
                      text: buttonText2 ?? '',
                      onPressed: () {
                        if (secondTapped != null) {
                          secondTapped!(remark);
                        }
                      },
                      color: colorTheme3,
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
              child: image,
            ),
          ),
        ),
      ],
    );
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
          margin: EdgeInsets.only(top: Consts.avatarRadius),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(Consts.padding),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              useDescription
                  ? Container()
                  : Text(
                      title ?? "",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
              const SizedBox(height: 16.0),
              useDescription
                  ? Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                    )
                  : TextField(
                      maxLength: 60,
                      controller: controller,
                    ),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  cancel
                      ? TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // To close the dialog
                          },
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : Container(),
                  secondButton
                      ? TextButton(
                          onPressed: () {
                            if (useDescription) {
                              if (secondTapped != null) secondTapped!("");
                            } else if (controller.text.isEmpty) {
                              Toast.show("Please enter remark before submit.");
                            } else if (controller.text.length <= 60) {
                              if (secondTapped != null)
                                secondTapped!(controller.text);
                            } else {
                              Toast.show("Maximum 60 characters");
                            }
                          },
                          child: Text(
                            buttonText2 ?? "",
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : Container(),
                  Button(
                    text: buttonText,
                    onPressed: () {
                      if (useDescription) {
                        if (remarkTapped != null) remarkTapped!("");
                      } else if (controller.text.isEmpty) {
                        Toast.show("Please enter remark before submit.");
                      } else if (controller.text.length <= 60) {
                        if (remarkTapped != null)
                          remarkTapped!(controller.text);
                      } else {
                        Toast.show("Maximum 60 characters");
                      }
                    },
                    color: colorTheme2,
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
              child: image,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'button.dart';
import 'package:toast/toast.dart';
import '../utils/reference.dart';

class Consts {
  Consts._();
  static const double padding = 16.0;
  static const double avatarRadius = 40.0;
}

typedef CustomVoidCallback = void Function(String text);

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
  String remark;
  final Function? okayTapped;
  final Function? secondTapped;
  bool showError;

  final TextEditingController controller = TextEditingController();

  CustomDialog({
    Key? key,
    this.title,
    required this.description,
    required this.buttonText,
    this.useDescription = false,
    this.buttonText2,
    this.cancel = false,
    this.image,
    this.rootPage,
    this.remarkTapped,
    this.okayTapped,
    this.secondButton = false,
    this.secondTapped,
    this.showError = false,
    this.remark = "",
  }) : super(key: key) {
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
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  cancel
                      ? TextButton(
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
                        )
                      : Container(),
                  Button(
                    text: buttonText,
                    onPressed: () {
                      if (okayTapped != null) okayTapped!();
                      if (rootPage != null) {
                        Navigator.popUntil(
                          context,
                          ModalRoute.withName(rootPage!),
                        );
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
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              !useDescription
                  ? Text(
                      title ?? "",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : Container(),
              const SizedBox(height: 16.0),
              useDescription
                  ? Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16.0),
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
                            Navigator.of(context).pop();
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
                              if (secondTapped != null) secondTapped!();
                            } else if (controller.text.isEmpty) {
                              Toast.show("Please enter remark before submit.",
                                  duration: Toast.lengthShort,
                                  gravity: Toast.bottom);
                            } else if (controller.text.length <= 60) {
                              if (secondTapped != null)
                                secondTapped!(controller.text);
                            } else {
                              Toast.show("Maximum 60 character",
                                  duration: Toast.lengthShort,
                                  gravity: Toast.bottom);
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
                        Toast.show("Please enter remark before submit.",
                            duration: Toast.lengthShort, gravity: Toast.bottom);
                      } else if (controller.text.length <= 60) {
                        if (remarkTapped != null)
                          remarkTapped!(controller.text);
                      } else {
                        Toast.show("Maximum 60 character",
                            duration: Toast.lengthShort, gravity: Toast.bottom);
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
              child: image ?? Container(),
            ),
          ),
        ),
      ],
    );
  }
}

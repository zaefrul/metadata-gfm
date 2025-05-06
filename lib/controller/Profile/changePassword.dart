import 'package:flutter/material.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:toast/toast.dart';

import '../../utils/reference.dart';
import '../../view/button.dart';
import '../../view/field.dart';
import '../../view/dialog.dart';
import '../../main.dart';

class Change extends StatefulWidget {
  @override
  _ChangeState createState() => _ChangeState();
}

class _ChangeState extends State<Change> {
  final titleTxt = "Forgot Password?";
  final noticeTxt =
      "Enter your email address and we'll send you a link to reset your password.";

  String oldPassword = "";
  String newPassword = "";
  String confirmPassword = "";
  bool loading = false;
  bool viewOld = true;
  bool viewNew = true;
  bool viewConfirm = true;

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    pressed() {
      String p =
          "^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$%\^&\*])(?=.{8,})";
      RegExp regExp = RegExp(p);

      var text = "Password Updating";
      if (oldPassword.length == 0 ||
          newPassword.length == 0 ||
          confirmPassword.length == 0)
        text = "Fill all field!";
      else if (oldPassword.length < 8 ||
          newPassword.length < 8 ||
          confirmPassword.length < 8)
        text = "Passwords must be at least 8 characters long";
      else if (oldPassword.length > 20 ||
          newPassword.length > 20 ||
          confirmPassword.length > 20)
        text = "All field must be lest than 20 character!";
      else if (oldPassword == newPassword)
        text = "Old password cannot be same as new password!";
      else if (newPassword != confirmPassword)
        text = "Password not match!";
      else if (regExp.hasMatch(newPassword) == false)
        text =
            " Password must be a combination of alphanumeric, symbol and capital letter.";
      else
        action;

      Toast.show(text, backgroundColor: colorTheme3);
    }

    var body = new Column(
      children: <Widget>[
        SizedBox(height: 40),
        new Image.asset(
          "assets/changepassword.png",
          height: 100,
        ),
        SizedBox(height: 30),
        title("Enter your new password below, we're just being extra safe",
            size: 16),
        SizedBox(height: 30),
        field("Old Password", (text) {
          oldPassword = text;
        },
            secure: viewOld,
            rightIcon: GestureDetector(
              child:
                  viewOld ? Icon(Icons.visibility) : Icon(Icons.visibility_off),
              onTap: () {
                setState(() {
                  viewOld = !viewOld;
                });
              },
            )),
        field("New Password", (text) {
          newPassword = text;
        },
            secure: viewNew,
            rightIcon: GestureDetector(
              child:
                  viewNew ? Icon(Icons.visibility) : Icon(Icons.visibility_off),
              onTap: () {
                setState(() {
                  viewNew = !viewNew;
                });
              },
            )),
        field("Confirm New Password", (text) {
          confirmPassword = text;
        },
            secure: viewConfirm,
            rightIcon: GestureDetector(
              child: viewConfirm
                  ? Icon(Icons.visibility)
                  : Icon(Icons.visibility_off),
              onTap: () {
                setState(() {
                  viewConfirm = !viewConfirm;
                });
              },
            )),
        SizedBox(height: 80),
        new Container(
            width: 200,
            height: 50,
            child: Button(
              text: "Done",
              onPressed: pressed,
              color: colorTheme2,
            ))
      ],
    );

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            title: title("Change Password"),
            backgroundColor: Colors.white,
            centerTitle: true,
            iconTheme: IconThemeData(color: colorTheme3)),
        body: loading
            ? new Stack(
                children: <Widget>[
                  body,
                  new Container(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                    color: Colors.black.withOpacity(0.5),
                  )
                ],
              )
            : body);
  }

  Widget title(text, {double size = 30.0}) => new Text(text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: colorTheme3,
        fontWeight: FontWeight.bold,
      ));

  Widget info() => Container(
          child: Column(children: <Widget>[
        new Center(child: title(titleTxt, size: 32)),
        new SizedBox(height: 30),
        new Center(child: title(noticeTxt, size: 20)),
      ]));

  get action async {
    setState(() => loading = true);

    var bodyProvider = {
      "action": "change_password",
      "oldPassword": oldPassword,
      "newPassword": newPassword
    };

    Provider provider = Provider(fetchURL: "/api/m_ppm.php"); // Replace with the actual URL

    provider
        .post(url: "/api/m_ppm.php", body: bodyProvider)
        .then((value) => setState(() => alert(value)))
        .catchError((err) => alert(err, success: false))
        .whenComplete(() => setState(() => loading = false));
  }

  void alert(String txt, {bool success = true}) => showDialog(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) => CustomDialog(
          rootPage: success ? "/profile" : "",
          description: txt,
          buttonText: "Okay",
          image: Image.asset(
            "assets/icon_trans.png",
            height: 40,
          )));
}

import 'package:flutter/material.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:toast/toast.dart';

import '../utils/reference.dart';
import '../view/button.dart';
import '../view/field.dart';
import '../view/dialog.dart';

class Forgot extends StatefulWidget {
  @override
  _ForgotState createState() => _ForgotState();
}

class _ForgotState extends State<Forgot> {
  final titleTxt = "Forgot Password?";
  final noticeTxt =
      "Enter your email address and we'll send you a link to reset your password.";
  bool loading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _email;

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    pressed() {
      var error = _validateEmail(_email);

      if (error == null)
        action(_email);
      else
        Toast.show(error, backgroundColor: colorTheme3);
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          title: title(titleTxt),
          backgroundColor: Colors.white,
          centerTitle: true,
          iconTheme: IconThemeData(color: colorTheme3)),
      body: new Stack(
        children: <Widget>[
          new Align(
            alignment: Alignment(0, -0.8),
            child: Image.asset(
              "assets/Email.png",
              height: 100,
            ),
          ),
          new Align(
            alignment: Alignment(0, -0.45),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: title(noticeTxt, size: 20),
            ),
          ),
          new Align(
            alignment: Alignment(0, -0.1),
            child: field("Email", (text) {
              _email = text;
            }, leftIcon: Icons.email),
          ),
          new Align(
              alignment: Alignment(0, 0.2),
              child: new Container(
                  width: 200,
                  height: 50,
                  child: Button(
                    text: "Submit",
                    onPressed: pressed,
                    color: colorTheme2,
                  ))),
          loading
              ? new Container(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                  color: Colors.black.withOpacity(0.5),
                )
              : new Container(),
        ],
      ),
    );
  }

  Widget title(text, {double size = 24.0}) => new Text(text,
      textAlign: TextAlign.center,
      style: new TextStyle(
        color: colorTheme3,
        //   fontFamily: 'Avenir',
        //   // fontSize: size,
        fontWeight: FontWeight.bold,
      ));

  Widget info() => Container(
          child: Column(children: <Widget>[
        new Center(child: title(titleTxt, size: 32)),
        new SizedBox(height: 30),
        new Center(child: title(noticeTxt, size: 20)),
      ]));

  String _validateEmail(String value) {
    if (value == null)
      return "Enter email address";
    else if (value.isEmpty) return "Enter email address";

    // This is just a regular expression for email addresses
    String p = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
        "\\@" +
        "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
        "(" +
        "\\." +
        "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
        ")+";
    RegExp regExp = new RegExp(p);

    if (regExp.hasMatch(value)) {
      // So, the email is valid
      return null;
    }

    // The pattern of the email didn't match the regex above.
    return 'Email is not valid';
  }

  action(username) async {
    setState(() => loading = true);

    var bodyProvider = {
      "action": "forgot_password",
      "email": username,
    };

    Provider provider = Provider();

    try {
      var result = await provider.post(
          url: "/api/m_login.php", body: bodyProvider, includedHeader: false);
      alert(result);
      setState(() => loading = false);
    } catch (err) {
      alert(err, success: false);
      setState(() => loading = false);
    }
  }

  void alert(String txt, {bool success = true}) => showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
          rootPage: success ? "/" : null,
          description: txt,
          buttonText: "Okay",
          image: Image.asset(
            "assets/icon_trans.png",
            height: 40,
          )));
}

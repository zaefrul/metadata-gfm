import 'package:flutter/material.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:toast/toast.dart';

import '../utils/reference.dart';
import '../view/button.dart';
import '../view/field.dart';
import '../view/dialog.dart';

import '../main.dart';

class Forgot extends StatefulWidget {
  const Forgot({Key? key}) : super(key: key);

  @override
  _ForgotState createState() => _ForgotState();
}

class _ForgotState extends State<Forgot> {
  final String titleTxt = "Forgot Password?";
  final String noticeTxt =
      "Enter your email address and we'll send you a link to reset your password.";
  bool loading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _email = "";

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);

    void pressed() {
      String? error = _validateEmail(_email);
      if (error != null) {
        Toast.show(error, backgroundColor: colorTheme3);
      } else {
        // Call your action when validation passes
        action(_email);
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          title: title(titleTxt),
          backgroundColor: Colors.white,
          centerTitle: true,
          iconTheme: IconThemeData(color: colorTheme3)),
      body: Stack(
        children: <Widget>[
          Align(
            alignment: const Alignment(0, -0.8),
            child: Image.asset(
              "assets/Email.png",
              height: 100,
            ),
          ),
          Align(
            alignment: const Alignment(0, -0.45),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: title(noticeTxt, size: 20),
            ),
          ),
          Align(
            alignment: const Alignment(0, -0.1),
            child: field("Email", (text) {
              _email = text;
            }, leftIcon: Icons.email),
          ),
          Align(
            alignment: const Alignment(0, 0.2),
            child: Container(
              width: 200,
              height: 50,
              child: Button(
                text: "Submit",
                onPressed: pressed,
                color: colorTheme2,
              ),
            ),
          ),
          loading
              ? Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget title(String text, {double size = 24.0}) => Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: colorTheme3,
          fontWeight: FontWeight.bold,
          fontSize: size,
        ),
      );

  Widget info() => Container(
          child: Column(children: <Widget>[
        Center(child: title(titleTxt, size: 32)),
        const SizedBox(height: 30),
        Center(child: title(noticeTxt, size: 20)),
      ]));

  String? _validateEmail(String value) {
    if (value.isEmpty) return "Enter email address";

    // Regular expression for email addresses
    String p =
        "[a-zA-Z0-9\\+\\.\\_\\%\\-\\+]{1,256}" +
            "\\@" +
            "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
            "(" +
            "\\." +
            "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
            ")+";
    RegExp regExp = RegExp(p);

    if (regExp.hasMatch(value)) {
      // Email is valid
      return null;
    }

    // The pattern did not match; return error message.
    return 'Email is not valid';
  }

  Future<void> action(String username) async {
    setState(() => loading = true);

    var bodyProvider = {
      "action": "forgot_password",
      "email": username,
    };

    Provider provider = Provider(fetchURL: "/api/m_login.php");

    try {
      var result = await provider.post(
          url: "/api/m_login.php", body: bodyProvider, includedHeader: false);
      alert(result);
      setState(() => loading = false);
    } catch (err) {
      alert(err.toString(), success: false);
      setState(() => loading = false);
    }
  }

  void alert(String txt, {bool success = true}) => showDialog(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) => CustomDialog(
            rootPage: success ? "/" : "",
            description: txt,
            buttonText: "Okay",
            image: Image.asset(
              "assets/icon_trans.png",
              height: 40,
            ),
          ));
}

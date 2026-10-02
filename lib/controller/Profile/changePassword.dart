import 'package:flutter/material.dart';
import 'package:GEMS/view/gems_chrome.dart';
import 'package:GEMS/utils/network.dart';
import 'package:toast/toast.dart';

import '../../view/dialog.dart';
import '../../main.dart';

class Change extends StatefulWidget {
  const Change({super.key});

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
          "^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$%^&*])(?=.{8,})";
      RegExp regExp = RegExp(p);

      var text = "Password Updating";
      if (oldPassword.isEmpty ||
          newPassword.isEmpty ||
          confirmPassword.isEmpty) {
        text = "Fill all field!";
      } else if (oldPassword.length < 8 ||
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

      Toast.show(text, backgroundColor: GemsChrome.text);
    }

    Widget passwordField({
      required String label,
      required bool hidden,
      required ValueChanged<String> onChanged,
      required VoidCallback onToggle,
    }) {
      return TextField(
        obscureText: hidden,
        style: GemsChrome.body(size: 14),
        onChanged: onChanged,
        decoration: gemsFieldDecoration(label: label).copyWith(
          suffixIcon: IconButton(
            onPressed: onToggle,
            icon: Icon(
              hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: GemsChrome.textSoft,
            ),
          ),
        ),
      );
    }

    var body = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          GemsFormSection(
            title: 'New password',
            icon: Icons.lock_outline,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Enter your new password below, we're just being extra safe",
                  style: GemsChrome.body(size: 13, color: GemsChrome.textSoft),
                ),
                const SizedBox(height: 14),
                passwordField(
                  label: 'Old password',
                  hidden: viewOld,
                  onChanged: (text) => oldPassword = text,
                  onToggle: () => setState(() => viewOld = !viewOld),
                ),
                const SizedBox(height: 12),
                passwordField(
                  label: 'New password',
                  hidden: viewNew,
                  onChanged: (text) => newPassword = text,
                  onToggle: () => setState(() => viewNew = !viewNew),
                ),
                const SizedBox(height: 12),
                passwordField(
                  label: 'Confirm new password',
                  hidden: viewConfirm,
                  onChanged: (text) => confirmPassword = text,
                  onToggle: () => setState(() => viewConfirm = !viewConfirm),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            style: gemsPrimaryButton(),
            onPressed: loading ? null : pressed,
            child: Text(
              'Save',
              style: GemsChrome.body(weight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: GemsChrome.page,
        appBar: gemsAppBar(
            title: const Text('Change Password')),
        body: loading
            ? Stack(
                children: <Widget>[
                  body,
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(color: GemsChrome.primary),
                    ),
                  )
                ],
              )
            : body);
  }

  Widget title(text, {double size = 30.0}) => Text(text,
      textAlign: TextAlign.center,
      style: GemsChrome.heading(size: size > 20 ? 18 : 14));

  Widget info() => Container(
          child: Column(children: <Widget>[
        Center(child: title(titleTxt, size: 32)),
        SizedBox(height: 30),
        Center(child: title(noticeTxt, size: 20)),
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

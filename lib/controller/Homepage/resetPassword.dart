import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import '../../utils/network.dart';
import '../../utils/reference.dart';
import '../../view/button.dart';
import '../../view/field.dart';
import '../../view/dialog.dart';
import '../../main.dart';

class ResetArguments {
  final String username;

  ResetArguments(this.username);
}

class ResetPassword extends StatefulWidget {
  static const routeName = '/reset';

  ResetPassword();

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final String noticeTxt =
      "Enter your new password below, we're just being extra safe";

  String newPassword = "";
  String confirmPassword = "";
  bool loading = false;
  bool viewNew = true;
  bool viewConfirm = true;

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);

    void pressed() {
      String p =
          "^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$%\^&\*])(?=.{8,})";
      RegExp regExp = RegExp(p);

      var text = "Password Updating";
      if (newPassword.isEmpty || confirmPassword.isEmpty)
        text = "Fill all field!";
      else if (newPassword.length < 8 || confirmPassword.length < 8)
        text = "Passwords must be at least 8 characters long";
      else if (newPassword.length > 20 || confirmPassword.length > 20)
        text = "Password must be less than 20 characters!";
      else if (newPassword != confirmPassword)
        text = "Password not match!";
      else if (!regExp.hasMatch(newPassword))
        text =
            "Password must be a combination of alphanumeric, symbol and capital letter.";
      else
        action(newPassword);

      Toast.show(text, backgroundColor: colorTheme3);
    }

    var body = Column(
      children: <Widget>[
        SizedBox(height: 40),
        Image.asset(
          "assets/changepassword.png",
          height: 100,
        ),
        SizedBox(height: 30),
        title(noticeTxt, size: 16),
        SizedBox(height: 30),
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
        Container(
            width: 200,
            height: 50,
            child: Button(
              text: "Save",
              onPressed: pressed,
              color: colorTheme2,
            ))
      ],
    );

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            title: title("New Password"),
            backgroundColor: Colors.white,
            centerTitle: true,
            iconTheme: IconThemeData(color: colorTheme3)),
        body: loading
            ? Stack(
                children: <Widget>[
                  body,
                  Container(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                    color: Colors.black.withOpacity(0.5),
                  )
                ],
              )
            : body);
  }

  Widget title(String text, {double size = 30.0}) => Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: colorTheme3,
          fontWeight: FontWeight.bold,
          fontSize: size,
        ),
      );

  Future<void> action(String password) async {
    final ResetArguments args =
        ModalRoute.of(context)!.settings.arguments as ResetArguments;

    setState(() => loading = true);

    var deviceId = await getDeviceDetails();

    var bodyProvider = {
      "action": "reset_password",
      "username": args.username,
      "password": password,
      "deviceId": deviceId
    };

    Provider provider = Provider(fetchURL: "/api/m_login.php");

    provider
        .post(
            url: "/api/m_login.php", body: bodyProvider, includedHeader: false)
        .then((value) => setState(() {
              alert(value);
            }))
        .catchError((err) {
      alert(err);
    }).whenComplete(() => setState(() => loading = false));
  }

  void alert(String txt) => showDialog(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) => CustomDialog(
          rootPage: "/homepage",
          description: txt,
          buttonText: "Okay",
          image: Image.asset(
            "assets/icon_trans.png",
            height: 40,
          )));
}

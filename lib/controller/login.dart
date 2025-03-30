import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gfm_gems/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../view/button.dart';
import '../view/field.dart';
import '../utils/reference.dart';
import '../utils/network.dart';
import 'forgotPassword.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  final double pad = 20.0;

  String? _username;
  String? _password;
  bool userExist = true;
  bool userlogIn = false;
  late AnimationController _animationController;
  bool secure = true;
  bool requestedLocation = false;

  @override
  void initState() {
    super.initState();

    User.getPrefUser.then((_) {
      Navigator.of(context).pushReplacementNamed("/homepage");
    }).catchError((err) {
      setState(() {
        userExist = false;
      });
    });

    _animationController = AnimationController(
      value: 0.0,
      lowerBound: 0.0,
      upperBound: 0.15,
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);

    if (userExist) return background;

    bool keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0.0;
    if (keyboardOpen) {
      _animationController.animateTo(0.15, curve: Curves.easeInOut);
    } else {
      _animationController.reverse();
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) => Stack(
          children: <Widget>[
            background,
            Align(
              alignment: Alignment(0, -0.7 - _animationController.value),
              child: logo,
            ),
            Align(
              alignment: Alignment(0, 0 - _animationController.value),
              child: field("User ID", (text) {
                _username = text;
              }),
            ),
            Align(
              alignment: Alignment(0, 0.20 - _animationController.value),
              child: field(
                "Password",
                (text) => _password = text,
                secure: secure,
                rightIcon: GestureDetector(
                  child: Icon(
                      secure ? Icons.visibility : Icons.visibility_off),
                  onTap: () {
                    setState(() {
                      secure = !secure;
                    });
                  },
                ),
              ),
            ),
            Align(
              alignment: Alignment(0, 0.45),
              child: button,
            ),
            Align(
              alignment: Alignment(0, 0.8),
              child: GestureDetector(
                child: Hero(
                  tag: "ForgotPassword",
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      "Forgot Password",
                      style: TextStyle(
                        color: colorTheme2,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Forgot()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get background => Container(
        height: double.infinity,
        width: double.infinity,
        child: Image.asset("assets/bg.jpg", fit: BoxFit.fill),
      );

  Widget get logo => Padding(
        padding: const EdgeInsets.all(50.0),
        child: Image.asset("assets/logo.png"),
      );

  Widget get button => Container(
        color: Colors.transparent,
        width: 200,
        height: 50,
        child: Button(
          text: userlogIn ? "Loading" : "Login",
          onPressed: userlogIn
              ? () {}
              : () async {
                  if ((await keepLocationSession) == false) {
                    Toast.show("Please Login with better GPS Area");
                    return;
                  }

                  getDeviceDetails().then((result) {
                    print(result);
                  });

                  setState(() => userlogIn = true);

                  void showErr(String err) {
                    setState(() => userlogIn = false);
                    Toast.show(err, backgroundColor: colorTheme3);
                  }

                  void homepage() =>
                      Navigator.pushReplacementNamed(context, "/homepage");

                  if (_username == null || _password == null) {
                    showErr("Please fill up all field");
                  } else {
                    login(_username!, _password!).then((user) async {
                      if (user == null) return Future.error("No Result");
                      setState(() => userlogIn = false);
                      user.saveUser();
                      homepage();
                      showErr("Welcome ${user.username} !");
                    }).catchError((err) {
                      print(err);
                      showErr(err.toString());
                    }).whenComplete(() {
                      setState(() => userlogIn = false);
                    });
                  }
                },
        ),
      );

  Future<bool> get keepLocationSession async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      bool value = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

      while (!value) {
        final result = await Geolocator.requestPermission();
        permission = result;
        value = permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse;
      }
      var position = await Geolocator.getLastKnownPosition(
          forceAndroidLocationManager: true);
      if (position == null) {
        position = await Geolocator.getCurrentPosition(
            forceAndroidLocationManager: true);
      }

      var prefs = await SharedPreferences.getInstance();

      prefs.setString(prefsLATITUDE, position.latitude.toString());
      prefs.setString(prefsLONGITUDE, position.longitude.toString());

      return value;
    } catch (err) {
      print(err);
      return true;
    }
  }
}

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
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  final double pad = 20.0;

  String _username;
  String _password;
  bool userExist = true;
  bool userlogIn = false;
  AnimationController _animationController;
  bool secure = true;

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
        duration: Duration(milliseconds: 100),
        vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (userExist) return background;

    var keyboardOpen =
        MediaQuery.of(context).viewInsets.bottom > 0.0 ? true : false;
    if (keyboardOpen == true)
      _animationController.animateTo(0.15, curve: Curves.easeInOut);
    if (keyboardOpen == false) _animationController.reverse();

    return new Scaffold(
        resizeToAvoidBottomInset: false,
        body: new AnimatedBuilder(
            animation: _animationController,
            builder: (context, controller) => new Stack(
                  children: <Widget>[
                    background,
                    new Align(
                      alignment:
                          Alignment(0, -0.7 - _animationController.value),
                      child: logo,
                    ),
                    new Align(
                      alignment: Alignment(0, 0 - _animationController.value),
                      child: field("User ID", (text) {
                        _username = text;
                      }),
                    ),
                    new Align(
                        alignment:
                            Alignment(0, 0.20 - _animationController.value),
                        child: field("Password", (text) => _password = text,
                            secure: secure,
                            rightIcon: GestureDetector(
                              child: secure
                                  ? Icon(Icons.visibility)
                                  : Icon(Icons.visibility_off),
                              onTap: () {
                                setState(() {
                                  secure = !secure;
                                });
                              },
                            ))),
                    new Align(alignment: Alignment(0, 0.45), child: button),
                    new Align(
                        alignment: Alignment(0, 0.8),
                        child: new GestureDetector(
                          child: Hero(
                              tag: "ForgotPassword",
                              child: Material(
                                color: Colors.transparent,
                                child: new Text("Forgot Password",
                                    style: TextStyle(
                                        // fontFamily: "Avenir",
                                        // fontSize: 16,
                                        color: colorTheme2,
                                        decoration: TextDecoration.underline)),
                              )),
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Forgot())),
                        ))
                  ],
                )));
  }

  get background => new Container(
        height: double.infinity,
        width: double.infinity,
        child: Image.asset("assets/bg.jpg", fit: BoxFit.fill),
      );

  get logo => new Padding(
        padding: EdgeInsets.all(50.0),
        child: new Image.asset("assets/logo.png"),
      );

  get button => Container(
        color: Colors.transparent,
        width: 200,
        height: 50,
        child: Button(
          text: userlogIn ? "Loading" : "Login",
          onPressed: userlogIn
              ? null
              : () async {
                  if ((await keepLocationSession) == false) {
                    Toast.show("Please Login with better GPS Area");
                    return;
                  }

                  getDeviceDetails().then((result) {
                    print(result);
                  });

                  setState(() => userlogIn = true);

                  showErr(String err) {
                    setState(() => userlogIn = false);
                    Toast.show(err, backgroundColor: colorTheme3);
                  }

                  homepage() =>
                      Navigator.pushReplacementNamed(context, "/homepage");

                  if (_username == null || _password == null)
                    showErr("Please fill up all field");
                  else
                    login(_username, _password).then((user) {
                      if (user == null) return Future.error("No Result");
                      setState(() => userlogIn = false);
                      user.saveUser();
                      homepage();
                      showErr("Welcome ${user.username} !");
                    }).catchError((err) {
                      print(err);
                      showErr(err);
                    }).whenComplete(() {
                      setState(() => userlogIn = false);
                    });
                },
        ),
      );

  Future<bool> get keepLocationSession async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      bool value = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

      while (value == false) {
        Geolocator.requestPermission().then((value) => permission = value);
        value = permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse;
      }
      var position = await Geolocator.getLastKnownPosition(
          forceAndroidLocationManager: true);
      if (position == null)
        position = await Geolocator.getCurrentPosition(
            forceAndroidLocationManager: true);

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

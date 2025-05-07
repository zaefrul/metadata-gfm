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
  late AnimationController _controller;
  late Animation<Alignment> _logoAlignment;
  late Animation<double> _formOpacity;

  String? _username;
  String? _password;
  bool userExist = true;
  bool userlogIn = false;
  bool secure = true;

  @override
  void initState() {
    super.initState();

    // check if already logged in
    User.getPrefUser.then((_) {
      Navigator.of(context).pushReplacementNamed("/homepage");
    }).catchError((_) {
      setState(() => userExist = false);
    });

    // 3s total, first half moves logo, second half fades form in
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _logoAlignment = AlignmentTween(
      begin: Alignment.center,
      end: const Alignment(0, -0.7),
    ).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );

    _formOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0, curve: Curves.easeIn)),
    );

    // kick off
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);

    // while we’re still checking prefs, just show the background
    if (userExist) return _background;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          _background,

          // Animated logo
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => Align(
              alignment: _logoAlignment.value,
              child: _logo,
            ),
          ),

          // Fading-in form
          FadeTransition(
            opacity: _formOpacity,
            child: Align(
              alignment: const Alignment(0, 0.30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _field("User ID", (v) => _username = v),
                  const SizedBox(height: 16),
                  _field(
                    "Password",
                    (v) => _password = v,
                    secure: secure,
                    rightIcon: GestureDetector(
                      child: Icon(
                        secure ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.secondaryDark,
                      ),
                      onTap: () => setState(() => secure = !secure),
                    ),
                  ),
                  const SizedBox(height: 40),
                  _submitButton,
                  const SizedBox(height: 16),
                  GestureDetector(
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const Forgot()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget get _background => Container(
        height: double.infinity,
        width: double.infinity,
        child: Image.asset("assets/bg.jpg", fit: BoxFit.fill),
      );

  Widget get _logo => Padding(
        padding: const EdgeInsets.all(50.0),
        child: Image.asset("assets/logo.png"),
      );

  Widget _field(String label, ValueChanged<String> onChanged,
        {bool secure = false, Widget? rightIcon}) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: TextField(
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: rightIcon,
          ),
          onChanged: onChanged,
          obscureText: secure,
        ),
      );
    }

  Widget get _submitButton => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 60),
    child: SizedBox(
      width: double.infinity,  // take all the space left by your padding
      height: 48,               // your desired button height
      child: Button(
        text: userlogIn ? "Loading…" : "LOGIN",
        onPressed: userlogIn
          ? () async {} 
          : () async => await _onLoginPressed(),
        color: AppColors.primaryDark,
      ),
    ),
  );

  Future<void> _onLoginPressed() async {
    setState(() => userlogIn = true);
    // location check, login logic, etc.
    if (!(await _keepLocationSession())) {
      Toast.show("Please login in an area with good GPS", backgroundColor: AppColors.danger);
      setState(() => userlogIn = false);
      return;
    }

    if (_username == null || _password == null || _username!.isEmpty || _password!.isEmpty) {
      Toast.show("Please fill out all fields", backgroundColor: AppColors.warning);
      setState(() => userlogIn = false);
      return;
    }

    try {
      final user = await login(_username!, _password!);
      if (user == null) throw "Invalid credentials";
      user.saveUser();
      Navigator.pushReplacementNamed(context, "/homepage");
      Toast.show("Welcome to GEMS, ${user.username}!", backgroundColor: AppColors.success);
    } catch (e) {
      Toast.show(e.toString(), backgroundColor: AppColors.danger);
    } finally {
      setState(() => userlogIn = false);
    }
  }

  Future<bool> _keepLocationSession() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      final ok = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
      final pos = await Geolocator.getCurrentPosition();
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(prefsLATITUDE, pos.latitude.toString());
      prefs.setString(prefsLONGITUDE, pos.longitude.toString());
      return ok;
    } catch (_) {
      return false;
    }
  }
}

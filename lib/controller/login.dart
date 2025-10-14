import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:GEMS/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:local_auth/local_auth.dart';

import '../view/button.dart';
import '../utils/reference.dart';
import '../utils/network.dart';
import 'forgotPassword.dart';
import '../utils/auth_secure_storage.dart';

class Login extends StatefulWidget {
  const Login({super.key});
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
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;

  final LocalAuthentication _localAuthentication = LocalAuthentication();

  @override
  void initState() {
    super.initState();

    // check if already logged in
    User.getPrefUser.then((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed("/homepage");
    }).catchError((_) {
      if (!mounted) return;
      setState(() => userExist = false);
      _initBiometric();
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
                  if (_biometricEnabled) ...[
                    const SizedBox(height: 12),
                    _biometricButton,
                  ],
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

  Widget get _background => SizedBox(
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

  Widget get _biometricButton => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.fingerprint),
            label: const Text("Sign in with biometrics"),
            onPressed: userlogIn ? null : () => _handleBiometricLogin(auto: false),
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
      user.saveUser();
      await _handlePostLoginBiometric();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/homepage");
      Toast.show("Welcome to GEMS, ${user.username}!", backgroundColor: AppColors.success);
    } catch (e) {
      Toast.show(e.toString(), backgroundColor: AppColors.danger);
    } finally {
      if (mounted) {
        setState(() => userlogIn = false);
      }
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

  Future<void> _handlePostLoginBiometric() async {
    if (!_biometricAvailable || _username == null || _password == null) return;

    final alreadyEnabled = await AuthSecureStorage.isEnabled();
    if (alreadyEnabled) {
      await AuthSecureStorage.updateCredentials(_username!, _password!);
      if (!mounted) return;
      setState(() => _biometricEnabled = true);
      return;
    }

    final shouldEnable = await _showEnableBiometricDialog();
    if (shouldEnable == true) {
      await AuthSecureStorage.enable(_username!, _password!);
      if (!mounted) return;
      setState(() => _biometricEnabled = true);
    }
  }

  Future<bool?> _showEnableBiometricDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enable biometric login'),
        content: const Text('Would you like to sign in faster using Face ID / Touch ID next time?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Not now'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  Future<void> _initBiometric() async {
    try {
      final isSupported = await _localAuthentication.isDeviceSupported();
      final canCheck = await _localAuthentication.canCheckBiometrics;
      final hasDeviceBiometric = isSupported && canCheck;
      final enabled = await AuthSecureStorage.isEnabled();
      final storedCreds = await AuthSecureStorage.readCredentials();

      if (!mounted) return;

      setState(() {
        _biometricAvailable = hasDeviceBiometric;
        _biometricEnabled = enabled && storedCreds != null;
      });
    } catch (e) {
      debugPrint('Biometric init failed: $e');
    }
  }

  Future<void> _handleBiometricLogin({required bool auto}) async {
    if (!_biometricAvailable) return;
    final creds = await AuthSecureStorage.readCredentials();
    if (creds == null) {
      if (!auto) {
        Toast.show(
          "Biometric credentials not available.",
          backgroundColor: AppColors.warning,
        );
      }
      return;
    }

    try {
      final didAuthenticate = await _localAuthentication.authenticate(
        localizedReason: 'Authenticate to sign in to GEMS',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!didAuthenticate) {
        if (!auto) {
          Toast.show('Biometric authentication cancelled.', backgroundColor: AppColors.warning);
        }
        return;
      }

      if (!mounted) return;
      setState(() => userlogIn = true);

      final user = await login(creds.username, creds.password);
      user.saveUser();
      await AuthSecureStorage.updateCredentials(creds.username, creds.password);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/homepage");
      Toast.show("Welcome back, ${user.username}!", backgroundColor: AppColors.success);
    } catch (e) {
      Toast.show(e.toString(), backgroundColor: AppColors.danger);
    } finally {
      if (mounted) {
        setState(() => userlogIn = false);
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:GEMS/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:local_auth/local_auth.dart';
import 'package:GEMS/utils/biometric_lock_manager.dart';

import '../utils/reference.dart';
import '../utils/network.dart';
import 'forgotPassword.dart';
import '../utils/auth_secure_storage.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _cardAlignment;
  late Animation<double> _contentOpacity;

  String? _username;
  String? _password;
  bool userExist = true;
  bool userlogIn = false;
  bool secure = true;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  bool _rememberMe = false;
  NetworkSource _selectedNetworkSource = NetworkSource.gemsPlus;

  final LocalAuthentication _localAuthentication = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _loadNetworkSource();

    User.getPrefUser.then((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed("/homepage");
    }).catchError((_) {
      if (!mounted) return;
      setState(() => userExist = false);
      _initBiometric();
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _cardAlignment = AlignmentTween(
      begin: Alignment.center,
      end: const Alignment(0, -0.1),
    ).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );

    _contentOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.5, 1.0, curve: Curves.easeIn)),
    );

    _controller.forward();
  }

  Future<void> _loadNetworkSource() async {
    final source = await NetworkEnvironment.load();
    if (!mounted) return;
    setState(() => _selectedNetworkSource = source);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);

    if (userExist) {
      return _initialBackground();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/login-bg.jpg',
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => Align(
                alignment: _cardAlignment.value,
                child: FadeTransition(
                  opacity: _contentOpacity,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    child: _buildLoginCard(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _initialBackground() {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Image.asset(
        'assets/login-bg.jpg',
        fit: BoxFit.cover,
        alignment: Alignment.center,
      ),
    );
  }

  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  // Approx. CSS: linear-gradient(135deg, #ceeef0 0%, #e7eaec 100%)
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFCEEFF0),
                    Color(0xFFE7EAEC),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo-cropped.png',
                    height: 200, // adjust as you like
                    fit: BoxFit.contain,
                  )
                  // const SizedBox(height: 12)
                  // ,
                  // Text(
                  //   'Log in to your account',
                  //   style: TextStyle(
                  //     color: Colors.black.withOpacity(0.8),
                  //     fontSize: 18,
                  //     fontWeight: FontWeight.w600,
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: FadeTransition(
              opacity: _contentOpacity,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _inputField(
                      label: 'User ID',
                      hintText: '',
                      onChanged: (v) => _username = v,
                    ),
                    const SizedBox(height: 20),
                    _passwordField(),
                    const SizedBox(height: 18),
                    _networkSelector(),
                    const SizedBox(height: 12),
                    _rememberRow(),
                    const SizedBox(height: 24),
                    _primaryButton(),
                    if (_biometricEnabled) ...[
                      const SizedBox(height: 16),
                      _biometricButton(),
                    ],
                    const SizedBox(height: 24),
                    // _signupPrompt(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _networkSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System',
          style: TextStyle(
            color: AppColors.dark,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<NetworkSource>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment<NetworkSource>(
                value: NetworkSource.gemsPlus,
                label: Text('GEMS+'),
              ),
              ButtonSegment<NetworkSource>(
                value: NetworkSource.gems20,
                label: Text('GEMS 2.0'),
              ),
            ],
            selected: {_selectedNetworkSource},
            onSelectionChanged: userlogIn
                ? null
                : (selection) {
                    setState(() => _selectedNetworkSource = selection.first);
                  },
          ),
        ),
      ],
    );
  }

  Widget _inputField({
    required String label,
    required ValueChanged<String> onChanged,
    String? hintText,
  }) {
    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: AppColors.secondary.withValues(alpha: 0.2)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.dark,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: const Color(0xFFF8F9FB),
            border: baseBorder,
            enabledBorder: baseBorder,
            focusedBorder: baseBorder.copyWith(
              borderSide: BorderSide(color: AppColors.primary, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _passwordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Password',
              style: TextStyle(
                color: AppColors.dark,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Forgot()),
              ),
              child: Text(
                'Forgot Password?',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          obscureText: secure,
          onChanged: (v) => _password = v,
          decoration: InputDecoration(
            hintText: '',
            filled: true,
            fillColor: const Color(0xFFF8F9FB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide:
                  BorderSide(color: AppColors.secondary.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: AppColors.primary, width: 1.4),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                secure ? Icons.visibility_off : Icons.visibility,
                color: AppColors.secondaryDark,
              ),
              onPressed: () => setState(() => secure = !secure),
            ),
          ),
        ),
      ],
    );
  }

  Widget _rememberRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Remember me next time',
          style: TextStyle(color: AppColors.secondaryDark),
        ),
        Checkbox(
          value: _rememberMe,
          onChanged: (value) => setState(() => _rememberMe = value ?? false),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _primaryButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(0, 173, 168, 1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
          elevation: 0,
        ),
        onPressed: userlogIn ? null : () async => await _onLoginPressed(),
        child: Text(
          userlogIn ? 'Loading…' : 'Log in',
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }

  Widget _biometricButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        ),
        icon: const Icon(Icons.fingerprint),
        label: const Text('Sign in with biometrics'),
        onPressed: userlogIn ? null : () => _handleBiometricLogin(auto: false),
      ),
    );
  }

  Widget _signupPrompt() {
    return Center(
      child: Text.rich(
        TextSpan(
          text: "Don't have an account? ",
          style: TextStyle(color: Colors.grey.shade600),
          children: [
            TextSpan(
              text: 'Sign up',
              style: TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onLoginPressed() async {
    setState(() => userlogIn = true);

    if (!(await _keepLocationSession())) {
      Toast.show("Please login in an area with good GPS",
          backgroundColor: AppColors.danger);
      setState(() => userlogIn = false);
      return;
    }

    if (_username == null ||
        _password == null ||
        _username!.isEmpty ||
        _password!.isEmpty) {
      Toast.show("Please fill out all fields",
          backgroundColor: AppColors.warning);
      setState(() => userlogIn = false);
      return;
    }

    try {
      final user =
          await login(_username!, _password!, source: _selectedNetworkSource);
      user.saveUser();
      await _handlePostLoginBiometric();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/homepage");
      Toast.show("Welcome to GEMS, ${user.username}!",
          backgroundColor: AppColors.success);
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
    final networkSource = NetworkEnvironment.valueFor(_selectedNetworkSource);

    final alreadyEnabled = await AuthSecureStorage.isEnabled();
    if (alreadyEnabled) {
      await AuthSecureStorage.updateCredentials(
        _username!,
        _password!,
        networkSource: networkSource,
      );
      if (!mounted) return;
      setState(() => _biometricEnabled = true);
      return;
    }

    final shouldEnable = await _showEnableBiometricDialog();
    if (shouldEnable == true) {
      await AuthSecureStorage.enable(
        _username!,
        _password!,
        networkSource: networkSource,
      );
      if (!mounted) return;
      setState(() => _biometricEnabled = true);
    }
  }

  Future<bool?> _showEnableBiometricDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enable biometric login'),
        content: const Text(
            'Would you like to sign in faster using Face ID / Touch ID next time?'),
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
      if (mounted) {
        setState(() {
          _biometricAvailable = hasDeviceBiometric;
        });
      }

      final enabledFlag = await AuthSecureStorage.isEnabled();
      final storedCreds = await AuthSecureStorage.readCredentials();

      if (!mounted) return;

      setState(() {
        // Be resilient to drift between the flag and the stored creds.
        // If creds exist but the flag is missing/false (legacy or partial wipe), still show the button.
        _biometricEnabled =
            hasDeviceBiometric && (enabledFlag || storedCreds != null);
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
      BiometricLockManager.suppressNextLock();
      final didAuthenticate = await _localAuthentication.authenticate(
        localizedReason: 'Authenticate to sign in to GEMS',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!didAuthenticate) {
        if (!auto) {
          Toast.show('Biometric authentication cancelled.',
              backgroundColor: AppColors.warning);
        }
        return;
      }

      if (!mounted) return;
      final source = creds.networkSource == null
          ? _selectedNetworkSource
          : NetworkEnvironment.sourceFromValue(creds.networkSource);
      setState(() {
        userlogIn = true;
        _selectedNetworkSource = source;
      });

      final user = await login(creds.username, creds.password, source: source);
      user.saveUser();
      // Ensure the enabled flag and creds stay consistent (prevents button disappearing).
      await AuthSecureStorage.enable(
        creds.username,
        creds.password,
        networkSource: NetworkEnvironment.valueFor(source),
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/homepage");
      Toast.show("Welcome back, ${user.username}!",
          backgroundColor: AppColors.success);
    } catch (e) {
      Toast.show(e.toString(), backgroundColor: AppColors.danger);
    } finally {
      if (mounted) {
        setState(() => userlogIn = false);
      }
    }
  }
}

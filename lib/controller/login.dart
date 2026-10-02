import 'package:flutter/material.dart';
import 'package:GEMS/model/user.dart';
import 'package:GEMS/main.dart' as app show navigatorKey;
import 'package:GEMS/service/notification_router.dart';
import 'package:GEMS/service/notification_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:toast/toast.dart';
import 'package:local_auth/local_auth.dart';
import 'package:GEMS/utils/biometric_lock_manager.dart';

import '../utils/location_helper.dart';
import '../utils/reference.dart';
import '../utils/network.dart';
import '../view/gems_chrome.dart';
import 'forgotPassword.dart';
import '../utils/auth_secure_storage.dart';

class Login extends StatefulWidget {
  final NetworkSource? preselectedSource;

  const Login({super.key, this.preselectedSource});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _contentOpacity;

  String? _username;
  String? _password;
  String _appVersion = '';
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
    if (widget.preselectedSource != null) {
      _selectedNetworkSource = widget.preselectedSource!;
      NetworkEnvironment.save(widget.preselectedSource!);
      // Coming from notification backend-switch: force login UI.
      userExist = false;
      _initBiometric();
    } else {
      _loadNetworkSource();
      User.getPrefUser.then((_) {
        if (!mounted) return;
        // Session restore skips the password GPS gate — refresh in the background.
        resolveDeviceLocation(forceRefresh: true);
        Navigator.of(context).pushReplacementNamed("/homepage");
      }).catchError((_) {
        if (!mounted) return;
        setState(() => userExist = false);
        _initBiometric();
      });
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _contentOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
      });
    } catch (e) {
      debugPrint('Error getting app version: $e');
    }
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
      backgroundColor: GemsChrome.page,
      body: Column(
        children: [
          _brandBand(),
          Expanded(
            child: FadeTransition(
              opacity: _contentOpacity,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: _buildLoginCard(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _initialBackground() {
    return const Scaffold(
      backgroundColor: GemsChrome.page,
      body: Center(
        child: Image(
          image: AssetImage('assets/logo-cropped.png'),
          height: 96,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _brandBand() {
    final topInset = MediaQuery.paddingOf(context).top;
    return SizedBox(
      height: 176 + topInset,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/login-bg.jpg', fit: BoxFit.cover),
          const ColoredBox(color: Color(0xC7CEEFF0)),
          Padding(
            padding: EdgeInsets.only(top: topInset),
            child: const Center(
              child: Image(
                image: AssetImage('assets/logo-cropped.png'),
                height: 96,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 3,
            child: ColoredBox(color: GemsChrome.teal),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(GemsChrome.radius),
            border: Border.all(color: GemsChrome.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 3,
                  margin: const EdgeInsets.only(bottom: 14),
                  color: GemsChrome.teal,
                ),
              ),
              Text(
                'Welcome back',
                textAlign: TextAlign.center,
                style: GemsChrome.heading(size: 22),
              ),
              const SizedBox(height: 4),
              Text(
                'Sign in to continue to GEMS.',
                textAlign: TextAlign.center,
                style: GemsChrome.body(size: 13, color: GemsChrome.textSoft),
              ),
              const SizedBox(height: 20),
              _inputField(
                label: 'Login ID',
                onChanged: (v) => _username = v,
              ),
              const SizedBox(height: 14),
              _passwordField(),
              const SizedBox(height: 14),
              _networkSelector(),
              const SizedBox(height: 4),
              _rememberRow(),
              const SizedBox(height: 16),
              _primaryButton(),
              if (_biometricEnabled) ...[
                const SizedBox(height: 10),
                _biometricButton(),
              ],
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Forgot()),
                ),
                child: Text(
                  'Forgot password?',
                  style: GemsChrome.body(
                    size: 13,
                    weight: FontWeight.w500,
                    color: GemsChrome.primary,
                  ),
                ),
              ),
              Text(
                '© 2019 – 2026 GEMS',
                textAlign: TextAlign.center,
                style: GemsChrome.body(size: 11, color: GemsChrome.textSoft),
              ),
              if (_appVersion.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Version $_appVersion',
                  textAlign: TextAlign.center,
                  style: GemsChrome.body(size: 11, color: GemsChrome.muted),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text.rich(
        TextSpan(
          text: label,
          style: GemsChrome.body(size: 13, weight: FontWeight.w500),
          children: const [
            TextSpan(
              text: ' *',
              style: TextStyle(color: GemsChrome.danger),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({Widget? suffixIcon}) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(GemsChrome.radius),
      borderSide: const BorderSide(color: GemsChrome.border),
    );
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      suffixIcon: suffixIcon,
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: GemsChrome.primary, width: 1.4),
      ),
    );
  }

  Widget _networkSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('System', style: GemsChrome.body(size: 13, weight: FontWeight.w500)),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: GemsChrome.primary,
                  ),
            ),
            child: SegmentedButton<NetworkSource>(
              showSelectedIcon: false,
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(GemsChrome.radius),
                  ),
                ),
                side: WidgetStateProperty.all(
                  const BorderSide(color: GemsChrome.border),
                ),
              ),
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
        ),
      ],
    );
  }

  Widget _inputField({
    required String label,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        TextField(
          onChanged: onChanged,
          style: GemsChrome.body(size: 14),
          decoration: _fieldDecoration(),
        ),
      ],
    );
  }

  Widget _passwordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Password'),
        TextField(
          obscureText: secure,
          onChanged: (v) => _password = v,
          style: GemsChrome.body(size: 14),
          decoration: _fieldDecoration(
            suffixIcon: IconButton(
              icon: Icon(
                secure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: GemsChrome.textSoft,
                size: 20,
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
      children: [
        Checkbox(
          value: _rememberMe,
          onChanged: (value) => setState(() => _rememberMe = value ?? false),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          activeColor: GemsChrome.primary,
          side: const BorderSide(color: GemsChrome.muted),
          visualDensity: VisualDensity.compact,
        ),
        Text(
          'Remember me',
          style: GemsChrome.body(size: 13, color: GemsChrome.textSoft),
        ),
      ],
    );
  }

  Widget _primaryButton() {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: GemsChrome.primary,
          disabledBackgroundColor: GemsChrome.primary.withValues(alpha: 0.6),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GemsChrome.radius),
          ),
          elevation: 0,
        ),
        onPressed: userlogIn ? null : () async => await _onLoginPressed(),
        child: userlogIn
            ? Text('Loading…', style: GemsChrome.body(size: 15, weight: FontWeight.w600, color: Colors.white))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Log In',
                    style: GemsChrome.body(
                      size: 15,
                      weight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 18),
                ],
              ),
      ),
    );
  }

  Widget _biometricButton() {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: GemsChrome.primary,
          side: const BorderSide(color: GemsChrome.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GemsChrome.radius),
          ),
        ),
        icon: const Icon(Icons.fingerprint),
        label: Text(
          'Sign in with biometrics',
          style: GemsChrome.body(
            size: 14,
            weight: FontWeight.w500,
            color: GemsChrome.primary,
          ),
        ),
        onPressed: userlogIn ? null : () => _handleBiometricLogin(auto: false),
      ),
    );
  }

  Future<void> _onLoginPressed() async {
    setState(() => userlogIn = true);

    if (!(await _keepLocationSession())) {
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
      await _registerTokenAndOpenPending();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/homepage");
      Toast.show("Welcome to GEMS, ${user.username}!",
          backgroundColor: AppColors.success);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        NotificationRouter.consumePendingAndNavigate(app.navigatorKey);
      });
    } catch (e) {
      Toast.show(e.toString(), backgroundColor: AppColors.danger);
    } finally {
      if (mounted) {
        setState(() => userlogIn = false);
      }
    }
  }

  Future<void> _registerTokenAndOpenPending() async {
    try {
      if (mounted) {
        await NotificationService.registerToken(context: context);
      }
    } catch (e) {
      debugPrint('FCM token registration after login failed: $e');
    }
  }

  Future<bool> _keepLocationSession() async {
    final location = await resolveDeviceLocationOrPrompt(
      context,
      forceRefresh: true,
      requireFresh: true,
    );
    return location.isFreshFix;
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

      if (!(await _keepLocationSession())) {
        if (mounted) {
          setState(() => userlogIn = false);
        }
        return;
      }

      final user = await login(creds.username, creds.password, source: source);
      user.saveUser();
      // Ensure the enabled flag and creds stay consistent (prevents button disappearing).
      await AuthSecureStorage.enable(
        creds.username,
        creds.password,
        networkSource: NetworkEnvironment.valueFor(source),
      );
      if (!mounted) return;
      await _registerTokenAndOpenPending();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/homepage");
      Toast.show("Welcome back, ${user.username}!",
          backgroundColor: AppColors.success);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        NotificationRouter.consumePendingAndNavigate(app.navigatorKey);
      });
    } catch (e) {
      Toast.show(e.toString(), backgroundColor: AppColors.danger);
    } finally {
      if (mounted) {
        setState(() => userlogIn = false);
      }
    }
  }
}

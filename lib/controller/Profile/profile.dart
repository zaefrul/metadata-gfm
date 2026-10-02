// lib/controller/Profile/profile.dart

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:toast/toast.dart';

import '../../model/user.dart';
import '../../utils/auth_secure_storage.dart';
import '../../utils/network.dart';
import '../../view/drawer.dart';
import '../../view/gems_chrome.dart';
import '../PPM/Form/openImage.dart';
import 'changePassword.dart';
import 'editProfile.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final LocalAuthentication _localAuth = LocalAuthentication();

  String _name = "";
  List<String> _role = [];
  String _contact = "";
  String _email = "";
  String _imageSrc = "";
  late User user;
  bool _profileLoaded = false;
  bool _biometricSupported = false;
  bool _biometricEnabled = false;
  bool _loadingBiometric = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _initBiometricState();
  }

  void _loadProfile() {
    User.getPrefUser.then((prefs) {
      user = User.fromMap(prefs);
      if (!mounted) return;
      setState(() {
        _name     = user.firstName;
        _role     = user.roles.map((r) => r.desc).toList();
        _contact  = user.contactNo;
        _email    = user.email;
        _imageSrc = user.imageUrl;
        _profileLoaded = true;
      });
    });
  }

  Future<void> _initBiometricState() async {
    try {
      final supported = await _localAuth.isDeviceSupported();
      final available = await _localAuth.getAvailableBiometrics();
      final enabled = await AuthSecureStorage.isEnabled();
      final creds = await AuthSecureStorage.readCredentials();
      if (!mounted) return;
      setState(() {
        _biometricSupported = supported && available.isNotEmpty;
        _biometricEnabled = enabled && creds != null;
      });
    } catch (e) {
      debugPrint('Biometric status check failed: $e');
      if (!mounted) return;
      setState(() {
        _biometricSupported = false;
        _biometricEnabled = false;
      });
    }
  }

  Future<void> _onBiometricChanged(bool value) async {
    if (_loadingBiometric) return;
    final previous = _biometricEnabled;
    setState(() => _loadingBiometric = true);

    final success = value ? await _enableBiometric() : await _disableBiometric();
    if (!mounted) return;

    setState(() {
      _biometricEnabled = success ? value : previous;
      _loadingBiometric = false;
    });

    if (success) {
      await _initBiometricState();
    }
  }

  Future<bool> _enableBiometric() async {
    if (!_biometricSupported) {
      Toast.show(
        "Biometric authentication isn't available on this device.",
        backgroundColor: GemsChrome.warning,
      );
      return false;
    }
    if (!_profileLoaded) {
      Toast.show(
        "Profile data is still loading. Please try again in a moment.",
        backgroundColor: GemsChrome.warning,
      );
      return false;
    }

    final password = await _promptPassword();
    if (password == null || password.isEmpty) {
      return false;
    }

    try {
      final refreshedUser = await login(user.username, password);
      user = refreshedUser;
      await user.saveUser();
      await AuthSecureStorage.enable(user.username, password);
      _loadProfile();
      Toast.show(
        "Biometric login enabled.",
        backgroundColor: GemsChrome.success,
      );
      return true;
    } catch (e) {
      Toast.show(
        e.toString(),
        backgroundColor: GemsChrome.danger,
      );
      return false;
    }
  }

  Future<bool> _disableBiometric() async {
    final confirm = await _confirmDisable();
    if (!confirm) {
      return false;
    }
    try {
      await AuthSecureStorage.disable();
      Toast.show(
        "Biometric login disabled.",
        backgroundColor: GemsChrome.success,
      );
      return true;
    } catch (e) {
      Toast.show(
        "Failed to disable biometric login.",
        backgroundColor: GemsChrome.danger,
      );
      return false;
    }
  }

  Future<String?> _promptPassword() async {
    final controller = TextEditingController();
    String? password;
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Enable biometric login'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter your current password to enable biometric login.'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              obscureText: true,
              style: GemsChrome.body(size: 14),
              decoration: gemsFieldDecoration(label: 'Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: GemsChrome.body(color: GemsChrome.textSoft)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: Text(
              'Enable',
              style: GemsChrome.body(weight: FontWeight.w600, color: GemsChrome.primary),
            ),
          ),
        ],
      ),
    ).then((value) => password = value);
    controller.dispose();
    return password;
  }

  Future<bool> _confirmDisable() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Disable biometric login'),
        content: const Text('You will need to enter your password the next time you sign in.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: GemsChrome.body(color: GemsChrome.textSoft)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Disable',
              style: GemsChrome.body(weight: FontWeight.w600, color: GemsChrome.danger),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Widget _buildRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: GemsChrome.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GemsChrome.body(size: 12, color: GemsChrome.textSoft)),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? '-' : value,
                  style: GemsChrome.body(size: 14, weight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: GemsChrome.page,
      appBar: gemsAppBar(
        title: const Text('Profile'),
      ),
      drawer: BuildDrawer(() => Navigator.pop(context)),
      body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            children: [
              Center(
                child: GestureDetector(
                  onTap: _imageSrc.isEmpty ? null : () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ImageViewer(url: "http:$_imageSrc"),
                    ));
                  },
                  child: CircleAvatar(
                    radius: 52,
                    backgroundColor: GemsChrome.primarySoft,
                    backgroundImage: _imageSrc.isEmpty
                      ? const AssetImage('assets/profile_plain.png') as ImageProvider
                      : NetworkImage("http:$_imageSrc"),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _name.isEmpty ? 'Profile' : _name,
                textAlign: TextAlign.center,
                style: GemsChrome.heading(size: 20),
              ),
              if (_role.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  _role.join(', '),
                  textAlign: TextAlign.center,
                  style: GemsChrome.body(size: 13, color: GemsChrome.textSoft),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton.icon(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                label: Text(
                  'Edit profile',
                  style: GemsChrome.body(weight: FontWeight.w600, color: Colors.white),
                ),
                style: gemsPrimaryButton(),
                onPressed: !_profileLoaded
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => Edit(user)),
                        ).then((_) => _loadProfile()),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.lock_outline),
                label: Text(
                  'Change password',
                  style: GemsChrome.body(weight: FontWeight.w600, color: GemsChrome.primary),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: GemsChrome.primary,
                  side: const BorderSide(color: GemsChrome.primary),
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(GemsChrome.radius),
                  ),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => Change()),
                ),
              ),
              const SizedBox(height: 20),
              GemsFormSection(
                title: 'Details',
                icon: Icons.badge_outlined,
                child: Column(
                  children: [
                    _buildRow(Icons.person_outline, 'Name', _name),
                    _buildRow(Icons.work_outline, 'Roles', _role.join(', ')),
                    _buildRow(Icons.phone_outlined, 'Contact No.', _contact),
                    _buildRow(Icons.email_outlined, 'Email', _email),
                  ],
                ),
              ),
              if (_biometricSupported) ...[
                const SizedBox(height: 12),
                _buildBiometricSettingsCard(),
              ],
            ],
      ),
    );
  }

  Widget _buildBiometricSettingsCard() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(GemsChrome.radius),
        border: Border.all(color: GemsChrome.border),
      ),
      child: Column(
        children: [
          SwitchListTile.adaptive(
            activeColor: GemsChrome.primary,
            title: Text(
              'Biometric login',
              style: GemsChrome.body(weight: FontWeight.w600),
            ),
            subtitle: Text(
              _biometricEnabled
                  ? 'Disable if you prefer to enter your password every time.'
                  : 'Enable to sign in faster using Face ID or Touch ID.',
              style: GemsChrome.body(size: 13, color: GemsChrome.textSoft),
            ),
            value: _biometricEnabled,
            onChanged: _loadingBiometric ? null : _onBiometricChanged,
          ),
          if (_loadingBiometric)
            const LinearProgressIndicator(
              minHeight: 2,
              color: GemsChrome.primary,
              backgroundColor: GemsChrome.border,
            ),
        ],
      ),
    );
  }
}

Widget get background => SizedBox(
  height: double.infinity,
  width: double.infinity,
  child: Image.asset("assets/bg.jpg", fit: BoxFit.fill),
);
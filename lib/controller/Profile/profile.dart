// lib/controller/Profile/profile.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:toast/toast.dart';

import '../../model/user.dart';
import '../../utils/auth_secure_storage.dart';
import '../../utils/network.dart';
import '../../utils/reference.dart';
import '../../view/bar.dart';
import '../../view/drawer.dart';
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
        backgroundColor: AppColors.warning,
      );
      return false;
    }
    if (!_profileLoaded) {
      Toast.show(
        "Profile data is still loading. Please try again in a moment.",
        backgroundColor: AppColors.warning,
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
        backgroundColor: AppColors.success,
      );
      return true;
    } catch (e) {
      Toast.show(
        e.toString(),
        backgroundColor: AppColors.danger,
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
        backgroundColor: AppColors.success,
      );
      return true;
    } catch (e) {
      Toast.show(
        "Failed to disable biometric login.",
        backgroundColor: AppColors.danger,
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
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Enable'),
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
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Disable'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Widget _buildRow(IconData icon, String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: colorTheme2),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        subtitle: Text(value, style: GoogleFonts.poppins()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: bar(
        _scaffoldKey,
        text: "Profile",
        search: false,
      ) as PreferredSizeWidget?,
      drawer: BuildDrawer(() => Navigator.pop(context)),

      body: Stack(
        children: [
          background,
          ListView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            children: [
              // — Avatar —
              Center(
                child: GestureDetector(
                  onTap: _imageSrc.isEmpty ? null : () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ImageViewer(url: "http:$_imageSrc"),
                    ));
                  },
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _imageSrc.isEmpty
                      ? AssetImage('assets/profile_plain.png') as ImageProvider
                      : NetworkImage("http:$_imageSrc"),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // — Edit / Change buttons —
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(Icons.edit, color: Colors.white),
                      label: Text("Edit Profile", style: GoogleFonts.poppins(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => Edit(user)),
                      ).then((_) => _loadProfile()),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon: Icon(Icons.lock, color: Colors.white),
                      label: Text("Change Password", style: GoogleFonts.poppins(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => Change()),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // — Profile fields —
              _buildRow(Icons.person,       "Name",         _name),
              _buildRow(Icons.work,         "Roles",        _role.join(", ")),
              _buildRow(Icons.phone,        "Contact No.",  _contact),
              _buildRow(Icons.email,        "Email",        _email),
              if (_biometricSupported) ...[
                _buildBiometricSettingsCard(),
              ],
            ],
          ),
        ],
      )
    );
  }

  Widget _buildBiometricSettingsCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        children: [
          SwitchListTile.adaptive(
            title: Text(
              'Biometric Login',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              _biometricEnabled
                  ? 'Disable if you prefer to enter your password every time.'
                  : 'Enable to sign in faster using Face ID / Touch ID.',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            value: _biometricEnabled,
            onChanged: _loadingBiometric ? null : _onBiometricChanged,
          ),
          if (_loadingBiometric)
            const LinearProgressIndicator(minHeight: 2),
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
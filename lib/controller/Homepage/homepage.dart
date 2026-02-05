import 'dart:async';
import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:GEMS/controller/Storekeeper/utils/constant.dart';
import 'package:GEMS/controller/Storekeeper/utils/widget/dialog.dart';
import 'package:GEMS/model/user.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:GEMS/view/drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart'; // Import package_info_plus
import 'package:GEMS/utils/biometric_lock_manager.dart';

import 'resetPassword.dart';

// --- Constants for Role IDs ---
const String _roleAdminId = "1";
const String _roleStorekeeperId = "16";
const String _roleUtilitiesId = "18";

// --- Constants for Route Names (if not already in constant.dart) ---
// const String routePPM = "/ppm";
// const String routeWorkOrder = "/workorder";
// const String routeNotifications = "/notifications";

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  User? _currentUser;
  bool _isStorekeeperFeatureEnabled = false;
  bool _isUtilitiesFeatureEnabled = false;
  bool _isLoading = true;
  String _appVersion = ''; // New state variable for app version
  int _versionTapCount = 0; // Secret debug menu tap counter

  @override
  void initState() {
    super.initState();
    ToastContext().init(context);
    _initializeHomepage();
    _getAppVersion(); // Fetch app version
  }

  Future<void> _getAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = packageInfo.version;
          // If you also want build number: _appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
        });
      }
    } catch (e) {
      debugPrint("Error getting app version: $e");
      if (mounted) {
        setState(() {
          _appVersion = 'N/A'; // Fallback if unable to get version
        });
      }
    }
  }

  void _onVersionTap() {
    if (!mounted) return;
    
    setState(() {
      _versionTapCount++;
    });

    if (_versionTapCount >= 6 && _versionTapCount <= 9) {
      // Show countdown toast for last 4 taps (only if still mounted)
      if (mounted) {
        int remaining = 10 - _versionTapCount;
        try {
          Toast.show(
            "Navigate to debug menu in $remaining",
            duration: Toast.lengthShort,
            gravity: Toast.bottom,
          );
        } catch (e) {
          debugPrint("Toast error: $e");
        }
      }
    } else if (_versionTapCount == 10) {
      // Reset counter immediately
      setState(() {
        _versionTapCount = 0;
      });
      
      // Navigate after a brief delay to ensure any toasts are dismissed
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          Navigator.pushNamed(context, '/secret-debug-menu');
        }
      });
      
      return; // Don't set up the reset timer for this case
    }

    // Reset counter after 2 seconds of inactivity
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _versionTapCount < 10) {
        setState(() {
          _versionTapCount = 0;
        });
      }
    });
  }

  Future<void> _initializeHomepage() async {
    try {
      await _setupFirebaseMessaging();
      await _loadUserDataAndPermissions();
      if (_currentUser != null) {
        await _handleInitialUserFlow(_currentUser!);
      }
    } catch (e) {
      debugPrint("Error during homepage initialization: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error initializing page: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _setupFirebaseMessaging() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null && mounted) {
        final provider = Provider(fetchURL: "/api/m_ppm.php")..context = context;
        await provider.post(url: "/api/m_ppm.php", body: {
          "action": "save_token",
          "token": token,
        });
        debugPrint("FCM Token saved: $token");
      }
    } catch (e) {
      debugPrint("Error setting up Firebase Messaging: $e");
    }
  }

  Future<void> _loadUserDataAndPermissions() async {
    try {
      final prefs = await User.getPrefUser;
      final user = User.fromMap(prefs);

      bool tempIsStorekeeper = false;
      bool tempIsUtilities = false;

      for (final role in user.roles) {
        if (role.id == _roleAdminId) {
          tempIsStorekeeper = true;
          tempIsUtilities = true;
          break;
        }
        if (role.id == _roleStorekeeperId) {
          tempIsStorekeeper = true;
        }
        if (role.id == _roleUtilitiesId) {
          tempIsUtilities = true;
        }
      }

      if (mounted) {
        setState(() {
          _currentUser = user;
          _isStorekeeperFeatureEnabled = tempIsStorekeeper;
          _isUtilitiesFeatureEnabled = tempIsUtilities;
        });
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load user data.")),
        );
      }
    }
  }

  Future<void> _handleInitialUserFlow(User user) async {
    if (!mounted) return;

    final requestHandler = Request(context, user.userID);

    try {
      if (user.isFirstTime == "Yes") {
        await Navigator.pushNamed(
          context,
          ResetPassword.routeName,
          arguments: ResetArguments(user.username),
        );
        await user.updateFirstTime("No");
        final signaturePath = await requestHandler.checkSignature();
        if (signaturePath.isEmpty && mounted) {
          requestHandler.promptSignatureSetup(user.userID);
        }
      } else {
        final signaturePath = await requestHandler.checkSignature();
        if (signaturePath.isEmpty && mounted) {
          requestHandler.promptSignatureSetup(user.userID);
        }
      }
    } catch (e) {
      debugPrint("Error in initial user flow: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: BuildDrawer(() => Navigator.pop(context), isHome: true),
      appBar: _buildAppBar(),
      extendBodyBehindAppBar: true,
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.black87),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: Text(
        "GEMS",
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.black87),
          onPressed: () => Navigator.pushNamed(context, "/notifications"),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_currentUser == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text(
                "Could not load user information. Please try again later.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                  });
                  _initializeHomepage();
                },
                child: const Text("Retry"),
              )
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        Positioned.fill(child: _backgroundImage),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(_currentUser!),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "What would you like to do today?",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildFeatureList(context)),
              // --- Version Text at the bottom ---
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0), // Adjust padding as needed
                  child: GestureDetector(
                    onTap: _onVersionTap,
                    child: Text(
                      'Version: $_appVersion',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black54, // Or a color that stands out against your background
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(User user) {
    String displayName = user.username.split('@').first;
    if (displayName.isNotEmpty) {
      displayName = displayName[0].toUpperCase() + displayName.substring(1);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _buildProfileImage(user),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back,",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  displayName,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(User user) {
    String? imageUrl = user.imageUrl;
    bool hasValidUrl = false;

    if (imageUrl.isNotEmpty) {
      if (!imageUrl.startsWith("http://") && !imageUrl.startsWith("https://")) {
        imageUrl = "https:$imageUrl";
      }
      if (Uri.tryParse(imageUrl)?.hasAbsolutePath ?? false) {
         hasValidUrl = true;
      } else {
        imageUrl = null;
      }
    }

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ]
      ),
      child: CircleAvatar(
        radius: 26,
        backgroundColor: Colors.transparent,
        backgroundImage: hasValidUrl
            ? NetworkImage(imageUrl!)
            : const AssetImage('assets/profile_plain.png') as ImageProvider,
        onBackgroundImageError: hasValidUrl ? (dynamic exception, StackTrace? stackTrace) {
          debugPrint("Error loading profile image: $exception");
        } : null,
        child: (!hasValidUrl || (imageUrl == null) )
            ? _buildInitialsAvatar(user)
            : null,
      ),
    );
  }

  Widget _buildInitialsAvatar(User user) {
    final String initials = user.username.isNotEmpty
        ? user.username[0].toUpperCase()
        : "?";
    return Center(
      child: Text(
        initials,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFeatureList(BuildContext context) {
    final features = <_FeatureUIData>[
      _FeatureUIData("Preventive Maintenance", Icons.build_circle_outlined, "/ppm"),
      _FeatureUIData("Work Order", Icons.assignment_outlined, "/workorder"),
      _FeatureUIData("StoreKeeper", Icons.inventory_2_outlined, routeDashboard, enabled: _isStorekeeperFeatureEnabled),
      _FeatureUIData("Utilities", Icons.folder_special_outlined, routeUtilities, enabled: _isUtilitiesFeatureEnabled),
      _FeatureUIData("Leaderboard", Icons.emoji_events_outlined, routeLeaderboard),
      _FeatureUIData("Attendance", Icons.event_available_outlined, routeAttendance),
      _FeatureUIData("Suggestion", Icons.lightbulb_outline, null, onTap: _openSuggestionForm),
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      itemCount: features.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final feature = features[i];
        return _FeatureListItem(
          feature: feature,
          onTap: feature.enabled
              ? () {
                  if (feature.onTap != null) {
                    feature.onTap!();
                  } else if (feature.route != null) {
                    Navigator.pushNamed(context, feature.route!);
                  }
                }
              : null,
        );
      },
    );
  }

  void _openSuggestionForm() async {
    _launchUrlHelper("https://forms.office.com/r/CYvjipHJ4S");
  }

  Future<void> _launchUrlHelper(String urlString) async {
    try {
      // Use BiometricLockManager to prevent biometric prompt when returning from browser
      final launched = await BiometricLockManager.launchExternalUrlString(urlString);
      if (!launched) {
        throw 'Could not launch $urlString';
      }
    } catch (e) {
      debugPrint("Error launching URL: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not open link: ${e.toString()}")),
        );
      }
    }
  }

  Widget get _backgroundImage => SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Image.asset("assets/bg.jpg", fit: BoxFit.cover),
      );
}

// --- UI Data Model for Features ---
class _FeatureUIData {
  final String title;
  final IconData icon;
  final String? route;
  final bool enabled;
  final VoidCallback? onTap;

  _FeatureUIData(
    this.title,
    this.icon,
    this.route, {
    this.enabled = true,
    this.onTap,
  });
}

// --- Refactored Feature List Item Widget ---
class _FeatureListItem extends StatelessWidget {
  final _FeatureUIData feature;
  final VoidCallback? onTap;

  const _FeatureListItem({
    required this.feature,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = feature.enabled && onTap != null;
    final Color tileColor = isEnabled ? (AppColors.primary ?? Colors.blue) : (AppColors.secondary ?? Colors.grey.shade400);
    final Color contentColor = isEnabled ? Colors.white : Colors.white70;

    return PressScaleWidget(
      onTap: isEnabled ? onTap : null,
      child: Container(
        height: 65,
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            Icon(feature.icon, color: contentColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                feature.title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: contentColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isEnabled)
              Icon(Icons.chevron_right, color: contentColor),
          ],
        ),
      ),
    );
  }
}

// --- PressScaleWidget (Your existing widget, ensure AnimationController is disposed) ---
class PressScaleWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const PressScaleWidget({super.key, required this.child, this.onTap});

  @override
  State<PressScaleWidget> createState() => _PressScaleWidgetState();
}

class _PressScaleWidgetState extends State<PressScaleWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (widget.onTap != null) {
      _animationController.reverse();
    }
  }

  void _handleTapUp(TapUpDetails _) {
    if (widget.onTap != null) {
      _animationController.forward().then((_) {
         widget.onTap?.call();
      });
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? _handleTapDown : null,
      onTapUp: widget.onTap != null ? _handleTapUp : null,
      onTapCancel: widget.onTap != null ? _handleTapCancel : null,
      child: ScaleTransition(
        scale: _animationController,
        child: widget.child,
      ),
    );
  }
}

// --- Request Helper Class (Adjusted for clarity and error handling) ---
class Request {
  final BuildContext _buildContext;
  final String _userId;
  late final Provider _signatureProvider;

  Request(this._buildContext, this._userId) {
    _signatureProvider = Provider(fetchURL: "/user_signature/", taskID: _userId)
      ..context = _buildContext;
  }

  Future<String> checkSignature() async {
    try {
      final dynamic result = await _signatureProvider.getJson(url: "/user_signature/");

      if (result == null || result is! Map || result['file'] == null) {
        return "";
      }
      final String filePath = result['file'] as String;
      if (filePath.isEmpty) {
        return "";
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kUserSignature, filePath);
      return filePath;
    } catch (e) {
      debugPrint("Error checking signature: $e");
      return "";
    }
  }

  void promptSignatureSetup(String userId) {
    if (!_buildContext.mounted) return;

    // showDialog(
    //   context: _buildContext,
    //   barrierDismissible: false,
    //   builder: (_) => CustomDialog(
    //     title: "Signature Required",
    //     rootPage: '/homepage',
    //     description: "For security and verification, please set up your digital signature.",
    //     buttonText: "Set Up Signature",
    //     image: Image.asset("assets/icon_trans.png", height: 40),
    //     okayTapped: () {
    //       Navigator.of(_buildContext, rootNavigator: true).pop();
    //       Navigator.pushNamed(_buildContext, routeSignature, arguments: userId);
    //     },
    //   ),
    // );
  }
}
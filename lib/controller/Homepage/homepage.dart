import 'dart:async';

import 'package:GEMS/service/notification_service.dart';
import 'package:GEMS/service/notification_router.dart';
import 'package:GEMS/data/repository/notification_repository.dart';
import 'package:GEMS/main.dart' show navigatorKey;
import 'package:flutter/material.dart';
import 'package:GEMS/controller/Storekeeper/utils/constant.dart';
import 'package:GEMS/model/user.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/view/drawer.dart';
import 'package:GEMS/view/gems_chrome.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
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
  final NotificationRepository _notificationRepository = NotificationRepository();

  User? _currentUser;
  bool _isStorekeeperFeatureEnabled = false;
  bool _isUtilitiesFeatureEnabled = false;
  bool _isLoading = true;
  bool _profileImageLoadFailed = false;
  String _appVersion = '';
  int _versionTapCount = 0;
  int _unreadNotificationCount = 0;

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
          _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
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
      // Deep-link after backend switch + login (or cold start with pending).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        NotificationRouter.consumePendingAndNavigate(navigatorKey);
      });
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
      if (mounted) {
        await NotificationService.registerToken(context: context);
        await _refreshUnreadCount();
      }
    } catch (e) {
      debugPrint("Error setting up Firebase Messaging: $e");
    }
  }

  Future<void> _refreshUnreadCount() async {
    try {
      final count = await _notificationRepository.fetchUnreadCount(context);
      if (mounted) {
        setState(() => _unreadNotificationCount = count);
      }
    } catch (e) {
      debugPrint('Failed to load unread notification count: $e');
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
          _profileImageLoadFailed = false;
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
      backgroundColor: GemsChrome.page,
      drawer: BuildDrawer(() => Navigator.pop(context), isHome: true),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: const Border(bottom: BorderSide(color: GemsChrome.border)),
      leading: IconButton(
        icon: const Icon(Icons.menu, color: GemsChrome.text),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: Text('Home', style: GemsChrome.heading(size: 20)),
      actions: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: GemsChrome.text),
              onPressed: () async {
                await Navigator.pushNamed(context, "/notifications");
                if (mounted) {
                  await _refreshUnreadCount();
                }
              },
            ),
            if (_unreadNotificationCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: GemsChrome.danger,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Text(
                    _unreadNotificationCount > 99
                        ? '99+'
                        : '$_unreadNotificationCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(_currentUser!),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "What would you like to do today?",
            style: GemsChrome.body(size: 13, color: GemsChrome.textSoft),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(child: _buildFeatureList(context)),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: _onVersionTap,
              child: Text(
                'Version $_appVersion',
                style: GemsChrome.body(size: 12, color: GemsChrome.textSoft),
              ),
            ),
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 2),
      child: Row(
        children: [
          _buildProfileImage(user),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back,",
                  style: GemsChrome.body(size: 13, color: GemsChrome.textSoft),
                ),
                Text(
                  displayName,
                  style: GemsChrome.heading(size: 20),
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

    if (!_profileImageLoadFailed && imageUrl.isNotEmpty) {
      if (!imageUrl.startsWith("http://") && !imageUrl.startsWith("https://")) {
        imageUrl = "https:$imageUrl";
      }
      if (Uri.tryParse(imageUrl)?.hasAbsolutePath ?? false) {
         hasValidUrl = true;
      } else {
        imageUrl = null;
      }
    }

    return CircleAvatar(
      radius: 22,
      backgroundColor: GemsChrome.primarySoft,
      backgroundImage: hasValidUrl ? NetworkImage(imageUrl!) : null,
      onBackgroundImageError: hasValidUrl
          ? (dynamic exception, StackTrace? stackTrace) {
              debugPrint("Error loading profile image: $exception");
              if (mounted && !_profileImageLoadFailed) {
                setState(() {
                  _profileImageLoadFailed = true;
                });
              }
            }
          : null,
      child: (!hasValidUrl || imageUrl == null) ? _buildInitialsAvatar(user) : null,
    );
  }

  Widget _buildInitialsAvatar(User user) {
    final String initials = user.username.isNotEmpty
        ? user.username[0].toUpperCase()
        : "?";
    return Center(
      child: Text(
        initials,
        style: GemsChrome.body(
          size: 16,
          weight: FontWeight.w600,
          color: GemsChrome.primary,
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
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
    final Color iconColor = isEnabled ? GemsChrome.primary : GemsChrome.muted;
    final Color labelColor = isEnabled ? GemsChrome.text : GemsChrome.muted;

    return PressScaleWidget(
      onTap: isEnabled ? onTap : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(GemsChrome.radius),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: GemsChrome.border),
            borderRadius: BorderRadius.circular(GemsChrome.radius),
          ),
          child: Column(
            children: [
              Container(
                height: 3,
                color: isEnabled ? GemsChrome.teal : GemsChrome.border,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isEnabled
                            ? GemsChrome.primarySoft
                            : GemsChrome.neutralSoft,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(feature.icon, color: iconColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        feature.title,
                        style: GemsChrome.body(
                          size: 14,
                          weight: FontWeight.w500,
                          color: labelColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isEnabled)
                      const Icon(
                        Icons.chevron_right,
                        color: GemsChrome.muted,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ],
          ),
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
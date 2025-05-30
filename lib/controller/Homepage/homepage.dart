import 'dart:async';
import 'dart:ui'; // Keep if used by other parts of your app, not directly used here after changes

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
// Assuming these are your project's local imports
import 'package:GEMS/controller/Storekeeper/utils/constant.dart'; // For AppColors, routeDashboard etc.
import 'package:GEMS/controller/Storekeeper/utils/widget/dialog.dart'; // For CustomDialog
import 'package:GEMS/model/user.dart'; // Your User model
import 'package:GEMS/utils/network.dart'; // Your custom Provider
import 'package:GEMS/utils/reference.dart'; // For kUserSignature, routeSignature etc.
import 'package:GEMS/view/drawer.dart'; // Your BuildDrawer widget
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart'; // Ensure this is the intended toast package
import 'package:url_launcher/url_launcher.dart';

import 'resetPassword.dart'; // Your ResetPassword screen

// --- Constants for Role IDs ---
const String _roleAdminId = "1";
const String _roleStorekeeperId = "16";
const String _roleUtilitiesId = "18";

// --- Constants for Route Names (if not already in constant.dart) ---
// const String routePPM = "/ppm";
// const String routeWorkOrder = "/workorder";
// const String routeNotifications = "/notifications";
// Example: if routeDashboard is not in constant.dart, define it here.

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
  bool _isLoading = true; // To show a loading indicator initially

  @override
  void initState() {
    super.initState();
    // It's generally better to initialize ToastContext once at the app root,
    // for example, in your MaterialApp's builder.
    // However, keeping it here to match original structure if it's intended.
    ToastContext().init(context);
    _initializeHomepage();
  }

  Future<void> _initializeHomepage() async {
    try {
      await _setupFirebaseMessaging();
      await _loadUserDataAndPermissions();
      if (_currentUser != null) {
        await _handleInitialUserFlow(_currentUser!);
      }
    } catch (e) {
      // Log error more formally if you have a logging service
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
        // Use a local context if Provider doesn't need the Scaffold's context specifically
        final provider = Provider(fetchURL: "/api/m_ppm.php")..context = context;
        // Consider adding error handling for this network call
        await provider.post(url: "/api/m_ppm.php", body: {
          "action": "save_token",
          "token": token,
        });
        debugPrint("FCM Token saved: $token");
      }
    } catch (e) {
      debugPrint("Error setting up Firebase Messaging: $e");
      // Optionally show a non-blocking error to the user
    }
  }

  Future<void> _loadUserDataAndPermissions() async {
    try {
      final prefs = await User.getPrefUser; // Assuming this fetches from SharedPreferences
      final user = User.fromMap(prefs);

      bool tempIsStorekeeper = false;
      bool tempIsUtilities = false;

      for (final role in user.roles) {
        if (role.id == _roleAdminId) {
          tempIsStorekeeper = true;
          tempIsUtilities = true;
          break; // Admin has all permissions, no need to check further
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
        // Show an error message or handle appropriately
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load user data.")),
        );
      }
      // Rethrow if this is a critical failure for the page
      // throw Exception("Failed to load user data: $e");
    }
  }

  Future<void> _handleInitialUserFlow(User user) async {
    try {
      // Ensure context is still valid if operations are long
      if (!mounted) return;

      final requestHandler = Request(context, user.userID);

      if (user.isFirstTime == "Yes") {
        // Navigate to ResetPassword and wait for it to complete
        await Navigator.pushNamed(
          context,
          ResetPassword.routeName,
          arguments: ResetArguments(user.username),
        );
        // After password reset, update first time status
        // Assuming updateFirstTime is an async operation that persists the change
        await user.updateFirstTime("No");
        // Then check for signature
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
      extendBodyBehindAppBar: true, // Keep if the design requires it with the new background
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent, // Or Colors.white if extendBodyBehindAppBar is false
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.black87),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: Text(
        "GEMS", // Consider making this a constant or configurable
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.black87),
          // Ensure "/notifications" is a defined route
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
      // This state could occur if user data fails to load critically
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
                  _initializeHomepage(); // Retry initialization
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
        // The background image
        Positioned.fill(child: _backgroundImage),
        // The main content
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
              Expanded(child: _buildFeatureList(context)), // Changed from _buildList
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(User user) {
    // Extracting username display logic for clarity
    String displayName = user.username.split('@').first;
    // Capitalize the first letter of the display name
    if (displayName.isNotEmpty) {
      displayName = displayName[0].toUpperCase() + displayName.substring(1);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), // Increased vertical padding
      child: Row(
        children: [
          _buildProfileImage(user),
          const SizedBox(width: 16),
          Expanded( // Use Expanded to prevent overflow if name is too long
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
                  overflow: TextOverflow.ellipsis, // Handle long names
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
        imageUrl = "https:$imageUrl"; // Assuming HTTPS if no scheme
      }
      // Basic validation for URL format (can be more robust)
      if (Uri.tryParse(imageUrl)?.hasAbsolutePath ?? false) {
         hasValidUrl = true;
      } else {
        imageUrl = null; // Invalid URL, fallback to initials
      }
    }


    return Container(
      width: 52, // Slightly larger
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade700], // Adjusted gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [ // Adding a subtle shadow for depth
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ]
      ),
      child: CircleAvatar(
        radius: 26, // Should match container size
        backgroundColor: Colors.transparent, // Transparent to show gradient
        backgroundImage: hasValidUrl
            ? NetworkImage(imageUrl!)
            : AssetImage('assets/profile_plain.png') as ImageProvider, // Fallback asset
        onBackgroundImageError: hasValidUrl ? (dynamic exception, StackTrace? stackTrace) {
          // Log error or handle
          debugPrint("Error loading profile image: $exception");
          // Optionally update UI to show initials if image fails
        } : null,
        child: (!hasValidUrl || (imageUrl == null) ) // Show initials if no valid URL or if asset is primary
            ? _buildInitialsAvatar(user) // Fallback to initials if URL is invalid or empty
            : null, // If NetworkImage is supposed to load, don't show initials on top
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
        style: GoogleFonts.poppins( // Using Poppins for consistency
          color: Colors.white,
          fontSize: 22, // Adjusted size
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Using ListView by default as per your commented out GridView
  Widget _buildFeatureList(BuildContext context) {
    // Define features here or pass them if they become dynamic
    final features = <_FeatureUIData>[
      _FeatureUIData("Preventive Maintenance", Icons.build_circle_outlined, "/ppm"), // Using outlined icons
      _FeatureUIData("Work Order", Icons.assignment_outlined, "/workorder"),
      _FeatureUIData("StoreKeeper", Icons.inventory_2_outlined, routeDashboard, enabled: _isStorekeeperFeatureEnabled),
      _FeatureUIData("Utilities", Icons.folder_special_outlined, routeUtilities, enabled: _isUtilitiesFeatureEnabled),
      _FeatureUIData("Leaderboard", Icons.emoji_events_outlined, routeLeaderboard),
      _FeatureUIData("Attendance", Icons.event_available_outlined, null, onTap: _openAttendanceForm), // Specific handler
      _FeatureUIData("Suggestion", Icons.lightbulb_outline, null, onTap: _openSuggestionForm), // Specific handler
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20), // Adjusted padding
      itemCount: features.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12), // Increased spacing
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

  // Example of opening a specific form (if different URLs or logic)
  void _openAttendanceForm() async {
    // Assuming this is the correct URL for attendance
    _launchUrlHelper("https://forms.office.com/r/CYvjipHJ4S");
  }

  void _openSuggestionForm() async {
    // Assuming this is the correct URL for suggestions
    _launchUrlHelper("https://forms.office.com/r/ANOTHER_FORM_ID"); // Replace with actual URL
  }

  Future<void> _launchUrlHelper(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
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

  // Background image getter
  Widget get _backgroundImage => SizedBox(
        height: double.infinity,
        width: double.infinity,
        // Ensure you have 'assets/bg.jpg' in your pubspec.yaml and project
        child: Image.asset("assets/bg.jpg", fit: BoxFit.cover), // BoxFit.cover is often better
      );
}

// --- UI Data Model for Features ---
class _FeatureUIData {
  final String title;
  final IconData icon;
  final String? route; // Nullable if onTap is used
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
    final bool isEnabled = feature.enabled && onTap != null; // Enabled only if onTap action is present
    final Color tileColor = isEnabled ? (AppColors.primary ?? Colors.blue) : (AppColors.secondary ?? Colors.grey.shade400);
    final Color contentColor = isEnabled ? Colors.white : Colors.white70;

    return PressScaleWidget( // Your existing PressScaleWidget
      onTap: isEnabled ? onTap : null,
      child: Container(
        height: 65, // Slightly taller
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(12), // Softer radius
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
                  fontWeight: FontWeight.w500, // Slightly less bold for list items
                  color: contentColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isEnabled) // Show chevron only if enabled and tappable
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
  // static final _scaleTween = Tween<double>(begin: 1.0, end: 0.95); // Original had lowerBound 0.95
  // static final _duration = const Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95, // Scale down to 95%
      upperBound: 1.0,  // Scale up to 100%
      value: 1.0,       // Start at normal scale
    );
  }

  @override
  void dispose() {
    _animationController.dispose(); // IMPORTANT: Dispose the controller
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
  final BuildContext _buildContext; // Store context passed during construction
  final String _userId;
  late final Provider _signatureProvider; // Initialized in constructor

  Request(this._buildContext, this._userId) {
    // Initialize Provider here, ensuring context is available if needed by Provider's constructor
    // If Provider doesn't need context at construction, this is fine.
    // If it needs context for EACH call, it should be passed to methods like checkSignature.
    _signatureProvider = Provider(fetchURL: "/user_signature/", taskID: _userId)
      ..context = _buildContext; // Assign context if Provider implementation requires it this way
  }

  /// Checks if a user signature exists.
  /// Returns the file path or identifier if found, otherwise an empty string.
  Future<String> checkSignature() async {
    try {
      // If your Provider class needs context per call, you might need to re-assign or pass it
      // _signatureProvider.context = _buildContext; // If needed per call

      final dynamic result = await _signatureProvider.getJson(url: "/user_signature/");

      if (result == null || result is! Map || result['file'] == null) {
        return "";
      }
      final String filePath = result['file'] as String;
      if (filePath.isEmpty) {
        return "";
      }

      // Persist signature locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kUserSignature, filePath); // kUserSignature from reference.dart
      return filePath;
    } catch (e) {
      debugPrint("Error checking signature: $e");
      // Optionally show a non-critical error to the user via SnackBar if context is available
      // ScaffoldMessenger.of(_buildContext).showSnackBar(
      //   SnackBar(content: Text("Could not verify signature status.")),
      // );
      return ""; // Return empty on error to allow app flow, or rethrow if critical
    }
  }

  /// Prompts the user to set up their signature.
  void promptSignatureSetup(String userId) {
    // Ensure context is still valid and widget is mounted before showing dialog
    if (!_buildContext.mounted) return;

    showDialog(
      context: _buildContext,
      barrierDismissible: false, // User must interact
      builder: (_) => CustomDialog(
        // Assuming CustomDialog is designed for this
        rootPage: "/homepage", // Or null if no specific root page needed after dialog
        title: "Signature Required", // Added title for clarity
        description: "For security and verification, please set up your digital signature.",
        buttonText: "Set Up Signature",
        image: Image.asset("assets/icon_trans.png", height: 40), // Ensure asset exists
        okayTapped: () {
          // Pop the dialog first
          Navigator.of(_buildContext, rootNavigator: true).pop();
          // Then navigate to signature setup page
          Navigator.pushNamed(_buildContext, routeSignature, arguments: userId);
        },
        // Optional: Add a cancel button or alternative action if appropriate
      ),
    );
  }
}

// The _AnimatedFeatureTile widget was used for the GridView.
// If you decide to use GridView again, you can uncomment and adapt it.
// For ListView, the PressScaleWidget is applied directly to each list item.

/*
// Simple scale‑up animation for Grid Tiles (if you revert to GridView)
class _AnimatedFeatureTile extends StatelessWidget {
  final Widget child;
  const _AnimatedFeatureTile({required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      builder: (_, scale, childToBuild) => Transform.scale(scale: scale, child: childToBuild),
      child: child,
    );
  }
}

Widget _buildGrid(BuildContext context) {
    final features = <_FeatureUIData>[
      // ... define features ...
    ];

    final crossCount = MediaQuery.of(context).size.width > 600 ? 4 : 2;
    return GridView.count(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      crossAxisCount: crossCount,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.9, // Adjusted for potentially more content
      children: features
          .map((f) => _AnimatedFeatureTile(child: _buildFeatureGridTile(f))) // New method for grid tile
          .toList(),
    );
  }

Widget _buildFeatureGridTile(_FeatureUIData f) {
  // Similar to _FeatureListItem but styled for a grid
  // Ensure you have a PressScaleWidget wrapping this if desired
  return PressScaleWidget(
    onTap: f.enabled
        ? () async {
            if (f.onTap != null) {
              f.onTap!();
            } else if (f.route != null) {
              // Add a delay before navigating if needed for animation
              // await Future.delayed(const Duration(milliseconds: 100));
              Navigator.pushNamed(context, f.route!);
            }
          }
        : null,
    child: Material( // Material for ink splash effects if desired
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: f.enabled
              ? LinearGradient(
                  colors: [Colors.blue.shade300, Colors.blue.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [Colors.grey.shade400, Colors.grey.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero( // Optional: Hero animation for icon
              tag: 'tile-icon-${f.title}',
              child: Icon(f.icon, size: 32, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              f.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              maxLines: 2, // Allow for slightly longer titles
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ),
  );
}
*/

// Ensure your User model, Provider network utility, constants (AppColors, route names),
// and other imported widgets (BuildDrawer, ResetPassword, CustomDialog) are correctly defined
// and available in your project.
// Also, ensure 'assets/bg.jpg' and 'assets/profile_plain.png', 'assets/icon_trans.png'
// are included in your pubspec.yaml and project assets folder.


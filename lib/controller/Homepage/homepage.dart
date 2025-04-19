import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/constant.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/widget/dialog.dart';
import 'package:gfm_gems/model/user.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/view/drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

import 'resetPassword.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  bool _isStorekeeper = false;
  bool _isUtilities = false;
  User? _user;

  @override
  void initState() {
    super.initState();
    ToastContext().init(context);

    // Register FCM token
    _firebaseMessaging.getToken().then((token) {
      if (token != null) {
        Provider provider = Provider(fetchURL: "/api/m_ppm.php")..context = context;
        provider.post(url: "/api/m_ppm.php", body: {
          "action": "save_token",
          "token": token,
        });
      }
    });

    // Load user and roles
    User.getPrefUser.then((prefs) {
      final user = User.fromMap(prefs);
      setState(() => _user = user);

      for (final role in user.roles) {
        if (role.id == "1") {
          _isStorekeeper = _isUtilities = true;
        } else {
          if (role.id == "16") _isStorekeeper = true;
          if (role.id == "18") _isUtilities = true;
        }
      }
      setState(() {});

      // First‑time password reset & signature flow
      final req = Request(context, user.userID);
      if (user.isFirstTime == "Yes") {
        Navigator.pushNamed(context, ResetPassword.routeName,
          arguments: ResetArguments(user.username),
        ).then((_) {
          user.updateFirstTime("No");
          return req.check();
        }).then((sig) {
          if (sig.isEmpty) req.openSignature(user.userID);
        }).catchError((e) => print(e));
      } else {
        req.check().then((sig) {
          if (sig.isEmpty) req.openSignature(user.userID);
        }).catchError((e) => print(e));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: BuildDrawer(() => Navigator.pop(context), isHome: true),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, "/notifications"),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Enhanced background with parallax effect
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue.shade900,
                    Colors.blue.shade800,
                  ],
                ),
              ),
            ),
          ),
          
          // Floating elements
          Positioned(
            top: -50,
            right: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          
          Positioned(
            bottom: -100,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_user != null) _buildHeader(_user!),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "What would you like to do today?",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(child: _buildGrid(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(User user) {
    final initials = user.username.isNotEmpty
        ? user.username[0].toUpperCase()
        : "?";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Profile image with fallback
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
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                Text(
                  user.username.split('@').first,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(User user) {
  // If you have a profile image URL in your user model
    final imageUrl = user.imageUrl ?? '';
    
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.blue.shade300, Colors.blue.shade700],
        ),
      ),
      child: imageUrl.isNotEmpty
          ? ClipOval(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildInitialsAvatar(user),
              ),
            )
          : _buildInitialsAvatar(user),
    );
  }

  Widget _buildInitialsAvatar(User user) {
    final initials = user.username.isNotEmpty
        ? user.username[0].toUpperCase()
        : "?";
    
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final features = <_Feature>[
      _Feature(
        title: "Preventive Maintenance",
        icon: Icons.build,
        color: Colors.cyan,
        route: "/ppm",
        enabled: true,
      ),
      _Feature(
        title: "Work Order",
        icon: Icons.assignment,
        color: Colors.cyan,
        route: "/workorder",
        enabled: true,
      ),
      _Feature(
        title: "StoreKeeper",
        icon: Icons.inventory,
        color: Colors.orange,
        route: routeDashboard,
        enabled: _isStorekeeper,
      ),
      _Feature(
        title: "Utilities",
        icon: Icons.folder,
        color: Colors.green,
        route: routeUtilities,
        enabled: _isUtilities,
      ),
      _Feature(
        title: "Leaderboard",
        icon: Icons.bar_chart,
        color: Colors.black,
        route: routeLeaderboard,
        enabled: true,
      ),
      _Feature(
        title: "Attendance",
        icon: Icons.calendar_today,
        color: Colors.black,
        route: routeAttendance,
        enabled: true,
        onTap: _openForm,
      ),
      _Feature(
        title: "Suggestion",
        icon: Icons.feedback,
        color: Color(0xFF99C24C),
        route: null,
        enabled: true,
        onTap: _openForm,
      ),
    ];

    final crossCount = MediaQuery.of(context).size.width > 600 ? 4 : 2;

    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (notification) {
        notification.disallowIndicator();
        return true;
      },
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: features.length,
        itemBuilder: (ctx, i) {
          final f = features[i];
          return _AnimatedFeatureTile(
            child: _buildFeatureTile(f),
          );
        },
      ),
    );
  }

  Widget _buildFeatureTile(_Feature f) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: f.enabled
            ? () {
                if (f.onTap != null) f.onTap!();
                else if (f.route != null) Navigator.pushNamed(context, f.route!);
              }
            : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 5),
              )
            ],
            // Glassmorphism effect
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.25),
                Colors.white.withOpacity(0.15),
              ],
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            f.color,
                            Color.lerp(f.color, Colors.black, 0.2)!,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          )
                        ],
                      ),
                      child: Icon(f.icon, size: 28, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      f.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: f.enabled ? Colors.white : Colors.white.withOpacity(0.6),
                      ),
                    ),
                    if (!f.enabled)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          "Coming soon",
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openForm() async {
    final url = Uri.parse("https://forms.office.com/r/CYvjipHJ4S");
    if (!await launchUrl(url)) throw 'Could not launch $url';
  }
}

/// Small helper class to describe each tile
class _Feature {
  final String title;
  final IconData icon;
  final Color color;
  final String? route;
  final bool enabled;
  final VoidCallback? onTap;

  _Feature({
    required this.title,
    required this.icon,
    required this.color,
    this.route,
    this.enabled = true,
    this.onTap,
  });
}

/// A simple scale‑up animation for each tile
class _AnimatedFeatureTile extends StatelessWidget {
  final Widget child;
  const _AnimatedFeatureTile({required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      builder: (_, scale, __) => Transform.scale(scale: scale, child: child),
      child: child,
    );
  }
}

/// Handles your signature check & opening dialog
class Request {
  final Provider _checkSignature;
  final BuildContext _context;

  Request(this._context, String id)
      : _checkSignature = Provider(fetchURL: "/user_signature/", taskID: id);

  Future<String> check() async {
    _checkSignature.context = _context;
    final result = await _checkSignature.getJson(url: "/user_signature/");
    if (result is List || result == null) return "";
    final file = result["file"];
    if (file == null || (file as String).isEmpty) return "";
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(kUserSignature, file);
    return "file";
  }

  void openSignature(String id) {
    showDialog(
      context: _context,
      builder: (_) => CustomDialog(
        rootPage: "/homepage",
        description: "You need to set an initial signature",
        buttonText: "Okay",
        image: Image.asset("assets/icon_trans.png", height: 40),
        okayTapped: () {
          Navigator.pushNamed(_context, routeSignature, arguments: id);
        },
      ),
    );
  }
}

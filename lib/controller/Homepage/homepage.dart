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
import 'package:gfm_gems/utils/reference.dart';

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
        Navigator.pushNamed(
          context,
          ResetPassword.routeName,
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
      backgroundColor: Colors.white,                          // ← white background
      drawer: BuildDrawer(() => Navigator.pop(context), isHome: true),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.black87),      // ← black menu icon
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
            icon: Icon(Icons.notifications, color: Colors.black87), // ← black notif icon
            onPressed: () => Navigator.pushNamed(context, "/notifications"),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // remove the blue gradient background
          // Positioned.fill(child: your old gradient), 
          background,
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_user != null) _buildHeader(_user!),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "What would you like to do today?",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,               // ← black text
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Expanded(child: _buildGrid(context)),
                Expanded(child: _buildList(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(User user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          _buildProfileImage(user),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome back,",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black54,                // ← softer black
                ),
              ),
              Text(
                user.username.split('@').first,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,               // ← darker black
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(User user) {
    var imageUrl = user.imageUrl ?? '';
    // if imageUrl does not start with "http", prepend it with "http:" or "https:"
    if (imageUrl.isNotEmpty && !imageUrl.startsWith("http")) {
      imageUrl = "https:$imageUrl";
    }
    debugPrint("Image URL: $imageUrl");
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
          ? CircleAvatar(
                    radius: 60,
                    backgroundImage: imageUrl.isEmpty
                      ? AssetImage('assets/profile_plain.png') as ImageProvider
                      : NetworkImage(imageUrl),
                  )
          : _buildInitialsAvatar(user),
    );
  }

  Widget _buildInitialsAvatar(User user) {
    final initials =
        user.username.isNotEmpty ? user.username[0].toUpperCase() : "?";
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
      _Feature("Preventive Maintenance", Icons.build, "/ppm"),
      _Feature("Work Order", Icons.assignment, "/workorder"),
      _Feature("StoreKeeper", Icons.inventory, routeDashboard, enabled: _isStorekeeper),
      _Feature("Utilities", Icons.folder, routeUtilities, enabled: _isUtilities),
      _Feature("Leaderboard", Icons.bar_chart, routeLeaderboard),
      _Feature("Attendance", Icons.calendar_today, routeAttendance, onTap: _openForm),
      _Feature("Suggestion", Icons.feedback, null, onTap: _openForm),
    ];

    final crossCount = MediaQuery.of(context).size.width > 600 ? 4 : 2;
    return GridView.count(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      crossAxisCount: crossCount,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.85,
      children: features
          .map((f) => _AnimatedFeatureTile(child: _buildFeatureTile(f)))
          .toList(),
    );
  }

  Widget _buildList(BuildContext context) {
    final features = <_Feature>[
      _Feature("Preventive Maintenance", Icons.build, "/ppm"),
      _Feature("Work Order", Icons.assignment, "/workorder"),
      _Feature("StoreKeeper", Icons.inventory, routeDashboard, enabled: _isStorekeeper),
      _Feature("Utilities", Icons.folder, routeUtilities, enabled: _isUtilities),
      _Feature("Leaderboard", Icons.bar_chart, routeLeaderboard),
      _Feature("Attendance", Icons.calendar_today, routeAttendance, onTap: _openForm),
      _Feature("Suggestion", Icons.feedback, null, onTap: _openForm),
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      itemCount: features.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) {
        final f = features[i];
        return SizedBox(
          height: 60, // small box height
          child: PressScaleWidget(
            onTap: f.enabled
                ? () {
                    if (f.onTap != null) f.onTap!();
                    else if (f.route != null) Navigator.pushNamed(context, f.route!);
                  }
                : null,
            child: Container(
              decoration: BoxDecoration(
                color: f.enabled ? AppColors.primary : AppColors.secondary,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(f.icon, color: f.enabled ? Colors.white : Colors.white60),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      f.title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right,
                      color: f.enabled ? Colors.white : Colors.white60),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureTile(_Feature f) {
    return PressScaleWidget(
      onTap: f.enabled
          ? () async {
              if (f.onTap != null) {
                f.onTap!();
              } else if (f.route != null) {
                // Add a delay before navigating
                await Future.delayed(const Duration(milliseconds: 300));
                Navigator.pushNamed(context, f.route!);
              }
            }
          : null,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: f.enabled ? LinearGradient(
              colors: [Colors.blue.shade300, Colors.blue.shade700],
            ) : LinearGradient(
              colors: [Colors.grey.shade400, Colors.grey.shade500],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'tile-icon-${f.title}',
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.transparent,
                  child: Icon(f.icon, size: 28, color: Colors.white),
                ),
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
              ),
            ],
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

// Simple scale‑up animation
class _AnimatedFeatureTile extends StatelessWidget {
  final Widget child;
  const _AnimatedFeatureTile({ Key? key, required this.child }) : super(key: key);

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

class PressScaleWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const PressScaleWidget({Key? key, required this.child, this.onTap})
      : super(key: key);

  @override
  _PressScaleWidgetState createState() => _PressScaleWidgetState();
}

class _PressScaleWidgetState extends State<PressScaleWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  void _down(TapDownDetails _) => _ctrl.reverse();
  void _up(TapUpDetails _) {
    _ctrl.forward();
    widget.onTap?.call();
  }

  void _cancel() => _ctrl.forward();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _down,
      onTapUp: _up,
      onTapCancel: _cancel,
      child: ScaleTransition(scale: _ctrl, child: widget.child),
    );
  }
}

// Feature model
class _Feature {
  final String title;
  final IconData icon;
  final String? route;
  final bool enabled;
  final VoidCallback? onTap;
  _Feature(this.title, this.icon, this.route,
      {this.enabled = true, this.onTap});
}

// Signature helper omitted for brevity...

// Signature helper
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

  Widget get background => Container(
    height: double.infinity,
    width: double.infinity,
    child: Image.asset("assets/bg.jpg", fit: BoxFit.fill),
  );
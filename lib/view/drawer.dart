import 'dart:async';
import 'package:flutter/material.dart';

import '../model/user.dart';
import 'debug_log_screen.dart';

class BuildDrawer extends StatelessWidget {
  final bool isHome;
  final Function backFunc;
  final String email = "operationalexcellence@globalfm.com.my";

  BuildDrawer(this.backFunc, {this.isHome = false, super.key});

  @override
  Widget build(BuildContext context) {
    // Grab the Navigator once here
    final nav = Navigator.of(context);

    return FutureBuilder<String?>(
      future: User.getPrefUser,
      builder: (ctx, snapshot) {
        final List<Widget> roleDrawer = [];
        final data = snapshot.data;
        User? currentUser;
        if (data != null) {
          currentUser = User.fromMap(data);
          roleDrawer.add(SizedBox(height: 35));
          roleDrawer.add(header);
          roleDrawer.add(getTile(currentUser.firstName, "username.png",
              userFlag: true, user: currentUser, onTap: () {
            nav.pop();
            nav.pushNamed("/profile");
          }));
          roleDrawer.add(SizedBox(height: 20));
        }

        roleDrawer.add(getTile("Profile", "profile_icon.png", onTap: () {
          nav.pop();
          nav.pushNamed("/profile");
        }));

        roleDrawer.addAll([
          if (!isHome)
            getTile("Home", "home_icon.png", onTap: () {
              nav.pop();
              Timer(const Duration(milliseconds: 300), () {
                nav.popUntil(ModalRoute.withName("/homepage"));
              });
            }),
          getTile("Track Monitoring", "sidemenu_trackmonitoring.png",
              onTap: () {
            nav.pop();
            nav.pushNamed("/monitoring");
          }),
          getTile("Debug Logs", "flash.png", onTap: () {
            nav.pop();
            nav.pushNamed(DebugLogScreen.routeName);
          }),
          Expanded(
            child: Container(
              alignment: Alignment.bottomLeft,
              child: Column(
                children: <Widget>[
                  Expanded(child: SizedBox()),
                  getTile("Support", "support_icon.png", onTap: () {
                    nav.pop();
                    nav.pushNamed("/support");
                  }),
                  getTile("Logout", "logout_icon.png", onTap: () async {
                    if (currentUser != null) {
                      await currentUser.removeUser();
                    }
                    nav.pop();
                    nav.pushReplacementNamed("/");
                  }),
                  SizedBox(height: 35),
                ],
              ),
            ),
          ),
        ]);

        return Drawer(
          child: Container(
            color: const Color(0xFF404040),
            child: Column(children: roleDrawer),
          ),
        );
      },
    );
  }

  Widget getTitle(String text, {bool bigger = false}) => Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: bigger ? 24.0 : null,
          fontWeight: bigger ? FontWeight.bold : FontWeight.normal,
        ),
      );

  Widget getIcon(String icon, {double size = 24.0}) => Image.asset(
        "assets/$icon",
        height: size,
      );

  Widget _buildUserLogo(User? user) {
    if (user != null && user.imageUrl.isNotEmpty) {
      return Container(
        height: 120.0,
        width: 120.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage("http:${user.imageUrl}"),
            fit: BoxFit.fitWidth,
          ),
        ),
      );
    }
    return Image.asset(
      'assets/profile_plain.png',
      height: 150,
    );
  }

  Widget getTile(String text, String icon,
          {bool userFlag = false,
          String subtitle = "",
          User? user,
          required VoidCallback onTap}) =>
      ListTile(
        title: getTitle(text, bigger: userFlag),
        leading: !userFlag
            ? getIcon(icon)
            : CircleAvatar(
                radius: 30.0,
                backgroundColor: const Color(0xFF778899),
                child: _buildUserLogo(user),
              ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 30.0),
        onTap: onTap,
      );

  Widget get header => Container(
        height: 100,
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: <Widget>[
            Image.asset("assets/Logo_menu.png", width: 120.0),
          ],
        ),
      );
}

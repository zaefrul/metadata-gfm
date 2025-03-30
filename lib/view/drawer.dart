import 'dart:async';

import 'package:flutter/material.dart';
import '../model/user.dart';

class BuildDrawer extends StatelessWidget {
  late User user; // This will be assigned in the FutureBuilder
  final bool isHome;
  final Function backFunc;
  final String email = "operationalexcellence@globalfm.com.my";

  BuildDrawer(this.backFunc, {this.isHome = false, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> tiles = [
      if (!isHome)
        getTile("Home", "home_icon.png", onTap: () {
          Navigator.pop(context);
          Timer(
              const Duration(milliseconds: 300),
              () => Navigator.popUntil(
                  context, ModalRoute.withName("/homepage")));
        }),
      getTile("Track Monitoring", "sidemenu_trackmonitoring.png", onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, "/monitoring");
      }),
      Expanded(
          child: Container(
        alignment: Alignment.bottomLeft,
        child: Column(
          children: <Widget>[
            Expanded(child: SizedBox()),
            getTile("Support", "support_icon.png", onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/support");
            }),
            getTile("Logout", "logout_icon.png", onTap: () async {
              await user.removeUser();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, "/");
            }),
            SizedBox(height: 35)
          ],
        ),
      ))
    ];

    return FutureBuilder(
        future: User.getPrefUser,
        builder: (context, snapshot) {
          final List<Widget> roleDrawer = [];
          if (snapshot.data != null) {
            user = User.fromMap(snapshot.data as String);
            roleDrawer.add(SizedBox(height: 35));
            roleDrawer.add(header);
            roleDrawer.add(getTile(user.firstName, "username.png",
                userFlag: true,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, "/profile");
                }));
            roleDrawer.add(SizedBox(height: 20));
          }
          roleDrawer.add(getTile("Profile", "profile_icon.png", onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, "/profile");
          }));
          roleDrawer.addAll(tiles);
          return Drawer(
            child: Container(
              color: const Color(0xFF404040),
              child: Column(children: roleDrawer),
            ),
          );
        });
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

  Widget get logo {
    if (user.imageUrl.isNotEmpty) {
      return Container(
        height: 120.0,
        width: 120.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage("http:" + user.imageUrl),
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
          {bool userFlag = false, String subtitle = "", required VoidCallback onTap}) =>
      ListTile(
        title: getTitle(text, bigger: userFlag),
        // Uncomment and modify the subtitle below if needed.
        // subtitle: userFlag
        //     ? Row(
        //         children: <Widget>[
        //           Icon(
        //             Icons.location_on,
        //             size: 16.0,
        //             color: Colors.white,
        //           ),
        //           SizedBox(width: 6),
        //           getTitle(subtitle)
        //         ],
        //       )
        //     : null,
        leading: !userFlag
            ? getIcon(icon)
            : CircleAvatar(
                radius: 30.0,
                backgroundColor: const Color(0xFF778899),
                child: logo,
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

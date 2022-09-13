import 'dart:async';

import 'package:flutter/material.dart';
import '../model/user.dart';

class BuildDrawer extends StatelessWidget {
  User user;
  final bool isHome;
  final Function backFunc;

  final String email = "operationalexcellence@globalfm.com.my";

  BuildDrawer(this.backFunc, {this.isHome = false});

  @override
  Widget build(BuildContext context) {
    List<Widget> tiles = [
      if (this.isHome == false)
        getTile("Home", "home_icon.png", onTap: () {
          Navigator.pop(context);
          Timer(
              Duration(milliseconds: 300),
              () => Navigator.popUntil(
                  context, ModalRoute.withName("/homepage")));
        }),
      getTile("Track Monitoring", "sidemenu_trackmonitoring.png", onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, "/monitoring");
      }),
      new Expanded(
          child: new Container(
        child: Column(
          children: <Widget>[
            new Expanded(child: new SizedBox()),
            getTile("Support", "support_icon.png", onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/support");
            }),
            getTile("Logout", "logout_icon.png", onTap: () async {
              await user.removeUser();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(
                context,
                "/",
              );
            }),
            new SizedBox(height: 35)
          ],
        ),
        alignment: Alignment.bottomLeft,
      ))
    ];

    return FutureBuilder(
        future: User.getPrefUser,
        builder: (context, snapshot) {
          List<Widget> roleDrawer = List<Widget>();

          if (snapshot.data != null) {
            user = User.fromMap(snapshot.data);
            roleDrawer.add(SizedBox(height: 35));
            roleDrawer.add(header);
            roleDrawer.add(getTile(user.firstName, "username.png", user: true,
                // subtitle: user.address.state,
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
            child: new Container(
              color: Color(0xFF404040),
              child: Column(children: roleDrawer),
            ),
          );
        });
  }

  Widget getTitle(String text, {bigger = false}) => new Text(text,
      style: TextStyle(
          color: Colors.white, fontSize: bigger == false ? null : 24));
  Widget getIcon(icon, {size = 24.0}) => new Image.asset(
        "assets/" + icon,
        height: size,
      );

  Widget get logo {
    if (user.imageUrl != null) if (user.imageUrl.length > 0)
      return Container(
        height: 120.0,
        width: 120.0,
        decoration: new BoxDecoration(
          image: DecorationImage(
            image: new NetworkImage("http:" + user.imageUrl),
            fit: BoxFit.fitWidth,
          ),
          shape: BoxShape.circle,
        ),
      );

    return new Image.asset(
      'assets/profile_plain.png',
      height: 150,
    );
  }

  Widget getTile(text, icon, {user = false, subtitle = "", Function onTap}) =>
      ListTile(
          title: getTitle(text, bigger: user == false ? user : true),
          // subtitle: user == false
          //     ? null
          //     : Row(
          //         children: <Widget>[
          //           Icon(
          //             Icons.location_on,
          //             size: 16.0,
          //             color: Colors.white,
          //           ),
          //           SizedBox(
          //             width: 6,
          //           ),
          //           getTitle(subtitle)
          //         ],
          //       ),
          leading: user == false
              ? getIcon(icon)
              : new CircleAvatar(
                  radius: 30.0,
                  backgroundColor: const Color(0xFF778899),
                  child: logo),
          contentPadding: EdgeInsets.symmetric(horizontal: 30.0),
          onTap: onTap);

  Widget get header => Container(
        height: 100,
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: new Row(
            children: <Widget>[
              new Image.asset("assets/Logo_menu.png", width: 120.0),
            ],
          ),
        ),
      );
}

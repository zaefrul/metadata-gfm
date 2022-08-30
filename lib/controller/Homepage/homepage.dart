import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/constant.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/widget/dialog.dart';
import 'package:gfm_gems/model/user.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../../view/bar.dart';
import '../../view/drawer.dart';
import 'resetPassword.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool isStorekeeper = false;
  bool isUtilities = false;

  @override
  void initState() {
    super.initState();

    _firebaseMessaging.getToken().then((token) {
      if (token != null) {
        var body = {"action": "save_token", "token": token};

        Provider provider = Provider();
        provider.context = context;
        provider.post(url: "/api/m_ppm.php", body: body);
      }
    });

    User.getPrefUser.then((value) {
      var user = User.fromMap(value);
      user.roles.forEach((element) {
        if (element.id == "1") {
          setState(() {
            isStorekeeper = true;
            isUtilities = true;
          });
        } else {
          if (element.id == "16") setState(() => isStorekeeper = true);
          if (element.id == "18") setState(() => isUtilities = true);
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    User.getPrefUser.then((value) {
      var user = User.fromMap(value);
      final Request _request = Request(context, user.userID);
      if (user.isFirstTime == "Yes") {
        Navigator.pushNamed(context, ResetPassword.routeName,
                arguments: ResetArguments(user.username))
            .then((_) {
          user.updateFirstTime("No");
          return Request(context, user.userID).check();
        }).then((value) {
          if (value.isEmpty) _request.openSignature(user.userID);
        }).catchError((err) => print(err));
      } else {
        Request(context, user.userID).check().then((value) {
          if (value.isEmpty) _request.openSignature(user.userID);
        }).catchError((err) => print(err));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        drawer: BuildDrawer(() => Navigator.pop(context), isHome: true),
        appBar: bar(_scaffoldKey, text: "GEMS"),
        body: Stack(
          children: <Widget>[
            background,
            new GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                padding: EdgeInsets.all(3.0),
                children: <Widget>[
                  gridView("Preventive Maintenance", Colors.cyanAccent,
                      icon: "workorder.png", route: "/ppm"),
                  gridView("Work Order", Colors.cyanAccent,
                      icon: "work_order.png", route: "/workorder"),
                  gridView("StoreKeeper", Colors.yellowAccent,
                      icon: "facilitycondition.png", onTap: () async {
                    final user = User.fromMap(await User.getPrefUser);
                    final _role = user.roles.map((role) => role.desc).toList();
                    if (_role.contains("Storekeeper") ||
                        _role.contains("Administrator"))
                      Navigator.pushNamed(context, routeDashboard);
                    else
                      Toast.show("You have no access rights");
                  }, notAllowed: isStorekeeper),
                  gridView(
                    "Utilities", Colors.greenAccent, icon: "bpm.png",
                    //     onTap: () async {
                    //   final user = User.fromMap(await User.getPrefUser);
                    //   final _role = user.roles.map((role) => role.desc).toList();
                    //   if (_role.contains("Administrator"))
                    //     UtilsBill().selectType(context);
                    //   else
                    //     Toast.show("You have no access rights", context);
                    // },
                    route: routeUtilities,
                    notAllowed: isUtilities,
                  ),
                  gridView(
                    "Leaderboard",
                    Colors.black,
                    image: Padding(
                      padding: EdgeInsets.all(8),
                      child: Image.asset(
                        "assets/Complete.png",
                        color: Colors.white,
                      ),
                    ),
                    onTap: () {},
                    route: routeLeaderboard,
                    // notAllowed: isUtilities,
                  ),
                  gridView(
                    "Attendance",
                    Colors.black,
                    image: Padding(
                      padding: EdgeInsets.all(8),
                      child: Image.asset(
                        "assets/attandance.png",
                        color: Colors.white,
                      ),
                    ),
                    onTap: () {},
                    route: routeAttendance,
                    // notAllowed: isUtilities,
                  ),
                ]),
          ],
        ));
  }

  Widget gridView(text, color,
          {String icon,
          Widget image,
          String route,
          Function onTap,
          bool notAllowed = true}) =>
      new GestureDetector(
          onTap: () => notAllowed == false
              ? Toast.show("No Access Rights", duration: 3)
              : route == null
                  ? onTap()
                  : Navigator.pushNamed(context, route),
          child: Container(
              padding: EdgeInsets.all(10.0),
              alignment: Alignment.bottomCenter,
              color: Colors.transparent,
              child: new Column(
                children: <Widget>[
                  new Container(
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: color,
                    ),
                    child: icon == null
                        ? image
                        : Image.asset("assets/$icon", fit: BoxFit.fitHeight),
                  ),
                  SizedBox(height: 20),
                  Align(
                      alignment: Alignment.center,
                      child: Text(
                        text,
                        textAlign: TextAlign.center,
                      )),
                ],
              )));

  get background => new Container(
        height: double.infinity,
        width: double.infinity,
        child: Image.asset("assets/bg.jpg", fit: BoxFit.fill),
      );
}

class Request {
  final Provider _checkSignature;
  final BuildContext _context;

  Request(this._context, String id)
      : this._checkSignature = Provider(
          fetchURL: "/user_signature/",
          taskID: id,
        );

  Future<String> check() async {
    _checkSignature.context = _context;
    try {
      final result = await _checkSignature.getJson();
      if (result is List) return "";
      if (result == null) return "";
      final file = result["file"];
      if (file.isEmpty) {
        return "";
      } else {
        final pref = await SharedPreferences.getInstance();
        pref.setString(kUserSignature, file);
      }

      return "file";
    } catch (err) {
      throw (err);
    }
  }

  void openSignature(String id) {
    showDialog(
        context: _context,
        builder: (_) {
          return CustomDialog(
              rootPage: "/homepage",
              description: "You need set initial signature",
              buttonText: "Okay",
              image: Image.asset("assets/icon_trans.png", height: 40),
              okayTapped: () {
                return Navigator.pushNamed(
                  _context,
                  routeSignature,
                  arguments: id,
                );
              });
        });
  }
}

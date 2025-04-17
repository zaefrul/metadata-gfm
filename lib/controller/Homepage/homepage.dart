import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/constant.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/widget/dialog.dart';
import 'package:gfm_gems/model/user.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../view/bar.dart';
import '../../view/drawer.dart';
import 'resetPassword.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool isStorekeeper = false;
  bool isUtilities = false;

  final String email = "operationalexcellence@globalfm.com.my";

  @override
  void initState() {
    super.initState();

    _firebaseMessaging.getToken().then((token) {
      if (token != null) {
        print(token);
        var body = {"action": "save_token", "token": token};

        Provider provider = Provider(fetchURL: "/api/m_ppm.php");
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
    ToastContext().init(context);
    return Scaffold(
      key: _scaffoldKey,
      drawer: BuildDrawer(() => Navigator.pop(context), isHome: true),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: bar(_scaffoldKey, text: "GEMS"),
      ),
      body: Stack(
        children: <Widget>[
          background,
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            padding: EdgeInsets.all(3.0),
            children: <Widget>[
              gridView("Preventive Maintenance", Colors.cyanAccent,
                  icon: "workorder.png", route: "/ppm"),
              // gridView("Routine Inspection", Colors.cyanAccent,
              //     icon: "workorder.png", route: routeRoutineInspection),
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
              gridView("Utilities", Colors.greenAccent,
                  icon: "bpm.png",
                  route: routeUtilities,
                  notAllowed: isUtilities),
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
                onTap: openEmail,
                route: routeAttendance,
              ),
              gridView(
                "Suggestion",
                Color(0xFF99C24C),
                image: Padding(
                  padding: EdgeInsets.all(8),
                  child: Image.asset(
                    "assets/feedback.png",
                  ),
                ),
                onTap: openEmail,
                route: null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget gridView(dynamic text, dynamic color,
          {String? icon,
          Widget? image,
          String? route,
          Function()? onTap,
          bool notAllowed = true}) =>
      GestureDetector(
        onTap: () {
          if (!notAllowed) {
            Toast.show("No Access Rights", duration: 3);
          } else {
            if (route == null) {
              onTap?.call();
            } else {
              Navigator.pushNamed(context, route);
            }
          }
        },
        child: Container(
          padding: EdgeInsets.all(10.0),
          alignment: Alignment.bottomCenter,
          color: Colors.transparent,
          child: Column(
            children: <Widget>[
              Container(
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
          ),
        ),
      );

  Widget get background => Container(
        height: double.infinity,
        width: double.infinity,
        child: Image.asset("assets/bg.jpg", fit: BoxFit.fill),
      );

  void openEmail() async {
    final url = Uri.parse("https://forms.office.com/r/CYvjipHJ4S");
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }
}

class Request {
  final Provider _checkSignature;
  final BuildContext _context;

  Request(this._context, String id)
      : _checkSignature = Provider(
          fetchURL: "/user_signature/",
          taskID: id,
        );

  Future<String> check() async {
    _checkSignature.context = _context;
    try {
      final result = await _checkSignature.getJson(url: "/user_signature/");
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
                Navigator.pushNamed(
                  _context,
                  routeSignature,
                  arguments: id,
                );
              });
        });
  }
}

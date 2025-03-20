import 'package:flutter/material.dart';

import '../../view/bar.dart';
import '../../view/drawer.dart';
import '../../utils/reference.dart';
import '../../model/user.dart';

import '../PPM/Form/openImage.dart';
import 'changePassword.dart';
import 'editProfile.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String _name = "";
  List<String> _role;
  String _contact = "";
  String _email = "";
  String _imageSrc = "";

  User user;

  _ProfileState() {
    fetch;
  }

  get fetch {
    User.getPrefUser.then((value) {
      user = User.fromMap(value);
      setState(() {
        _name = user.firstName;
        _role = user.roles.map((role) => role.desc).toList();
        _contact = user.contactNo;
        _email = user.email;
        _imageSrc = user.imageUrl;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      appBar: bar(_scaffoldKey, text: "Profile", navigateTo: menu),
      drawer: BuildDrawer(() => Navigator.pop(context)),
      body: new Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SingleChildScrollView(
            child: new Column(
              children: <Widget>[
                // SizedBox(height: 60),
                // title,
                SizedBox(height: 80),
                logo,
                SizedBox(height: 50),
                fields,
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget titletext(text, bold) => new Text(
        text,
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            color: colorTheme3,
            fontFamily: 'Avenir',
            fontSize: 16,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal),
      );

  get title => new Column(children: <Widget>[
        titletext("You have been successfully signed in.", true),
        titletext(
            "Please upload or take a picture of you activate your profile",
            false)
      ]);

  get background => new Container(
        width: double.infinity,
        height: double.infinity,
        child: Image.asset(
          "assets/bg.jpg",
          fit: BoxFit.fitWidth,
        ),
      );

  Widget get logo {
    if (_imageSrc.length > 0)
    return GestureDetector(
      child: Container(
        height: 120.0,
        width: 120.0,
        decoration: new BoxDecoration(
          image: DecorationImage(
            image: new NetworkImage("http:" + _imageSrc),
            fit: BoxFit.fitWidth,
          ),
          shape: BoxShape.circle,
        ),
      ),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ImageViewer(url: "http:" + _imageSrc)));
      },
    );

    return new Image.asset(
      'assets/profile_plain.png',
      height: 150,
    );
  }

  get fields => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Divider(color: colorTheme3, height: 1),
          field("Name : ", trailing: _name),
          Divider(color: colorTheme3, height: 1),
          field("Role : ", trailings: _role),
          Divider(
            color: colorTheme3,
            height: 1,
          ),
          field("Contact No : ", trailing: _contact),
          Divider(color: colorTheme3, height: 1),
          field("Email : ", trailing: _email),
          Divider(color: colorTheme3, height: 1),
        ],
      );

  Widget field(String leading, {String trailing = "", List<String> trailings}) {
    int lines = trailings == null ? 1 : trailings.length;
    double height = 30.0 + (lines * 20.0);

    List<Widget> children = [
      titletext(leading, true),
      lines == 1
          ? titletext(trailing.length == 0 ? trailings[0] : trailing, false)
          : new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: trailings
                  .map((String text) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: titletext(" - " + text, false),
                      ))
                  .toList())
    ];

    return new Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 12),
      // height: height,
      child: new Row(
        children: children,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }

  // TextField field(String frontText,TextEditingController controller) => new TextField(
  //   controller: controller,
  //   enabled: false,
  //   style: new TextStyle(fontFamily: 'Avenir'),
  //   decoration: InputDecoration(
  //     border: InputBorder.none,
  //     prefixIcon: new Container(
  //       width: 150,
  //       alignment: Alignment.centerLeft,
  //       child: titletext(frontText, true)
  //     ),
  //   ),
  // );

  PopupMenuButton get menu => PopupMenuButton(
        offset: Offset(0, 100),
        icon: Icon(
          Icons.more_vert,
          color: colorTheme3,
        ),
        itemBuilder: (context) => ["Edit Profile", "Change Password"]
            .map((String choice) => PopupMenuItem<String>(
                value: choice,
                child: ListTile(
                  contentPadding: EdgeInsets.all(0),
                  leading: choice == "Edit Profile"
                      ? Icon(Icons.edit)
                      : Icon(Icons.lock),
                  title: titletext(choice, false),
                )))
            .toList(),
        onSelected: (text) {
          if (text == "Edit Profile")
            Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Edit(user)))
                .then((_) => fetch);
          else if (text == "Change Password")
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Change()));
        },
      );
}

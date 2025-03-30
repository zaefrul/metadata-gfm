import 'package:flutter/material.dart';
import '../../view/bar.dart';
import '../../view/drawer.dart';
import '../../utils/reference.dart';
import '../../model/user.dart';
import '../PPM/Form/openImage.dart';
import 'changePassword.dart';
import 'editProfile.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _name = "";
  List<String> _role = [];
  String _contact = "";
  String _email = "";
  String _imageSrc = "";

  late User user;

  _ProfileState() {
    fetch;
  }

  // fetch the user profile details.
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
      appBar: AppBar(
        title: const Text("Profile"),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          menu,
        ],
      ),
      drawer: BuildDrawer(() => Navigator.pop(context)),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 80),
                logo,
                const SizedBox(height: 50),
                fields,
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget titletext(String text, bool bold) => Text(
        text,
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: colorTheme3,
          fontFamily: 'Avenir',
          fontSize: 16,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      );

  Widget get title => Column(
        children: <Widget>[
          titletext("You have been successfully signed in.", true),
          titletext("Please upload or take a picture of you activate your profile", false),
        ],
      );

  Widget get background => Container(
        width: double.infinity,
        height: double.infinity,
        child: Image.asset(
          "assets/bg.jpg",
          fit: BoxFit.fitWidth,
        ),
      );

  Widget get logo {
    if (_imageSrc.isNotEmpty) {
      return GestureDetector(
        child: Container(
          height: 120.0,
          width: 120.0,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage("http:" + _imageSrc),
              fit: BoxFit.fitWidth,
            ),
            shape: BoxShape.circle,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageViewer(url: "http:" + _imageSrc),
            ),
          );
        },
      );
    }
    return Image.asset(
      'assets/profile_plain.png',
      height: 150,
    );
  }

  Widget get fields => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Divider(color: colorTheme3, height: 1),
          field("Name : ", trailing: _name),
          Divider(color: colorTheme3, height: 1),
          field("Role : ", trailings: _role),
          Divider(color: colorTheme3, height: 1),
          field("Contact No : ", trailing: _contact),
          Divider(color: colorTheme3, height: 1),
          field("Email : ", trailing: _email),
          Divider(color: colorTheme3, height: 1),
        ],
      );

  Widget field(String leading, {String trailing = "", List<String>? trailings}) {
  bool hasTrails = trailings != null && trailings.isNotEmpty;
  int lines = hasTrails ? trailings!.length : 1;
  List<Widget> children = [
    titletext(leading, true),
    // If there is only one line, use trailing if not empty; otherwise, if trailings exist, use its first element.
    lines == 1
        ? titletext(trailing.isEmpty ? (hasTrails ? trailings![0] : "") : trailing, false)
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: trailings!
                .map((String text) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: titletext(" - " + text, false),
                    ))
                .toList(),
          ),
  ];

  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 12),
    child: Row(
      children: children,
      crossAxisAlignment: CrossAxisAlignment.start,
    ),
  );
}

  PopupMenuButton get menu => PopupMenuButton(
        offset: const Offset(0, 100),
        icon: Icon(
          Icons.more_vert,
          color: colorTheme3,
        ),
        itemBuilder: (context) => ["Edit Profile", "Change Password"]
            .map(
              (String choice) => PopupMenuItem<String>(
                value: choice,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: choice == "Edit Profile" ? const Icon(Icons.edit) : const Icon(Icons.lock),
                  title: titletext(choice, false),
                ),
              ),
            )
            .toList(),
        onSelected: (text) {
          if (text == "Edit Profile") {
            Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Edit(user)))
                .then((_) => fetch);
          } else if (text == "Change Password") {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Change()));
          }
        },
      );
}

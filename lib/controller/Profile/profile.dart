// lib/controller/Profile/profile.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../view/bar.dart';
import '../../view/drawer.dart';
import '../../utils/reference.dart';
import '../../model/user.dart';
import '../PPM/Form/openImage.dart';
import 'editProfile.dart';
import 'changePassword.dart';
import '../Homepage/homepage.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

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
    _loadProfile();
  }

  void _loadProfile() {
    User.getPrefUser.then((prefs) {
      user = User.fromMap(prefs);
      setState(() {
        _name     = user.firstName;
        _role     = user.roles.map((r) => r.desc).toList();
        _contact  = user.contactNo;
        _email    = user.email;
        _imageSrc = user.imageUrl;
      });
    });
  }

  Widget _buildRow(IconData icon, String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: colorTheme2),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        subtitle: Text(value, style: GoogleFonts.poppins()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: bar(
        _scaffoldKey,
        text: "Profile",
        search: false,
      ) as PreferredSizeWidget?,
      drawer: BuildDrawer(() => Navigator.pop(context)),

      body: Stack(
        children: [
          background,
          ListView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            children: [
              // — Avatar —
              Center(
                child: GestureDetector(
                  onTap: _imageSrc.isEmpty ? null : () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ImageViewer(url: "http:$_imageSrc"),
                    ));
                  },
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _imageSrc.isEmpty
                      ? AssetImage('assets/profile_plain.png') as ImageProvider
                      : NetworkImage("http:$_imageSrc"),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // — Edit / Change buttons —
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(Icons.edit, color: Colors.white),
                      label: Text("Edit Profile", style: GoogleFonts.poppins(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => Edit(user)),
                      ).then((_) => _loadProfile()),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon: Icon(Icons.lock, color: Colors.white),
                      label: Text("Change Password", style: GoogleFonts.poppins(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => Change()),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // — Profile fields —
              _buildRow(Icons.person,       "Name",         _name),
              _buildRow(Icons.work,         "Roles",        _role.join(", ")),
              _buildRow(Icons.phone,        "Contact No.",  _contact),
              _buildRow(Icons.email,        "Email",        _email),
            ],
          ),
        ],
      )
    );
  }
}

Widget get background => SizedBox(
  height: double.infinity,
  width: double.infinity,
  child: Image.asset("assets/bg.jpg", fit: BoxFit.fill),
);
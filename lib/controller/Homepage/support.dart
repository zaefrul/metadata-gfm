import 'package:flutter/material.dart';
import 'package:GEMS/controller/Storekeeper/utils/constant.dart';
import 'package:GEMS/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/network.dart';

class Support extends StatelessWidget {
  final String title = "Support";
  final String address1 = "A-3A-1, Melawati Corporate Centre";
  final String address2 = "Jalan Bandar Melawati,";
  final String address3 = "Taman Melawati,";
  final String address4 = "53100 Kuala Lumpur, Malaysia";
  final String phone = "+603-4101-0555";
  final String email = "operationalexcellence@globalfm.com.my";

  const Support({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Support"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              getTitle("GFM Services Berhad 1033141-H"),
              ListTile(
                leading: locIcon,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(address1),
                    Text(address2),
                    Text(address3),
                    Text(address4),
                  ],
                ),
              ),
              ListTile(
                leading: phoneIcon,
                title: Text(
                  phone,
                  style: TextStyle(color: colorTheme2),
                ),
                onTap: () => openPhone(),
              ),
              ListTile(
                leading: mailIcon,
                title: Text(
                  email,
                  style: TextStyle(color: colorTheme2),
                ),
                onTap: () => openEmail(),
              ),
              getTitle("User Manual"),
              ListTile(
                title: Text("1. PPM - Executor"),
                trailing: pdfIcon,
                onTap: () => openExecutor(),
              ),
              ListTile(
                title: Text("2. PPM - Reviewer"),
                trailing: pdfIcon,
                onTap: () => openReviewer(),
              ),
              ListTile(
                title: Text("3. PPM - Verifier"),
                trailing: pdfIcon,
                onTap: () => openVerifier(),
              ),
              ListTile(
                title: Text("4. WO - Assigner"),
                trailing: pdfIcon,
                onTap: () => openVerifier(),
              ),
              ListTile(
                title: Text("5. WO - Complainer"),
                trailing: pdfIcon,
                onTap: () => openReviewer(),
              ),
              ListTile(
                title: Text("6. WO - Executor"),
                trailing: pdfIcon,
                onTap: () => openExecutor(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getTitle(String text) => Container(
        padding: EdgeInsets.all(12.0),
        child: Text(
          text,
          style: TextStyle(
              fontSize: 18.0, color: colorTheme3, fontWeight: FontWeight.bold),
        ),
      );

  Widget get pdfIcon => Icon(
        Icons.picture_as_pdf,
        color: colorTheme2,
      );
  Widget get locIcon => Icon(
        Icons.location_on,
        color: colorTheme2,
      );
  Widget get phoneIcon => Icon(
        Icons.call,
        color: colorTheme2,
      );
  Widget get mailIcon => Icon(
        Icons.mail,
        color: colorTheme2,
      );

  Future<void> openPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '60341010555');
    if (!await launchUrl(phoneUri)) {
      throw 'Could not launch $phoneUri';
    }
  }

  Future<void> openEmail() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    final String? userJson = pref.getString(kUserPrefs);
    if (userJson == null) return;
    final value = User.fromMap(userJson);
    final String url =
        "mailto:$email?subject=Mobile App Support (From : ${value.username})&body=Complainer:${value.email}\nName:${value.firstName} ${value.lastName} \nPhone Number : ${value.contactNo} \nYour Complaint: ";
    final Uri emailUri = Uri.parse(url);
    if (!await launchUrl(emailUri)) {
      throw 'Could not launch $emailUri';
    }
  }

  Future<void> openExecutor() async {
    final Uri uri = Uri.parse("$netDomain/api/pdf/user_manual_executor.pdf");
    if (!await launchUrl(uri)) {
      throw 'Could not launch $uri';
    }
  }

  Future<void> openReviewer() async {
    final Uri uri = Uri.parse("$netDomain/api/pdf/user_manual_reviewer.pdf");
    if (!await launchUrl(uri)) {
      throw 'Could not launch $uri';
    }
  }

  Future<void> openVerifier() async {
    final Uri uri = Uri.parse("$netDomain/api/pdf/user_manual_verifier.pdf");
    if (!await launchUrl(uri)) {
      throw 'Could not launch $uri';
    }
  }

  Future<void> openWOExecutor() async {
    final Uri uri = Uri.parse("$netDomain/api/pdf/user_manual_wo_executor.pdf");
    if (!await launchUrl(uri)) {
      throw 'Could not launch $uri';
    }
  }

  Future<void> openWOReviewer() async {
    final Uri uri =
        Uri.parse("$netDomain/api/pdf/user_manual_wo_complainer.pdf");
    if (!await launchUrl(uri)) {
      throw 'Could not launch $uri';
    }
  }

  Future<void> openWOVerifier() async {
    final Uri uri =
        Uri.parse("$netDomain/api/pdf/user_manual_wo_assigner.pdf");
    if (!await launchUrl(uri)) {
      throw 'Could not launch $uri';
    }
  }
}

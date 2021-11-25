import 'package:flutter/material.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/network.dart';

class Support extends StatelessWidget {
  final String title = "Support";
  final String address1 = "A-3A-1, Melawati Corporate Centre";
  final String address2 = "Jalan Bandar Melawati,";
  final String address3 = "Taman Melawati,";
  final String address4 = "53100 Kuala Lumpur, Malaysia";
  final String phone = "+603-4101-0555";
  final String email = "ict-support@globalfm.com.my";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("Support"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Container(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            getTitle("GFM Services Berhad 1033141-H"),
            ListTile(
              leading: locIcon,
              title: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new Text(address1),
                  new Text(address2),
                  new Text(address3),
                  new Text(address4),
                ],
              ),
            ),
            ListTile(
              leading: phoneIcon,
              title: new Text(
                phone,
                style: TextStyle(color: colorTheme2),
              ),
              onTap: () => openPhone(),
            ),
            ListTile(
              leading: mailIcon,
              title: new Text(email),
            ),
            getTitle("User Manual"),
            ListTile(
              title: new Text("1. PPM - Executor"),
              trailing: pdfIcon,
              onTap: () => openExecutor(),
            ),
            ListTile(
                title: new Text("2. PPM - Reviewer"),
                trailing: pdfIcon,
                onTap: () => openReviewer()),
            ListTile(
                title: new Text("3. PPM - Verifier"),
                trailing: pdfIcon,
                onTap: () => openVerifier()),
            ListTile(
              title: new Text("4. WO - Assigner"),
              trailing: pdfIcon,
              onTap: () => openVerifier(),
            ),
            ListTile(
                title: new Text("5. WO - Complainer"),
                trailing: pdfIcon,
                onTap: () => openReviewer()),
            ListTile(
                title: new Text("6. WO - Executor"),
                trailing: pdfIcon,
                onTap: () => openExecutor())
          ],
        ),
      ),
    );
  }

  Widget getTitle(String text) => Container(
        padding: EdgeInsets.all(12.0),
        child: new Text(
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

  void openPhone() => launch("tel://60341010555");

  void openExecutor() => launch("$netDomain/api/pdf/user_manual_executor.pdf");

  void openReviewer() => launch("$netDomain/api/pdf/user_manual_reviewer.pdf");

  void openVerifier() => launch("$netDomain/api/pdf/user_manual_verifier.pdf");

  void openWOExecutor() =>
      launch("$netDomain/api/pdf/user_manual_wo_executor.pdf");

  void openWOReviewer() =>
      launch("$netDomain/api/pdf/user_manual_wo_complainer.pdf");

  void openWOVerifier() =>
      launch("$netDomain/api/pdf/user_manual_wo_assigner.pdf");
}

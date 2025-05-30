import 'package:flutter/material.dart';
import 'package:GEMS/model/responseValue.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/utils/reference.dart';

class FormB extends StatelessWidget {
  final String id;
  final Provider provider;

  FormB(this.id, {super.key})
      : provider = Provider(
            taskID: id,
            fetchURL: "/api/m_ppm.php?type=ppm_section_b&ppmTaskId=");

  @override
  Widget build(BuildContext context) {
    provider.context = context;
    return Scaffold(
      appBar: AppBar(
        title: getTitle("B. Safety Precaution / General Guideline",
            bold: true, size: 18.0),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: colorTheme3,
        ),
      ),
      body: FutureBuilder<ResponseValue>(
        future: provider.fetch(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(snapshot.data!.sectionBList?.ppmTaskGuideline ?? 'No guideline available'),
            );
          }
        },
      ),
    );
  }

  Widget getTitle(String text, {bool bold = false, double size = 16.0}) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: bold ? null : EdgeInsets.only(top: 12),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          color: colorTheme3,
          fontSize: size,
        ),
      ),
    );
  }
}

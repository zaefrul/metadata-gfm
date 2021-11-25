import 'package:flutter/material.dart';
import 'package:gfm_gems/model/responseValue.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';

class FormB extends StatelessWidget {
  final String id;
  final Provider provider;

  FormB(this.id)
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
        body: FutureBuilder(
            future: provider.fetch(),
            builder: (context, AsyncSnapshot<ResponseValue> snapshot) =>
                snapshot.data == null
                    ? new Center(child: CircularProgressIndicator())
                    : Padding(
                        padding: EdgeInsets.all(16.0),
                        child: new Text(
                            snapshot.data.sectionBList.ppmTaskGuideline),
                      )));
  }

  Widget getTitle(String text, {bold = false, size = 16.0}) => new Container(
        alignment: Alignment.centerLeft,
        padding: bold == true ? null : EdgeInsets.only(top: 12),
        child: new Text(text,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: colorTheme3,
            )),
      );
}

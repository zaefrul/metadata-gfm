import 'package:flutter/material.dart';
import 'package:GEMS/model/responseValue.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:GEMS/view/gems_chrome.dart';

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
      backgroundColor: GemsChrome.page,
      appBar: gemsAppBar(
        title: Text(
          'B. Safety Precaution / General Guideline',
          style: GemsChrome.heading(size: 16),
        ),
      ),
      body: FutureBuilder<ResponseValue>(
        future: provider.fetch(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: GemsFormSection(
                title: 'Guideline',
                icon: Icons.menu_book_outlined,
                child: Text(
                  snapshot.data!.sectionBList?.ppmTaskGuideline ?? 'No guideline available',
                  style: GemsChrome.body(size: 14),
                ),
              ),
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

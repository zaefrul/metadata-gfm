import 'package:flutter/material.dart';

// Shared Preferences
final String prefsLATITUDE = "latitude";
final String prefsLONGITUDE = "longitude";
const String kUsername = "USERNAME";

final String app_name = "GEMS";
final Color colorTheme1 = Color(0xff58c2c4);
final Color colorTheme2 = Color(0xff2367f6);
final Color colorTheme3 = Color(0xff022c41);
final Color colorTheme4 = Color(0xffd24129);
final Color colorTheme5 = Color(0xff1f7775);

abstract class Upload {
  final String action;
  final String ppmTaskId;

  Upload({this.action, this.ppmTaskId});

  @required
  Map<String, dynamic> get body {
    return {"action": action, "ppmTaskId": ppmTaskId};
  }
}

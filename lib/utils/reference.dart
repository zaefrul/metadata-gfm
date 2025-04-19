import 'package:flutter/material.dart';

// Shared Preferences
final String prefsLATITUDE = "latitude";
final String prefsLONGITUDE = "longitude";
const String kUsername = "USERNAME";

final String app_name = "GEMS";
final Color colorTheme1 = Color(0xff58c2c4);
final Color colorTheme1Light = Color.fromARGB(255, 147, 195, 196);
final Color colorTheme2 = Color(0xff2367f6);
final Color colorTheme2Light = Color.fromARGB(255, 202, 214, 247);
final Color colorTheme3 = Color(0xff022c41);
final Color colorTheme3Light = Color.fromARGB(255, 151, 191, 209);
final Color colorTheme4 = Color(0xffd24129);
final Color colorTheme4Light = Color.fromARGB(255, 255, 200, 192);
final Color colorTheme5 = Color(0xff1f7775);

abstract class Upload {
  final String action;
  final String ppmTaskId;

  Upload({required this.action, required this.ppmTaskId});

  Map<String, dynamic> get body {
    return {"action": action, "ppmTaskId": ppmTaskId};
  }
}

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:gfm_gems/model/complaint.dart';
import 'package:gfm_gems/model/complaintResponse.dart';
import 'package:gfm_gems/model/meter.dart';
import 'package:gfm_gems/model/responseValue.dart';
import 'package:gfm_gems/model/serializers.dart';
import 'package:gfm_gems/view/dialog.dart';

import '../model/user.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'dart:convert';

// final String netDomain = "http://gems2.metadatasyst.com";
final String netDomain = "https://gems.globalfm.com.my";
final String netLogin = "/api/m_login.php";
final String netLogout = "";

Future<User> login(username, password) async {
  var deviceId = await getDeviceDetails();

  var body = {
    "action": "login",
    "username": username,
    "password": password,
    "deviceId": deviceId
  };
  try {
    final response = await http.post(netDomain + netLogin,
        // headers: {"Content-Type": 'multipart/form-data'},
        headers: {
          HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
        },
        body: body);

    var result = json.decode(response.body);

    if (result["success"] == true) {
      var user = User.fromMap(response.body);
      user.responseJSON = response.body;

      return user;
    }

    return Future.error(result["errmsg"]);
  } catch (err) {
    print(err);
    return Future.error(err);
  }
}

Future<String> getDeviceDetails() async {
  String deviceVersion;

  final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
  try {
    if (Platform.isAndroid) {
      var build = await deviceInfoPlugin.androidInfo;
      deviceVersion = build.androidId;
    } else if (Platform.isIOS) {
      var data = await deviceInfoPlugin.iosInfo;
      deviceVersion = data.identifierForVendor;
    }
  } catch (_) {
    print('Failed to get platform version');
  }

  return deviceVersion;
}

class Provider {
  var item;

  final String taskID;
  final String fetchURL;
  BuildContext context;
  String deviceID;
  String token;

  Provider({this.fetchURL, this.taskID});

  Future init() async {
    deviceID = await getDeviceDetails();

    var pref = await User.getPrefUser;
    var user = User.fromMap(pref);

    token = "Bearer " + user.token;
  }

  Future<ResponseValue> fetch() async {
    await init();

    print(fetchURL);

    var response = await http.get(
      netDomain + fetchURL + (this.taskID == null ? "" : this.taskID),
      headers: {"Authorization": token, "Deviceid": deviceID},
    );

    if (response.statusCode == 200) {
      var body = response.body;
      var decode = json.decode(body);

      if (decode["error"] == "Signature verification failed" ||
          decode["error"] == "Device ID invalid with this login" ||
          decode["error"] == "Expired token") {
        alert("Your session already expired, please relogin.");
      }

      if (decode["result"].length > 0) {
        ResponseValue responseValue =
            serializers.deserializeWith(ResponseValue.serializer, decode);

        if (responseValue.success == true)
          return responseValue;
        else
          return Future.error(responseValue.errmsg);
      }
    }

    return Future.error("Please try again.");
  }

  Future<List> fetchComplaint(
      {String additionalParam,
      bool store = false,
      bool storePart = false,
      bool group = false,
      bool groupStore = false,
      bool type = false,
      bool storeType = false,
      bool part = false}) async {
    await init();

    print(fetchURL);
    print(additionalParam);

    var response = await http.get(
      netDomain +
          fetchURL +
          (this.taskID == null ? "" : this.taskID) +
          (additionalParam == null ? "" : additionalParam),
      headers: {"Authorization": token, "Deviceid": deviceID},
    );

    if (response.statusCode == 200) {
      var body = response.body;
      var decode = json.decode(body);

      if (decode["error"] == "Signature verification failed" ||
          decode["error"] == "Device ID invalid with this login" ||
          decode["error"] == "Expired token") {
        alert("Your session already expired, please relogin.");

        throw "Your session already expired, please relogin.";
      }

      if (decode["result"].length > 0) {
        if (group)
          return deserializeListOf<ComplaintDGroup>(decode["result"]).toList();
        else if (type)
          return deserializeListOf<ComplaintDType>(decode["result"]).toList();
        else if (part)
          return deserializeListOf<ComplaintDPart>(decode["result"]).toList();
        else if (store)
          return deserializeListOf<ComplaintDStore>(decode["result"]).toList();
        else if (groupStore)
          return deserializeListOf<ComplaintDGroupStore>(decode["result"])
              .toList();
        else if (storePart)
          return deserializeListOf<MaterialStorePart>(decode["result"])
              .toList();
        else if (storeType)
          return deserializeListOf<ComplaintDStoreType>(decode["result"])
              .toList();
        else {
          ComplaintResponse responseValue =
              serializers.deserializeWith(ComplaintResponse.serializer, decode);
          return responseValue.items.toList();
        }
      } else {
        return [];
      }
    }

    return Future.error("Please try again.");
  }

  Future<List> fetchUtilities({
    bool meter = false,
    bool reading = false,
    String id,
  }) async {
    await init();

    print(fetchURL);

    var response = await http.get(
      netDomain + fetchURL + (id == null ? "" : "/$id"),
      headers: {"Authorization": token, "Deviceid": deviceID},
    );

    if (response.statusCode == 200) {
      var body = response.body;
      var decode = json.decode(body);

      if (decode["error"] == "Signature verification failed" ||
          decode["error"] == "Device ID invalid with this login" ||
          decode["error"] == "Expired token") {
        alert("Your session already expired, please relogin.");

        throw "Your session already expired, please relogin.";
      }

      try {
        if (decode["result"].length > 0) {
          if (meter)
            return deserializeListOf<Meter>(decode["result"]).toList();
          else if (reading)
            return deserializeListOf<Reading>(decode["result"]).toList();
          return [];
        } else {
          return [];
        }
      } catch (e) {
        throw e;
      }
    }

    return Future.error("Please try again.");
  }

  Future<dynamic> getJson(
      {String url, dynamic body, bool includedHeader = true}) async {
    await init();

    print(fetchURL);

    var response = await http.get(
      netDomain + fetchURL + (this.taskID == null ? "" : this.taskID),
      headers: {"Authorization": token, "Deviceid": deviceID},
    );

    if (response.statusCode == 200) {
      var body = response.body;
      var decode = json.decode(body);
      if (decode["error"] == "Signature verification failed" ||
          decode["error"] == "Device ID invalid with this login" ||
          decode["error"] == "Expired token") {
        alert("Your session already expired, please relogin.");
      }

      if (decode['success'] == true) {
        return decode["result"];
      } else
        return Future.error(decode['errmsg']);
    }

    return Future.error("Please try again.");
  }

  Future<dynamic> post(
      {String url, dynamic body, bool includedHeader = true}) async {
    var action = "";
    if (body != null) if (body["action"] != null) action = body["action"];
    if (includedHeader == true) await init();

    final response = await http.post(netDomain + url,
        headers: includedHeader == true
            ? {
                HttpHeaders.contentTypeHeader:
                    'application/x-www-form-urlencoded',
                "authorization": token,
                "deviceid": deviceID
              }
            : {
                HttpHeaders.contentTypeHeader:
                    'application/x-www-form-urlencoded',
              },
        body: body);

    print(response);
    print(response.body);

    if (response.statusCode == 200) {
      var body = response.body;
      var decode = json.decode(body);
      if (decode["error"] == "Signature verification failed" ||
          decode["error"] == "Device ID invalid with this login" ||
          decode["error"] == "Expired token") {
        alert("Your session already expired, please relogin.");
      }

      ResponseValue responseValue = serializers.deserializeWith(
          ResponseValue.serializer, json.decode(response.body));

      if (responseValue.success == true) {
        if (action == "edit_profile")
          return responseValue;
        else
          return responseValue.errmsg;
      } else
        return Future.error(responseValue.errmsg);
    }

    return Future.error("Please try again.");
  }

  Future<dynamic> postUtilities({String url, dynamic body}) async {
    await init();

    final response = await http.post(netDomain + url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
          "authorization": token,
          "deviceid": deviceID,
        },
        body: body);

    print(response);
    print(response.body);

    if (response.statusCode == 200) {
      var body = response.body;
      var decode = json.decode(body);
      if (decode["error"] == "Signature verification failed" ||
          decode["error"] == "Device ID invalid with this login" ||
          decode["error"] == "Expired token") {
        alert("Your session already expired, please relogin.");
      }
      if (decode['success'] == true) {
        return true;
      } else
        return Future.error(decode['errmsg']);
    }

    return Future.error("Please try again.");
  }

  Future<dynamic> put(
      {dynamic body = const {}, bool includedHeader = true}) async {
    var action = "";
    if (body["action"] != null) action = body["action"];
    if (includedHeader == true) await init();

    final response = await http.put(
        netDomain + fetchURL + (this.taskID == null ? "" : this.taskID),
        headers: includedHeader == true
            ? {
                HttpHeaders.contentTypeHeader:
                    'application/x-www-form-urlencoded',
                "authorization": token,
                "deviceid": deviceID
              }
            : {
                HttpHeaders.contentTypeHeader:
                    'application/x-www-form-urlencoded',
              },
        body: body);

    print(response);
    print(response.body);

    if (response.statusCode == 200) {
      var body = response.body;
      var decode = json.decode(body);
      if (decode["error"] == "Signature verification failed" ||
          decode["error"] == "Device ID invalid with this login" ||
          decode["error"] == "Expired token") {
        alert("Your session already expired, please relogin.");
      }

      ResponseValue responseValue = serializers.deserializeWith(
          ResponseValue.serializer, json.decode(response.body));

      if (responseValue.success == true) {
        if (action == "edit_profile")
          return responseValue;
        else
          return responseValue.errmsg;
      } else
        return Future.error(responseValue.errmsg);
    }

    return Future.error("Please try again.");
  }

  Future<String> delete({String url}) async {
    await init();

    final response = await http.delete(netDomain + url, headers: {
      HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
      "Authorization": token,
      "Deviceid": deviceID
    });

    if (response.statusCode == 200) {
      ResponseValue responseValue = serializers.deserializeWith(
          ResponseValue.serializer, json.decode(response.body));

      if (responseValue.success == true)
        return responseValue.errmsg;
      else
        return Future.error(responseValue.errmsg);
    }

    return Future.error("Please try again.");
  }

  void alert(String txt) {
    showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
              title: "Expired Session",
              description: txt,
              buttonText: "Okay",
              image: Image.asset(
                "assets/icon_trans.png",
                height: 40,
              ),
            )).whenComplete(() async {
      var userPref = await User.getPrefUser;
      var user = User.fromMap(userPref);
      user.removeUser();
      Navigator.pop(context);
      Navigator.pushReplacementNamed(
        context,
        "/",
      );
    });
  }
}

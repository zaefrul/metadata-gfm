import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:GEMS/model/complaint.dart';
import 'package:GEMS/model/complaintResponse.dart';
import 'package:GEMS/model/meter.dart';
import 'package:GEMS/model/responseValue.dart';
import 'package:GEMS/model/serializers.dart';
import 'package:GEMS/view/dialog.dart';

import '../model/user.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'dart:convert';

import '../main.dart';

final String netDomain = "https://gems.metadatasystem.my";
// final String netDomain = "https://gfmgems.globalfm.com.my";
// final String netDomain = "http://localhost/gems2";
final String netLogin = "/api/m_login.php";
final String netLogout = "";

Future<User> login(String username, String password) async {
  var deviceId = await getDeviceDetails();

  var body = {
    "action": "login",
    "username": username,
    "password": password,
    "deviceId": deviceId
  };
  try {
    final response = await http.post(Uri.parse(netDomain + netLogin),
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
  String deviceVersion = "";
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  try {
    if (Platform.isAndroid) {
      var build = await deviceInfoPlugin.androidInfo;
      deviceVersion = build.id;
    } else if (Platform.isIOS) {
      var data = await deviceInfoPlugin.iosInfo;
      deviceVersion = data.identifierForVendor ?? "";
    }
  } catch (_) {
    print('Failed to get platform version');
  }
  return deviceVersion;
}

class Provider {
  dynamic item;

  final String? taskID;
  final String fetchURL;
  late BuildContext context;
  late String deviceID;
  late String token;
  static bool _sessionDialogVisible = false;

  Provider({required this.fetchURL, this.taskID});

  Future init() async {
    deviceID = await getDeviceDetails();

    var pref = await User.getPrefUser;
    var user = User.fromMap(pref);
    token = "Bearer ${user.token}";
  }

  Future<ResponseValue> fetch() async {
    await init();


    final uri = Uri.parse(netDomain +
        fetchURL +
        (taskID == null ? "" : taskID!));

    debugPrint(uri.toString());
    debugPrint('Authorization header: $token');
    debugPrint('deviceid header: $deviceID');
    
    var response = await http.get(uri, headers: {
      "Authorization": token,
      "deviceid": deviceID,
    });

    if (response.statusCode == 200) {
      var decode = json.decode(response.body);
      debugPrint(decode["resultS"]);
      debugPrint(decode["error"]);
      if (decode["error"] == "Signature verification failed" ||
          decode["error"] == "Device ID invalid with this login" ||
          decode["error"] == "Expired token") {
        alert("Your session already expired, please relogin.");
      }
      
      // Branch based on type of decode["result"].
      if (decode["result"] is List) {
        ResponseValue responseValue = serializers.deserializeWith(
            ResponseValue.serializer, decode)!;
        if (responseValue.success == true) {
          return responseValue;
        } else {
          return Future.error(responseValue.errmsg.isNotEmpty
              ? responseValue.errmsg
              : "Request failed");
        }
      } else if (decode["result"] is Map<String, dynamic>) {
        // When the response returns a Map instead of a List:
        ResponseValue responseValue = serializers.deserializeWith(
            ResponseValue.serializer, decode)!;
        if (responseValue.success == true) {
          return responseValue;
        } else {
          return Future.error(responseValue.errmsg);
        }
      } else if (decode["result"] is String) {
        // You could attempt to decode the string if it should be JSON,
          // or handle it in a different way.
          try {
            var decodedResult = json.decode(decode["result"]);
            // Now, if decodedResult is a List:
            if (decodedResult is List && decodedResult.isNotEmpty) {
              decode["result"] = decodedResult;
              ResponseValue responseValue = serializers.deserializeWith(
                  ResponseValue.serializer, decode)!;
              if (responseValue.success == true) {
                return responseValue;
              } else {
                return Future.error(responseValue.errmsg);
              }
            }
          } catch (_) {
            // If decoding fails, handle the string directly or throw an error.
            ResponseValue responseValue = serializers.deserializeWith(
                ResponseValue.serializer, decode)!;
            if (responseValue.success == true) {
              return responseValue;
            } else {
              return Future.error(responseValue.errmsg);
            }
          }
      } else {
        return Future.error("Unexpected type for result: ${decode["result"].runtimeType}");
      }
    }
    return Future.error("Please try again.");
  }

  Future<List> fetchComplaint({
    String? additionalParam,
    bool store = false,
    bool storePart = false,
    bool group = false,
    bool groupStore = false,
    bool type = false,
    bool storeType = false,
    bool part = false,
  }) async {
    await init();

    print(fetchURL);
    print(additionalParam);

    final uri = Uri.parse(netDomain +
        fetchURL +
        (taskID == null ? "" : taskID!) +
        (additionalParam ?? ""));
    var response = await http.get(uri, headers: {
      "Authorization": token,
      "Deviceid": deviceID,
    });

    if (response.statusCode == 200) {
      var decode = json.decode(response.body);
      if (decode["error"] == "Signature verification failed" ||
          decode["error"] == "Device ID invalid with this login" ||
          decode["error"] == "Expired token") {
        alert("Your session already expired, please relogin.");
        throw "Your session already expired, please relogin.";
      }

      // Handle double-encoded JSON string
      var result = decode["result"];
      if (result is String) {
        debugPrint("Result is double-encoded, decoding again...");
        result = json.decode(result);
      }

      if ((result as List).isNotEmpty) {
        if (group) {
          return deserializeListOf<ComplaintDGroup>(result).toList();
        } else if (type) {
          return deserializeListOf<ComplaintDType>(result).toList();
        } else if (part) {
          return deserializeListOf<ComplaintDPart>(result).toList();
        } else if (store) {
          return deserializeListOf<ComplaintDStore>(result).toList();
        } else if (groupStore) {
          return deserializeListOf<ComplaintDGroupStore>(result)
              .toList();
        } else if (storePart) {
          return deserializeListOf<MaterialStorePart>(result)
              .toList();
        } else if (storeType) {
          return deserializeListOf<ComplaintDStoreType>(result)
              .toList();
        } else {
          ComplaintResponse responseValue = serializers.deserializeWith(
              ComplaintResponse.serializer, decode)!;
          return responseValue.items!.toList();
        }
      } else {
        debugPrint("Empty result");
        return [];
      }
    }
    return Future.error("Please try again.");
  }

  Future<List> fetchUtilities({
    bool meter = false,
    bool reading = false,
    String? id,
  }) async {
    await init();

    final uri = Uri.parse(netDomain + fetchURL + (id == null ? "" : "/$id"));
    print(fetchURL);

    var response = await http.get(uri, headers: {
      "Authorization": token,
      "Deviceid": deviceID,
    });

    if (response.statusCode == 200) {
      var decode = json.decode(response.body);
      if (decode["error"] == "Signature verification failed" ||
          decode["error"] == "Device ID invalid with this login" ||
          decode["error"] == "Expired token") {
        alert("Your session already expired, please relogin.");
        throw "Your session already expired, please relogin.";
      }
      if ((decode["result"] as List).isNotEmpty) {
        if (meter) {
          return deserializeListOf<Meter>(decode["result"]).toList();
        } else if (reading) {
          return deserializeListOf<Reading>(decode["result"]).toList();
        }
        return [];
      } else {
        return [];
      }
    }
    return Future.error("Please try again.");
  }

  Future<dynamic> getJson({
    required String url,
    dynamic body,
    bool includedHeader = true,
  }) async {
    await init();

    print(fetchURL);

    final uri = Uri.parse(netDomain + fetchURL + (taskID == null ? "" : taskID!));
    var response = await http.get(uri, headers: {
      "Authorization": token,
      "Deviceid": deviceID,
    });

    debugPrint("GET request to: $uri");
    debugPrint(response.body);
    debugPrint(response.statusCode.toString());

    if (response.statusCode == 200) {
      var decode = json.decode(response.body);
      if (decode["error"] == "Signature verification failed" ||
          decode["error"] == "Device ID invalid with this login" ||
          decode["error"] == "Expired token") {
        alert("Your session already expired, please relogin.");
      }
      if (decode['success'] == true) {
        return decode["result"];
      } else {
        // Backend sometimes throws DB-layer "Select query result empty" even for
        // list endpoints. Treat it as an empty list instead of a hard error.
        if (decode["error"] == "Select query result empty") {
          return [];
        }
        return Future.error(decode['errmsg'] ?? "Please try again.");
      }
    }
    return Future.error("Please try again.");
  }

  Future<dynamic> post({
    required String url,
    dynamic body,
    bool includedHeader = true,
  }) async {
    var action = "";
    if (body != null && body is Map && body["action"] != null) {
      action = body["action"];
    }
    if (includedHeader) await init();

    final response = await http.post(Uri.parse(netDomain + url),
        headers: includedHeader
            ? {
                HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
                "Authorization": token,
                "Deviceid": deviceID
              }
            : {
                HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
              },
        body: body);

    print(response);
    print(response.body);

    if (response.statusCode == 200) {
      var decode = json.decode(response.body);
      if (decode["error"] == "Signature verification failed" ||
          decode["error"] == "Device ID invalid with this login" ||
          decode["error"] == "Expired token") {
        alert("Your session already expired, please relogin.");
      }

      ResponseValue responseValue = serializers.deserializeWith(
          ResponseValue.serializer, json.decode(response.body))!;

      if (responseValue.success == true) {
        if (action == "edit_profile") {
          return responseValue;
        } else {
          return responseValue.errmsg;
        }
      } else {
        return Future.error(responseValue.errmsg);
      }
    }
    return Future.error("Please try again.");
  }

  Future<dynamic> postUtilities({ // For utility posts.
    required String url,
    dynamic body,
  }) async {
    await init();

    final response = await http.post(Uri.parse(netDomain + url),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
          "Authorization": token,
          "Deviceid": deviceID,
        },
        body: body);

    print(response);
    print(response.body);

    if (response.statusCode == 200) {
      var decode = json.decode(response.body);
      if (decode["error"] == "Signature verification failed" ||
          decode["error"] == "Device ID invalid with this login" ||
          decode["error"] == "Expired token") {
        alert("Your session already expired, please relogin.");
      }
      if (decode['success'] == true) {
        return true;
      } else {
        return Future.error(decode['errmsg']);
      }
    }
    return Future.error("Please try again.");
  }

  Future<dynamic> put({
    dynamic body = const {},
    bool includedHeader = true,
  }) async {
    var action = "";
    if (body["action"] != null) action = body["action"];
    if (includedHeader) await init();

    final response = await http.put(
        Uri.parse(netDomain + fetchURL + (taskID == null ? "" : taskID!)),
        headers: includedHeader
            ? {
                HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
                "Authorization": token,
                "Deviceid": deviceID
              }
            : {
                HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
              },
        body: body);

    print(response);
    print(response.body);

    if (response.statusCode == 200) {
      var decode = json.decode(response.body);
      if (decode["error"] == "Signature verification failed" ||
          decode["error"] == "Device ID invalid with this login" ||
          decode["error"] == "Expired token") {
        alert("Your session already expired, please relogin.");
      }

      ResponseValue responseValue = serializers.deserializeWith(
          ResponseValue.serializer, json.decode(response.body))!;

      if (responseValue.success == true) {
        if (action == "edit_profile") {
          return responseValue;
        } else {
          return responseValue.errmsg;
        }
      } else {
        return Future.error(responseValue.errmsg);
      }
    }
    return Future.error("Please try again.");
  }

  Future<String> delete({required String url}) async {
    await init();

    final response = await http.delete(Uri.parse(netDomain + url), headers: {
      HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
      "Authorization": token,
      "Deviceid": deviceID
    });

    if (response.statusCode == 200) {
      ResponseValue responseValue = serializers.deserializeWith(
          ResponseValue.serializer, json.decode(response.body))!;
      if (responseValue.success == true) {
        return responseValue.errmsg;
      } else {
        return Future.error(responseValue.errmsg);
      }
    }
    return Future.error("Please try again.");
  }

  Future<void> alert(String txt) async {
    final navigator = navigatorKey.currentState;
    final dialogContext = navigatorKey.currentContext;

    if (navigator == null || dialogContext == null || !navigator.mounted) {
      debugPrint("Navigator not ready to show session alert");
      return;
    }

    if (_sessionDialogVisible) {
      return;
    }
    _sessionDialogVisible = true;

    try {
      await showDialog(
        context: dialogContext,
        barrierDismissible: false,
        builder: (BuildContext context) => CustomDialog(
          title: "Expired Session",
          description: txt,
          buttonText: "Okay",
          image: Image.asset(
            "assets/icon_trans.png",
            height: 40,
          ),
        ),
      );

      try {
        var userPref = await User.getPrefUser;
        var user = User.fromMap(userPref);
        await user.removeUser();
      } catch (err) {
        debugPrint("Unable to clear expired session: $err");
      }

      if (navigator.mounted) {
        navigator.pushNamedAndRemoveUntil("/", (route) => false);
      }
    } finally {
      _sessionDialogVisible = false;
    }
  }
}

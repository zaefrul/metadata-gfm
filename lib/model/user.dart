import 'package:GEMS/data/local/offline_database.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

final String kUserPrefs = "USER";
final String kUserSignature = "SIGNATURE";
const String _kSessionContextPrefsKey = "SESSION_CONTEXT";

class User {
  final String token;
  final String userID;
  String username;
  final String userFirstName;
  final String userLastName;
  final String userType;
  final String userMykadNo;
  String userEmail;
  String userContactNo;
  String isFirstTime;
  final Address address;
  final List<Role> roles;
  String imageUrl;
  String responseJSON;

  User(
    this.token,
    this.userID,
    this.username,
    this.userFirstName,
    this.userLastName,
    this.userType,
    this.userMykadNo,
    this.userEmail,
    this.userContactNo,
    this.isFirstTime,
    this.address,
    this.roles,
    this.imageUrl,
    this.responseJSON,
  );

  factory User.fromMap(String response) {
    var jsonData = json.decode(response) as Map<String, dynamic>;
    var data = jsonData["result"];
    if (data == null) {
      throw Exception("User data is missing");
    }
    Address? address;
    List<Role> roleList = [];

    if (data["address"] != null) {
      address = Address.fromJson(data["address"]);
    }
    if (data["roles"] != null) {
      var rolesJson = data["roles"] as List<dynamic>;
      for (var each in rolesJson) {
        var r = Role.fromJson(each as Map<String, dynamic>);
        roleList.add(r);
      }
    }
    // Ensure that address is not null. You may throw an exception or provide a default.
    if (address == null) {
      throw Exception("Address data is missing");
    }
    return User(
      data["token"] as String,
      data["userId"] as String,
      data["userName"] as String,
      data["userFirstName"] as String,
      data["userLastName"] as String,
      data["userType"] as String,
      data["userMykadNo"] as String,
      data["userEmail"] as String,
      data["userContactNo"] as String,
      data["isFirstTime"] as String,
      address,
      roleList,
      data["imgUrl"] as String? ?? "",
      response,
    );
  }

  String get session => token;
  String get id => userID;
  String get firstName => userFirstName;
  String get lastName => userLastName;
  String get type => userType;
  String get myKad => userMykadNo;
  String get email => userEmail;
  String get contactNo => userContactNo;
  String get firstTime => isFirstTime;
  String get response => responseJSON;
  String get firstname => userFirstName;
  Address get addresses => address;
  List<Role> get allRole => roles;

  updateFirstTime(String status) async {
    var result = json.decode(responseJSON) as Map<String, dynamic>;
    result["result"]["isFirstTime"] = status;
    var newjson = json.encode(result);
    responseJSON = newjson;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(kUserPrefs, responseJSON);
  }

  updateProfile(String name, String phone, String url) async {
    var result = json.decode(responseJSON) as Map<String, dynamic>;
    result["result"]["userFirstName"] = name;
    result["result"]["userContactNo"] = phone;
    result["result"]["imgUrl"] = url;
    var newjson = json.encode(result);
    responseJSON = newjson;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(kUserPrefs, responseJSON);
  }

  saveUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(kUserPrefs, responseJSON);
  }

  removeUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(prefsLATITUDE);
    await prefs.remove(prefsLONGITUDE);
    await prefs.remove(kUserPrefs);
    await prefs.remove(_kSessionContextPrefsKey);

    try {
      await OfflineDatabase.instance.clearAll();
    } catch (_) {
      // Best-effort cache clear during logout/session reset.
    }
  }

  static Future<String> get getPrefUser async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var value = prefs.getString(kUserPrefs);
    if (value == null) return Future.error("not login yet");
    return value;
  }
}

class Address {
  final String desc;
  final String postcode;
  final String city;
  final String state;

  Address(this.desc, this.postcode, this.city, this.state);

  String get _desc => desc;
  String get _postcode => postcode;
  String get _city => city;
  String get _state => state;

  factory Address.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw Exception("Address JSON data is null");
    }
    return Address(
      json["addressDesc"] as String,
      json["addressPostcode"] as String,
      json["addressCity"] as String,
      json["addressState"] as String,
    );
  }
}

class Role {
  final String id;
  final String desc;
  final String type;

  Role(this.id, this.desc, this.type);

  String get _id => id;
  String get _desc => desc;
  String get _type => type;

  factory Role.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw Exception("Role JSON data is null");
    }
    return Role(
      json["roleId"] as String,
      json["roleDesc"] as String,
      json["roleType"] as String,
    );
  }
}

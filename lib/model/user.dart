import 'package:gfm_gems/utils/reference.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

final kUserPrefs = "USER";
final kUserSignature = "SIGNATURE";

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
      this.responseJSON);

  factory User.fromMap(String response) {
    var jsonData = json.decode(response);
    var data = jsonData["result"];

    Address address;
    List<Role> role = List<Role>();

    if (data["address"] != null) address = Address.fromJson(data["address"]);

    if (data["roles"] != null) {
      var roles = data["roles"] as List<Object>;
      roles.forEach((each) => role.add(Role.fromJson(each)));
    }

    return data == null
        ? null
        : User(
            data["token"],
            data["userId"],
            data["userName"],
            data["userFirstName"],
            data["userLastName"],
            data["userType"],
            data["userMykadNo"],
            data["userEmail"],
            data["userContactNo"],
            data["isFirstTime"],
            address,
            role,
            data["imgUrl"],
            response);
  }

  String get session => this.token;
  String get id => this.userID;
  String get firstName => this.userFirstName;
  String get lastName => this.userLastName;
  String get type => this.userType;
  String get myKad => this.userMykadNo;
  String get email => this.userEmail;
  String get contactNo => this.userContactNo;
  String get firstTime => this.isFirstTime;
  String get response => this.responseJSON;

  String get firstname => this.userFirstName;
  Address get addresses => this.address;
  List<Role> get allRole => this.roles;

  updateFirstTime(String status) async {
    var result = json.decode(responseJSON);
    result["result"]["isFirstTime"] = status;
    var newjson = json.encode(result);
    responseJSON = newjson;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(kUserPrefs, responseJSON);
  }

  updateProfile(String name, String phone, String url) async {
    var result = json.decode(responseJSON);
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
    prefs.setString(kUserPrefs, response);
  }

  removeUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(prefsLATITUDE);
    prefs.remove(prefsLONGITUDE);
    prefs.remove(kUserPrefs);
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

  String get _desc => this.desc;
  String get _postcode => this.postcode;
  String get _city => this.city;
  String get _state => this.state;

  factory Address.fromJson(Map<String, Object> json) {
    return json == null
        ? null
        : Address(
            json["addressDesc"],
            json["addressPostcode"],
            json["addressCity"],
            json["addressState"],
          );
  }
}

class Role {
  final String id;
  final String desc;
  final String type;

  Role(this.id, this.desc, this.type);

  String get _id => this.id;
  String get _desc => this.desc;
  String get _type => this.type;

  factory Role.fromJson(Map<String, Object> json) {
    return json == null
        ? null
        : Role(
            json["roleId"],
            json["roleDesc"],
            json["roleType"],
          );
  }
}

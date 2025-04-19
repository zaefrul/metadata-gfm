import 'package:http/http.dart' as http;
import 'dart:convert';

class Session {
  final String id;
  final String password;
  final String param;

  final Map<String, String> header = {"Content-Type": "application/json"};

  Session({required this.id, required this.password})
      : param = json.encode({"user_id": id, "password": password});

  Future<Map<String, dynamic>> get logIn async => http
      .post(Uri.parse(""), body: param, headers: header)
      .then((value) => json.decode(value.body) as Map<String, dynamic>);
}

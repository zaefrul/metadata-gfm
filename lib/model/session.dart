import 'package:http/http.dart' as http;
import 'dart:convert';

class Session {
  final String id;
  final String password;
  final String param;

  var header = {"Content-Type":"application/json"};

  Session({this.id,this.password})
  : this.param = json.encode({
    "user_id"  : id,
    "password" : password
  });

  Future<Map<String,dynamic>> get logIn async =>  
    http
    .post("",body: param, headers: this.header)
    .then((value)=>json.decode(value.body));
  
}
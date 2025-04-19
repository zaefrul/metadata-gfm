library dot;

import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:gfm_gems/model/serializers.dart';

part 'dot.g.dart';

abstract class Dot implements Built<Dot, DotBuilder> {
  String get date;
  String get total;
  BuiltList<String> get status;

  Dot._();
  factory Dot([void Function(DotBuilder) updates]) = _$Dot;

  String toJson() {
    return json.encode(serializers.serializeWith(Dot.serializer, this));
  }

  static Dot? fromJson(String jsonString) {
    return serializers.deserializeWith(Dot.serializer, json.decode(jsonString));
  }

  static Serializer<Dot> get serializer => _$dotSerializer;
}

library task;

import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:gfm_gems/model/serializers.dart';

part 'task.g.dart';

abstract class Task implements Built<Task, TaskBuilder> {
  String get taskId;
  String get ppmTaskId;
  String get transactionNo;
  String get assetNo;
  String get siteName;
  String get assetTypeName;
  String get statusDesc;
  String get taskDateDue;
  String get technician;
  BuiltList<String> get frequency;

  Task._();

  factory Task([updates(TaskBuilder b)]) = _$Task;

  String toJson() {
    return json.encode(serializers.serializeWith(Task.serializer, this));
  }

  static fromJson(String jsonString) {
    return serializers.deserializeWith(
        Task.serializer, json.decode(jsonString));
  }

  static Serializer<Task> get serializer => _$taskSerializer;
}

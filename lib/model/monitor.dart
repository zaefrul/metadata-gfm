library monitor;

import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:GEMS/model/serializers.dart';
import 'package:flutter/foundation.dart';

part 'monitor.g.dart';

abstract class MonitorTask implements Built<MonitorTask, MonitorTaskBuilder> {
  String get transactionId;
  String get transactionNo;
  String get transactionTimeCreated;
  String get flowId;
  String get flowName;
  String get checkpointName;
  String get transactionStatus;

  // PPM
  String? get userFullName;
  String? get assetNo;

  // WO  
  String? get currentTaskOwner;
  String? get woTaskType;
  String? get woTaskSeverity;
  String? get assignedTo;

  MonitorTask._();
  factory MonitorTask([void Function(MonitorTaskBuilder) updates]) = _$MonitorTask;

  String toJson() {
    return json.encode(serializers.serializeWith(MonitorTask.serializer, this));
  }

  static MonitorTask fromJson(String jsonString) {
    return serializers.deserializeWith(
        MonitorTask.serializer, json.decode(jsonString))!;
  }

  static Serializer<MonitorTask> get serializer => _$monitorTaskSerializer;
}

abstract class MonitorDetail implements Built<MonitorDetail, MonitorDetailBuilder> {
  String get flowName;
  String get transactionNo;
  String get initiateBy;
  String get initiateByGroup;
  String get initiateTimeCreated;
  String get taskStatus;
  String get currentUser;
  String get receivedTime;
  String get flowStatus;
  String get flowDueDate;
  String get checkpointId;
  String? get woTaskId;
  String? get ppmTaskId;
  String? get siteName;
  BuiltList<MonitorHistory> get taskHistory;

  String get currentStatus {
    var status = "Execute";
    if (checkpointId == "2") {
      status = "Check";
    } else if (checkpointId == "3") {
      status = "Verify";
    } else if (checkpointId == "4") {
      status = "Completed";
    }
    return status;
  }

  MonitorDetail._();
  factory MonitorDetail([void Function(MonitorDetailBuilder) updates]) = _$MonitorDetail;

  String toJson() {
    return json.encode(serializers.serializeWith(MonitorDetail.serializer, this));
  }

  static MonitorDetail fromJson(String jsonString) {
    return serializers.deserializeWith(
        MonitorDetail.serializer, json.decode(jsonString))!;
  }

  static Serializer<MonitorDetail> get serializer => _$monitorDetailSerializer;
}

abstract class MonitorHistory implements Built<MonitorHistory, MonitorHistoryBuilder> {
  String get checkpointId;
  String get roleId;
  String get taskClaimedUser;
  String get taskRemark;
  String get taskDateDue;
  String get taskTimeCreated;
  String get taskTimeSubmit;
  String get taskStatus;

  MonitorHistory._();
  factory MonitorHistory([void Function(MonitorHistoryBuilder) updates]) = _$MonitorHistory;

  String toJson() {
    return json.encode(serializers.serializeWith(MonitorHistory.serializer, this));
  }

  static MonitorHistory fromJson(String jsonString) {
    debugPrint('MonitorHistory fromJson: $jsonString');
    return serializers.deserializeWith(
        MonitorHistory.serializer, json.decode(jsonString))!;
  }

  static Serializer<MonitorHistory> get serializer => _$monitorHistorySerializer;
}

library workorder;

import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:gfm_gems/model/serializers.dart';

part 'workorder.g.dart';

abstract class WorkOrderTask
    implements Built<WorkOrderTask, WorkOrderTaskBuilder> {
  String get woTaskId;
  String get woTaskNo;
  String get woTaskLocation;
  String get woTaskType;
  String get reportedBy;
  String get woTaskTimeCreated;
  String get woTaskStatus;
  String get woTaskSeverity;

  WorkOrderTask._();
  factory WorkOrderTask([void Function(WorkOrderTaskBuilder) updates]) = _$WorkOrderTask;

  String toJson() {
    return json.encode(serializers.serializeWith(WorkOrderTask.serializer, this));
  }

  static WorkOrderTask fromJson(String jsonString) {
    return serializers.deserializeWith(
        WorkOrderTask.serializer, json.decode(jsonString))!;
  }

  static Serializer<WorkOrderTask> get serializer => _$workOrderTaskSerializer;
}

abstract class WorkOrderStatus
    implements Built<WorkOrderStatus, WorkOrderStatusBuilder> {
  String? get sectionName;
  String? get sectionDesc;
  String? get sectionStatus;
  String? get sectionStatusMaterial;
  String? get sectionStatusMaterialId;
  String? get sectionComment;
  String? get groupId;
  String? get groupName;
  String? get userId;
  String? get userName;
  String? get comment;
  String? get severityId;
  String? get severityName;

  WorkOrderStatus._();
  factory WorkOrderStatus([void Function(WorkOrderStatusBuilder) updates]) = _$WorkOrderStatus;

  String toJson() {
    return json.encode(serializers.serializeWith(WorkOrderStatus.serializer, this));
  }

  static WorkOrderStatus fromJson(String jsonString) {
    return serializers.deserializeWith(
        WorkOrderStatus.serializer, json.decode(jsonString))!;
  }

  static Serializer<WorkOrderStatus> get serializer => _$workOrderStatusSerializer;
}

abstract class WorkOrderDetail
    implements Built<WorkOrderDetail, WorkOrderDetailBuilder> {
  String get woTaskId;
  String get woTaskNo;
  String get woTaskRequestNo;
  String get woTaskReportedBy;
  String get woTaskTimeResponded;
  String get woTaskCategory;
  String get woTaskClient;
  String get woTaskLocation;
  String get woTaskComplaint;
  String get woTaskStatus;
  String get woTaskPhoneNo;
  String get woTaskEmail;
  String get assetNo;
  BuiltList<ComplaintImage> get complaintImages;

  WorkOrderDetail._();
  factory WorkOrderDetail([void Function(WorkOrderDetailBuilder) updates]) = _$WorkOrderDetail;

  String toJson() {
    return json.encode(serializers.serializeWith(WorkOrderDetail.serializer, this));
  }

  static WorkOrderDetail fromJson(String jsonString) {
    return serializers.deserializeWith(
        WorkOrderDetail.serializer, json.decode(jsonString))!;
  }

  static Serializer<WorkOrderDetail> get serializer => _$workOrderDetailSerializer;
}

abstract class ComplaintImage
    implements Built<ComplaintImage, ComplaintImageBuilder> {
  String get woTaskUploadId;
  String get woTaskUploadType;
  String get woTaskId;
  String get woTaskUploadLongitude;
  String get woTaskUploadLatitude;
  String get woTaskUploadTimestamp;
  String get woTaskUploadDesc;
  String get uploadId;
  String get uploadName;
  String get documentDesc;
  String get documentFilename;
  String get documentSrc;

  ComplaintImage._();
  factory ComplaintImage([void Function(ComplaintImageBuilder) updates]) = _$ComplaintImage;

  String toJson() {
    return json.encode(serializers.serializeWith(ComplaintImage.serializer, this));
  }

  static ComplaintImage fromJson(String jsonString) {
    return serializers.deserializeWith(
        ComplaintImage.serializer, json.decode(jsonString))!;
  }

  static Serializer<ComplaintImage> get serializer => _$complaintImageSerializer;
}

abstract class TechnicianDetails
    implements Built<TechnicianDetails, TechnicianDetailsBuilder> {
  String get name;
  String get phoneNo;
  String get email;
  String get group;
  int get totalCurrentTask;
  BuiltList<TechnicianTask> get currentTask;

  TechnicianDetails._();
  factory TechnicianDetails([void Function(TechnicianDetailsBuilder) updates]) = _$TechnicianDetails;

  String toJson() {
    return json.encode(serializers.serializeWith(TechnicianDetails.serializer, this));
  }

  static TechnicianDetails fromJson(String jsonString) {
    return serializers.deserializeWith(
        TechnicianDetails.serializer, json.decode(jsonString))!;
  }

  static Serializer<TechnicianDetails> get serializer => _$technicianDetailsSerializer;
}

abstract class TechnicianTask
    implements Built<TechnicianTask, TechnicianTaskBuilder> {
  String get woTaskNo;
  String get dateReceived;

  TechnicianTask._();
  factory TechnicianTask([void Function(TechnicianTaskBuilder) updates]) = _$TechnicianTask;

  String toJson() {
    return json.encode(serializers.serializeWith(TechnicianTask.serializer, this));
  }

  static TechnicianTask fromJson(String jsonString) {
    return serializers.deserializeWith(
        TechnicianTask.serializer, json.decode(jsonString))!;
  }

  static Serializer<TechnicianTask> get serializer => _$technicianTaskSerializer;
}

abstract class TechnicianImageRepair
    implements Built<TechnicianImageRepair, TechnicianImageRepairBuilder> {
  String get woTaskUploadId;
  String get woTaskUploadType;
  String get woTaskId;
  String get woTaskUploadLongitude;
  String get woTaskUploadLatitude;
  String get woTaskUploadTimestamp;
  String get woTaskUploadDesc;
  String get uploadId;
  String get uploadName;
  String get documentDesc;
  String get documentFilename;
  String get documentSrc;

  TechnicianImageRepair._();
  factory TechnicianImageRepair([void Function(TechnicianImageRepairBuilder) updates]) = _$TechnicianImageRepair;

  String toJson() {
    return json.encode(serializers.serializeWith(TechnicianImageRepair.serializer, this));
  }

  static TechnicianImageRepair fromJson(String jsonString) {
    return serializers.deserializeWith(
        TechnicianImageRepair.serializer, json.decode(jsonString))!;
  }

  static Serializer<TechnicianImageRepair> get serializer => _$technicianImageRepairSerializer;
}

abstract class TechnicianAssign
    implements Built<TechnicianAssign, TechnicianAssignBuilder> {
  String get userId;
  String get severity;
  String get groupId;
  String get woTaskCategory;
  String get userCategory;
  String get woTaskMaxAssistant;
  BuiltList<String> get assistUserId;

  TechnicianAssign._();
  factory TechnicianAssign([void Function(TechnicianAssignBuilder) updates]) = _$TechnicianAssign;

  String toJson() {
    return json.encode(serializers.serializeWith(TechnicianAssign.serializer, this));
  }

  static TechnicianAssign fromJson(String jsonString) {
    return serializers.deserializeWith(
        TechnicianAssign.serializer, json.decode(jsonString))!;
  }

  static Serializer<TechnicianAssign> get serializer => _$technicianAssignSerializer;
}

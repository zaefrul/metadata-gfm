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

  factory WorkOrderTask([updates(WorkOrderTaskBuilder b)]) = _$WorkOrderTask;

  String toJson() {
    return json
        .encode(serializers.serializeWith(WorkOrderTask.serializer, this));
  }

  static WorkOrderTask fromJson(String jsonString) {
    return serializers.deserializeWith(
        WorkOrderTask.serializer, json.decode(jsonString));
  }

  static Serializer<WorkOrderTask> get serializer => _$workOrderTaskSerializer;
}

abstract class WorkOrderStatus
    implements Built<WorkOrderStatus, WorkOrderStatusBuilder> {
  @nullable
  String get sectionName;
  @nullable
  String get sectionDesc;
  @nullable
  String get sectionStatus;
  @nullable
  String get sectionStatusMaterial;
  @nullable
  String get sectionStatusMaterialId;
  @nullable
  String get sectionComment;
  @nullable
  String get groupId;
  @nullable
  String get groupName;
  @nullable
  String get userId;
  @nullable
  String get userName;
  @nullable
  String get comment;
  @nullable
  String get severityId;
  @nullable
  String get severityName;

  WorkOrderStatus._();

  factory WorkOrderStatus([updates(WorkOrderStatusBuilder b)]) =
      _$WorkOrderStatus;

  String toJson() {
    return json
        .encode(serializers.serializeWith(WorkOrderStatus.serializer, this));
  }

  static WorkOrderStatus fromJson(String jsonString) {
    return serializers.deserializeWith(
        WorkOrderStatus.serializer, json.decode(jsonString));
  }

  static Serializer<WorkOrderStatus> get serializer =>
      _$workOrderStatusSerializer;
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
  BuiltList<ComplaintImage> get complaintImages;

  WorkOrderDetail._();

  factory WorkOrderDetail([updates(WorkOrderDetailBuilder b)]) =
      _$WorkOrderDetail;

  String toJson() {
    return json
        .encode(serializers.serializeWith(WorkOrderDetail.serializer, this));
  }

  static WorkOrderDetail fromJson(String jsonString) {
    return serializers.deserializeWith(
        WorkOrderDetail.serializer, json.decode(jsonString));
  }

  static Serializer<WorkOrderDetail> get serializer =>
      _$workOrderDetailSerializer;
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

  factory ComplaintImage([updates(ComplaintImageBuilder b)]) = _$ComplaintImage;

  String toJson() {
    return json
        .encode(serializers.serializeWith(ComplaintImage.serializer, this));
  }

  static ComplaintImage fromJson(String jsonString) {
    return serializers.deserializeWith(
        ComplaintImage.serializer, json.decode(jsonString));
  }

  static Serializer<ComplaintImage> get serializer =>
      _$complaintImageSerializer;
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

  factory TechnicianDetails([updates(TechnicianDetailsBuilder b)]) =
      _$TechnicianDetails;

  String toJson() {
    return json
        .encode(serializers.serializeWith(TechnicianDetails.serializer, this));
  }

  static TechnicianDetails fromJson(String jsonString) {
    return serializers.deserializeWith(
        TechnicianDetails.serializer, json.decode(jsonString));
  }

  static Serializer<TechnicianDetails> get serializer =>
      _$technicianDetailsSerializer;
}

abstract class TechnicianTask
    implements Built<TechnicianTask, TechnicianTaskBuilder> {
  String get woTaskNo;
  String get dateReceived;

  TechnicianTask._();

  factory TechnicianTask([updates(TechnicianTaskBuilder b)]) = _$TechnicianTask;

  String toJson() {
    return json
        .encode(serializers.serializeWith(TechnicianTask.serializer, this));
  }

  static TechnicianTask fromJson(String jsonString) {
    return serializers.deserializeWith(
        TechnicianTask.serializer, json.decode(jsonString));
  }

  static Serializer<TechnicianTask> get serializer =>
      _$technicianTaskSerializer;
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

  factory TechnicianImageRepair([updates(TechnicianImageRepairBuilder b)]) =
      _$TechnicianImageRepair;

  String toJson() {
    return json.encode(
        serializers.serializeWith(TechnicianImageRepair.serializer, this));
  }

  static TechnicianImageRepair fromJson(String jsonString) {
    return serializers.deserializeWith(
        TechnicianImageRepair.serializer, json.decode(jsonString));
  }

  static Serializer<TechnicianImageRepair> get serializer =>
      _$technicianImageRepairSerializer;
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

  factory TechnicianAssign([updates(TechnicianAssignBuilder b)]) =
      _$TechnicianAssign;

  String toJson() {
    return json
        .encode(serializers.serializeWith(TechnicianAssign.serializer, this));
  }

  static TechnicianAssign fromJson(String jsonString) {
    return serializers.deserializeWith(
        TechnicianAssign.serializer, json.decode(jsonString));
  }

  static Serializer<TechnicianAssign> get serializer =>
      _$technicianAssignSerializer;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workorder.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<WorkOrderTask> _$workOrderTaskSerializer =
    new _$WorkOrderTaskSerializer();
Serializer<WorkOrderStatus> _$workOrderStatusSerializer =
    new _$WorkOrderStatusSerializer();
Serializer<WorkOrderDetail> _$workOrderDetailSerializer =
    new _$WorkOrderDetailSerializer();
Serializer<ComplaintImage> _$complaintImageSerializer =
    new _$ComplaintImageSerializer();
Serializer<TechnicianDetails> _$technicianDetailsSerializer =
    new _$TechnicianDetailsSerializer();
Serializer<TechnicianTask> _$technicianTaskSerializer =
    new _$TechnicianTaskSerializer();
Serializer<TechnicianImageRepair> _$technicianImageRepairSerializer =
    new _$TechnicianImageRepairSerializer();
Serializer<TechnicianAssign> _$technicianAssignSerializer =
    new _$TechnicianAssignSerializer();

class _$WorkOrderTaskSerializer implements StructuredSerializer<WorkOrderTask> {
  @override
  final Iterable<Type> types = const [WorkOrderTask, _$WorkOrderTask];
  @override
  final String wireName = 'WorkOrderTask';

  @override
  Iterable<Object?> serialize(Serializers serializers, WorkOrderTask object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'woTaskId',
      serializers.serialize(object.woTaskId,
          specifiedType: const FullType(String)),
      'woTaskNo',
      serializers.serialize(object.woTaskNo,
          specifiedType: const FullType(String)),
      'woTaskLocation',
      serializers.serialize(object.woTaskLocation,
          specifiedType: const FullType(String)),
      'woTaskType',
      serializers.serialize(object.woTaskType,
          specifiedType: const FullType(String)),
      'woTaskTypeInit',
      serializers.serialize(object.woTaskTypeInit,
          specifiedType: const FullType(String)),
      'reportedBy',
      serializers.serialize(object.reportedBy,
          specifiedType: const FullType(String)),
      'woTaskTimeCreated',
      serializers.serialize(object.woTaskTimeCreated,
          specifiedType: const FullType(String)),
      'woTaskStatus',
      serializers.serialize(object.woTaskStatus,
          specifiedType: const FullType(String)),
      'woTaskSeverity',
      serializers.serialize(object.woTaskSeverity,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  WorkOrderTask deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new WorkOrderTaskBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'woTaskId':
          result.woTaskId = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'woTaskNo':
          result.woTaskNo = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'woTaskLocation':
          result.woTaskLocation = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'woTaskType':
          result.woTaskType = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'woTaskTypeInit':
          result.woTaskTypeInit = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'reportedBy':
          result.reportedBy = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'woTaskTimeCreated':
          result.woTaskTimeCreated = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'woTaskStatus':
          result.woTaskStatus = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'woTaskSeverity':
          result.woTaskSeverity = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$WorkOrderStatusSerializer
    implements StructuredSerializer<WorkOrderStatus> {
  @override
  final Iterable<Type> types = const [WorkOrderStatus, _$WorkOrderStatus];
  @override
  final String wireName = 'WorkOrderStatus';

  @override
  Iterable<Object?> serialize(Serializers serializers, WorkOrderStatus object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.sectionName;
    if (value != null) {
      result
        ..add('sectionName')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.sectionDesc;
    if (value != null) {
      result
        ..add('sectionDesc')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.sectionStatus;
    if (value != null) {
      result
        ..add('sectionStatus')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.sectionStatusMaterial;
    if (value != null) {
      result
        ..add('sectionStatusMaterial')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.sectionStatusMaterialId;
    if (value != null) {
      result
        ..add('sectionStatusMaterialId')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.sectionComment;
    if (value != null) {
      result
        ..add('sectionComment')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.groupId;
    if (value != null) {
      result
        ..add('groupId')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.groupName;
    if (value != null) {
      result
        ..add('groupName')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.userId;
    if (value != null) {
      result
        ..add('userId')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.userName;
    if (value != null) {
      result
        ..add('userName')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.comment;
    if (value != null) {
      result
        ..add('comment')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.severityId;
    if (value != null) {
      result
        ..add('severityId')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.severityName;
    if (value != null) {
      result
        ..add('severityName')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  WorkOrderStatus deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new WorkOrderStatusBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'sectionName':
          result.sectionName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'sectionDesc':
          result.sectionDesc = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'sectionStatus':
          result.sectionStatus = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'sectionStatusMaterial':
          result.sectionStatusMaterial = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'sectionStatusMaterialId':
          result.sectionStatusMaterialId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'sectionComment':
          result.sectionComment = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'groupId':
          result.groupId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'groupName':
          result.groupName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'userId':
          result.userId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'userName':
          result.userName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'comment':
          result.comment = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'severityId':
          result.severityId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'severityName':
          result.severityName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
      }
    }

    return result.build();
  }
}

class _$WorkOrderDetailSerializer
    implements StructuredSerializer<WorkOrderDetail> {
  @override
  final Iterable<Type> types = const [WorkOrderDetail, _$WorkOrderDetail];
  @override
  final String wireName = 'WorkOrderDetail';

  @override
  Iterable<Object?> serialize(Serializers serializers, WorkOrderDetail object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'woTaskId',
      serializers.serialize(object.woTaskId,
          specifiedType: const FullType(String)),
      'woTaskNo',
      serializers.serialize(object.woTaskNo,
          specifiedType: const FullType(String)),
      'woTaskRequestNo',
      serializers.serialize(object.woTaskRequestNo,
          specifiedType: const FullType(String)),
      'woTaskReportedBy',
      serializers.serialize(object.woTaskReportedBy,
          specifiedType: const FullType(String)),
      'woTaskTimeResponded',
      serializers.serialize(object.woTaskTimeResponded,
          specifiedType: const FullType(String)),
      'woTaskCategory',
      serializers.serialize(object.woTaskCategory,
          specifiedType: const FullType(String)),
      'woTaskClient',
      serializers.serialize(object.woTaskClient,
          specifiedType: const FullType(String)),
      'woTaskLocation',
      serializers.serialize(object.woTaskLocation,
          specifiedType: const FullType(String)),
      'woTaskComplaint',
      serializers.serialize(object.woTaskComplaint,
          specifiedType: const FullType(String)),
      'woTaskStatus',
      serializers.serialize(object.woTaskStatus,
          specifiedType: const FullType(String)),
      'woTaskPhoneNo',
      serializers.serialize(object.woTaskPhoneNo,
          specifiedType: const FullType(String)),
      'woTaskEmail',
      serializers.serialize(object.woTaskEmail,
          specifiedType: const FullType(String)),
      'zoneName',
      serializers.serialize(object.zoneName,
          specifiedType: const FullType(String)),
      'complaintImages',
      serializers.serialize(object.complaintImages,
          specifiedType: const FullType(
              BuiltList, const [const FullType(ComplaintImage)])),
    ];
    Object? value;
    value = object.woTaskCategoryInit;
    if (value != null) {
      result
        ..add('woTaskCategoryInit')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.assetNo;
    if (value != null) {
      result
        ..add('assetNo')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  WorkOrderDetail deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new WorkOrderDetailBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'woTaskId':
          result.woTaskId = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'woTaskNo':
          result.woTaskNo = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'woTaskRequestNo':
          result.woTaskRequestNo = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'woTaskReportedBy':
          result.woTaskReportedBy = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'woTaskTimeResponded':
          result.woTaskTimeResponded = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'woTaskCategory':
          result.woTaskCategory = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'woTaskCategoryInit':
          result.woTaskCategoryInit = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'woTaskClient':
          result.woTaskClient = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'woTaskLocation':
          result.woTaskLocation = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'woTaskComplaint':
          result.woTaskComplaint = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'woTaskStatus':
          result.woTaskStatus = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'woTaskPhoneNo':
          result.woTaskPhoneNo = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'woTaskEmail':
          result.woTaskEmail = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'assetNo':
          result.assetNo = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'zoneName':
          result.zoneName = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'complaintImages':
          result.complaintImages.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(ComplaintImage)]))!
              as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$ComplaintImageSerializer
    implements StructuredSerializer<ComplaintImage> {
  @override
  final Iterable<Type> types = const [ComplaintImage, _$ComplaintImage];
  @override
  final String wireName = 'ComplaintImage';

  @override
  Iterable<Object?> serialize(Serializers serializers, ComplaintImage object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'woTaskUploadId',
      serializers.serialize(object.woTaskUploadId,
          specifiedType: const FullType(String)),
      'woTaskUploadType',
      serializers.serialize(object.woTaskUploadType,
          specifiedType: const FullType(String)),
      'woTaskId',
      serializers.serialize(object.woTaskId,
          specifiedType: const FullType(String)),
      'woTaskUploadLongitude',
      serializers.serialize(object.woTaskUploadLongitude,
          specifiedType: const FullType(String)),
      'woTaskUploadLatitude',
      serializers.serialize(object.woTaskUploadLatitude,
          specifiedType: const FullType(String)),
      'woTaskUploadTimestamp',
      serializers.serialize(object.woTaskUploadTimestamp,
          specifiedType: const FullType(String)),
      'woTaskUploadDesc',
      serializers.serialize(object.woTaskUploadDesc,
          specifiedType: const FullType(String)),
      'uploadId',
      serializers.serialize(object.uploadId,
          specifiedType: const FullType(String)),
      'uploadName',
      serializers.serialize(object.uploadName,
          specifiedType: const FullType(String)),
      'documentDesc',
      serializers.serialize(object.documentDesc,
          specifiedType: const FullType(String)),
      'documentFilename',
      serializers.serialize(object.documentFilename,
          specifiedType: const FullType(String)),
      'documentSrc',
      serializers.serialize(object.documentSrc,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  ComplaintImage deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new ComplaintImageBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'woTaskUploadId':
          result.woTaskUploadId = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'woTaskUploadType':
          result.woTaskUploadType = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'woTaskId':
          result.woTaskId = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'woTaskUploadLongitude':
          result.woTaskUploadLongitude = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'woTaskUploadLatitude':
          result.woTaskUploadLatitude = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'woTaskUploadTimestamp':
          result.woTaskUploadTimestamp = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'woTaskUploadDesc':
          result.woTaskUploadDesc = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'uploadId':
          result.uploadId = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'uploadName':
          result.uploadName = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'documentDesc':
          result.documentDesc = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'documentFilename':
          result.documentFilename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'documentSrc':
          result.documentSrc = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$TechnicianDetailsSerializer
    implements StructuredSerializer<TechnicianDetails> {
  @override
  final Iterable<Type> types = const [TechnicianDetails, _$TechnicianDetails];
  @override
  final String wireName = 'TechnicianDetails';

  @override
  Iterable<Object?> serialize(Serializers serializers, TechnicianDetails object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'name',
      serializers.serialize(object.name, specifiedType: const FullType(String)),
      'phoneNo',
      serializers.serialize(object.phoneNo,
          specifiedType: const FullType(String)),
      'email',
      serializers.serialize(object.email,
          specifiedType: const FullType(String)),
      'group',
      serializers.serialize(object.group,
          specifiedType: const FullType(String)),
      'totalCurrentTask',
      serializers.serialize(object.totalCurrentTask,
          specifiedType: const FullType(int)),
      'currentTask',
      serializers.serialize(object.currentTask,
          specifiedType: const FullType(
              BuiltList, const [const FullType(TechnicianTask)])),
    ];

    return result;
  }

  @override
  TechnicianDetails deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new TechnicianDetailsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'name':
          result.name = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'phoneNo':
          result.phoneNo = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'email':
          result.email = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'group':
          result.group = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'totalCurrentTask':
          result.totalCurrentTask = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'currentTask':
          result.currentTask.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(TechnicianTask)]))!
              as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$TechnicianTaskSerializer
    implements StructuredSerializer<TechnicianTask> {
  @override
  final Iterable<Type> types = const [TechnicianTask, _$TechnicianTask];
  @override
  final String wireName = 'TechnicianTask';

  @override
  Iterable<Object?> serialize(Serializers serializers, TechnicianTask object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'woTaskNo',
      serializers.serialize(object.woTaskNo,
          specifiedType: const FullType(String)),
      'dateReceived',
      serializers.serialize(object.dateReceived,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  TechnicianTask deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new TechnicianTaskBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'woTaskNo':
          result.woTaskNo = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'dateReceived':
          result.dateReceived = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$TechnicianImageRepairSerializer
    implements StructuredSerializer<TechnicianImageRepair> {
  @override
  final Iterable<Type> types = const [
    TechnicianImageRepair,
    _$TechnicianImageRepair
  ];
  @override
  final String wireName = 'TechnicianImageRepair';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, TechnicianImageRepair object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'woTaskUploadId',
      serializers.serialize(object.woTaskUploadId,
          specifiedType: const FullType(String)),
      'woTaskUploadType',
      serializers.serialize(object.woTaskUploadType,
          specifiedType: const FullType(String)),
      'woTaskId',
      serializers.serialize(object.woTaskId,
          specifiedType: const FullType(String)),
      'woTaskUploadLongitude',
      serializers.serialize(object.woTaskUploadLongitude,
          specifiedType: const FullType(String)),
      'woTaskUploadLatitude',
      serializers.serialize(object.woTaskUploadLatitude,
          specifiedType: const FullType(String)),
      'woTaskUploadTimestamp',
      serializers.serialize(object.woTaskUploadTimestamp,
          specifiedType: const FullType(String)),
      'woTaskUploadDesc',
      serializers.serialize(object.woTaskUploadDesc,
          specifiedType: const FullType(String)),
      'uploadId',
      serializers.serialize(object.uploadId,
          specifiedType: const FullType(String)),
      'uploadName',
      serializers.serialize(object.uploadName,
          specifiedType: const FullType(String)),
      'documentDesc',
      serializers.serialize(object.documentDesc,
          specifiedType: const FullType(String)),
      'documentFilename',
      serializers.serialize(object.documentFilename,
          specifiedType: const FullType(String)),
      'documentSrc',
      serializers.serialize(object.documentSrc,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  TechnicianImageRepair deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new TechnicianImageRepairBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'woTaskUploadId':
          result.woTaskUploadId = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'woTaskUploadType':
          result.woTaskUploadType = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'woTaskId':
          result.woTaskId = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'woTaskUploadLongitude':
          result.woTaskUploadLongitude = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'woTaskUploadLatitude':
          result.woTaskUploadLatitude = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'woTaskUploadTimestamp':
          result.woTaskUploadTimestamp = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'woTaskUploadDesc':
          result.woTaskUploadDesc = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'uploadId':
          result.uploadId = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'uploadName':
          result.uploadName = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'documentDesc':
          result.documentDesc = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'documentFilename':
          result.documentFilename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'documentSrc':
          result.documentSrc = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$TechnicianAssignSerializer
    implements StructuredSerializer<TechnicianAssign> {
  @override
  final Iterable<Type> types = const [TechnicianAssign, _$TechnicianAssign];
  @override
  final String wireName = 'TechnicianAssign';

  @override
  Iterable<Object?> serialize(Serializers serializers, TechnicianAssign object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'userId',
      serializers.serialize(object.userId,
          specifiedType: const FullType(String)),
      'severity',
      serializers.serialize(object.severity,
          specifiedType: const FullType(String)),
      'groupId',
      serializers.serialize(object.groupId,
          specifiedType: const FullType(String)),
      'woTaskCategory',
      serializers.serialize(object.woTaskCategory,
          specifiedType: const FullType(String)),
      'userCategory',
      serializers.serialize(object.userCategory,
          specifiedType: const FullType(String)),
      'woTaskMaxAssistant',
      serializers.serialize(object.woTaskMaxAssistant,
          specifiedType: const FullType(String)),
      'assistUserId',
      serializers.serialize(object.assistUserId,
          specifiedType:
              const FullType(BuiltList, const [const FullType(String)])),
    ];

    return result;
  }

  @override
  TechnicianAssign deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new TechnicianAssignBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'userId':
          result.userId = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'severity':
          result.severity = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'groupId':
          result.groupId = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'woTaskCategory':
          result.woTaskCategory = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'userCategory':
          result.userCategory = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'woTaskMaxAssistant':
          result.woTaskMaxAssistant = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'assistUserId':
          result.assistUserId.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$WorkOrderTask extends WorkOrderTask {
  @override
  final String woTaskId;
  @override
  final String woTaskNo;
  @override
  final String woTaskLocation;
  @override
  final String woTaskType;
  @override
  final String woTaskTypeInit;
  @override
  final String reportedBy;
  @override
  final String woTaskTimeCreated;
  @override
  final String woTaskStatus;
  @override
  final String woTaskSeverity;

  factory _$WorkOrderTask([void Function(WorkOrderTaskBuilder)? updates]) =>
      (new WorkOrderTaskBuilder()..update(updates))._build();

  _$WorkOrderTask._(
      {required this.woTaskId,
      required this.woTaskNo,
      required this.woTaskLocation,
      required this.woTaskType,
      required this.woTaskTypeInit,
      required this.reportedBy,
      required this.woTaskTimeCreated,
      required this.woTaskStatus,
      required this.woTaskSeverity})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        woTaskId, r'WorkOrderTask', 'woTaskId');
    BuiltValueNullFieldError.checkNotNull(
        woTaskNo, r'WorkOrderTask', 'woTaskNo');
    BuiltValueNullFieldError.checkNotNull(
        woTaskLocation, r'WorkOrderTask', 'woTaskLocation');
    BuiltValueNullFieldError.checkNotNull(
        woTaskType, r'WorkOrderTask', 'woTaskType');
    BuiltValueNullFieldError.checkNotNull(
        woTaskTypeInit, r'WorkOrderTask', 'woTaskTypeInit');
    BuiltValueNullFieldError.checkNotNull(
        reportedBy, r'WorkOrderTask', 'reportedBy');
    BuiltValueNullFieldError.checkNotNull(
        woTaskTimeCreated, r'WorkOrderTask', 'woTaskTimeCreated');
    BuiltValueNullFieldError.checkNotNull(
        woTaskStatus, r'WorkOrderTask', 'woTaskStatus');
    BuiltValueNullFieldError.checkNotNull(
        woTaskSeverity, r'WorkOrderTask', 'woTaskSeverity');
  }

  @override
  WorkOrderTask rebuild(void Function(WorkOrderTaskBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WorkOrderTaskBuilder toBuilder() => new WorkOrderTaskBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WorkOrderTask &&
        woTaskId == other.woTaskId &&
        woTaskNo == other.woTaskNo &&
        woTaskLocation == other.woTaskLocation &&
        woTaskType == other.woTaskType &&
        woTaskTypeInit == other.woTaskTypeInit &&
        reportedBy == other.reportedBy &&
        woTaskTimeCreated == other.woTaskTimeCreated &&
        woTaskStatus == other.woTaskStatus &&
        woTaskSeverity == other.woTaskSeverity;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, woTaskId.hashCode);
    _$hash = $jc(_$hash, woTaskNo.hashCode);
    _$hash = $jc(_$hash, woTaskLocation.hashCode);
    _$hash = $jc(_$hash, woTaskType.hashCode);
    _$hash = $jc(_$hash, woTaskTypeInit.hashCode);
    _$hash = $jc(_$hash, reportedBy.hashCode);
    _$hash = $jc(_$hash, woTaskTimeCreated.hashCode);
    _$hash = $jc(_$hash, woTaskStatus.hashCode);
    _$hash = $jc(_$hash, woTaskSeverity.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WorkOrderTask')
          ..add('woTaskId', woTaskId)
          ..add('woTaskNo', woTaskNo)
          ..add('woTaskLocation', woTaskLocation)
          ..add('woTaskType', woTaskType)
          ..add('woTaskTypeInit', woTaskTypeInit)
          ..add('reportedBy', reportedBy)
          ..add('woTaskTimeCreated', woTaskTimeCreated)
          ..add('woTaskStatus', woTaskStatus)
          ..add('woTaskSeverity', woTaskSeverity))
        .toString();
  }
}

class WorkOrderTaskBuilder
    implements Builder<WorkOrderTask, WorkOrderTaskBuilder> {
  _$WorkOrderTask? _$v;

  String? _woTaskId;
  String? get woTaskId => _$this._woTaskId;
  set woTaskId(String? woTaskId) => _$this._woTaskId = woTaskId;

  String? _woTaskNo;
  String? get woTaskNo => _$this._woTaskNo;
  set woTaskNo(String? woTaskNo) => _$this._woTaskNo = woTaskNo;

  String? _woTaskLocation;
  String? get woTaskLocation => _$this._woTaskLocation;
  set woTaskLocation(String? woTaskLocation) =>
      _$this._woTaskLocation = woTaskLocation;

  String? _woTaskType;
  String? get woTaskType => _$this._woTaskType;
  set woTaskType(String? woTaskType) => _$this._woTaskType = woTaskType;

  String? _woTaskTypeInit;
  String? get woTaskTypeInit => _$this._woTaskTypeInit;
  set woTaskTypeInit(String? woTaskTypeInit) =>
      _$this._woTaskTypeInit = woTaskTypeInit;

  String? _reportedBy;
  String? get reportedBy => _$this._reportedBy;
  set reportedBy(String? reportedBy) => _$this._reportedBy = reportedBy;

  String? _woTaskTimeCreated;
  String? get woTaskTimeCreated => _$this._woTaskTimeCreated;
  set woTaskTimeCreated(String? woTaskTimeCreated) =>
      _$this._woTaskTimeCreated = woTaskTimeCreated;

  String? _woTaskStatus;
  String? get woTaskStatus => _$this._woTaskStatus;
  set woTaskStatus(String? woTaskStatus) => _$this._woTaskStatus = woTaskStatus;

  String? _woTaskSeverity;
  String? get woTaskSeverity => _$this._woTaskSeverity;
  set woTaskSeverity(String? woTaskSeverity) =>
      _$this._woTaskSeverity = woTaskSeverity;

  WorkOrderTaskBuilder();

  WorkOrderTaskBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _woTaskId = $v.woTaskId;
      _woTaskNo = $v.woTaskNo;
      _woTaskLocation = $v.woTaskLocation;
      _woTaskType = $v.woTaskType;
      _woTaskTypeInit = $v.woTaskTypeInit;
      _reportedBy = $v.reportedBy;
      _woTaskTimeCreated = $v.woTaskTimeCreated;
      _woTaskStatus = $v.woTaskStatus;
      _woTaskSeverity = $v.woTaskSeverity;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WorkOrderTask other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$WorkOrderTask;
  }

  @override
  void update(void Function(WorkOrderTaskBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WorkOrderTask build() => _build();

  _$WorkOrderTask _build() {
    final _$result = _$v ??
        new _$WorkOrderTask._(
          woTaskId: BuiltValueNullFieldError.checkNotNull(
              woTaskId, r'WorkOrderTask', 'woTaskId'),
          woTaskNo: BuiltValueNullFieldError.checkNotNull(
              woTaskNo, r'WorkOrderTask', 'woTaskNo'),
          woTaskLocation: BuiltValueNullFieldError.checkNotNull(
              woTaskLocation, r'WorkOrderTask', 'woTaskLocation'),
          woTaskType: BuiltValueNullFieldError.checkNotNull(
              woTaskType, r'WorkOrderTask', 'woTaskType'),
          woTaskTypeInit: BuiltValueNullFieldError.checkNotNull(
              woTaskTypeInit, r'WorkOrderTask', 'woTaskTypeInit'),
          reportedBy: BuiltValueNullFieldError.checkNotNull(
              reportedBy, r'WorkOrderTask', 'reportedBy'),
          woTaskTimeCreated: BuiltValueNullFieldError.checkNotNull(
              woTaskTimeCreated, r'WorkOrderTask', 'woTaskTimeCreated'),
          woTaskStatus: BuiltValueNullFieldError.checkNotNull(
              woTaskStatus, r'WorkOrderTask', 'woTaskStatus'),
          woTaskSeverity: BuiltValueNullFieldError.checkNotNull(
              woTaskSeverity, r'WorkOrderTask', 'woTaskSeverity'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$WorkOrderStatus extends WorkOrderStatus {
  @override
  final String? sectionName;
  @override
  final String? sectionDesc;
  @override
  final String? sectionStatus;
  @override
  final String? sectionStatusMaterial;
  @override
  final String? sectionStatusMaterialId;
  @override
  final String? sectionComment;
  @override
  final String? groupId;
  @override
  final String? groupName;
  @override
  final String? userId;
  @override
  final String? userName;
  @override
  final String? comment;
  @override
  final String? severityId;
  @override
  final String? severityName;

  factory _$WorkOrderStatus([void Function(WorkOrderStatusBuilder)? updates]) =>
      (new WorkOrderStatusBuilder()..update(updates))._build();

  _$WorkOrderStatus._(
      {this.sectionName,
      this.sectionDesc,
      this.sectionStatus,
      this.sectionStatusMaterial,
      this.sectionStatusMaterialId,
      this.sectionComment,
      this.groupId,
      this.groupName,
      this.userId,
      this.userName,
      this.comment,
      this.severityId,
      this.severityName})
      : super._();

  @override
  WorkOrderStatus rebuild(void Function(WorkOrderStatusBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WorkOrderStatusBuilder toBuilder() =>
      new WorkOrderStatusBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WorkOrderStatus &&
        sectionName == other.sectionName &&
        sectionDesc == other.sectionDesc &&
        sectionStatus == other.sectionStatus &&
        sectionStatusMaterial == other.sectionStatusMaterial &&
        sectionStatusMaterialId == other.sectionStatusMaterialId &&
        sectionComment == other.sectionComment &&
        groupId == other.groupId &&
        groupName == other.groupName &&
        userId == other.userId &&
        userName == other.userName &&
        comment == other.comment &&
        severityId == other.severityId &&
        severityName == other.severityName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, sectionName.hashCode);
    _$hash = $jc(_$hash, sectionDesc.hashCode);
    _$hash = $jc(_$hash, sectionStatus.hashCode);
    _$hash = $jc(_$hash, sectionStatusMaterial.hashCode);
    _$hash = $jc(_$hash, sectionStatusMaterialId.hashCode);
    _$hash = $jc(_$hash, sectionComment.hashCode);
    _$hash = $jc(_$hash, groupId.hashCode);
    _$hash = $jc(_$hash, groupName.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, userName.hashCode);
    _$hash = $jc(_$hash, comment.hashCode);
    _$hash = $jc(_$hash, severityId.hashCode);
    _$hash = $jc(_$hash, severityName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WorkOrderStatus')
          ..add('sectionName', sectionName)
          ..add('sectionDesc', sectionDesc)
          ..add('sectionStatus', sectionStatus)
          ..add('sectionStatusMaterial', sectionStatusMaterial)
          ..add('sectionStatusMaterialId', sectionStatusMaterialId)
          ..add('sectionComment', sectionComment)
          ..add('groupId', groupId)
          ..add('groupName', groupName)
          ..add('userId', userId)
          ..add('userName', userName)
          ..add('comment', comment)
          ..add('severityId', severityId)
          ..add('severityName', severityName))
        .toString();
  }
}

class WorkOrderStatusBuilder
    implements Builder<WorkOrderStatus, WorkOrderStatusBuilder> {
  _$WorkOrderStatus? _$v;

  String? _sectionName;
  String? get sectionName => _$this._sectionName;
  set sectionName(String? sectionName) => _$this._sectionName = sectionName;

  String? _sectionDesc;
  String? get sectionDesc => _$this._sectionDesc;
  set sectionDesc(String? sectionDesc) => _$this._sectionDesc = sectionDesc;

  String? _sectionStatus;
  String? get sectionStatus => _$this._sectionStatus;
  set sectionStatus(String? sectionStatus) =>
      _$this._sectionStatus = sectionStatus;

  String? _sectionStatusMaterial;
  String? get sectionStatusMaterial => _$this._sectionStatusMaterial;
  set sectionStatusMaterial(String? sectionStatusMaterial) =>
      _$this._sectionStatusMaterial = sectionStatusMaterial;

  String? _sectionStatusMaterialId;
  String? get sectionStatusMaterialId => _$this._sectionStatusMaterialId;
  set sectionStatusMaterialId(String? sectionStatusMaterialId) =>
      _$this._sectionStatusMaterialId = sectionStatusMaterialId;

  String? _sectionComment;
  String? get sectionComment => _$this._sectionComment;
  set sectionComment(String? sectionComment) =>
      _$this._sectionComment = sectionComment;

  String? _groupId;
  String? get groupId => _$this._groupId;
  set groupId(String? groupId) => _$this._groupId = groupId;

  String? _groupName;
  String? get groupName => _$this._groupName;
  set groupName(String? groupName) => _$this._groupName = groupName;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  String? _userName;
  String? get userName => _$this._userName;
  set userName(String? userName) => _$this._userName = userName;

  String? _comment;
  String? get comment => _$this._comment;
  set comment(String? comment) => _$this._comment = comment;

  String? _severityId;
  String? get severityId => _$this._severityId;
  set severityId(String? severityId) => _$this._severityId = severityId;

  String? _severityName;
  String? get severityName => _$this._severityName;
  set severityName(String? severityName) => _$this._severityName = severityName;

  WorkOrderStatusBuilder();

  WorkOrderStatusBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _sectionName = $v.sectionName;
      _sectionDesc = $v.sectionDesc;
      _sectionStatus = $v.sectionStatus;
      _sectionStatusMaterial = $v.sectionStatusMaterial;
      _sectionStatusMaterialId = $v.sectionStatusMaterialId;
      _sectionComment = $v.sectionComment;
      _groupId = $v.groupId;
      _groupName = $v.groupName;
      _userId = $v.userId;
      _userName = $v.userName;
      _comment = $v.comment;
      _severityId = $v.severityId;
      _severityName = $v.severityName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WorkOrderStatus other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$WorkOrderStatus;
  }

  @override
  void update(void Function(WorkOrderStatusBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WorkOrderStatus build() => _build();

  _$WorkOrderStatus _build() {
    final _$result = _$v ??
        new _$WorkOrderStatus._(
          sectionName: sectionName,
          sectionDesc: sectionDesc,
          sectionStatus: sectionStatus,
          sectionStatusMaterial: sectionStatusMaterial,
          sectionStatusMaterialId: sectionStatusMaterialId,
          sectionComment: sectionComment,
          groupId: groupId,
          groupName: groupName,
          userId: userId,
          userName: userName,
          comment: comment,
          severityId: severityId,
          severityName: severityName,
        );
    replace(_$result);
    return _$result;
  }
}

class _$WorkOrderDetail extends WorkOrderDetail {
  @override
  final String woTaskId;
  @override
  final String woTaskNo;
  @override
  final String woTaskRequestNo;
  @override
  final String woTaskReportedBy;
  @override
  final String woTaskTimeResponded;
  @override
  final String woTaskCategory;
  @override
  final String? woTaskCategoryInit;
  @override
  final String woTaskClient;
  @override
  final String woTaskLocation;
  @override
  final String woTaskComplaint;
  @override
  final String woTaskStatus;
  @override
  final String woTaskPhoneNo;
  @override
  final String woTaskEmail;
  @override
  final String? assetNo;
  @override
  final String zoneName;
  @override
  final BuiltList<ComplaintImage> complaintImages;

  factory _$WorkOrderDetail([void Function(WorkOrderDetailBuilder)? updates]) =>
      (new WorkOrderDetailBuilder()..update(updates))._build();

  _$WorkOrderDetail._(
      {required this.woTaskId,
      required this.woTaskNo,
      required this.woTaskRequestNo,
      required this.woTaskReportedBy,
      required this.woTaskTimeResponded,
      required this.woTaskCategory,
      this.woTaskCategoryInit,
      required this.woTaskClient,
      required this.woTaskLocation,
      required this.woTaskComplaint,
      required this.woTaskStatus,
      required this.woTaskPhoneNo,
      required this.woTaskEmail,
      this.assetNo,
      required this.zoneName,
      required this.complaintImages})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        woTaskId, r'WorkOrderDetail', 'woTaskId');
    BuiltValueNullFieldError.checkNotNull(
        woTaskNo, r'WorkOrderDetail', 'woTaskNo');
    BuiltValueNullFieldError.checkNotNull(
        woTaskRequestNo, r'WorkOrderDetail', 'woTaskRequestNo');
    BuiltValueNullFieldError.checkNotNull(
        woTaskReportedBy, r'WorkOrderDetail', 'woTaskReportedBy');
    BuiltValueNullFieldError.checkNotNull(
        woTaskTimeResponded, r'WorkOrderDetail', 'woTaskTimeResponded');
    BuiltValueNullFieldError.checkNotNull(
        woTaskCategory, r'WorkOrderDetail', 'woTaskCategory');
    BuiltValueNullFieldError.checkNotNull(
        woTaskClient, r'WorkOrderDetail', 'woTaskClient');
    BuiltValueNullFieldError.checkNotNull(
        woTaskLocation, r'WorkOrderDetail', 'woTaskLocation');
    BuiltValueNullFieldError.checkNotNull(
        woTaskComplaint, r'WorkOrderDetail', 'woTaskComplaint');
    BuiltValueNullFieldError.checkNotNull(
        woTaskStatus, r'WorkOrderDetail', 'woTaskStatus');
    BuiltValueNullFieldError.checkNotNull(
        woTaskPhoneNo, r'WorkOrderDetail', 'woTaskPhoneNo');
    BuiltValueNullFieldError.checkNotNull(
        woTaskEmail, r'WorkOrderDetail', 'woTaskEmail');
    BuiltValueNullFieldError.checkNotNull(
        zoneName, r'WorkOrderDetail', 'zoneName');
    BuiltValueNullFieldError.checkNotNull(
        complaintImages, r'WorkOrderDetail', 'complaintImages');
  }

  @override
  WorkOrderDetail rebuild(void Function(WorkOrderDetailBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WorkOrderDetailBuilder toBuilder() =>
      new WorkOrderDetailBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WorkOrderDetail &&
        woTaskId == other.woTaskId &&
        woTaskNo == other.woTaskNo &&
        woTaskRequestNo == other.woTaskRequestNo &&
        woTaskReportedBy == other.woTaskReportedBy &&
        woTaskTimeResponded == other.woTaskTimeResponded &&
        woTaskCategory == other.woTaskCategory &&
        woTaskCategoryInit == other.woTaskCategoryInit &&
        woTaskClient == other.woTaskClient &&
        woTaskLocation == other.woTaskLocation &&
        woTaskComplaint == other.woTaskComplaint &&
        woTaskStatus == other.woTaskStatus &&
        woTaskPhoneNo == other.woTaskPhoneNo &&
        woTaskEmail == other.woTaskEmail &&
        assetNo == other.assetNo &&
        zoneName == other.zoneName &&
        complaintImages == other.complaintImages;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, woTaskId.hashCode);
    _$hash = $jc(_$hash, woTaskNo.hashCode);
    _$hash = $jc(_$hash, woTaskRequestNo.hashCode);
    _$hash = $jc(_$hash, woTaskReportedBy.hashCode);
    _$hash = $jc(_$hash, woTaskTimeResponded.hashCode);
    _$hash = $jc(_$hash, woTaskCategory.hashCode);
    _$hash = $jc(_$hash, woTaskCategoryInit.hashCode);
    _$hash = $jc(_$hash, woTaskClient.hashCode);
    _$hash = $jc(_$hash, woTaskLocation.hashCode);
    _$hash = $jc(_$hash, woTaskComplaint.hashCode);
    _$hash = $jc(_$hash, woTaskStatus.hashCode);
    _$hash = $jc(_$hash, woTaskPhoneNo.hashCode);
    _$hash = $jc(_$hash, woTaskEmail.hashCode);
    _$hash = $jc(_$hash, assetNo.hashCode);
    _$hash = $jc(_$hash, zoneName.hashCode);
    _$hash = $jc(_$hash, complaintImages.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WorkOrderDetail')
          ..add('woTaskId', woTaskId)
          ..add('woTaskNo', woTaskNo)
          ..add('woTaskRequestNo', woTaskRequestNo)
          ..add('woTaskReportedBy', woTaskReportedBy)
          ..add('woTaskTimeResponded', woTaskTimeResponded)
          ..add('woTaskCategory', woTaskCategory)
          ..add('woTaskCategoryInit', woTaskCategoryInit)
          ..add('woTaskClient', woTaskClient)
          ..add('woTaskLocation', woTaskLocation)
          ..add('woTaskComplaint', woTaskComplaint)
          ..add('woTaskStatus', woTaskStatus)
          ..add('woTaskPhoneNo', woTaskPhoneNo)
          ..add('woTaskEmail', woTaskEmail)
          ..add('assetNo', assetNo)
          ..add('zoneName', zoneName)
          ..add('complaintImages', complaintImages))
        .toString();
  }
}

class WorkOrderDetailBuilder
    implements Builder<WorkOrderDetail, WorkOrderDetailBuilder> {
  _$WorkOrderDetail? _$v;

  String? _woTaskId;
  String? get woTaskId => _$this._woTaskId;
  set woTaskId(String? woTaskId) => _$this._woTaskId = woTaskId;

  String? _woTaskNo;
  String? get woTaskNo => _$this._woTaskNo;
  set woTaskNo(String? woTaskNo) => _$this._woTaskNo = woTaskNo;

  String? _woTaskRequestNo;
  String? get woTaskRequestNo => _$this._woTaskRequestNo;
  set woTaskRequestNo(String? woTaskRequestNo) =>
      _$this._woTaskRequestNo = woTaskRequestNo;

  String? _woTaskReportedBy;
  String? get woTaskReportedBy => _$this._woTaskReportedBy;
  set woTaskReportedBy(String? woTaskReportedBy) =>
      _$this._woTaskReportedBy = woTaskReportedBy;

  String? _woTaskTimeResponded;
  String? get woTaskTimeResponded => _$this._woTaskTimeResponded;
  set woTaskTimeResponded(String? woTaskTimeResponded) =>
      _$this._woTaskTimeResponded = woTaskTimeResponded;

  String? _woTaskCategory;
  String? get woTaskCategory => _$this._woTaskCategory;
  set woTaskCategory(String? woTaskCategory) =>
      _$this._woTaskCategory = woTaskCategory;

  String? _woTaskCategoryInit;
  String? get woTaskCategoryInit => _$this._woTaskCategoryInit;
  set woTaskCategoryInit(String? woTaskCategoryInit) =>
      _$this._woTaskCategoryInit = woTaskCategoryInit;

  String? _woTaskClient;
  String? get woTaskClient => _$this._woTaskClient;
  set woTaskClient(String? woTaskClient) => _$this._woTaskClient = woTaskClient;

  String? _woTaskLocation;
  String? get woTaskLocation => _$this._woTaskLocation;
  set woTaskLocation(String? woTaskLocation) =>
      _$this._woTaskLocation = woTaskLocation;

  String? _woTaskComplaint;
  String? get woTaskComplaint => _$this._woTaskComplaint;
  set woTaskComplaint(String? woTaskComplaint) =>
      _$this._woTaskComplaint = woTaskComplaint;

  String? _woTaskStatus;
  String? get woTaskStatus => _$this._woTaskStatus;
  set woTaskStatus(String? woTaskStatus) => _$this._woTaskStatus = woTaskStatus;

  String? _woTaskPhoneNo;
  String? get woTaskPhoneNo => _$this._woTaskPhoneNo;
  set woTaskPhoneNo(String? woTaskPhoneNo) =>
      _$this._woTaskPhoneNo = woTaskPhoneNo;

  String? _woTaskEmail;
  String? get woTaskEmail => _$this._woTaskEmail;
  set woTaskEmail(String? woTaskEmail) => _$this._woTaskEmail = woTaskEmail;

  String? _assetNo;
  String? get assetNo => _$this._assetNo;
  set assetNo(String? assetNo) => _$this._assetNo = assetNo;

  String? _zoneName;
  String? get zoneName => _$this._zoneName;
  set zoneName(String? zoneName) => _$this._zoneName = zoneName;

  ListBuilder<ComplaintImage>? _complaintImages;
  ListBuilder<ComplaintImage> get complaintImages =>
      _$this._complaintImages ??= new ListBuilder<ComplaintImage>();
  set complaintImages(ListBuilder<ComplaintImage>? complaintImages) =>
      _$this._complaintImages = complaintImages;

  WorkOrderDetailBuilder();

  WorkOrderDetailBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _woTaskId = $v.woTaskId;
      _woTaskNo = $v.woTaskNo;
      _woTaskRequestNo = $v.woTaskRequestNo;
      _woTaskReportedBy = $v.woTaskReportedBy;
      _woTaskTimeResponded = $v.woTaskTimeResponded;
      _woTaskCategory = $v.woTaskCategory;
      _woTaskCategoryInit = $v.woTaskCategoryInit;
      _woTaskClient = $v.woTaskClient;
      _woTaskLocation = $v.woTaskLocation;
      _woTaskComplaint = $v.woTaskComplaint;
      _woTaskStatus = $v.woTaskStatus;
      _woTaskPhoneNo = $v.woTaskPhoneNo;
      _woTaskEmail = $v.woTaskEmail;
      _assetNo = $v.assetNo;
      _zoneName = $v.zoneName;
      _complaintImages = $v.complaintImages.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WorkOrderDetail other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$WorkOrderDetail;
  }

  @override
  void update(void Function(WorkOrderDetailBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WorkOrderDetail build() => _build();

  _$WorkOrderDetail _build() {
    _$WorkOrderDetail _$result;
    try {
      _$result = _$v ??
          new _$WorkOrderDetail._(
            woTaskId: BuiltValueNullFieldError.checkNotNull(
                woTaskId, r'WorkOrderDetail', 'woTaskId'),
            woTaskNo: BuiltValueNullFieldError.checkNotNull(
                woTaskNo, r'WorkOrderDetail', 'woTaskNo'),
            woTaskRequestNo: BuiltValueNullFieldError.checkNotNull(
                woTaskRequestNo, r'WorkOrderDetail', 'woTaskRequestNo'),
            woTaskReportedBy: BuiltValueNullFieldError.checkNotNull(
                woTaskReportedBy, r'WorkOrderDetail', 'woTaskReportedBy'),
            woTaskTimeResponded: BuiltValueNullFieldError.checkNotNull(
                woTaskTimeResponded, r'WorkOrderDetail', 'woTaskTimeResponded'),
            woTaskCategory: BuiltValueNullFieldError.checkNotNull(
                woTaskCategory, r'WorkOrderDetail', 'woTaskCategory'),
            woTaskCategoryInit: woTaskCategoryInit,
            woTaskClient: BuiltValueNullFieldError.checkNotNull(
                woTaskClient, r'WorkOrderDetail', 'woTaskClient'),
            woTaskLocation: BuiltValueNullFieldError.checkNotNull(
                woTaskLocation, r'WorkOrderDetail', 'woTaskLocation'),
            woTaskComplaint: BuiltValueNullFieldError.checkNotNull(
                woTaskComplaint, r'WorkOrderDetail', 'woTaskComplaint'),
            woTaskStatus: BuiltValueNullFieldError.checkNotNull(
                woTaskStatus, r'WorkOrderDetail', 'woTaskStatus'),
            woTaskPhoneNo: BuiltValueNullFieldError.checkNotNull(
                woTaskPhoneNo, r'WorkOrderDetail', 'woTaskPhoneNo'),
            woTaskEmail: BuiltValueNullFieldError.checkNotNull(
                woTaskEmail, r'WorkOrderDetail', 'woTaskEmail'),
            assetNo: assetNo,
            zoneName: BuiltValueNullFieldError.checkNotNull(
                zoneName, r'WorkOrderDetail', 'zoneName'),
            complaintImages: complaintImages.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'complaintImages';
        complaintImages.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'WorkOrderDetail', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$ComplaintImage extends ComplaintImage {
  @override
  final String woTaskUploadId;
  @override
  final String woTaskUploadType;
  @override
  final String woTaskId;
  @override
  final String woTaskUploadLongitude;
  @override
  final String woTaskUploadLatitude;
  @override
  final String woTaskUploadTimestamp;
  @override
  final String woTaskUploadDesc;
  @override
  final String uploadId;
  @override
  final String uploadName;
  @override
  final String documentDesc;
  @override
  final String documentFilename;
  @override
  final String documentSrc;

  factory _$ComplaintImage([void Function(ComplaintImageBuilder)? updates]) =>
      (new ComplaintImageBuilder()..update(updates))._build();

  _$ComplaintImage._(
      {required this.woTaskUploadId,
      required this.woTaskUploadType,
      required this.woTaskId,
      required this.woTaskUploadLongitude,
      required this.woTaskUploadLatitude,
      required this.woTaskUploadTimestamp,
      required this.woTaskUploadDesc,
      required this.uploadId,
      required this.uploadName,
      required this.documentDesc,
      required this.documentFilename,
      required this.documentSrc})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        woTaskUploadId, r'ComplaintImage', 'woTaskUploadId');
    BuiltValueNullFieldError.checkNotNull(
        woTaskUploadType, r'ComplaintImage', 'woTaskUploadType');
    BuiltValueNullFieldError.checkNotNull(
        woTaskId, r'ComplaintImage', 'woTaskId');
    BuiltValueNullFieldError.checkNotNull(
        woTaskUploadLongitude, r'ComplaintImage', 'woTaskUploadLongitude');
    BuiltValueNullFieldError.checkNotNull(
        woTaskUploadLatitude, r'ComplaintImage', 'woTaskUploadLatitude');
    BuiltValueNullFieldError.checkNotNull(
        woTaskUploadTimestamp, r'ComplaintImage', 'woTaskUploadTimestamp');
    BuiltValueNullFieldError.checkNotNull(
        woTaskUploadDesc, r'ComplaintImage', 'woTaskUploadDesc');
    BuiltValueNullFieldError.checkNotNull(
        uploadId, r'ComplaintImage', 'uploadId');
    BuiltValueNullFieldError.checkNotNull(
        uploadName, r'ComplaintImage', 'uploadName');
    BuiltValueNullFieldError.checkNotNull(
        documentDesc, r'ComplaintImage', 'documentDesc');
    BuiltValueNullFieldError.checkNotNull(
        documentFilename, r'ComplaintImage', 'documentFilename');
    BuiltValueNullFieldError.checkNotNull(
        documentSrc, r'ComplaintImage', 'documentSrc');
  }

  @override
  ComplaintImage rebuild(void Function(ComplaintImageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ComplaintImageBuilder toBuilder() =>
      new ComplaintImageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ComplaintImage &&
        woTaskUploadId == other.woTaskUploadId &&
        woTaskUploadType == other.woTaskUploadType &&
        woTaskId == other.woTaskId &&
        woTaskUploadLongitude == other.woTaskUploadLongitude &&
        woTaskUploadLatitude == other.woTaskUploadLatitude &&
        woTaskUploadTimestamp == other.woTaskUploadTimestamp &&
        woTaskUploadDesc == other.woTaskUploadDesc &&
        uploadId == other.uploadId &&
        uploadName == other.uploadName &&
        documentDesc == other.documentDesc &&
        documentFilename == other.documentFilename &&
        documentSrc == other.documentSrc;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, woTaskUploadId.hashCode);
    _$hash = $jc(_$hash, woTaskUploadType.hashCode);
    _$hash = $jc(_$hash, woTaskId.hashCode);
    _$hash = $jc(_$hash, woTaskUploadLongitude.hashCode);
    _$hash = $jc(_$hash, woTaskUploadLatitude.hashCode);
    _$hash = $jc(_$hash, woTaskUploadTimestamp.hashCode);
    _$hash = $jc(_$hash, woTaskUploadDesc.hashCode);
    _$hash = $jc(_$hash, uploadId.hashCode);
    _$hash = $jc(_$hash, uploadName.hashCode);
    _$hash = $jc(_$hash, documentDesc.hashCode);
    _$hash = $jc(_$hash, documentFilename.hashCode);
    _$hash = $jc(_$hash, documentSrc.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ComplaintImage')
          ..add('woTaskUploadId', woTaskUploadId)
          ..add('woTaskUploadType', woTaskUploadType)
          ..add('woTaskId', woTaskId)
          ..add('woTaskUploadLongitude', woTaskUploadLongitude)
          ..add('woTaskUploadLatitude', woTaskUploadLatitude)
          ..add('woTaskUploadTimestamp', woTaskUploadTimestamp)
          ..add('woTaskUploadDesc', woTaskUploadDesc)
          ..add('uploadId', uploadId)
          ..add('uploadName', uploadName)
          ..add('documentDesc', documentDesc)
          ..add('documentFilename', documentFilename)
          ..add('documentSrc', documentSrc))
        .toString();
  }
}

class ComplaintImageBuilder
    implements Builder<ComplaintImage, ComplaintImageBuilder> {
  _$ComplaintImage? _$v;

  String? _woTaskUploadId;
  String? get woTaskUploadId => _$this._woTaskUploadId;
  set woTaskUploadId(String? woTaskUploadId) =>
      _$this._woTaskUploadId = woTaskUploadId;

  String? _woTaskUploadType;
  String? get woTaskUploadType => _$this._woTaskUploadType;
  set woTaskUploadType(String? woTaskUploadType) =>
      _$this._woTaskUploadType = woTaskUploadType;

  String? _woTaskId;
  String? get woTaskId => _$this._woTaskId;
  set woTaskId(String? woTaskId) => _$this._woTaskId = woTaskId;

  String? _woTaskUploadLongitude;
  String? get woTaskUploadLongitude => _$this._woTaskUploadLongitude;
  set woTaskUploadLongitude(String? woTaskUploadLongitude) =>
      _$this._woTaskUploadLongitude = woTaskUploadLongitude;

  String? _woTaskUploadLatitude;
  String? get woTaskUploadLatitude => _$this._woTaskUploadLatitude;
  set woTaskUploadLatitude(String? woTaskUploadLatitude) =>
      _$this._woTaskUploadLatitude = woTaskUploadLatitude;

  String? _woTaskUploadTimestamp;
  String? get woTaskUploadTimestamp => _$this._woTaskUploadTimestamp;
  set woTaskUploadTimestamp(String? woTaskUploadTimestamp) =>
      _$this._woTaskUploadTimestamp = woTaskUploadTimestamp;

  String? _woTaskUploadDesc;
  String? get woTaskUploadDesc => _$this._woTaskUploadDesc;
  set woTaskUploadDesc(String? woTaskUploadDesc) =>
      _$this._woTaskUploadDesc = woTaskUploadDesc;

  String? _uploadId;
  String? get uploadId => _$this._uploadId;
  set uploadId(String? uploadId) => _$this._uploadId = uploadId;

  String? _uploadName;
  String? get uploadName => _$this._uploadName;
  set uploadName(String? uploadName) => _$this._uploadName = uploadName;

  String? _documentDesc;
  String? get documentDesc => _$this._documentDesc;
  set documentDesc(String? documentDesc) => _$this._documentDesc = documentDesc;

  String? _documentFilename;
  String? get documentFilename => _$this._documentFilename;
  set documentFilename(String? documentFilename) =>
      _$this._documentFilename = documentFilename;

  String? _documentSrc;
  String? get documentSrc => _$this._documentSrc;
  set documentSrc(String? documentSrc) => _$this._documentSrc = documentSrc;

  ComplaintImageBuilder();

  ComplaintImageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _woTaskUploadId = $v.woTaskUploadId;
      _woTaskUploadType = $v.woTaskUploadType;
      _woTaskId = $v.woTaskId;
      _woTaskUploadLongitude = $v.woTaskUploadLongitude;
      _woTaskUploadLatitude = $v.woTaskUploadLatitude;
      _woTaskUploadTimestamp = $v.woTaskUploadTimestamp;
      _woTaskUploadDesc = $v.woTaskUploadDesc;
      _uploadId = $v.uploadId;
      _uploadName = $v.uploadName;
      _documentDesc = $v.documentDesc;
      _documentFilename = $v.documentFilename;
      _documentSrc = $v.documentSrc;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ComplaintImage other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ComplaintImage;
  }

  @override
  void update(void Function(ComplaintImageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ComplaintImage build() => _build();

  _$ComplaintImage _build() {
    final _$result = _$v ??
        new _$ComplaintImage._(
          woTaskUploadId: BuiltValueNullFieldError.checkNotNull(
              woTaskUploadId, r'ComplaintImage', 'woTaskUploadId'),
          woTaskUploadType: BuiltValueNullFieldError.checkNotNull(
              woTaskUploadType, r'ComplaintImage', 'woTaskUploadType'),
          woTaskId: BuiltValueNullFieldError.checkNotNull(
              woTaskId, r'ComplaintImage', 'woTaskId'),
          woTaskUploadLongitude: BuiltValueNullFieldError.checkNotNull(
              woTaskUploadLongitude,
              r'ComplaintImage',
              'woTaskUploadLongitude'),
          woTaskUploadLatitude: BuiltValueNullFieldError.checkNotNull(
              woTaskUploadLatitude, r'ComplaintImage', 'woTaskUploadLatitude'),
          woTaskUploadTimestamp: BuiltValueNullFieldError.checkNotNull(
              woTaskUploadTimestamp,
              r'ComplaintImage',
              'woTaskUploadTimestamp'),
          woTaskUploadDesc: BuiltValueNullFieldError.checkNotNull(
              woTaskUploadDesc, r'ComplaintImage', 'woTaskUploadDesc'),
          uploadId: BuiltValueNullFieldError.checkNotNull(
              uploadId, r'ComplaintImage', 'uploadId'),
          uploadName: BuiltValueNullFieldError.checkNotNull(
              uploadName, r'ComplaintImage', 'uploadName'),
          documentDesc: BuiltValueNullFieldError.checkNotNull(
              documentDesc, r'ComplaintImage', 'documentDesc'),
          documentFilename: BuiltValueNullFieldError.checkNotNull(
              documentFilename, r'ComplaintImage', 'documentFilename'),
          documentSrc: BuiltValueNullFieldError.checkNotNull(
              documentSrc, r'ComplaintImage', 'documentSrc'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$TechnicianDetails extends TechnicianDetails {
  @override
  final String name;
  @override
  final String phoneNo;
  @override
  final String email;
  @override
  final String group;
  @override
  final int totalCurrentTask;
  @override
  final BuiltList<TechnicianTask> currentTask;

  factory _$TechnicianDetails(
          [void Function(TechnicianDetailsBuilder)? updates]) =>
      (new TechnicianDetailsBuilder()..update(updates))._build();

  _$TechnicianDetails._(
      {required this.name,
      required this.phoneNo,
      required this.email,
      required this.group,
      required this.totalCurrentTask,
      required this.currentTask})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(name, r'TechnicianDetails', 'name');
    BuiltValueNullFieldError.checkNotNull(
        phoneNo, r'TechnicianDetails', 'phoneNo');
    BuiltValueNullFieldError.checkNotNull(email, r'TechnicianDetails', 'email');
    BuiltValueNullFieldError.checkNotNull(group, r'TechnicianDetails', 'group');
    BuiltValueNullFieldError.checkNotNull(
        totalCurrentTask, r'TechnicianDetails', 'totalCurrentTask');
    BuiltValueNullFieldError.checkNotNull(
        currentTask, r'TechnicianDetails', 'currentTask');
  }

  @override
  TechnicianDetails rebuild(void Function(TechnicianDetailsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TechnicianDetailsBuilder toBuilder() =>
      new TechnicianDetailsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TechnicianDetails &&
        name == other.name &&
        phoneNo == other.phoneNo &&
        email == other.email &&
        group == other.group &&
        totalCurrentTask == other.totalCurrentTask &&
        currentTask == other.currentTask;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, phoneNo.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, group.hashCode);
    _$hash = $jc(_$hash, totalCurrentTask.hashCode);
    _$hash = $jc(_$hash, currentTask.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TechnicianDetails')
          ..add('name', name)
          ..add('phoneNo', phoneNo)
          ..add('email', email)
          ..add('group', group)
          ..add('totalCurrentTask', totalCurrentTask)
          ..add('currentTask', currentTask))
        .toString();
  }
}

class TechnicianDetailsBuilder
    implements Builder<TechnicianDetails, TechnicianDetailsBuilder> {
  _$TechnicianDetails? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _phoneNo;
  String? get phoneNo => _$this._phoneNo;
  set phoneNo(String? phoneNo) => _$this._phoneNo = phoneNo;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _group;
  String? get group => _$this._group;
  set group(String? group) => _$this._group = group;

  int? _totalCurrentTask;
  int? get totalCurrentTask => _$this._totalCurrentTask;
  set totalCurrentTask(int? totalCurrentTask) =>
      _$this._totalCurrentTask = totalCurrentTask;

  ListBuilder<TechnicianTask>? _currentTask;
  ListBuilder<TechnicianTask> get currentTask =>
      _$this._currentTask ??= new ListBuilder<TechnicianTask>();
  set currentTask(ListBuilder<TechnicianTask>? currentTask) =>
      _$this._currentTask = currentTask;

  TechnicianDetailsBuilder();

  TechnicianDetailsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _phoneNo = $v.phoneNo;
      _email = $v.email;
      _group = $v.group;
      _totalCurrentTask = $v.totalCurrentTask;
      _currentTask = $v.currentTask.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TechnicianDetails other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$TechnicianDetails;
  }

  @override
  void update(void Function(TechnicianDetailsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TechnicianDetails build() => _build();

  _$TechnicianDetails _build() {
    _$TechnicianDetails _$result;
    try {
      _$result = _$v ??
          new _$TechnicianDetails._(
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'TechnicianDetails', 'name'),
            phoneNo: BuiltValueNullFieldError.checkNotNull(
                phoneNo, r'TechnicianDetails', 'phoneNo'),
            email: BuiltValueNullFieldError.checkNotNull(
                email, r'TechnicianDetails', 'email'),
            group: BuiltValueNullFieldError.checkNotNull(
                group, r'TechnicianDetails', 'group'),
            totalCurrentTask: BuiltValueNullFieldError.checkNotNull(
                totalCurrentTask, r'TechnicianDetails', 'totalCurrentTask'),
            currentTask: currentTask.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'currentTask';
        currentTask.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'TechnicianDetails', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$TechnicianTask extends TechnicianTask {
  @override
  final String woTaskNo;
  @override
  final String dateReceived;

  factory _$TechnicianTask([void Function(TechnicianTaskBuilder)? updates]) =>
      (new TechnicianTaskBuilder()..update(updates))._build();

  _$TechnicianTask._({required this.woTaskNo, required this.dateReceived})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        woTaskNo, r'TechnicianTask', 'woTaskNo');
    BuiltValueNullFieldError.checkNotNull(
        dateReceived, r'TechnicianTask', 'dateReceived');
  }

  @override
  TechnicianTask rebuild(void Function(TechnicianTaskBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TechnicianTaskBuilder toBuilder() =>
      new TechnicianTaskBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TechnicianTask &&
        woTaskNo == other.woTaskNo &&
        dateReceived == other.dateReceived;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, woTaskNo.hashCode);
    _$hash = $jc(_$hash, dateReceived.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TechnicianTask')
          ..add('woTaskNo', woTaskNo)
          ..add('dateReceived', dateReceived))
        .toString();
  }
}

class TechnicianTaskBuilder
    implements Builder<TechnicianTask, TechnicianTaskBuilder> {
  _$TechnicianTask? _$v;

  String? _woTaskNo;
  String? get woTaskNo => _$this._woTaskNo;
  set woTaskNo(String? woTaskNo) => _$this._woTaskNo = woTaskNo;

  String? _dateReceived;
  String? get dateReceived => _$this._dateReceived;
  set dateReceived(String? dateReceived) => _$this._dateReceived = dateReceived;

  TechnicianTaskBuilder();

  TechnicianTaskBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _woTaskNo = $v.woTaskNo;
      _dateReceived = $v.dateReceived;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TechnicianTask other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$TechnicianTask;
  }

  @override
  void update(void Function(TechnicianTaskBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TechnicianTask build() => _build();

  _$TechnicianTask _build() {
    final _$result = _$v ??
        new _$TechnicianTask._(
          woTaskNo: BuiltValueNullFieldError.checkNotNull(
              woTaskNo, r'TechnicianTask', 'woTaskNo'),
          dateReceived: BuiltValueNullFieldError.checkNotNull(
              dateReceived, r'TechnicianTask', 'dateReceived'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$TechnicianImageRepair extends TechnicianImageRepair {
  @override
  final String woTaskUploadId;
  @override
  final String woTaskUploadType;
  @override
  final String woTaskId;
  @override
  final String woTaskUploadLongitude;
  @override
  final String woTaskUploadLatitude;
  @override
  final String woTaskUploadTimestamp;
  @override
  final String woTaskUploadDesc;
  @override
  final String uploadId;
  @override
  final String uploadName;
  @override
  final String documentDesc;
  @override
  final String documentFilename;
  @override
  final String documentSrc;

  factory _$TechnicianImageRepair(
          [void Function(TechnicianImageRepairBuilder)? updates]) =>
      (new TechnicianImageRepairBuilder()..update(updates))._build();

  _$TechnicianImageRepair._(
      {required this.woTaskUploadId,
      required this.woTaskUploadType,
      required this.woTaskId,
      required this.woTaskUploadLongitude,
      required this.woTaskUploadLatitude,
      required this.woTaskUploadTimestamp,
      required this.woTaskUploadDesc,
      required this.uploadId,
      required this.uploadName,
      required this.documentDesc,
      required this.documentFilename,
      required this.documentSrc})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        woTaskUploadId, r'TechnicianImageRepair', 'woTaskUploadId');
    BuiltValueNullFieldError.checkNotNull(
        woTaskUploadType, r'TechnicianImageRepair', 'woTaskUploadType');
    BuiltValueNullFieldError.checkNotNull(
        woTaskId, r'TechnicianImageRepair', 'woTaskId');
    BuiltValueNullFieldError.checkNotNull(woTaskUploadLongitude,
        r'TechnicianImageRepair', 'woTaskUploadLongitude');
    BuiltValueNullFieldError.checkNotNull(
        woTaskUploadLatitude, r'TechnicianImageRepair', 'woTaskUploadLatitude');
    BuiltValueNullFieldError.checkNotNull(woTaskUploadTimestamp,
        r'TechnicianImageRepair', 'woTaskUploadTimestamp');
    BuiltValueNullFieldError.checkNotNull(
        woTaskUploadDesc, r'TechnicianImageRepair', 'woTaskUploadDesc');
    BuiltValueNullFieldError.checkNotNull(
        uploadId, r'TechnicianImageRepair', 'uploadId');
    BuiltValueNullFieldError.checkNotNull(
        uploadName, r'TechnicianImageRepair', 'uploadName');
    BuiltValueNullFieldError.checkNotNull(
        documentDesc, r'TechnicianImageRepair', 'documentDesc');
    BuiltValueNullFieldError.checkNotNull(
        documentFilename, r'TechnicianImageRepair', 'documentFilename');
    BuiltValueNullFieldError.checkNotNull(
        documentSrc, r'TechnicianImageRepair', 'documentSrc');
  }

  @override
  TechnicianImageRepair rebuild(
          void Function(TechnicianImageRepairBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TechnicianImageRepairBuilder toBuilder() =>
      new TechnicianImageRepairBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TechnicianImageRepair &&
        woTaskUploadId == other.woTaskUploadId &&
        woTaskUploadType == other.woTaskUploadType &&
        woTaskId == other.woTaskId &&
        woTaskUploadLongitude == other.woTaskUploadLongitude &&
        woTaskUploadLatitude == other.woTaskUploadLatitude &&
        woTaskUploadTimestamp == other.woTaskUploadTimestamp &&
        woTaskUploadDesc == other.woTaskUploadDesc &&
        uploadId == other.uploadId &&
        uploadName == other.uploadName &&
        documentDesc == other.documentDesc &&
        documentFilename == other.documentFilename &&
        documentSrc == other.documentSrc;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, woTaskUploadId.hashCode);
    _$hash = $jc(_$hash, woTaskUploadType.hashCode);
    _$hash = $jc(_$hash, woTaskId.hashCode);
    _$hash = $jc(_$hash, woTaskUploadLongitude.hashCode);
    _$hash = $jc(_$hash, woTaskUploadLatitude.hashCode);
    _$hash = $jc(_$hash, woTaskUploadTimestamp.hashCode);
    _$hash = $jc(_$hash, woTaskUploadDesc.hashCode);
    _$hash = $jc(_$hash, uploadId.hashCode);
    _$hash = $jc(_$hash, uploadName.hashCode);
    _$hash = $jc(_$hash, documentDesc.hashCode);
    _$hash = $jc(_$hash, documentFilename.hashCode);
    _$hash = $jc(_$hash, documentSrc.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TechnicianImageRepair')
          ..add('woTaskUploadId', woTaskUploadId)
          ..add('woTaskUploadType', woTaskUploadType)
          ..add('woTaskId', woTaskId)
          ..add('woTaskUploadLongitude', woTaskUploadLongitude)
          ..add('woTaskUploadLatitude', woTaskUploadLatitude)
          ..add('woTaskUploadTimestamp', woTaskUploadTimestamp)
          ..add('woTaskUploadDesc', woTaskUploadDesc)
          ..add('uploadId', uploadId)
          ..add('uploadName', uploadName)
          ..add('documentDesc', documentDesc)
          ..add('documentFilename', documentFilename)
          ..add('documentSrc', documentSrc))
        .toString();
  }
}

class TechnicianImageRepairBuilder
    implements Builder<TechnicianImageRepair, TechnicianImageRepairBuilder> {
  _$TechnicianImageRepair? _$v;

  String? _woTaskUploadId;
  String? get woTaskUploadId => _$this._woTaskUploadId;
  set woTaskUploadId(String? woTaskUploadId) =>
      _$this._woTaskUploadId = woTaskUploadId;

  String? _woTaskUploadType;
  String? get woTaskUploadType => _$this._woTaskUploadType;
  set woTaskUploadType(String? woTaskUploadType) =>
      _$this._woTaskUploadType = woTaskUploadType;

  String? _woTaskId;
  String? get woTaskId => _$this._woTaskId;
  set woTaskId(String? woTaskId) => _$this._woTaskId = woTaskId;

  String? _woTaskUploadLongitude;
  String? get woTaskUploadLongitude => _$this._woTaskUploadLongitude;
  set woTaskUploadLongitude(String? woTaskUploadLongitude) =>
      _$this._woTaskUploadLongitude = woTaskUploadLongitude;

  String? _woTaskUploadLatitude;
  String? get woTaskUploadLatitude => _$this._woTaskUploadLatitude;
  set woTaskUploadLatitude(String? woTaskUploadLatitude) =>
      _$this._woTaskUploadLatitude = woTaskUploadLatitude;

  String? _woTaskUploadTimestamp;
  String? get woTaskUploadTimestamp => _$this._woTaskUploadTimestamp;
  set woTaskUploadTimestamp(String? woTaskUploadTimestamp) =>
      _$this._woTaskUploadTimestamp = woTaskUploadTimestamp;

  String? _woTaskUploadDesc;
  String? get woTaskUploadDesc => _$this._woTaskUploadDesc;
  set woTaskUploadDesc(String? woTaskUploadDesc) =>
      _$this._woTaskUploadDesc = woTaskUploadDesc;

  String? _uploadId;
  String? get uploadId => _$this._uploadId;
  set uploadId(String? uploadId) => _$this._uploadId = uploadId;

  String? _uploadName;
  String? get uploadName => _$this._uploadName;
  set uploadName(String? uploadName) => _$this._uploadName = uploadName;

  String? _documentDesc;
  String? get documentDesc => _$this._documentDesc;
  set documentDesc(String? documentDesc) => _$this._documentDesc = documentDesc;

  String? _documentFilename;
  String? get documentFilename => _$this._documentFilename;
  set documentFilename(String? documentFilename) =>
      _$this._documentFilename = documentFilename;

  String? _documentSrc;
  String? get documentSrc => _$this._documentSrc;
  set documentSrc(String? documentSrc) => _$this._documentSrc = documentSrc;

  TechnicianImageRepairBuilder();

  TechnicianImageRepairBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _woTaskUploadId = $v.woTaskUploadId;
      _woTaskUploadType = $v.woTaskUploadType;
      _woTaskId = $v.woTaskId;
      _woTaskUploadLongitude = $v.woTaskUploadLongitude;
      _woTaskUploadLatitude = $v.woTaskUploadLatitude;
      _woTaskUploadTimestamp = $v.woTaskUploadTimestamp;
      _woTaskUploadDesc = $v.woTaskUploadDesc;
      _uploadId = $v.uploadId;
      _uploadName = $v.uploadName;
      _documentDesc = $v.documentDesc;
      _documentFilename = $v.documentFilename;
      _documentSrc = $v.documentSrc;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TechnicianImageRepair other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$TechnicianImageRepair;
  }

  @override
  void update(void Function(TechnicianImageRepairBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TechnicianImageRepair build() => _build();

  _$TechnicianImageRepair _build() {
    final _$result = _$v ??
        new _$TechnicianImageRepair._(
          woTaskUploadId: BuiltValueNullFieldError.checkNotNull(
              woTaskUploadId, r'TechnicianImageRepair', 'woTaskUploadId'),
          woTaskUploadType: BuiltValueNullFieldError.checkNotNull(
              woTaskUploadType, r'TechnicianImageRepair', 'woTaskUploadType'),
          woTaskId: BuiltValueNullFieldError.checkNotNull(
              woTaskId, r'TechnicianImageRepair', 'woTaskId'),
          woTaskUploadLongitude: BuiltValueNullFieldError.checkNotNull(
              woTaskUploadLongitude,
              r'TechnicianImageRepair',
              'woTaskUploadLongitude'),
          woTaskUploadLatitude: BuiltValueNullFieldError.checkNotNull(
              woTaskUploadLatitude,
              r'TechnicianImageRepair',
              'woTaskUploadLatitude'),
          woTaskUploadTimestamp: BuiltValueNullFieldError.checkNotNull(
              woTaskUploadTimestamp,
              r'TechnicianImageRepair',
              'woTaskUploadTimestamp'),
          woTaskUploadDesc: BuiltValueNullFieldError.checkNotNull(
              woTaskUploadDesc, r'TechnicianImageRepair', 'woTaskUploadDesc'),
          uploadId: BuiltValueNullFieldError.checkNotNull(
              uploadId, r'TechnicianImageRepair', 'uploadId'),
          uploadName: BuiltValueNullFieldError.checkNotNull(
              uploadName, r'TechnicianImageRepair', 'uploadName'),
          documentDesc: BuiltValueNullFieldError.checkNotNull(
              documentDesc, r'TechnicianImageRepair', 'documentDesc'),
          documentFilename: BuiltValueNullFieldError.checkNotNull(
              documentFilename, r'TechnicianImageRepair', 'documentFilename'),
          documentSrc: BuiltValueNullFieldError.checkNotNull(
              documentSrc, r'TechnicianImageRepair', 'documentSrc'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$TechnicianAssign extends TechnicianAssign {
  @override
  final String userId;
  @override
  final String severity;
  @override
  final String groupId;
  @override
  final String woTaskCategory;
  @override
  final String userCategory;
  @override
  final String woTaskMaxAssistant;
  @override
  final BuiltList<String> assistUserId;

  factory _$TechnicianAssign(
          [void Function(TechnicianAssignBuilder)? updates]) =>
      (new TechnicianAssignBuilder()..update(updates))._build();

  _$TechnicianAssign._(
      {required this.userId,
      required this.severity,
      required this.groupId,
      required this.woTaskCategory,
      required this.userCategory,
      required this.woTaskMaxAssistant,
      required this.assistUserId})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        userId, r'TechnicianAssign', 'userId');
    BuiltValueNullFieldError.checkNotNull(
        severity, r'TechnicianAssign', 'severity');
    BuiltValueNullFieldError.checkNotNull(
        groupId, r'TechnicianAssign', 'groupId');
    BuiltValueNullFieldError.checkNotNull(
        woTaskCategory, r'TechnicianAssign', 'woTaskCategory');
    BuiltValueNullFieldError.checkNotNull(
        userCategory, r'TechnicianAssign', 'userCategory');
    BuiltValueNullFieldError.checkNotNull(
        woTaskMaxAssistant, r'TechnicianAssign', 'woTaskMaxAssistant');
    BuiltValueNullFieldError.checkNotNull(
        assistUserId, r'TechnicianAssign', 'assistUserId');
  }

  @override
  TechnicianAssign rebuild(void Function(TechnicianAssignBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TechnicianAssignBuilder toBuilder() =>
      new TechnicianAssignBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TechnicianAssign &&
        userId == other.userId &&
        severity == other.severity &&
        groupId == other.groupId &&
        woTaskCategory == other.woTaskCategory &&
        userCategory == other.userCategory &&
        woTaskMaxAssistant == other.woTaskMaxAssistant &&
        assistUserId == other.assistUserId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, severity.hashCode);
    _$hash = $jc(_$hash, groupId.hashCode);
    _$hash = $jc(_$hash, woTaskCategory.hashCode);
    _$hash = $jc(_$hash, userCategory.hashCode);
    _$hash = $jc(_$hash, woTaskMaxAssistant.hashCode);
    _$hash = $jc(_$hash, assistUserId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TechnicianAssign')
          ..add('userId', userId)
          ..add('severity', severity)
          ..add('groupId', groupId)
          ..add('woTaskCategory', woTaskCategory)
          ..add('userCategory', userCategory)
          ..add('woTaskMaxAssistant', woTaskMaxAssistant)
          ..add('assistUserId', assistUserId))
        .toString();
  }
}

class TechnicianAssignBuilder
    implements Builder<TechnicianAssign, TechnicianAssignBuilder> {
  _$TechnicianAssign? _$v;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  String? _severity;
  String? get severity => _$this._severity;
  set severity(String? severity) => _$this._severity = severity;

  String? _groupId;
  String? get groupId => _$this._groupId;
  set groupId(String? groupId) => _$this._groupId = groupId;

  String? _woTaskCategory;
  String? get woTaskCategory => _$this._woTaskCategory;
  set woTaskCategory(String? woTaskCategory) =>
      _$this._woTaskCategory = woTaskCategory;

  String? _userCategory;
  String? get userCategory => _$this._userCategory;
  set userCategory(String? userCategory) => _$this._userCategory = userCategory;

  String? _woTaskMaxAssistant;
  String? get woTaskMaxAssistant => _$this._woTaskMaxAssistant;
  set woTaskMaxAssistant(String? woTaskMaxAssistant) =>
      _$this._woTaskMaxAssistant = woTaskMaxAssistant;

  ListBuilder<String>? _assistUserId;
  ListBuilder<String> get assistUserId =>
      _$this._assistUserId ??= new ListBuilder<String>();
  set assistUserId(ListBuilder<String>? assistUserId) =>
      _$this._assistUserId = assistUserId;

  TechnicianAssignBuilder();

  TechnicianAssignBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _userId = $v.userId;
      _severity = $v.severity;
      _groupId = $v.groupId;
      _woTaskCategory = $v.woTaskCategory;
      _userCategory = $v.userCategory;
      _woTaskMaxAssistant = $v.woTaskMaxAssistant;
      _assistUserId = $v.assistUserId.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TechnicianAssign other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$TechnicianAssign;
  }

  @override
  void update(void Function(TechnicianAssignBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TechnicianAssign build() => _build();

  _$TechnicianAssign _build() {
    _$TechnicianAssign _$result;
    try {
      _$result = _$v ??
          new _$TechnicianAssign._(
            userId: BuiltValueNullFieldError.checkNotNull(
                userId, r'TechnicianAssign', 'userId'),
            severity: BuiltValueNullFieldError.checkNotNull(
                severity, r'TechnicianAssign', 'severity'),
            groupId: BuiltValueNullFieldError.checkNotNull(
                groupId, r'TechnicianAssign', 'groupId'),
            woTaskCategory: BuiltValueNullFieldError.checkNotNull(
                woTaskCategory, r'TechnicianAssign', 'woTaskCategory'),
            userCategory: BuiltValueNullFieldError.checkNotNull(
                userCategory, r'TechnicianAssign', 'userCategory'),
            woTaskMaxAssistant: BuiltValueNullFieldError.checkNotNull(
                woTaskMaxAssistant, r'TechnicianAssign', 'woTaskMaxAssistant'),
            assistUserId: assistUserId.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'assistUserId';
        assistUserId.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'TechnicianAssign', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

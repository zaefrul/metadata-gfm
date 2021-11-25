// GENERATED CODE - DO NOT MODIFY BY HAND

part of workorder;

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
  Iterable<Object> serialize(Serializers serializers, WorkOrderTask object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
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
      Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new WorkOrderTaskBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'woTaskId':
          result.woTaskId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'woTaskNo':
          result.woTaskNo = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'woTaskLocation':
          result.woTaskLocation = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'woTaskType':
          result.woTaskType = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'reportedBy':
          result.reportedBy = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'woTaskTimeCreated':
          result.woTaskTimeCreated = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'woTaskStatus':
          result.woTaskStatus = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'woTaskSeverity':
          result.woTaskSeverity = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
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
  Iterable<Object> serialize(Serializers serializers, WorkOrderStatus object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[];
    if (object.sectionName != null) {
      result
        ..add('sectionName')
        ..add(serializers.serialize(object.sectionName,
            specifiedType: const FullType(String)));
    }
    if (object.sectionDesc != null) {
      result
        ..add('sectionDesc')
        ..add(serializers.serialize(object.sectionDesc,
            specifiedType: const FullType(String)));
    }
    if (object.sectionStatus != null) {
      result
        ..add('sectionStatus')
        ..add(serializers.serialize(object.sectionStatus,
            specifiedType: const FullType(String)));
    }
    if (object.sectionStatusMaterial != null) {
      result
        ..add('sectionStatusMaterial')
        ..add(serializers.serialize(object.sectionStatusMaterial,
            specifiedType: const FullType(String)));
    }
    if (object.sectionStatusMaterialId != null) {
      result
        ..add('sectionStatusMaterialId')
        ..add(serializers.serialize(object.sectionStatusMaterialId,
            specifiedType: const FullType(String)));
    }
    if (object.sectionComment != null) {
      result
        ..add('sectionComment')
        ..add(serializers.serialize(object.sectionComment,
            specifiedType: const FullType(String)));
    }
    if (object.groupId != null) {
      result
        ..add('groupId')
        ..add(serializers.serialize(object.groupId,
            specifiedType: const FullType(String)));
    }
    if (object.groupName != null) {
      result
        ..add('groupName')
        ..add(serializers.serialize(object.groupName,
            specifiedType: const FullType(String)));
    }
    if (object.userId != null) {
      result
        ..add('userId')
        ..add(serializers.serialize(object.userId,
            specifiedType: const FullType(String)));
    }
    if (object.userName != null) {
      result
        ..add('userName')
        ..add(serializers.serialize(object.userName,
            specifiedType: const FullType(String)));
    }
    if (object.comment != null) {
      result
        ..add('comment')
        ..add(serializers.serialize(object.comment,
            specifiedType: const FullType(String)));
    }
    if (object.severityId != null) {
      result
        ..add('severityId')
        ..add(serializers.serialize(object.severityId,
            specifiedType: const FullType(String)));
    }
    if (object.severityName != null) {
      result
        ..add('severityName')
        ..add(serializers.serialize(object.severityName,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  WorkOrderStatus deserialize(
      Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new WorkOrderStatusBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'sectionName':
          result.sectionName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'sectionDesc':
          result.sectionDesc = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'sectionStatus':
          result.sectionStatus = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'sectionStatusMaterial':
          result.sectionStatusMaterial = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'sectionStatusMaterialId':
          result.sectionStatusMaterialId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'sectionComment':
          result.sectionComment = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'groupId':
          result.groupId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'groupName':
          result.groupName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'userId':
          result.userId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'userName':
          result.userName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'comment':
          result.comment = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'severityId':
          result.severityId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'severityName':
          result.severityName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
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
  Iterable<Object> serialize(Serializers serializers, WorkOrderDetail object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
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
      'complaintImages',
      serializers.serialize(object.complaintImages,
          specifiedType: const FullType(
              BuiltList, const [const FullType(ComplaintImage)])),
    ];

    return result;
  }

  @override
  WorkOrderDetail deserialize(
      Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new WorkOrderDetailBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'woTaskId':
          result.woTaskId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'woTaskNo':
          result.woTaskNo = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'woTaskRequestNo':
          result.woTaskRequestNo = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'woTaskReportedBy':
          result.woTaskReportedBy = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'woTaskTimeResponded':
          result.woTaskTimeResponded = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'woTaskCategory':
          result.woTaskCategory = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'woTaskClient':
          result.woTaskClient = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'woTaskLocation':
          result.woTaskLocation = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'woTaskComplaint':
          result.woTaskComplaint = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'woTaskStatus':
          result.woTaskStatus = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'woTaskPhoneNo':
          result.woTaskPhoneNo = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'woTaskEmail':
          result.woTaskEmail = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'complaintImages':
          result.complaintImages.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(ComplaintImage)]))
              as BuiltList<dynamic>);
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
  Iterable<Object> serialize(Serializers serializers, ComplaintImage object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
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
      Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new ComplaintImageBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'woTaskUploadId':
          result.woTaskUploadId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'woTaskUploadType':
          result.woTaskUploadType = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'woTaskId':
          result.woTaskId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'woTaskUploadLongitude':
          result.woTaskUploadLongitude = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'woTaskUploadLatitude':
          result.woTaskUploadLatitude = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'woTaskUploadTimestamp':
          result.woTaskUploadTimestamp = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'woTaskUploadDesc':
          result.woTaskUploadDesc = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'uploadId':
          result.uploadId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'uploadName':
          result.uploadName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'documentDesc':
          result.documentDesc = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'documentFilename':
          result.documentFilename = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'documentSrc':
          result.documentSrc = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
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
  Iterable<Object> serialize(Serializers serializers, TechnicianDetails object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
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
      Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new TechnicianDetailsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'name':
          result.name = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'phoneNo':
          result.phoneNo = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'email':
          result.email = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'group':
          result.group = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'totalCurrentTask':
          result.totalCurrentTask = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int;
          break;
        case 'currentTask':
          result.currentTask.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(TechnicianTask)]))
              as BuiltList<dynamic>);
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
  Iterable<Object> serialize(Serializers serializers, TechnicianTask object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
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
      Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new TechnicianTaskBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'woTaskNo':
          result.woTaskNo = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'dateReceived':
          result.dateReceived = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
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
  Iterable<Object> serialize(
      Serializers serializers, TechnicianImageRepair object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
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
      Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new TechnicianImageRepairBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'woTaskUploadId':
          result.woTaskUploadId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'woTaskUploadType':
          result.woTaskUploadType = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'woTaskId':
          result.woTaskId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'woTaskUploadLongitude':
          result.woTaskUploadLongitude = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'woTaskUploadLatitude':
          result.woTaskUploadLatitude = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'woTaskUploadTimestamp':
          result.woTaskUploadTimestamp = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'woTaskUploadDesc':
          result.woTaskUploadDesc = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'uploadId':
          result.uploadId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'uploadName':
          result.uploadName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'documentDesc':
          result.documentDesc = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'documentFilename':
          result.documentFilename = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'documentSrc':
          result.documentSrc = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
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
  Iterable<Object> serialize(Serializers serializers, TechnicianAssign object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
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
      'assistUserId',
      serializers.serialize(object.assistUserId,
          specifiedType:
              const FullType(BuiltList, const [const FullType(String)])),
    ];

    return result;
  }

  @override
  TechnicianAssign deserialize(
      Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new TechnicianAssignBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'userId':
          result.userId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'severity':
          result.severity = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'groupId':
          result.groupId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'woTaskCategory':
          result.woTaskCategory = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'userCategory':
          result.userCategory = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'assistUserId':
          result.assistUserId.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(BuiltList, const [const FullType(String)]))
              as BuiltList<dynamic>);
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
  final String reportedBy;
  @override
  final String woTaskTimeCreated;
  @override
  final String woTaskStatus;
  @override
  final String woTaskSeverity;

  factory _$WorkOrderTask([void Function(WorkOrderTaskBuilder) updates]) =>
      (new WorkOrderTaskBuilder()..update(updates)).build();

  _$WorkOrderTask._(
      {this.woTaskId,
      this.woTaskNo,
      this.woTaskLocation,
      this.woTaskType,
      this.reportedBy,
      this.woTaskTimeCreated,
      this.woTaskStatus,
      this.woTaskSeverity})
      : super._() {
    if (woTaskId == null) {
      throw new BuiltValueNullFieldError('WorkOrderTask', 'woTaskId');
    }
    if (woTaskNo == null) {
      throw new BuiltValueNullFieldError('WorkOrderTask', 'woTaskNo');
    }
    if (woTaskLocation == null) {
      throw new BuiltValueNullFieldError('WorkOrderTask', 'woTaskLocation');
    }
    if (woTaskType == null) {
      throw new BuiltValueNullFieldError('WorkOrderTask', 'woTaskType');
    }
    if (reportedBy == null) {
      throw new BuiltValueNullFieldError('WorkOrderTask', 'reportedBy');
    }
    if (woTaskTimeCreated == null) {
      throw new BuiltValueNullFieldError('WorkOrderTask', 'woTaskTimeCreated');
    }
    if (woTaskStatus == null) {
      throw new BuiltValueNullFieldError('WorkOrderTask', 'woTaskStatus');
    }
    if (woTaskSeverity == null) {
      throw new BuiltValueNullFieldError('WorkOrderTask', 'woTaskSeverity');
    }
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
        reportedBy == other.reportedBy &&
        woTaskTimeCreated == other.woTaskTimeCreated &&
        woTaskStatus == other.woTaskStatus &&
        woTaskSeverity == other.woTaskSeverity;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc(
                    $jc(
                        $jc($jc($jc(0, woTaskId.hashCode), woTaskNo.hashCode),
                            woTaskLocation.hashCode),
                        woTaskType.hashCode),
                    reportedBy.hashCode),
                woTaskTimeCreated.hashCode),
            woTaskStatus.hashCode),
        woTaskSeverity.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('WorkOrderTask')
          ..add('woTaskId', woTaskId)
          ..add('woTaskNo', woTaskNo)
          ..add('woTaskLocation', woTaskLocation)
          ..add('woTaskType', woTaskType)
          ..add('reportedBy', reportedBy)
          ..add('woTaskTimeCreated', woTaskTimeCreated)
          ..add('woTaskStatus', woTaskStatus)
          ..add('woTaskSeverity', woTaskSeverity))
        .toString();
  }
}

class WorkOrderTaskBuilder
    implements Builder<WorkOrderTask, WorkOrderTaskBuilder> {
  _$WorkOrderTask _$v;

  String _woTaskId;
  String get woTaskId => _$this._woTaskId;
  set woTaskId(String woTaskId) => _$this._woTaskId = woTaskId;

  String _woTaskNo;
  String get woTaskNo => _$this._woTaskNo;
  set woTaskNo(String woTaskNo) => _$this._woTaskNo = woTaskNo;

  String _woTaskLocation;
  String get woTaskLocation => _$this._woTaskLocation;
  set woTaskLocation(String woTaskLocation) =>
      _$this._woTaskLocation = woTaskLocation;

  String _woTaskType;
  String get woTaskType => _$this._woTaskType;
  set woTaskType(String woTaskType) => _$this._woTaskType = woTaskType;

  String _reportedBy;
  String get reportedBy => _$this._reportedBy;
  set reportedBy(String reportedBy) => _$this._reportedBy = reportedBy;

  String _woTaskTimeCreated;
  String get woTaskTimeCreated => _$this._woTaskTimeCreated;
  set woTaskTimeCreated(String woTaskTimeCreated) =>
      _$this._woTaskTimeCreated = woTaskTimeCreated;

  String _woTaskStatus;
  String get woTaskStatus => _$this._woTaskStatus;
  set woTaskStatus(String woTaskStatus) => _$this._woTaskStatus = woTaskStatus;

  String _woTaskSeverity;
  String get woTaskSeverity => _$this._woTaskSeverity;
  set woTaskSeverity(String woTaskSeverity) =>
      _$this._woTaskSeverity = woTaskSeverity;

  WorkOrderTaskBuilder();

  WorkOrderTaskBuilder get _$this {
    if (_$v != null) {
      _woTaskId = _$v.woTaskId;
      _woTaskNo = _$v.woTaskNo;
      _woTaskLocation = _$v.woTaskLocation;
      _woTaskType = _$v.woTaskType;
      _reportedBy = _$v.reportedBy;
      _woTaskTimeCreated = _$v.woTaskTimeCreated;
      _woTaskStatus = _$v.woTaskStatus;
      _woTaskSeverity = _$v.woTaskSeverity;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WorkOrderTask other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$WorkOrderTask;
  }

  @override
  void update(void Function(WorkOrderTaskBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$WorkOrderTask build() {
    final _$result = _$v ??
        new _$WorkOrderTask._(
            woTaskId: woTaskId,
            woTaskNo: woTaskNo,
            woTaskLocation: woTaskLocation,
            woTaskType: woTaskType,
            reportedBy: reportedBy,
            woTaskTimeCreated: woTaskTimeCreated,
            woTaskStatus: woTaskStatus,
            woTaskSeverity: woTaskSeverity);
    replace(_$result);
    return _$result;
  }
}

class _$WorkOrderStatus extends WorkOrderStatus {
  @override
  final String sectionName;
  @override
  final String sectionDesc;
  @override
  final String sectionStatus;
  @override
  final String sectionStatusMaterial;
  @override
  final String sectionStatusMaterialId;
  @override
  final String sectionComment;
  @override
  final String groupId;
  @override
  final String groupName;
  @override
  final String userId;
  @override
  final String userName;
  @override
  final String comment;
  @override
  final String severityId;
  @override
  final String severityName;

  factory _$WorkOrderStatus([void Function(WorkOrderStatusBuilder) updates]) =>
      (new WorkOrderStatusBuilder()..update(updates)).build();

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
    return $jf($jc(
        $jc(
            $jc(
                $jc(
                    $jc(
                        $jc(
                            $jc(
                                $jc(
                                    $jc(
                                        $jc(
                                            $jc(
                                                $jc(
                                                    $jc(0,
                                                        sectionName.hashCode),
                                                    sectionDesc.hashCode),
                                                sectionStatus.hashCode),
                                            sectionStatusMaterial.hashCode),
                                        sectionStatusMaterialId.hashCode),
                                    sectionComment.hashCode),
                                groupId.hashCode),
                            groupName.hashCode),
                        userId.hashCode),
                    userName.hashCode),
                comment.hashCode),
            severityId.hashCode),
        severityName.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('WorkOrderStatus')
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
  _$WorkOrderStatus _$v;

  String _sectionName;
  String get sectionName => _$this._sectionName;
  set sectionName(String sectionName) => _$this._sectionName = sectionName;

  String _sectionDesc;
  String get sectionDesc => _$this._sectionDesc;
  set sectionDesc(String sectionDesc) => _$this._sectionDesc = sectionDesc;

  String _sectionStatus;
  String get sectionStatus => _$this._sectionStatus;
  set sectionStatus(String sectionStatus) =>
      _$this._sectionStatus = sectionStatus;

  String _sectionStatusMaterial;
  String get sectionStatusMaterial => _$this._sectionStatusMaterial;
  set sectionStatusMaterial(String sectionStatusMaterial) =>
      _$this._sectionStatusMaterial = sectionStatusMaterial;

  String _sectionStatusMaterialId;
  String get sectionStatusMaterialId => _$this._sectionStatusMaterialId;
  set sectionStatusMaterialId(String sectionStatusMaterialId) =>
      _$this._sectionStatusMaterialId = sectionStatusMaterialId;

  String _sectionComment;
  String get sectionComment => _$this._sectionComment;
  set sectionComment(String sectionComment) =>
      _$this._sectionComment = sectionComment;

  String _groupId;
  String get groupId => _$this._groupId;
  set groupId(String groupId) => _$this._groupId = groupId;

  String _groupName;
  String get groupName => _$this._groupName;
  set groupName(String groupName) => _$this._groupName = groupName;

  String _userId;
  String get userId => _$this._userId;
  set userId(String userId) => _$this._userId = userId;

  String _userName;
  String get userName => _$this._userName;
  set userName(String userName) => _$this._userName = userName;

  String _comment;
  String get comment => _$this._comment;
  set comment(String comment) => _$this._comment = comment;

  String _severityId;
  String get severityId => _$this._severityId;
  set severityId(String severityId) => _$this._severityId = severityId;

  String _severityName;
  String get severityName => _$this._severityName;
  set severityName(String severityName) => _$this._severityName = severityName;

  WorkOrderStatusBuilder();

  WorkOrderStatusBuilder get _$this {
    if (_$v != null) {
      _sectionName = _$v.sectionName;
      _sectionDesc = _$v.sectionDesc;
      _sectionStatus = _$v.sectionStatus;
      _sectionStatusMaterial = _$v.sectionStatusMaterial;
      _sectionStatusMaterialId = _$v.sectionStatusMaterialId;
      _sectionComment = _$v.sectionComment;
      _groupId = _$v.groupId;
      _groupName = _$v.groupName;
      _userId = _$v.userId;
      _userName = _$v.userName;
      _comment = _$v.comment;
      _severityId = _$v.severityId;
      _severityName = _$v.severityName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WorkOrderStatus other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$WorkOrderStatus;
  }

  @override
  void update(void Function(WorkOrderStatusBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$WorkOrderStatus build() {
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
            severityName: severityName);
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
  final BuiltList<ComplaintImage> complaintImages;

  factory _$WorkOrderDetail([void Function(WorkOrderDetailBuilder) updates]) =>
      (new WorkOrderDetailBuilder()..update(updates)).build();

  _$WorkOrderDetail._(
      {this.woTaskId,
      this.woTaskNo,
      this.woTaskRequestNo,
      this.woTaskReportedBy,
      this.woTaskTimeResponded,
      this.woTaskCategory,
      this.woTaskClient,
      this.woTaskLocation,
      this.woTaskComplaint,
      this.woTaskStatus,
      this.woTaskPhoneNo,
      this.woTaskEmail,
      this.complaintImages})
      : super._() {
    if (woTaskId == null) {
      throw new BuiltValueNullFieldError('WorkOrderDetail', 'woTaskId');
    }
    if (woTaskNo == null) {
      throw new BuiltValueNullFieldError('WorkOrderDetail', 'woTaskNo');
    }
    if (woTaskRequestNo == null) {
      throw new BuiltValueNullFieldError('WorkOrderDetail', 'woTaskRequestNo');
    }
    if (woTaskReportedBy == null) {
      throw new BuiltValueNullFieldError('WorkOrderDetail', 'woTaskReportedBy');
    }
    if (woTaskTimeResponded == null) {
      throw new BuiltValueNullFieldError(
          'WorkOrderDetail', 'woTaskTimeResponded');
    }
    if (woTaskCategory == null) {
      throw new BuiltValueNullFieldError('WorkOrderDetail', 'woTaskCategory');
    }
    if (woTaskClient == null) {
      throw new BuiltValueNullFieldError('WorkOrderDetail', 'woTaskClient');
    }
    if (woTaskLocation == null) {
      throw new BuiltValueNullFieldError('WorkOrderDetail', 'woTaskLocation');
    }
    if (woTaskComplaint == null) {
      throw new BuiltValueNullFieldError('WorkOrderDetail', 'woTaskComplaint');
    }
    if (woTaskStatus == null) {
      throw new BuiltValueNullFieldError('WorkOrderDetail', 'woTaskStatus');
    }
    if (woTaskPhoneNo == null) {
      throw new BuiltValueNullFieldError('WorkOrderDetail', 'woTaskPhoneNo');
    }
    if (woTaskEmail == null) {
      throw new BuiltValueNullFieldError('WorkOrderDetail', 'woTaskEmail');
    }
    if (complaintImages == null) {
      throw new BuiltValueNullFieldError('WorkOrderDetail', 'complaintImages');
    }
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
        woTaskClient == other.woTaskClient &&
        woTaskLocation == other.woTaskLocation &&
        woTaskComplaint == other.woTaskComplaint &&
        woTaskStatus == other.woTaskStatus &&
        woTaskPhoneNo == other.woTaskPhoneNo &&
        woTaskEmail == other.woTaskEmail &&
        complaintImages == other.complaintImages;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc(
                    $jc(
                        $jc(
                            $jc(
                                $jc(
                                    $jc(
                                        $jc(
                                            $jc(
                                                $jc($jc(0, woTaskId.hashCode),
                                                    woTaskNo.hashCode),
                                                woTaskRequestNo.hashCode),
                                            woTaskReportedBy.hashCode),
                                        woTaskTimeResponded.hashCode),
                                    woTaskCategory.hashCode),
                                woTaskClient.hashCode),
                            woTaskLocation.hashCode),
                        woTaskComplaint.hashCode),
                    woTaskStatus.hashCode),
                woTaskPhoneNo.hashCode),
            woTaskEmail.hashCode),
        complaintImages.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('WorkOrderDetail')
          ..add('woTaskId', woTaskId)
          ..add('woTaskNo', woTaskNo)
          ..add('woTaskRequestNo', woTaskRequestNo)
          ..add('woTaskReportedBy', woTaskReportedBy)
          ..add('woTaskTimeResponded', woTaskTimeResponded)
          ..add('woTaskCategory', woTaskCategory)
          ..add('woTaskClient', woTaskClient)
          ..add('woTaskLocation', woTaskLocation)
          ..add('woTaskComplaint', woTaskComplaint)
          ..add('woTaskStatus', woTaskStatus)
          ..add('woTaskPhoneNo', woTaskPhoneNo)
          ..add('woTaskEmail', woTaskEmail)
          ..add('complaintImages', complaintImages))
        .toString();
  }
}

class WorkOrderDetailBuilder
    implements Builder<WorkOrderDetail, WorkOrderDetailBuilder> {
  _$WorkOrderDetail _$v;

  String _woTaskId;
  String get woTaskId => _$this._woTaskId;
  set woTaskId(String woTaskId) => _$this._woTaskId = woTaskId;

  String _woTaskNo;
  String get woTaskNo => _$this._woTaskNo;
  set woTaskNo(String woTaskNo) => _$this._woTaskNo = woTaskNo;

  String _woTaskRequestNo;
  String get woTaskRequestNo => _$this._woTaskRequestNo;
  set woTaskRequestNo(String woTaskRequestNo) =>
      _$this._woTaskRequestNo = woTaskRequestNo;

  String _woTaskReportedBy;
  String get woTaskReportedBy => _$this._woTaskReportedBy;
  set woTaskReportedBy(String woTaskReportedBy) =>
      _$this._woTaskReportedBy = woTaskReportedBy;

  String _woTaskTimeResponded;
  String get woTaskTimeResponded => _$this._woTaskTimeResponded;
  set woTaskTimeResponded(String woTaskTimeResponded) =>
      _$this._woTaskTimeResponded = woTaskTimeResponded;

  String _woTaskCategory;
  String get woTaskCategory => _$this._woTaskCategory;
  set woTaskCategory(String woTaskCategory) =>
      _$this._woTaskCategory = woTaskCategory;

  String _woTaskClient;
  String get woTaskClient => _$this._woTaskClient;
  set woTaskClient(String woTaskClient) => _$this._woTaskClient = woTaskClient;

  String _woTaskLocation;
  String get woTaskLocation => _$this._woTaskLocation;
  set woTaskLocation(String woTaskLocation) =>
      _$this._woTaskLocation = woTaskLocation;

  String _woTaskComplaint;
  String get woTaskComplaint => _$this._woTaskComplaint;
  set woTaskComplaint(String woTaskComplaint) =>
      _$this._woTaskComplaint = woTaskComplaint;

  String _woTaskStatus;
  String get woTaskStatus => _$this._woTaskStatus;
  set woTaskStatus(String woTaskStatus) => _$this._woTaskStatus = woTaskStatus;

  String _woTaskPhoneNo;
  String get woTaskPhoneNo => _$this._woTaskPhoneNo;
  set woTaskPhoneNo(String woTaskPhoneNo) =>
      _$this._woTaskPhoneNo = woTaskPhoneNo;

  String _woTaskEmail;
  String get woTaskEmail => _$this._woTaskEmail;
  set woTaskEmail(String woTaskEmail) => _$this._woTaskEmail = woTaskEmail;

  ListBuilder<ComplaintImage> _complaintImages;
  ListBuilder<ComplaintImage> get complaintImages =>
      _$this._complaintImages ??= new ListBuilder<ComplaintImage>();
  set complaintImages(ListBuilder<ComplaintImage> complaintImages) =>
      _$this._complaintImages = complaintImages;

  WorkOrderDetailBuilder();

  WorkOrderDetailBuilder get _$this {
    if (_$v != null) {
      _woTaskId = _$v.woTaskId;
      _woTaskNo = _$v.woTaskNo;
      _woTaskRequestNo = _$v.woTaskRequestNo;
      _woTaskReportedBy = _$v.woTaskReportedBy;
      _woTaskTimeResponded = _$v.woTaskTimeResponded;
      _woTaskCategory = _$v.woTaskCategory;
      _woTaskClient = _$v.woTaskClient;
      _woTaskLocation = _$v.woTaskLocation;
      _woTaskComplaint = _$v.woTaskComplaint;
      _woTaskStatus = _$v.woTaskStatus;
      _woTaskPhoneNo = _$v.woTaskPhoneNo;
      _woTaskEmail = _$v.woTaskEmail;
      _complaintImages = _$v.complaintImages?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WorkOrderDetail other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$WorkOrderDetail;
  }

  @override
  void update(void Function(WorkOrderDetailBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$WorkOrderDetail build() {
    _$WorkOrderDetail _$result;
    try {
      _$result = _$v ??
          new _$WorkOrderDetail._(
              woTaskId: woTaskId,
              woTaskNo: woTaskNo,
              woTaskRequestNo: woTaskRequestNo,
              woTaskReportedBy: woTaskReportedBy,
              woTaskTimeResponded: woTaskTimeResponded,
              woTaskCategory: woTaskCategory,
              woTaskClient: woTaskClient,
              woTaskLocation: woTaskLocation,
              woTaskComplaint: woTaskComplaint,
              woTaskStatus: woTaskStatus,
              woTaskPhoneNo: woTaskPhoneNo,
              woTaskEmail: woTaskEmail,
              complaintImages: complaintImages.build());
    } catch (_) {
      String _$failedField;
      try {
        _$failedField = 'complaintImages';
        complaintImages.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'WorkOrderDetail', _$failedField, e.toString());
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

  factory _$ComplaintImage([void Function(ComplaintImageBuilder) updates]) =>
      (new ComplaintImageBuilder()..update(updates)).build();

  _$ComplaintImage._(
      {this.woTaskUploadId,
      this.woTaskUploadType,
      this.woTaskId,
      this.woTaskUploadLongitude,
      this.woTaskUploadLatitude,
      this.woTaskUploadTimestamp,
      this.woTaskUploadDesc,
      this.uploadId,
      this.uploadName,
      this.documentDesc,
      this.documentFilename,
      this.documentSrc})
      : super._() {
    if (woTaskUploadId == null) {
      throw new BuiltValueNullFieldError('ComplaintImage', 'woTaskUploadId');
    }
    if (woTaskUploadType == null) {
      throw new BuiltValueNullFieldError('ComplaintImage', 'woTaskUploadType');
    }
    if (woTaskId == null) {
      throw new BuiltValueNullFieldError('ComplaintImage', 'woTaskId');
    }
    if (woTaskUploadLongitude == null) {
      throw new BuiltValueNullFieldError(
          'ComplaintImage', 'woTaskUploadLongitude');
    }
    if (woTaskUploadLatitude == null) {
      throw new BuiltValueNullFieldError(
          'ComplaintImage', 'woTaskUploadLatitude');
    }
    if (woTaskUploadTimestamp == null) {
      throw new BuiltValueNullFieldError(
          'ComplaintImage', 'woTaskUploadTimestamp');
    }
    if (woTaskUploadDesc == null) {
      throw new BuiltValueNullFieldError('ComplaintImage', 'woTaskUploadDesc');
    }
    if (uploadId == null) {
      throw new BuiltValueNullFieldError('ComplaintImage', 'uploadId');
    }
    if (uploadName == null) {
      throw new BuiltValueNullFieldError('ComplaintImage', 'uploadName');
    }
    if (documentDesc == null) {
      throw new BuiltValueNullFieldError('ComplaintImage', 'documentDesc');
    }
    if (documentFilename == null) {
      throw new BuiltValueNullFieldError('ComplaintImage', 'documentFilename');
    }
    if (documentSrc == null) {
      throw new BuiltValueNullFieldError('ComplaintImage', 'documentSrc');
    }
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
    return $jf($jc(
        $jc(
            $jc(
                $jc(
                    $jc(
                        $jc(
                            $jc(
                                $jc(
                                    $jc(
                                        $jc(
                                            $jc($jc(0, woTaskUploadId.hashCode),
                                                woTaskUploadType.hashCode),
                                            woTaskId.hashCode),
                                        woTaskUploadLongitude.hashCode),
                                    woTaskUploadLatitude.hashCode),
                                woTaskUploadTimestamp.hashCode),
                            woTaskUploadDesc.hashCode),
                        uploadId.hashCode),
                    uploadName.hashCode),
                documentDesc.hashCode),
            documentFilename.hashCode),
        documentSrc.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('ComplaintImage')
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
  _$ComplaintImage _$v;

  String _woTaskUploadId;
  String get woTaskUploadId => _$this._woTaskUploadId;
  set woTaskUploadId(String woTaskUploadId) =>
      _$this._woTaskUploadId = woTaskUploadId;

  String _woTaskUploadType;
  String get woTaskUploadType => _$this._woTaskUploadType;
  set woTaskUploadType(String woTaskUploadType) =>
      _$this._woTaskUploadType = woTaskUploadType;

  String _woTaskId;
  String get woTaskId => _$this._woTaskId;
  set woTaskId(String woTaskId) => _$this._woTaskId = woTaskId;

  String _woTaskUploadLongitude;
  String get woTaskUploadLongitude => _$this._woTaskUploadLongitude;
  set woTaskUploadLongitude(String woTaskUploadLongitude) =>
      _$this._woTaskUploadLongitude = woTaskUploadLongitude;

  String _woTaskUploadLatitude;
  String get woTaskUploadLatitude => _$this._woTaskUploadLatitude;
  set woTaskUploadLatitude(String woTaskUploadLatitude) =>
      _$this._woTaskUploadLatitude = woTaskUploadLatitude;

  String _woTaskUploadTimestamp;
  String get woTaskUploadTimestamp => _$this._woTaskUploadTimestamp;
  set woTaskUploadTimestamp(String woTaskUploadTimestamp) =>
      _$this._woTaskUploadTimestamp = woTaskUploadTimestamp;

  String _woTaskUploadDesc;
  String get woTaskUploadDesc => _$this._woTaskUploadDesc;
  set woTaskUploadDesc(String woTaskUploadDesc) =>
      _$this._woTaskUploadDesc = woTaskUploadDesc;

  String _uploadId;
  String get uploadId => _$this._uploadId;
  set uploadId(String uploadId) => _$this._uploadId = uploadId;

  String _uploadName;
  String get uploadName => _$this._uploadName;
  set uploadName(String uploadName) => _$this._uploadName = uploadName;

  String _documentDesc;
  String get documentDesc => _$this._documentDesc;
  set documentDesc(String documentDesc) => _$this._documentDesc = documentDesc;

  String _documentFilename;
  String get documentFilename => _$this._documentFilename;
  set documentFilename(String documentFilename) =>
      _$this._documentFilename = documentFilename;

  String _documentSrc;
  String get documentSrc => _$this._documentSrc;
  set documentSrc(String documentSrc) => _$this._documentSrc = documentSrc;

  ComplaintImageBuilder();

  ComplaintImageBuilder get _$this {
    if (_$v != null) {
      _woTaskUploadId = _$v.woTaskUploadId;
      _woTaskUploadType = _$v.woTaskUploadType;
      _woTaskId = _$v.woTaskId;
      _woTaskUploadLongitude = _$v.woTaskUploadLongitude;
      _woTaskUploadLatitude = _$v.woTaskUploadLatitude;
      _woTaskUploadTimestamp = _$v.woTaskUploadTimestamp;
      _woTaskUploadDesc = _$v.woTaskUploadDesc;
      _uploadId = _$v.uploadId;
      _uploadName = _$v.uploadName;
      _documentDesc = _$v.documentDesc;
      _documentFilename = _$v.documentFilename;
      _documentSrc = _$v.documentSrc;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ComplaintImage other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$ComplaintImage;
  }

  @override
  void update(void Function(ComplaintImageBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$ComplaintImage build() {
    final _$result = _$v ??
        new _$ComplaintImage._(
            woTaskUploadId: woTaskUploadId,
            woTaskUploadType: woTaskUploadType,
            woTaskId: woTaskId,
            woTaskUploadLongitude: woTaskUploadLongitude,
            woTaskUploadLatitude: woTaskUploadLatitude,
            woTaskUploadTimestamp: woTaskUploadTimestamp,
            woTaskUploadDesc: woTaskUploadDesc,
            uploadId: uploadId,
            uploadName: uploadName,
            documentDesc: documentDesc,
            documentFilename: documentFilename,
            documentSrc: documentSrc);
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
          [void Function(TechnicianDetailsBuilder) updates]) =>
      (new TechnicianDetailsBuilder()..update(updates)).build();

  _$TechnicianDetails._(
      {this.name,
      this.phoneNo,
      this.email,
      this.group,
      this.totalCurrentTask,
      this.currentTask})
      : super._() {
    if (name == null) {
      throw new BuiltValueNullFieldError('TechnicianDetails', 'name');
    }
    if (phoneNo == null) {
      throw new BuiltValueNullFieldError('TechnicianDetails', 'phoneNo');
    }
    if (email == null) {
      throw new BuiltValueNullFieldError('TechnicianDetails', 'email');
    }
    if (group == null) {
      throw new BuiltValueNullFieldError('TechnicianDetails', 'group');
    }
    if (totalCurrentTask == null) {
      throw new BuiltValueNullFieldError(
          'TechnicianDetails', 'totalCurrentTask');
    }
    if (currentTask == null) {
      throw new BuiltValueNullFieldError('TechnicianDetails', 'currentTask');
    }
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
    return $jf($jc(
        $jc(
            $jc(
                $jc($jc($jc(0, name.hashCode), phoneNo.hashCode),
                    email.hashCode),
                group.hashCode),
            totalCurrentTask.hashCode),
        currentTask.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('TechnicianDetails')
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
  _$TechnicianDetails _$v;

  String _name;
  String get name => _$this._name;
  set name(String name) => _$this._name = name;

  String _phoneNo;
  String get phoneNo => _$this._phoneNo;
  set phoneNo(String phoneNo) => _$this._phoneNo = phoneNo;

  String _email;
  String get email => _$this._email;
  set email(String email) => _$this._email = email;

  String _group;
  String get group => _$this._group;
  set group(String group) => _$this._group = group;

  int _totalCurrentTask;
  int get totalCurrentTask => _$this._totalCurrentTask;
  set totalCurrentTask(int totalCurrentTask) =>
      _$this._totalCurrentTask = totalCurrentTask;

  ListBuilder<TechnicianTask> _currentTask;
  ListBuilder<TechnicianTask> get currentTask =>
      _$this._currentTask ??= new ListBuilder<TechnicianTask>();
  set currentTask(ListBuilder<TechnicianTask> currentTask) =>
      _$this._currentTask = currentTask;

  TechnicianDetailsBuilder();

  TechnicianDetailsBuilder get _$this {
    if (_$v != null) {
      _name = _$v.name;
      _phoneNo = _$v.phoneNo;
      _email = _$v.email;
      _group = _$v.group;
      _totalCurrentTask = _$v.totalCurrentTask;
      _currentTask = _$v.currentTask?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TechnicianDetails other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$TechnicianDetails;
  }

  @override
  void update(void Function(TechnicianDetailsBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$TechnicianDetails build() {
    _$TechnicianDetails _$result;
    try {
      _$result = _$v ??
          new _$TechnicianDetails._(
              name: name,
              phoneNo: phoneNo,
              email: email,
              group: group,
              totalCurrentTask: totalCurrentTask,
              currentTask: currentTask.build());
    } catch (_) {
      String _$failedField;
      try {
        _$failedField = 'currentTask';
        currentTask.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'TechnicianDetails', _$failedField, e.toString());
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

  factory _$TechnicianTask([void Function(TechnicianTaskBuilder) updates]) =>
      (new TechnicianTaskBuilder()..update(updates)).build();

  _$TechnicianTask._({this.woTaskNo, this.dateReceived}) : super._() {
    if (woTaskNo == null) {
      throw new BuiltValueNullFieldError('TechnicianTask', 'woTaskNo');
    }
    if (dateReceived == null) {
      throw new BuiltValueNullFieldError('TechnicianTask', 'dateReceived');
    }
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
    return $jf($jc($jc(0, woTaskNo.hashCode), dateReceived.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('TechnicianTask')
          ..add('woTaskNo', woTaskNo)
          ..add('dateReceived', dateReceived))
        .toString();
  }
}

class TechnicianTaskBuilder
    implements Builder<TechnicianTask, TechnicianTaskBuilder> {
  _$TechnicianTask _$v;

  String _woTaskNo;
  String get woTaskNo => _$this._woTaskNo;
  set woTaskNo(String woTaskNo) => _$this._woTaskNo = woTaskNo;

  String _dateReceived;
  String get dateReceived => _$this._dateReceived;
  set dateReceived(String dateReceived) => _$this._dateReceived = dateReceived;

  TechnicianTaskBuilder();

  TechnicianTaskBuilder get _$this {
    if (_$v != null) {
      _woTaskNo = _$v.woTaskNo;
      _dateReceived = _$v.dateReceived;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TechnicianTask other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$TechnicianTask;
  }

  @override
  void update(void Function(TechnicianTaskBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$TechnicianTask build() {
    final _$result = _$v ??
        new _$TechnicianTask._(woTaskNo: woTaskNo, dateReceived: dateReceived);
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
          [void Function(TechnicianImageRepairBuilder) updates]) =>
      (new TechnicianImageRepairBuilder()..update(updates)).build();

  _$TechnicianImageRepair._(
      {this.woTaskUploadId,
      this.woTaskUploadType,
      this.woTaskId,
      this.woTaskUploadLongitude,
      this.woTaskUploadLatitude,
      this.woTaskUploadTimestamp,
      this.woTaskUploadDesc,
      this.uploadId,
      this.uploadName,
      this.documentDesc,
      this.documentFilename,
      this.documentSrc})
      : super._() {
    if (woTaskUploadId == null) {
      throw new BuiltValueNullFieldError(
          'TechnicianImageRepair', 'woTaskUploadId');
    }
    if (woTaskUploadType == null) {
      throw new BuiltValueNullFieldError(
          'TechnicianImageRepair', 'woTaskUploadType');
    }
    if (woTaskId == null) {
      throw new BuiltValueNullFieldError('TechnicianImageRepair', 'woTaskId');
    }
    if (woTaskUploadLongitude == null) {
      throw new BuiltValueNullFieldError(
          'TechnicianImageRepair', 'woTaskUploadLongitude');
    }
    if (woTaskUploadLatitude == null) {
      throw new BuiltValueNullFieldError(
          'TechnicianImageRepair', 'woTaskUploadLatitude');
    }
    if (woTaskUploadTimestamp == null) {
      throw new BuiltValueNullFieldError(
          'TechnicianImageRepair', 'woTaskUploadTimestamp');
    }
    if (woTaskUploadDesc == null) {
      throw new BuiltValueNullFieldError(
          'TechnicianImageRepair', 'woTaskUploadDesc');
    }
    if (uploadId == null) {
      throw new BuiltValueNullFieldError('TechnicianImageRepair', 'uploadId');
    }
    if (uploadName == null) {
      throw new BuiltValueNullFieldError('TechnicianImageRepair', 'uploadName');
    }
    if (documentDesc == null) {
      throw new BuiltValueNullFieldError(
          'TechnicianImageRepair', 'documentDesc');
    }
    if (documentFilename == null) {
      throw new BuiltValueNullFieldError(
          'TechnicianImageRepair', 'documentFilename');
    }
    if (documentSrc == null) {
      throw new BuiltValueNullFieldError(
          'TechnicianImageRepair', 'documentSrc');
    }
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
    return $jf($jc(
        $jc(
            $jc(
                $jc(
                    $jc(
                        $jc(
                            $jc(
                                $jc(
                                    $jc(
                                        $jc(
                                            $jc($jc(0, woTaskUploadId.hashCode),
                                                woTaskUploadType.hashCode),
                                            woTaskId.hashCode),
                                        woTaskUploadLongitude.hashCode),
                                    woTaskUploadLatitude.hashCode),
                                woTaskUploadTimestamp.hashCode),
                            woTaskUploadDesc.hashCode),
                        uploadId.hashCode),
                    uploadName.hashCode),
                documentDesc.hashCode),
            documentFilename.hashCode),
        documentSrc.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('TechnicianImageRepair')
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
  _$TechnicianImageRepair _$v;

  String _woTaskUploadId;
  String get woTaskUploadId => _$this._woTaskUploadId;
  set woTaskUploadId(String woTaskUploadId) =>
      _$this._woTaskUploadId = woTaskUploadId;

  String _woTaskUploadType;
  String get woTaskUploadType => _$this._woTaskUploadType;
  set woTaskUploadType(String woTaskUploadType) =>
      _$this._woTaskUploadType = woTaskUploadType;

  String _woTaskId;
  String get woTaskId => _$this._woTaskId;
  set woTaskId(String woTaskId) => _$this._woTaskId = woTaskId;

  String _woTaskUploadLongitude;
  String get woTaskUploadLongitude => _$this._woTaskUploadLongitude;
  set woTaskUploadLongitude(String woTaskUploadLongitude) =>
      _$this._woTaskUploadLongitude = woTaskUploadLongitude;

  String _woTaskUploadLatitude;
  String get woTaskUploadLatitude => _$this._woTaskUploadLatitude;
  set woTaskUploadLatitude(String woTaskUploadLatitude) =>
      _$this._woTaskUploadLatitude = woTaskUploadLatitude;

  String _woTaskUploadTimestamp;
  String get woTaskUploadTimestamp => _$this._woTaskUploadTimestamp;
  set woTaskUploadTimestamp(String woTaskUploadTimestamp) =>
      _$this._woTaskUploadTimestamp = woTaskUploadTimestamp;

  String _woTaskUploadDesc;
  String get woTaskUploadDesc => _$this._woTaskUploadDesc;
  set woTaskUploadDesc(String woTaskUploadDesc) =>
      _$this._woTaskUploadDesc = woTaskUploadDesc;

  String _uploadId;
  String get uploadId => _$this._uploadId;
  set uploadId(String uploadId) => _$this._uploadId = uploadId;

  String _uploadName;
  String get uploadName => _$this._uploadName;
  set uploadName(String uploadName) => _$this._uploadName = uploadName;

  String _documentDesc;
  String get documentDesc => _$this._documentDesc;
  set documentDesc(String documentDesc) => _$this._documentDesc = documentDesc;

  String _documentFilename;
  String get documentFilename => _$this._documentFilename;
  set documentFilename(String documentFilename) =>
      _$this._documentFilename = documentFilename;

  String _documentSrc;
  String get documentSrc => _$this._documentSrc;
  set documentSrc(String documentSrc) => _$this._documentSrc = documentSrc;

  TechnicianImageRepairBuilder();

  TechnicianImageRepairBuilder get _$this {
    if (_$v != null) {
      _woTaskUploadId = _$v.woTaskUploadId;
      _woTaskUploadType = _$v.woTaskUploadType;
      _woTaskId = _$v.woTaskId;
      _woTaskUploadLongitude = _$v.woTaskUploadLongitude;
      _woTaskUploadLatitude = _$v.woTaskUploadLatitude;
      _woTaskUploadTimestamp = _$v.woTaskUploadTimestamp;
      _woTaskUploadDesc = _$v.woTaskUploadDesc;
      _uploadId = _$v.uploadId;
      _uploadName = _$v.uploadName;
      _documentDesc = _$v.documentDesc;
      _documentFilename = _$v.documentFilename;
      _documentSrc = _$v.documentSrc;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TechnicianImageRepair other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$TechnicianImageRepair;
  }

  @override
  void update(void Function(TechnicianImageRepairBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$TechnicianImageRepair build() {
    final _$result = _$v ??
        new _$TechnicianImageRepair._(
            woTaskUploadId: woTaskUploadId,
            woTaskUploadType: woTaskUploadType,
            woTaskId: woTaskId,
            woTaskUploadLongitude: woTaskUploadLongitude,
            woTaskUploadLatitude: woTaskUploadLatitude,
            woTaskUploadTimestamp: woTaskUploadTimestamp,
            woTaskUploadDesc: woTaskUploadDesc,
            uploadId: uploadId,
            uploadName: uploadName,
            documentDesc: documentDesc,
            documentFilename: documentFilename,
            documentSrc: documentSrc);
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
  final BuiltList<String> assistUserId;

  factory _$TechnicianAssign(
          [void Function(TechnicianAssignBuilder) updates]) =>
      (new TechnicianAssignBuilder()..update(updates)).build();

  _$TechnicianAssign._(
      {this.userId,
      this.severity,
      this.groupId,
      this.woTaskCategory,
      this.userCategory,
      this.assistUserId})
      : super._() {
    if (userId == null) {
      throw new BuiltValueNullFieldError('TechnicianAssign', 'userId');
    }
    if (severity == null) {
      throw new BuiltValueNullFieldError('TechnicianAssign', 'severity');
    }
    if (groupId == null) {
      throw new BuiltValueNullFieldError('TechnicianAssign', 'groupId');
    }
    if (woTaskCategory == null) {
      throw new BuiltValueNullFieldError('TechnicianAssign', 'woTaskCategory');
    }
    if (userCategory == null) {
      throw new BuiltValueNullFieldError('TechnicianAssign', 'userCategory');
    }
    if (assistUserId == null) {
      throw new BuiltValueNullFieldError('TechnicianAssign', 'assistUserId');
    }
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
        assistUserId == other.assistUserId;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc($jc($jc(0, userId.hashCode), severity.hashCode),
                    groupId.hashCode),
                woTaskCategory.hashCode),
            userCategory.hashCode),
        assistUserId.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('TechnicianAssign')
          ..add('userId', userId)
          ..add('severity', severity)
          ..add('groupId', groupId)
          ..add('woTaskCategory', woTaskCategory)
          ..add('userCategory', userCategory)
          ..add('assistUserId', assistUserId))
        .toString();
  }
}

class TechnicianAssignBuilder
    implements Builder<TechnicianAssign, TechnicianAssignBuilder> {
  _$TechnicianAssign _$v;

  String _userId;
  String get userId => _$this._userId;
  set userId(String userId) => _$this._userId = userId;

  String _severity;
  String get severity => _$this._severity;
  set severity(String severity) => _$this._severity = severity;

  String _groupId;
  String get groupId => _$this._groupId;
  set groupId(String groupId) => _$this._groupId = groupId;

  String _woTaskCategory;
  String get woTaskCategory => _$this._woTaskCategory;
  set woTaskCategory(String woTaskCategory) =>
      _$this._woTaskCategory = woTaskCategory;

  String _userCategory;
  String get userCategory => _$this._userCategory;
  set userCategory(String userCategory) => _$this._userCategory = userCategory;

  ListBuilder<String> _assistUserId;
  ListBuilder<String> get assistUserId =>
      _$this._assistUserId ??= new ListBuilder<String>();
  set assistUserId(ListBuilder<String> assistUserId) =>
      _$this._assistUserId = assistUserId;

  TechnicianAssignBuilder();

  TechnicianAssignBuilder get _$this {
    if (_$v != null) {
      _userId = _$v.userId;
      _severity = _$v.severity;
      _groupId = _$v.groupId;
      _woTaskCategory = _$v.woTaskCategory;
      _userCategory = _$v.userCategory;
      _assistUserId = _$v.assistUserId?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TechnicianAssign other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$TechnicianAssign;
  }

  @override
  void update(void Function(TechnicianAssignBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$TechnicianAssign build() {
    _$TechnicianAssign _$result;
    try {
      _$result = _$v ??
          new _$TechnicianAssign._(
              userId: userId,
              severity: severity,
              groupId: groupId,
              woTaskCategory: woTaskCategory,
              userCategory: userCategory,
              assistUserId: assistUserId.build());
    } catch (_) {
      String _$failedField;
      try {
        _$failedField = 'assistUserId';
        assistUserId.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'TechnicianAssign', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new

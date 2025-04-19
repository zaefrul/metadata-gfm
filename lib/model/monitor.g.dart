// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monitor.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<MonitorTask> _$monitorTaskSerializer = new _$MonitorTaskSerializer();
Serializer<MonitorDetail> _$monitorDetailSerializer =
    new _$MonitorDetailSerializer();
Serializer<MonitorHistory> _$monitorHistorySerializer =
    new _$MonitorHistorySerializer();

class _$MonitorTaskSerializer implements StructuredSerializer<MonitorTask> {
  @override
  final Iterable<Type> types = const [MonitorTask, _$MonitorTask];
  @override
  final String wireName = 'MonitorTask';

  @override
  Iterable<Object?> serialize(Serializers serializers, MonitorTask object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'transactionId',
      serializers.serialize(object.transactionId,
          specifiedType: const FullType(String)),
      'transactionNo',
      serializers.serialize(object.transactionNo,
          specifiedType: const FullType(String)),
      'transactionTimeCreated',
      serializers.serialize(object.transactionTimeCreated,
          specifiedType: const FullType(String)),
      'flowId',
      serializers.serialize(object.flowId,
          specifiedType: const FullType(String)),
      'flowName',
      serializers.serialize(object.flowName,
          specifiedType: const FullType(String)),
      'checkpointName',
      serializers.serialize(object.checkpointName,
          specifiedType: const FullType(String)),
      'transactionStatus',
      serializers.serialize(object.transactionStatus,
          specifiedType: const FullType(String)),
    ];
    Object? value;
    value = object.userFullName;
    if (value != null) {
      result
        ..add('userFullName')
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
    value = object.currentTaskOwner;
    if (value != null) {
      result
        ..add('currentTaskOwner')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.woTaskType;
    if (value != null) {
      result
        ..add('woTaskType')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.woTaskSeverity;
    if (value != null) {
      result
        ..add('woTaskSeverity')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.assignedTo;
    if (value != null) {
      result
        ..add('assignedTo')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  MonitorTask deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new MonitorTaskBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'transactionId':
          result.transactionId = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'transactionNo':
          result.transactionNo = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'transactionTimeCreated':
          result.transactionTimeCreated = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'flowId':
          result.flowId = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'flowName':
          result.flowName = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'checkpointName':
          result.checkpointName = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'transactionStatus':
          result.transactionStatus = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'userFullName':
          result.userFullName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'assetNo':
          result.assetNo = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'currentTaskOwner':
          result.currentTaskOwner = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'woTaskType':
          result.woTaskType = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'woTaskSeverity':
          result.woTaskSeverity = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'assignedTo':
          result.assignedTo = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
      }
    }

    return result.build();
  }
}

class _$MonitorDetailSerializer implements StructuredSerializer<MonitorDetail> {
  @override
  final Iterable<Type> types = const [MonitorDetail, _$MonitorDetail];
  @override
  final String wireName = 'MonitorDetail';

  @override
  Iterable<Object?> serialize(Serializers serializers, MonitorDetail object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'flowName',
      serializers.serialize(object.flowName,
          specifiedType: const FullType(String)),
      'transactionNo',
      serializers.serialize(object.transactionNo,
          specifiedType: const FullType(String)),
      'initiateBy',
      serializers.serialize(object.initiateBy,
          specifiedType: const FullType(String)),
      'initiateByGroup',
      serializers.serialize(object.initiateByGroup,
          specifiedType: const FullType(String)),
      'initiateTimeCreated',
      serializers.serialize(object.initiateTimeCreated,
          specifiedType: const FullType(String)),
      'taskStatus',
      serializers.serialize(object.taskStatus,
          specifiedType: const FullType(String)),
      'currentUser',
      serializers.serialize(object.currentUser,
          specifiedType: const FullType(String)),
      'receivedTime',
      serializers.serialize(object.receivedTime,
          specifiedType: const FullType(String)),
      'flowStatus',
      serializers.serialize(object.flowStatus,
          specifiedType: const FullType(String)),
      'flowDueDate',
      serializers.serialize(object.flowDueDate,
          specifiedType: const FullType(String)),
      'checkpointId',
      serializers.serialize(object.checkpointId,
          specifiedType: const FullType(String)),
      'taskHistory',
      serializers.serialize(object.taskHistory,
          specifiedType: const FullType(
              BuiltList, const [const FullType(MonitorHistory)])),
    ];
    Object? value;
    value = object.woTaskId;
    if (value != null) {
      result
        ..add('woTaskId')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.ppmTaskId;
    if (value != null) {
      result
        ..add('ppmTaskId')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.siteName;
    if (value != null) {
      result
        ..add('siteName')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  MonitorDetail deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new MonitorDetailBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'flowName':
          result.flowName = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'transactionNo':
          result.transactionNo = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'initiateBy':
          result.initiateBy = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'initiateByGroup':
          result.initiateByGroup = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'initiateTimeCreated':
          result.initiateTimeCreated = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'taskStatus':
          result.taskStatus = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'currentUser':
          result.currentUser = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'receivedTime':
          result.receivedTime = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'flowStatus':
          result.flowStatus = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'flowDueDate':
          result.flowDueDate = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'checkpointId':
          result.checkpointId = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'woTaskId':
          result.woTaskId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'ppmTaskId':
          result.ppmTaskId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'siteName':
          result.siteName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'taskHistory':
          result.taskHistory.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(MonitorHistory)]))!
              as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$MonitorHistorySerializer
    implements StructuredSerializer<MonitorHistory> {
  @override
  final Iterable<Type> types = const [MonitorHistory, _$MonitorHistory];
  @override
  final String wireName = 'MonitorHistory';

  @override
  Iterable<Object?> serialize(Serializers serializers, MonitorHistory object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'checkpointId',
      serializers.serialize(object.checkpointId,
          specifiedType: const FullType(String)),
      'roleId',
      serializers.serialize(object.roleId,
          specifiedType: const FullType(String)),
      'taskClaimedUser',
      serializers.serialize(object.taskClaimedUser,
          specifiedType: const FullType(String)),
      'taskRemark',
      serializers.serialize(object.taskRemark,
          specifiedType: const FullType(String)),
      'taskDateDue',
      serializers.serialize(object.taskDateDue,
          specifiedType: const FullType(String)),
      'taskTimeCreated',
      serializers.serialize(object.taskTimeCreated,
          specifiedType: const FullType(String)),
      'taskTimeSubmit',
      serializers.serialize(object.taskTimeSubmit,
          specifiedType: const FullType(String)),
      'taskStatus',
      serializers.serialize(object.taskStatus,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  MonitorHistory deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new MonitorHistoryBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'checkpointId':
          result.checkpointId = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'roleId':
          result.roleId = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'taskClaimedUser':
          result.taskClaimedUser = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'taskRemark':
          result.taskRemark = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'taskDateDue':
          result.taskDateDue = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'taskTimeCreated':
          result.taskTimeCreated = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'taskTimeSubmit':
          result.taskTimeSubmit = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'taskStatus':
          result.taskStatus = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$MonitorTask extends MonitorTask {
  @override
  final String transactionId;
  @override
  final String transactionNo;
  @override
  final String transactionTimeCreated;
  @override
  final String flowId;
  @override
  final String flowName;
  @override
  final String checkpointName;
  @override
  final String transactionStatus;
  @override
  final String? userFullName;
  @override
  final String? assetNo;
  @override
  final String? currentTaskOwner;
  @override
  final String? woTaskType;
  @override
  final String? woTaskSeverity;
  @override
  final String? assignedTo;

  factory _$MonitorTask([void Function(MonitorTaskBuilder)? updates]) =>
      (new MonitorTaskBuilder()..update(updates))._build();

  _$MonitorTask._(
      {required this.transactionId,
      required this.transactionNo,
      required this.transactionTimeCreated,
      required this.flowId,
      required this.flowName,
      required this.checkpointName,
      required this.transactionStatus,
      this.userFullName,
      this.assetNo,
      this.currentTaskOwner,
      this.woTaskType,
      this.woTaskSeverity,
      this.assignedTo})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        transactionId, r'MonitorTask', 'transactionId');
    BuiltValueNullFieldError.checkNotNull(
        transactionNo, r'MonitorTask', 'transactionNo');
    BuiltValueNullFieldError.checkNotNull(
        transactionTimeCreated, r'MonitorTask', 'transactionTimeCreated');
    BuiltValueNullFieldError.checkNotNull(flowId, r'MonitorTask', 'flowId');
    BuiltValueNullFieldError.checkNotNull(flowName, r'MonitorTask', 'flowName');
    BuiltValueNullFieldError.checkNotNull(
        checkpointName, r'MonitorTask', 'checkpointName');
    BuiltValueNullFieldError.checkNotNull(
        transactionStatus, r'MonitorTask', 'transactionStatus');
  }

  @override
  MonitorTask rebuild(void Function(MonitorTaskBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MonitorTaskBuilder toBuilder() => new MonitorTaskBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MonitorTask &&
        transactionId == other.transactionId &&
        transactionNo == other.transactionNo &&
        transactionTimeCreated == other.transactionTimeCreated &&
        flowId == other.flowId &&
        flowName == other.flowName &&
        checkpointName == other.checkpointName &&
        transactionStatus == other.transactionStatus &&
        userFullName == other.userFullName &&
        assetNo == other.assetNo &&
        currentTaskOwner == other.currentTaskOwner &&
        woTaskType == other.woTaskType &&
        woTaskSeverity == other.woTaskSeverity &&
        assignedTo == other.assignedTo;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, transactionId.hashCode);
    _$hash = $jc(_$hash, transactionNo.hashCode);
    _$hash = $jc(_$hash, transactionTimeCreated.hashCode);
    _$hash = $jc(_$hash, flowId.hashCode);
    _$hash = $jc(_$hash, flowName.hashCode);
    _$hash = $jc(_$hash, checkpointName.hashCode);
    _$hash = $jc(_$hash, transactionStatus.hashCode);
    _$hash = $jc(_$hash, userFullName.hashCode);
    _$hash = $jc(_$hash, assetNo.hashCode);
    _$hash = $jc(_$hash, currentTaskOwner.hashCode);
    _$hash = $jc(_$hash, woTaskType.hashCode);
    _$hash = $jc(_$hash, woTaskSeverity.hashCode);
    _$hash = $jc(_$hash, assignedTo.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MonitorTask')
          ..add('transactionId', transactionId)
          ..add('transactionNo', transactionNo)
          ..add('transactionTimeCreated', transactionTimeCreated)
          ..add('flowId', flowId)
          ..add('flowName', flowName)
          ..add('checkpointName', checkpointName)
          ..add('transactionStatus', transactionStatus)
          ..add('userFullName', userFullName)
          ..add('assetNo', assetNo)
          ..add('currentTaskOwner', currentTaskOwner)
          ..add('woTaskType', woTaskType)
          ..add('woTaskSeverity', woTaskSeverity)
          ..add('assignedTo', assignedTo))
        .toString();
  }
}

class MonitorTaskBuilder implements Builder<MonitorTask, MonitorTaskBuilder> {
  _$MonitorTask? _$v;

  String? _transactionId;
  String? get transactionId => _$this._transactionId;
  set transactionId(String? transactionId) =>
      _$this._transactionId = transactionId;

  String? _transactionNo;
  String? get transactionNo => _$this._transactionNo;
  set transactionNo(String? transactionNo) =>
      _$this._transactionNo = transactionNo;

  String? _transactionTimeCreated;
  String? get transactionTimeCreated => _$this._transactionTimeCreated;
  set transactionTimeCreated(String? transactionTimeCreated) =>
      _$this._transactionTimeCreated = transactionTimeCreated;

  String? _flowId;
  String? get flowId => _$this._flowId;
  set flowId(String? flowId) => _$this._flowId = flowId;

  String? _flowName;
  String? get flowName => _$this._flowName;
  set flowName(String? flowName) => _$this._flowName = flowName;

  String? _checkpointName;
  String? get checkpointName => _$this._checkpointName;
  set checkpointName(String? checkpointName) =>
      _$this._checkpointName = checkpointName;

  String? _transactionStatus;
  String? get transactionStatus => _$this._transactionStatus;
  set transactionStatus(String? transactionStatus) =>
      _$this._transactionStatus = transactionStatus;

  String? _userFullName;
  String? get userFullName => _$this._userFullName;
  set userFullName(String? userFullName) => _$this._userFullName = userFullName;

  String? _assetNo;
  String? get assetNo => _$this._assetNo;
  set assetNo(String? assetNo) => _$this._assetNo = assetNo;

  String? _currentTaskOwner;
  String? get currentTaskOwner => _$this._currentTaskOwner;
  set currentTaskOwner(String? currentTaskOwner) =>
      _$this._currentTaskOwner = currentTaskOwner;

  String? _woTaskType;
  String? get woTaskType => _$this._woTaskType;
  set woTaskType(String? woTaskType) => _$this._woTaskType = woTaskType;

  String? _woTaskSeverity;
  String? get woTaskSeverity => _$this._woTaskSeverity;
  set woTaskSeverity(String? woTaskSeverity) =>
      _$this._woTaskSeverity = woTaskSeverity;

  String? _assignedTo;
  String? get assignedTo => _$this._assignedTo;
  set assignedTo(String? assignedTo) => _$this._assignedTo = assignedTo;

  MonitorTaskBuilder();

  MonitorTaskBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _transactionId = $v.transactionId;
      _transactionNo = $v.transactionNo;
      _transactionTimeCreated = $v.transactionTimeCreated;
      _flowId = $v.flowId;
      _flowName = $v.flowName;
      _checkpointName = $v.checkpointName;
      _transactionStatus = $v.transactionStatus;
      _userFullName = $v.userFullName;
      _assetNo = $v.assetNo;
      _currentTaskOwner = $v.currentTaskOwner;
      _woTaskType = $v.woTaskType;
      _woTaskSeverity = $v.woTaskSeverity;
      _assignedTo = $v.assignedTo;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MonitorTask other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$MonitorTask;
  }

  @override
  void update(void Function(MonitorTaskBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MonitorTask build() => _build();

  _$MonitorTask _build() {
    final _$result = _$v ??
        new _$MonitorTask._(
          transactionId: BuiltValueNullFieldError.checkNotNull(
              transactionId, r'MonitorTask', 'transactionId'),
          transactionNo: BuiltValueNullFieldError.checkNotNull(
              transactionNo, r'MonitorTask', 'transactionNo'),
          transactionTimeCreated: BuiltValueNullFieldError.checkNotNull(
              transactionTimeCreated, r'MonitorTask', 'transactionTimeCreated'),
          flowId: BuiltValueNullFieldError.checkNotNull(
              flowId, r'MonitorTask', 'flowId'),
          flowName: BuiltValueNullFieldError.checkNotNull(
              flowName, r'MonitorTask', 'flowName'),
          checkpointName: BuiltValueNullFieldError.checkNotNull(
              checkpointName, r'MonitorTask', 'checkpointName'),
          transactionStatus: BuiltValueNullFieldError.checkNotNull(
              transactionStatus, r'MonitorTask', 'transactionStatus'),
          userFullName: userFullName,
          assetNo: assetNo,
          currentTaskOwner: currentTaskOwner,
          woTaskType: woTaskType,
          woTaskSeverity: woTaskSeverity,
          assignedTo: assignedTo,
        );
    replace(_$result);
    return _$result;
  }
}

class _$MonitorDetail extends MonitorDetail {
  @override
  final String flowName;
  @override
  final String transactionNo;
  @override
  final String initiateBy;
  @override
  final String initiateByGroup;
  @override
  final String initiateTimeCreated;
  @override
  final String taskStatus;
  @override
  final String currentUser;
  @override
  final String receivedTime;
  @override
  final String flowStatus;
  @override
  final String flowDueDate;
  @override
  final String checkpointId;
  @override
  final String? woTaskId;
  @override
  final String? ppmTaskId;
  @override
  final String? siteName;
  @override
  final BuiltList<MonitorHistory> taskHistory;

  factory _$MonitorDetail([void Function(MonitorDetailBuilder)? updates]) =>
      (new MonitorDetailBuilder()..update(updates))._build();

  _$MonitorDetail._(
      {required this.flowName,
      required this.transactionNo,
      required this.initiateBy,
      required this.initiateByGroup,
      required this.initiateTimeCreated,
      required this.taskStatus,
      required this.currentUser,
      required this.receivedTime,
      required this.flowStatus,
      required this.flowDueDate,
      required this.checkpointId,
      this.woTaskId,
      this.ppmTaskId,
      this.siteName,
      required this.taskHistory})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        flowName, r'MonitorDetail', 'flowName');
    BuiltValueNullFieldError.checkNotNull(
        transactionNo, r'MonitorDetail', 'transactionNo');
    BuiltValueNullFieldError.checkNotNull(
        initiateBy, r'MonitorDetail', 'initiateBy');
    BuiltValueNullFieldError.checkNotNull(
        initiateByGroup, r'MonitorDetail', 'initiateByGroup');
    BuiltValueNullFieldError.checkNotNull(
        initiateTimeCreated, r'MonitorDetail', 'initiateTimeCreated');
    BuiltValueNullFieldError.checkNotNull(
        taskStatus, r'MonitorDetail', 'taskStatus');
    BuiltValueNullFieldError.checkNotNull(
        currentUser, r'MonitorDetail', 'currentUser');
    BuiltValueNullFieldError.checkNotNull(
        receivedTime, r'MonitorDetail', 'receivedTime');
    BuiltValueNullFieldError.checkNotNull(
        flowStatus, r'MonitorDetail', 'flowStatus');
    BuiltValueNullFieldError.checkNotNull(
        flowDueDate, r'MonitorDetail', 'flowDueDate');
    BuiltValueNullFieldError.checkNotNull(
        checkpointId, r'MonitorDetail', 'checkpointId');
    BuiltValueNullFieldError.checkNotNull(
        taskHistory, r'MonitorDetail', 'taskHistory');
  }

  @override
  MonitorDetail rebuild(void Function(MonitorDetailBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MonitorDetailBuilder toBuilder() => new MonitorDetailBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MonitorDetail &&
        flowName == other.flowName &&
        transactionNo == other.transactionNo &&
        initiateBy == other.initiateBy &&
        initiateByGroup == other.initiateByGroup &&
        initiateTimeCreated == other.initiateTimeCreated &&
        taskStatus == other.taskStatus &&
        currentUser == other.currentUser &&
        receivedTime == other.receivedTime &&
        flowStatus == other.flowStatus &&
        flowDueDate == other.flowDueDate &&
        checkpointId == other.checkpointId &&
        woTaskId == other.woTaskId &&
        ppmTaskId == other.ppmTaskId &&
        siteName == other.siteName &&
        taskHistory == other.taskHistory;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, flowName.hashCode);
    _$hash = $jc(_$hash, transactionNo.hashCode);
    _$hash = $jc(_$hash, initiateBy.hashCode);
    _$hash = $jc(_$hash, initiateByGroup.hashCode);
    _$hash = $jc(_$hash, initiateTimeCreated.hashCode);
    _$hash = $jc(_$hash, taskStatus.hashCode);
    _$hash = $jc(_$hash, currentUser.hashCode);
    _$hash = $jc(_$hash, receivedTime.hashCode);
    _$hash = $jc(_$hash, flowStatus.hashCode);
    _$hash = $jc(_$hash, flowDueDate.hashCode);
    _$hash = $jc(_$hash, checkpointId.hashCode);
    _$hash = $jc(_$hash, woTaskId.hashCode);
    _$hash = $jc(_$hash, ppmTaskId.hashCode);
    _$hash = $jc(_$hash, siteName.hashCode);
    _$hash = $jc(_$hash, taskHistory.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MonitorDetail')
          ..add('flowName', flowName)
          ..add('transactionNo', transactionNo)
          ..add('initiateBy', initiateBy)
          ..add('initiateByGroup', initiateByGroup)
          ..add('initiateTimeCreated', initiateTimeCreated)
          ..add('taskStatus', taskStatus)
          ..add('currentUser', currentUser)
          ..add('receivedTime', receivedTime)
          ..add('flowStatus', flowStatus)
          ..add('flowDueDate', flowDueDate)
          ..add('checkpointId', checkpointId)
          ..add('woTaskId', woTaskId)
          ..add('ppmTaskId', ppmTaskId)
          ..add('siteName', siteName)
          ..add('taskHistory', taskHistory))
        .toString();
  }
}

class MonitorDetailBuilder
    implements Builder<MonitorDetail, MonitorDetailBuilder> {
  _$MonitorDetail? _$v;

  String? _flowName;
  String? get flowName => _$this._flowName;
  set flowName(String? flowName) => _$this._flowName = flowName;

  String? _transactionNo;
  String? get transactionNo => _$this._transactionNo;
  set transactionNo(String? transactionNo) =>
      _$this._transactionNo = transactionNo;

  String? _initiateBy;
  String? get initiateBy => _$this._initiateBy;
  set initiateBy(String? initiateBy) => _$this._initiateBy = initiateBy;

  String? _initiateByGroup;
  String? get initiateByGroup => _$this._initiateByGroup;
  set initiateByGroup(String? initiateByGroup) =>
      _$this._initiateByGroup = initiateByGroup;

  String? _initiateTimeCreated;
  String? get initiateTimeCreated => _$this._initiateTimeCreated;
  set initiateTimeCreated(String? initiateTimeCreated) =>
      _$this._initiateTimeCreated = initiateTimeCreated;

  String? _taskStatus;
  String? get taskStatus => _$this._taskStatus;
  set taskStatus(String? taskStatus) => _$this._taskStatus = taskStatus;

  String? _currentUser;
  String? get currentUser => _$this._currentUser;
  set currentUser(String? currentUser) => _$this._currentUser = currentUser;

  String? _receivedTime;
  String? get receivedTime => _$this._receivedTime;
  set receivedTime(String? receivedTime) => _$this._receivedTime = receivedTime;

  String? _flowStatus;
  String? get flowStatus => _$this._flowStatus;
  set flowStatus(String? flowStatus) => _$this._flowStatus = flowStatus;

  String? _flowDueDate;
  String? get flowDueDate => _$this._flowDueDate;
  set flowDueDate(String? flowDueDate) => _$this._flowDueDate = flowDueDate;

  String? _checkpointId;
  String? get checkpointId => _$this._checkpointId;
  set checkpointId(String? checkpointId) => _$this._checkpointId = checkpointId;

  String? _woTaskId;
  String? get woTaskId => _$this._woTaskId;
  set woTaskId(String? woTaskId) => _$this._woTaskId = woTaskId;

  String? _ppmTaskId;
  String? get ppmTaskId => _$this._ppmTaskId;
  set ppmTaskId(String? ppmTaskId) => _$this._ppmTaskId = ppmTaskId;

  String? _siteName;
  String? get siteName => _$this._siteName;
  set siteName(String? siteName) => _$this._siteName = siteName;

  ListBuilder<MonitorHistory>? _taskHistory;
  ListBuilder<MonitorHistory> get taskHistory =>
      _$this._taskHistory ??= new ListBuilder<MonitorHistory>();
  set taskHistory(ListBuilder<MonitorHistory>? taskHistory) =>
      _$this._taskHistory = taskHistory;

  MonitorDetailBuilder();

  MonitorDetailBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _flowName = $v.flowName;
      _transactionNo = $v.transactionNo;
      _initiateBy = $v.initiateBy;
      _initiateByGroup = $v.initiateByGroup;
      _initiateTimeCreated = $v.initiateTimeCreated;
      _taskStatus = $v.taskStatus;
      _currentUser = $v.currentUser;
      _receivedTime = $v.receivedTime;
      _flowStatus = $v.flowStatus;
      _flowDueDate = $v.flowDueDate;
      _checkpointId = $v.checkpointId;
      _woTaskId = $v.woTaskId;
      _ppmTaskId = $v.ppmTaskId;
      _siteName = $v.siteName;
      _taskHistory = $v.taskHistory.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MonitorDetail other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$MonitorDetail;
  }

  @override
  void update(void Function(MonitorDetailBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MonitorDetail build() => _build();

  _$MonitorDetail _build() {
    _$MonitorDetail _$result;
    try {
      _$result = _$v ??
          new _$MonitorDetail._(
            flowName: BuiltValueNullFieldError.checkNotNull(
                flowName, r'MonitorDetail', 'flowName'),
            transactionNo: BuiltValueNullFieldError.checkNotNull(
                transactionNo, r'MonitorDetail', 'transactionNo'),
            initiateBy: BuiltValueNullFieldError.checkNotNull(
                initiateBy, r'MonitorDetail', 'initiateBy'),
            initiateByGroup: BuiltValueNullFieldError.checkNotNull(
                initiateByGroup, r'MonitorDetail', 'initiateByGroup'),
            initiateTimeCreated: BuiltValueNullFieldError.checkNotNull(
                initiateTimeCreated, r'MonitorDetail', 'initiateTimeCreated'),
            taskStatus: BuiltValueNullFieldError.checkNotNull(
                taskStatus, r'MonitorDetail', 'taskStatus'),
            currentUser: BuiltValueNullFieldError.checkNotNull(
                currentUser, r'MonitorDetail', 'currentUser'),
            receivedTime: BuiltValueNullFieldError.checkNotNull(
                receivedTime, r'MonitorDetail', 'receivedTime'),
            flowStatus: BuiltValueNullFieldError.checkNotNull(
                flowStatus, r'MonitorDetail', 'flowStatus'),
            flowDueDate: BuiltValueNullFieldError.checkNotNull(
                flowDueDate, r'MonitorDetail', 'flowDueDate'),
            checkpointId: BuiltValueNullFieldError.checkNotNull(
                checkpointId, r'MonitorDetail', 'checkpointId'),
            woTaskId: woTaskId,
            ppmTaskId: ppmTaskId,
            siteName: siteName,
            taskHistory: taskHistory.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'taskHistory';
        taskHistory.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'MonitorDetail', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$MonitorHistory extends MonitorHistory {
  @override
  final String checkpointId;
  @override
  final String roleId;
  @override
  final String taskClaimedUser;
  @override
  final String taskRemark;
  @override
  final String taskDateDue;
  @override
  final String taskTimeCreated;
  @override
  final String taskTimeSubmit;
  @override
  final String taskStatus;

  factory _$MonitorHistory([void Function(MonitorHistoryBuilder)? updates]) =>
      (new MonitorHistoryBuilder()..update(updates))._build();

  _$MonitorHistory._(
      {required this.checkpointId,
      required this.roleId,
      required this.taskClaimedUser,
      required this.taskRemark,
      required this.taskDateDue,
      required this.taskTimeCreated,
      required this.taskTimeSubmit,
      required this.taskStatus})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        checkpointId, r'MonitorHistory', 'checkpointId');
    BuiltValueNullFieldError.checkNotNull(roleId, r'MonitorHistory', 'roleId');
    BuiltValueNullFieldError.checkNotNull(
        taskClaimedUser, r'MonitorHistory', 'taskClaimedUser');
    BuiltValueNullFieldError.checkNotNull(
        taskRemark, r'MonitorHistory', 'taskRemark');
    BuiltValueNullFieldError.checkNotNull(
        taskDateDue, r'MonitorHistory', 'taskDateDue');
    BuiltValueNullFieldError.checkNotNull(
        taskTimeCreated, r'MonitorHistory', 'taskTimeCreated');
    BuiltValueNullFieldError.checkNotNull(
        taskTimeSubmit, r'MonitorHistory', 'taskTimeSubmit');
    BuiltValueNullFieldError.checkNotNull(
        taskStatus, r'MonitorHistory', 'taskStatus');
  }

  @override
  MonitorHistory rebuild(void Function(MonitorHistoryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MonitorHistoryBuilder toBuilder() =>
      new MonitorHistoryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MonitorHistory &&
        checkpointId == other.checkpointId &&
        roleId == other.roleId &&
        taskClaimedUser == other.taskClaimedUser &&
        taskRemark == other.taskRemark &&
        taskDateDue == other.taskDateDue &&
        taskTimeCreated == other.taskTimeCreated &&
        taskTimeSubmit == other.taskTimeSubmit &&
        taskStatus == other.taskStatus;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, checkpointId.hashCode);
    _$hash = $jc(_$hash, roleId.hashCode);
    _$hash = $jc(_$hash, taskClaimedUser.hashCode);
    _$hash = $jc(_$hash, taskRemark.hashCode);
    _$hash = $jc(_$hash, taskDateDue.hashCode);
    _$hash = $jc(_$hash, taskTimeCreated.hashCode);
    _$hash = $jc(_$hash, taskTimeSubmit.hashCode);
    _$hash = $jc(_$hash, taskStatus.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MonitorHistory')
          ..add('checkpointId', checkpointId)
          ..add('roleId', roleId)
          ..add('taskClaimedUser', taskClaimedUser)
          ..add('taskRemark', taskRemark)
          ..add('taskDateDue', taskDateDue)
          ..add('taskTimeCreated', taskTimeCreated)
          ..add('taskTimeSubmit', taskTimeSubmit)
          ..add('taskStatus', taskStatus))
        .toString();
  }
}

class MonitorHistoryBuilder
    implements Builder<MonitorHistory, MonitorHistoryBuilder> {
  _$MonitorHistory? _$v;

  String? _checkpointId;
  String? get checkpointId => _$this._checkpointId;
  set checkpointId(String? checkpointId) => _$this._checkpointId = checkpointId;

  String? _roleId;
  String? get roleId => _$this._roleId;
  set roleId(String? roleId) => _$this._roleId = roleId;

  String? _taskClaimedUser;
  String? get taskClaimedUser => _$this._taskClaimedUser;
  set taskClaimedUser(String? taskClaimedUser) =>
      _$this._taskClaimedUser = taskClaimedUser;

  String? _taskRemark;
  String? get taskRemark => _$this._taskRemark;
  set taskRemark(String? taskRemark) => _$this._taskRemark = taskRemark;

  String? _taskDateDue;
  String? get taskDateDue => _$this._taskDateDue;
  set taskDateDue(String? taskDateDue) => _$this._taskDateDue = taskDateDue;

  String? _taskTimeCreated;
  String? get taskTimeCreated => _$this._taskTimeCreated;
  set taskTimeCreated(String? taskTimeCreated) =>
      _$this._taskTimeCreated = taskTimeCreated;

  String? _taskTimeSubmit;
  String? get taskTimeSubmit => _$this._taskTimeSubmit;
  set taskTimeSubmit(String? taskTimeSubmit) =>
      _$this._taskTimeSubmit = taskTimeSubmit;

  String? _taskStatus;
  String? get taskStatus => _$this._taskStatus;
  set taskStatus(String? taskStatus) => _$this._taskStatus = taskStatus;

  MonitorHistoryBuilder();

  MonitorHistoryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _checkpointId = $v.checkpointId;
      _roleId = $v.roleId;
      _taskClaimedUser = $v.taskClaimedUser;
      _taskRemark = $v.taskRemark;
      _taskDateDue = $v.taskDateDue;
      _taskTimeCreated = $v.taskTimeCreated;
      _taskTimeSubmit = $v.taskTimeSubmit;
      _taskStatus = $v.taskStatus;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MonitorHistory other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$MonitorHistory;
  }

  @override
  void update(void Function(MonitorHistoryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MonitorHistory build() => _build();

  _$MonitorHistory _build() {
    final _$result = _$v ??
        new _$MonitorHistory._(
          checkpointId: BuiltValueNullFieldError.checkNotNull(
              checkpointId, r'MonitorHistory', 'checkpointId'),
          roleId: BuiltValueNullFieldError.checkNotNull(
              roleId, r'MonitorHistory', 'roleId'),
          taskClaimedUser: BuiltValueNullFieldError.checkNotNull(
              taskClaimedUser, r'MonitorHistory', 'taskClaimedUser'),
          taskRemark: BuiltValueNullFieldError.checkNotNull(
              taskRemark, r'MonitorHistory', 'taskRemark'),
          taskDateDue: BuiltValueNullFieldError.checkNotNull(
              taskDateDue, r'MonitorHistory', 'taskDateDue'),
          taskTimeCreated: BuiltValueNullFieldError.checkNotNull(
              taskTimeCreated, r'MonitorHistory', 'taskTimeCreated'),
          taskTimeSubmit: BuiltValueNullFieldError.checkNotNull(
              taskTimeSubmit, r'MonitorHistory', 'taskTimeSubmit'),
          taskStatus: BuiltValueNullFieldError.checkNotNull(
              taskStatus, r'MonitorHistory', 'taskStatus'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Task> _$taskSerializer = _$TaskSerializer();

class _$TaskSerializer implements StructuredSerializer<Task> {
  @override
  final Iterable<Type> types = const [Task, _$Task];
  @override
  final String wireName = 'Task';

  @override
  Iterable<Object?> serialize(Serializers serializers, Task object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'taskId',
      serializers.serialize(object.taskId,
          specifiedType: const FullType(String)),
      'ppmTaskId',
      serializers.serialize(object.ppmTaskId,
          specifiedType: const FullType(String)),
      'transactionNo',
      serializers.serialize(object.transactionNo,
          specifiedType: const FullType(String)),
      'assetNo',
      serializers.serialize(object.assetNo,
          specifiedType: const FullType(String)),
      'siteName',
      serializers.serialize(object.siteName,
          specifiedType: const FullType(String)),
      'assetTypeName',
      serializers.serialize(object.assetTypeName,
          specifiedType: const FullType(String)),
      'statusDesc',
      serializers.serialize(object.statusDesc,
          specifiedType: const FullType(String)),
      'taskDateDue',
      serializers.serialize(object.taskDateDue,
          specifiedType: const FullType(String)),
      'technician',
      serializers.serialize(object.technician,
          specifiedType: const FullType(String)),
      'frequency',
      serializers.serialize(object.frequency,
          specifiedType:
              const FullType(BuiltList, const [const FullType(String)])),
    ];

    return result;
  }

  @override
  Task deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = TaskBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'taskId':
          result.taskId = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'ppmTaskId':
          result.ppmTaskId = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'transactionNo':
          result.transactionNo = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'assetNo':
          result.assetNo = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'siteName':
          result.siteName = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'assetTypeName':
          result.assetTypeName = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'statusDesc':
          result.statusDesc = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'taskDateDue':
          result.taskDateDue = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'technician':
          result.technician = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'frequency':
          result.frequency.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$Task extends Task {
  @override
  final String taskId;
  @override
  final String ppmTaskId;
  @override
  final String transactionNo;
  @override
  final String assetNo;
  @override
  final String siteName;
  @override
  final String assetTypeName;
  @override
  final String statusDesc;
  @override
  final String taskDateDue;
  @override
  final String technician;
  @override
  final BuiltList<String> frequency;

  factory _$Task([void Function(TaskBuilder)? updates]) =>
      (TaskBuilder()..update(updates))._build();

  _$Task._(
      {required this.taskId,
      required this.ppmTaskId,
      required this.transactionNo,
      required this.assetNo,
      required this.siteName,
      required this.assetTypeName,
      required this.statusDesc,
      required this.taskDateDue,
      required this.technician,
      required this.frequency})
      : super._();
  @override
  Task rebuild(void Function(TaskBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TaskBuilder toBuilder() => TaskBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Task &&
        taskId == other.taskId &&
        ppmTaskId == other.ppmTaskId &&
        transactionNo == other.transactionNo &&
        assetNo == other.assetNo &&
        siteName == other.siteName &&
        assetTypeName == other.assetTypeName &&
        statusDesc == other.statusDesc &&
        taskDateDue == other.taskDateDue &&
        technician == other.technician &&
        frequency == other.frequency;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, taskId.hashCode);
    _$hash = $jc(_$hash, ppmTaskId.hashCode);
    _$hash = $jc(_$hash, transactionNo.hashCode);
    _$hash = $jc(_$hash, assetNo.hashCode);
    _$hash = $jc(_$hash, siteName.hashCode);
    _$hash = $jc(_$hash, assetTypeName.hashCode);
    _$hash = $jc(_$hash, statusDesc.hashCode);
    _$hash = $jc(_$hash, taskDateDue.hashCode);
    _$hash = $jc(_$hash, technician.hashCode);
    _$hash = $jc(_$hash, frequency.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Task')
          ..add('taskId', taskId)
          ..add('ppmTaskId', ppmTaskId)
          ..add('transactionNo', transactionNo)
          ..add('assetNo', assetNo)
          ..add('siteName', siteName)
          ..add('assetTypeName', assetTypeName)
          ..add('statusDesc', statusDesc)
          ..add('taskDateDue', taskDateDue)
          ..add('technician', technician)
          ..add('frequency', frequency))
        .toString();
  }
}

class TaskBuilder implements Builder<Task, TaskBuilder> {
  _$Task? _$v;

  String? _taskId;
  String? get taskId => _$this._taskId;
  set taskId(String? taskId) => _$this._taskId = taskId;

  String? _ppmTaskId;
  String? get ppmTaskId => _$this._ppmTaskId;
  set ppmTaskId(String? ppmTaskId) => _$this._ppmTaskId = ppmTaskId;

  String? _transactionNo;
  String? get transactionNo => _$this._transactionNo;
  set transactionNo(String? transactionNo) =>
      _$this._transactionNo = transactionNo;

  String? _assetNo;
  String? get assetNo => _$this._assetNo;
  set assetNo(String? assetNo) => _$this._assetNo = assetNo;

  String? _siteName;
  String? get siteName => _$this._siteName;
  set siteName(String? siteName) => _$this._siteName = siteName;

  String? _assetTypeName;
  String? get assetTypeName => _$this._assetTypeName;
  set assetTypeName(String? assetTypeName) =>
      _$this._assetTypeName = assetTypeName;

  String? _statusDesc;
  String? get statusDesc => _$this._statusDesc;
  set statusDesc(String? statusDesc) => _$this._statusDesc = statusDesc;

  String? _taskDateDue;
  String? get taskDateDue => _$this._taskDateDue;
  set taskDateDue(String? taskDateDue) => _$this._taskDateDue = taskDateDue;

  String? _technician;
  String? get technician => _$this._technician;
  set technician(String? technician) => _$this._technician = technician;

  ListBuilder<String>? _frequency;
  ListBuilder<String> get frequency =>
      _$this._frequency ??= ListBuilder<String>();
  set frequency(ListBuilder<String>? frequency) =>
      _$this._frequency = frequency;

  TaskBuilder();

  TaskBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _taskId = $v.taskId;
      _ppmTaskId = $v.ppmTaskId;
      _transactionNo = $v.transactionNo;
      _assetNo = $v.assetNo;
      _siteName = $v.siteName;
      _assetTypeName = $v.assetTypeName;
      _statusDesc = $v.statusDesc;
      _taskDateDue = $v.taskDateDue;
      _technician = $v.technician;
      _frequency = $v.frequency.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Task other) {
    _$v = other as _$Task;
  }

  @override
  void update(void Function(TaskBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Task build() => _build();

  _$Task _build() {
    _$Task _$result;
    try {
      _$result = _$v ??
          _$Task._(
            taskId: BuiltValueNullFieldError.checkNotNull(
                taskId, r'Task', 'taskId'),
            ppmTaskId: BuiltValueNullFieldError.checkNotNull(
                ppmTaskId, r'Task', 'ppmTaskId'),
            transactionNo: BuiltValueNullFieldError.checkNotNull(
                transactionNo, r'Task', 'transactionNo'),
            assetNo: BuiltValueNullFieldError.checkNotNull(
                assetNo, r'Task', 'assetNo'),
            siteName: BuiltValueNullFieldError.checkNotNull(
                siteName, r'Task', 'siteName'),
            assetTypeName: BuiltValueNullFieldError.checkNotNull(
                assetTypeName, r'Task', 'assetTypeName'),
            statusDesc: BuiltValueNullFieldError.checkNotNull(
                statusDesc, r'Task', 'statusDesc'),
            taskDateDue: BuiltValueNullFieldError.checkNotNull(
                taskDateDue, r'Task', 'taskDateDue'),
            technician: BuiltValueNullFieldError.checkNotNull(
                technician, r'Task', 'technician'),
            frequency: frequency.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'frequency';
        frequency.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'Task', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

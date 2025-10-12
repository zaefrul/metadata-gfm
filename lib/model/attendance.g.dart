// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Attendance> _$attendanceSerializer = _$AttendanceSerializer();

class _$AttendanceSerializer implements StructuredSerializer<Attendance> {
  @override
  final Iterable<Type> types = const [Attendance, _$Attendance];
  @override
  final String wireName = 'Attendance';

  @override
  Iterable<Object?> serialize(Serializers serializers, Attendance object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.date;
    if (value != null) {
      result
        ..add('date')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.attTransactionId;
    if (value != null) {
      result
        ..add('attTransactionId')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.currentTime;
    if (value != null) {
      result
        ..add('currentTime')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.currentShift;
    if (value != null) {
      result
        ..add('currentShift')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.button;
    if (value != null) {
      result
        ..add('button')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.status;
    if (value != null) {
      result
        ..add('status')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.shiftStart;
    if (value != null) {
      result
        ..add('shiftStart')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.shiftEnd;
    if (value != null) {
      result
        ..add('shiftEnd')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.timeClockIn;
    if (value != null) {
      result
        ..add('timeClockIn')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.timeClockOut;
    if (value != null) {
      result
        ..add('timeClockOut')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.duration;
    if (value != null) {
      result
        ..add('duration')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.weeklyRequiredHours;
    if (value != null) {
      result
        ..add('weeklyRequiredHours')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.weeklyDuration;
    if (value != null) {
      result
        ..add('weeklyDuration')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.weeklyProgress;
    if (value != null) {
      result
        ..add('weeklyProgress')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.nextShiftStart;
    if (value != null) {
      result
        ..add('nextShiftStart')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.remark;
    if (value != null) {
      result
        ..add('remark')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  Attendance deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = AttendanceBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'date':
          result.date = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'attTransactionId':
          result.attTransactionId = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'currentTime':
          result.currentTime = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'currentShift':
          result.currentShift = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'button':
          result.button = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'status':
          result.status = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'shiftStart':
          result.shiftStart = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'shiftEnd':
          result.shiftEnd = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'timeClockIn':
          result.timeClockIn = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'timeClockOut':
          result.timeClockOut = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'duration':
          result.duration = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'weeklyRequiredHours':
          result.weeklyRequiredHours = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'weeklyDuration':
          result.weeklyDuration = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'weeklyProgress':
          result.weeklyProgress = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'nextShiftStart':
          result.nextShiftStart = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'remark':
          result.remark = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
      }
    }

    return result.build();
  }
}

class _$Attendance extends Attendance {
  @override
  final String? date;
  @override
  final int? attTransactionId;
  @override
  final String? currentTime;
  @override
  final String? currentShift;
  @override
  final String? button;
  @override
  final String? status;
  @override
  final String? shiftStart;
  @override
  final String? shiftEnd;
  @override
  final String? timeClockIn;
  @override
  final String? timeClockOut;
  @override
  final String? duration;
  @override
  final String? weeklyRequiredHours;
  @override
  final String? weeklyDuration;
  @override
  final String? weeklyProgress;
  @override
  final String? nextShiftStart;
  @override
  final String? remark;

  factory _$Attendance([void Function(AttendanceBuilder)? updates]) =>
      (AttendanceBuilder()..update(updates))._build();

  _$Attendance._(
      {this.date,
      this.attTransactionId,
      this.currentTime,
      this.currentShift,
      this.button,
      this.status,
      this.shiftStart,
      this.shiftEnd,
      this.timeClockIn,
      this.timeClockOut,
      this.duration,
      this.weeklyRequiredHours,
      this.weeklyDuration,
      this.weeklyProgress,
      this.nextShiftStart,
      this.remark})
      : super._();
  @override
  Attendance rebuild(void Function(AttendanceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AttendanceBuilder toBuilder() => AttendanceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Attendance &&
        date == other.date &&
        attTransactionId == other.attTransactionId &&
        currentTime == other.currentTime &&
        currentShift == other.currentShift &&
        button == other.button &&
        status == other.status &&
        shiftStart == other.shiftStart &&
        shiftEnd == other.shiftEnd &&
        timeClockIn == other.timeClockIn &&
        timeClockOut == other.timeClockOut &&
        duration == other.duration &&
        weeklyRequiredHours == other.weeklyRequiredHours &&
        weeklyDuration == other.weeklyDuration &&
        weeklyProgress == other.weeklyProgress &&
        nextShiftStart == other.nextShiftStart &&
        remark == other.remark;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, date.hashCode);
    _$hash = $jc(_$hash, attTransactionId.hashCode);
    _$hash = $jc(_$hash, currentTime.hashCode);
    _$hash = $jc(_$hash, currentShift.hashCode);
    _$hash = $jc(_$hash, button.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, shiftStart.hashCode);
    _$hash = $jc(_$hash, shiftEnd.hashCode);
    _$hash = $jc(_$hash, timeClockIn.hashCode);
    _$hash = $jc(_$hash, timeClockOut.hashCode);
    _$hash = $jc(_$hash, duration.hashCode);
    _$hash = $jc(_$hash, weeklyRequiredHours.hashCode);
    _$hash = $jc(_$hash, weeklyDuration.hashCode);
    _$hash = $jc(_$hash, weeklyProgress.hashCode);
    _$hash = $jc(_$hash, nextShiftStart.hashCode);
    _$hash = $jc(_$hash, remark.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Attendance')
          ..add('date', date)
          ..add('attTransactionId', attTransactionId)
          ..add('currentTime', currentTime)
          ..add('currentShift', currentShift)
          ..add('button', button)
          ..add('status', status)
          ..add('shiftStart', shiftStart)
          ..add('shiftEnd', shiftEnd)
          ..add('timeClockIn', timeClockIn)
          ..add('timeClockOut', timeClockOut)
          ..add('duration', duration)
          ..add('weeklyRequiredHours', weeklyRequiredHours)
          ..add('weeklyDuration', weeklyDuration)
          ..add('weeklyProgress', weeklyProgress)
          ..add('nextShiftStart', nextShiftStart)
          ..add('remark', remark))
        .toString();
  }
}

class AttendanceBuilder implements Builder<Attendance, AttendanceBuilder> {
  _$Attendance? _$v;

  String? _date;
  String? get date => _$this._date;
  set date(String? date) => _$this._date = date;

  int? _attTransactionId;
  int? get attTransactionId => _$this._attTransactionId;
  set attTransactionId(int? attTransactionId) =>
      _$this._attTransactionId = attTransactionId;

  String? _currentTime;
  String? get currentTime => _$this._currentTime;
  set currentTime(String? currentTime) => _$this._currentTime = currentTime;

  String? _currentShift;
  String? get currentShift => _$this._currentShift;
  set currentShift(String? currentShift) => _$this._currentShift = currentShift;

  String? _button;
  String? get button => _$this._button;
  set button(String? button) => _$this._button = button;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  String? _shiftStart;
  String? get shiftStart => _$this._shiftStart;
  set shiftStart(String? shiftStart) => _$this._shiftStart = shiftStart;

  String? _shiftEnd;
  String? get shiftEnd => _$this._shiftEnd;
  set shiftEnd(String? shiftEnd) => _$this._shiftEnd = shiftEnd;

  String? _timeClockIn;
  String? get timeClockIn => _$this._timeClockIn;
  set timeClockIn(String? timeClockIn) => _$this._timeClockIn = timeClockIn;

  String? _timeClockOut;
  String? get timeClockOut => _$this._timeClockOut;
  set timeClockOut(String? timeClockOut) => _$this._timeClockOut = timeClockOut;

  String? _duration;
  String? get duration => _$this._duration;
  set duration(String? duration) => _$this._duration = duration;

  String? _weeklyRequiredHours;
  String? get weeklyRequiredHours => _$this._weeklyRequiredHours;
  set weeklyRequiredHours(String? weeklyRequiredHours) =>
      _$this._weeklyRequiredHours = weeklyRequiredHours;

  String? _weeklyDuration;
  String? get weeklyDuration => _$this._weeklyDuration;
  set weeklyDuration(String? weeklyDuration) =>
      _$this._weeklyDuration = weeklyDuration;

  String? _weeklyProgress;
  String? get weeklyProgress => _$this._weeklyProgress;
  set weeklyProgress(String? weeklyProgress) =>
      _$this._weeklyProgress = weeklyProgress;

  String? _nextShiftStart;
  String? get nextShiftStart => _$this._nextShiftStart;
  set nextShiftStart(String? nextShiftStart) =>
      _$this._nextShiftStart = nextShiftStart;

  String? _remark;
  String? get remark => _$this._remark;
  set remark(String? remark) => _$this._remark = remark;

  AttendanceBuilder();

  AttendanceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _date = $v.date;
      _attTransactionId = $v.attTransactionId;
      _currentTime = $v.currentTime;
      _currentShift = $v.currentShift;
      _button = $v.button;
      _status = $v.status;
      _shiftStart = $v.shiftStart;
      _shiftEnd = $v.shiftEnd;
      _timeClockIn = $v.timeClockIn;
      _timeClockOut = $v.timeClockOut;
      _duration = $v.duration;
      _weeklyRequiredHours = $v.weeklyRequiredHours;
      _weeklyDuration = $v.weeklyDuration;
      _weeklyProgress = $v.weeklyProgress;
      _nextShiftStart = $v.nextShiftStart;
      _remark = $v.remark;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Attendance other) {
    _$v = other as _$Attendance;
  }

  @override
  void update(void Function(AttendanceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Attendance build() => _build();

  _$Attendance _build() {
    final _$result = _$v ??
        _$Attendance._(
          date: date,
          attTransactionId: attTransactionId,
          currentTime: currentTime,
          currentShift: currentShift,
          button: button,
          status: status,
          shiftStart: shiftStart,
          shiftEnd: shiftEnd,
          timeClockIn: timeClockIn,
          timeClockOut: timeClockOut,
          duration: duration,
          weeklyRequiredHours: weeklyRequiredHours,
          weeklyDuration: weeklyDuration,
          weeklyProgress: weeklyProgress,
          nextShiftStart: nextShiftStart,
          remark: remark,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

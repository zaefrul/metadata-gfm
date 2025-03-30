// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eventDetail.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<EventDetail> _$eventDetailSerializer = new _$EventDetailSerializer();

class _$EventDetailSerializer implements StructuredSerializer<EventDetail> {
  @override
  final Iterable<Type> types = const [EventDetail, _$EventDetail];
  @override
  final String wireName = 'EventDetail';

  @override
  Iterable<Object?> serialize(Serializers serializers, EventDetail object,
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
    return result;
  }

  @override
  EventDetail deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new EventDetailBuilder();

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
        case 'currentTime':
          result.currentTime = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'currentShift':
          result.currentShift = serializers.deserialize(value,
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
      }
    }

    return result.build();
  }
}

class _$EventDetail extends EventDetail {
  @override
  final String? date;
  @override
  final String? currentTime;
  @override
  final String? currentShift;
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

  factory _$EventDetail([void Function(EventDetailBuilder)? updates]) =>
      (new EventDetailBuilder()..update(updates))._build();

  _$EventDetail._(
      {this.date,
      this.currentTime,
      this.currentShift,
      this.status,
      this.shiftStart,
      this.shiftEnd,
      this.timeClockIn,
      this.timeClockOut,
      this.duration})
      : super._();

  @override
  EventDetail rebuild(void Function(EventDetailBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EventDetailBuilder toBuilder() => new EventDetailBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EventDetail &&
        date == other.date &&
        currentTime == other.currentTime &&
        currentShift == other.currentShift &&
        status == other.status &&
        shiftStart == other.shiftStart &&
        shiftEnd == other.shiftEnd &&
        timeClockIn == other.timeClockIn &&
        timeClockOut == other.timeClockOut &&
        duration == other.duration;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, date.hashCode);
    _$hash = $jc(_$hash, currentTime.hashCode);
    _$hash = $jc(_$hash, currentShift.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, shiftStart.hashCode);
    _$hash = $jc(_$hash, shiftEnd.hashCode);
    _$hash = $jc(_$hash, timeClockIn.hashCode);
    _$hash = $jc(_$hash, timeClockOut.hashCode);
    _$hash = $jc(_$hash, duration.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EventDetail')
          ..add('date', date)
          ..add('currentTime', currentTime)
          ..add('currentShift', currentShift)
          ..add('status', status)
          ..add('shiftStart', shiftStart)
          ..add('shiftEnd', shiftEnd)
          ..add('timeClockIn', timeClockIn)
          ..add('timeClockOut', timeClockOut)
          ..add('duration', duration))
        .toString();
  }
}

class EventDetailBuilder implements Builder<EventDetail, EventDetailBuilder> {
  _$EventDetail? _$v;

  String? _date;
  String? get date => _$this._date;
  set date(String? date) => _$this._date = date;

  String? _currentTime;
  String? get currentTime => _$this._currentTime;
  set currentTime(String? currentTime) => _$this._currentTime = currentTime;

  String? _currentShift;
  String? get currentShift => _$this._currentShift;
  set currentShift(String? currentShift) => _$this._currentShift = currentShift;

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

  EventDetailBuilder();

  EventDetailBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _date = $v.date;
      _currentTime = $v.currentTime;
      _currentShift = $v.currentShift;
      _status = $v.status;
      _shiftStart = $v.shiftStart;
      _shiftEnd = $v.shiftEnd;
      _timeClockIn = $v.timeClockIn;
      _timeClockOut = $v.timeClockOut;
      _duration = $v.duration;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EventDetail other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$EventDetail;
  }

  @override
  void update(void Function(EventDetailBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EventDetail build() => _build();

  _$EventDetail _build() {
    final _$result = _$v ??
        new _$EventDetail._(
          date: date,
          currentTime: currentTime,
          currentShift: currentShift,
          status: status,
          shiftStart: shiftStart,
          shiftEnd: shiftEnd,
          timeClockIn: timeClockIn,
          timeClockOut: timeClockOut,
          duration: duration,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

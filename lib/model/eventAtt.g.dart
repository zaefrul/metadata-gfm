// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eventAtt.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<EventAtt> _$eventAttSerializer = new _$EventAttSerializer();

class _$EventAttSerializer implements StructuredSerializer<EventAtt> {
  @override
  final Iterable<Type> types = const [EventAtt, _$EventAtt];
  @override
  final String wireName = 'EventAtt';

  @override
  Iterable<Object> serialize(Serializers serializers, EventAtt object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[];
    Object value;
    value = object.date;
    if (value != null) {
      result
        ..add('date')
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
    value = object.color;
    if (value != null) {
      result
        ..add('color')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  EventAtt deserialize(Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new EventAttBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final Object value = iterator.current;
      switch (key) {
        case 'date':
          result.date = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'status':
          result.status = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'color':
          result.color = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
      }
    }

    return result.build();
  }
}

class _$EventAtt extends EventAtt {
  @override
  final String date;
  @override
  final String status;
  @override
  final String color;

  factory _$EventAtt([void Function(EventAttBuilder) updates]) =>
      (new EventAttBuilder()..update(updates))._build();

  _$EventAtt._({this.date, this.status, this.color}) : super._();

  @override
  EventAtt rebuild(void Function(EventAttBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EventAttBuilder toBuilder() => new EventAttBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EventAtt &&
        date == other.date &&
        status == other.status &&
        color == other.color;
  }

  @override
  int get hashCode {
    return $jf(
        $jc($jc($jc(0, date.hashCode), status.hashCode), color.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EventAtt')
          ..add('date', date)
          ..add('status', status)
          ..add('color', color))
        .toString();
  }
}

class EventAttBuilder implements Builder<EventAtt, EventAttBuilder> {
  _$EventAtt _$v;

  String _date;
  String get date => _$this._date;
  set date(String date) => _$this._date = date;

  String _status;
  String get status => _$this._status;
  set status(String status) => _$this._status = status;

  String _color;
  String get color => _$this._color;
  set color(String color) => _$this._color = color;

  EventAttBuilder();

  EventAttBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _date = $v.date;
      _status = $v.status;
      _color = $v.color;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EventAtt other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$EventAtt;
  }

  @override
  void update(void Function(EventAttBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  EventAtt build() => _build();

  _$EventAtt _build() {
    final _$result =
        _$v ?? new _$EventAtt._(date: date, status: status, color: color);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,no_leading_underscores_for_local_identifiers,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new,unnecessary_lambdas

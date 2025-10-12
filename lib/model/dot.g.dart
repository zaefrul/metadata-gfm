// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dot.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Dot> _$dotSerializer = _$DotSerializer();

class _$DotSerializer implements StructuredSerializer<Dot> {
  @override
  final Iterable<Type> types = const [Dot, _$Dot];
  @override
  final String wireName = 'Dot';

  @override
  Iterable<Object?> serialize(Serializers serializers, Dot object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'date',
      serializers.serialize(object.date, specifiedType: const FullType(String)),
      'total',
      serializers.serialize(object.total,
          specifiedType: const FullType(String)),
      'status',
      serializers.serialize(object.status,
          specifiedType:
              const FullType(BuiltList, const [const FullType(String)])),
    ];

    return result;
  }

  @override
  Dot deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = DotBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'date':
          result.date = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'total':
          result.total = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'status':
          result.status.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$Dot extends Dot {
  @override
  final String date;
  @override
  final String total;
  @override
  final BuiltList<String> status;

  factory _$Dot([void Function(DotBuilder)? updates]) =>
      (DotBuilder()..update(updates))._build();

  _$Dot._({required this.date, required this.total, required this.status})
      : super._();
  @override
  Dot rebuild(void Function(DotBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DotBuilder toBuilder() => DotBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Dot &&
        date == other.date &&
        total == other.total &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, date.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Dot')
          ..add('date', date)
          ..add('total', total)
          ..add('status', status))
        .toString();
  }
}

class DotBuilder implements Builder<Dot, DotBuilder> {
  _$Dot? _$v;

  String? _date;
  String? get date => _$this._date;
  set date(String? date) => _$this._date = date;

  String? _total;
  String? get total => _$this._total;
  set total(String? total) => _$this._total = total;

  ListBuilder<String>? _status;
  ListBuilder<String> get status => _$this._status ??= ListBuilder<String>();
  set status(ListBuilder<String>? status) => _$this._status = status;

  DotBuilder();

  DotBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _date = $v.date;
      _total = $v.total;
      _status = $v.status.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Dot other) {
    _$v = other as _$Dot;
  }

  @override
  void update(void Function(DotBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Dot build() => _build();

  _$Dot _build() {
    _$Dot _$result;
    try {
      _$result = _$v ??
          _$Dot._(
            date: BuiltValueNullFieldError.checkNotNull(date, r'Dot', 'date'),
            total:
                BuiltValueNullFieldError.checkNotNull(total, r'Dot', 'total'),
            status: status.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'status';
        status.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'Dot', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complaintResponse.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<ComplaintResponse> _$complaintResponseSerializer =
    new _$ComplaintResponseSerializer();

class _$ComplaintResponseSerializer
    implements StructuredSerializer<ComplaintResponse> {
  @override
  final Iterable<Type> types = const [ComplaintResponse, _$ComplaintResponse];
  @override
  final String wireName = 'ComplaintResponse';

  @override
  Iterable<Object?> serialize(Serializers serializers, ComplaintResponse object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'success',
      serializers.serialize(object.success,
          specifiedType: const FullType(bool)),
      'error',
      serializers.serialize(object.error,
          specifiedType: const FullType(String)),
      'errmsg',
      serializers.serialize(object.errmsg,
          specifiedType: const FullType(String)),
    ];
    Object? value;
    value = object.items;
    if (value != null) {
      result
        ..add('result')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(ComplaintD)])));
    }
    value = object.groups;
    if (value != null) {
      result
        ..add('result')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                BuiltList, const [const FullType(ComplaintDGroup)])));
    }
    value = object.types;
    if (value != null) {
      result
        ..add('result')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                BuiltList, const [const FullType(ComplaintDType)])));
    }
    value = object.parts;
    if (value != null) {
      result
        ..add('result')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                BuiltList, const [const FullType(ComplaintDPart)])));
    }
    return result;
  }

  @override
  ComplaintResponse deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new ComplaintResponseBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'success':
          result.success = serializers.deserialize(value,
              specifiedType: const FullType(bool))! as bool;
          break;
        case 'error':
          result.error = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'errmsg':
          result.errmsg = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'result':
          result.items.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(ComplaintD)]))!
              as BuiltList<Object?>);
          break;
        case 'result':
          result.groups.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(ComplaintDGroup)]))!
              as BuiltList<Object?>);
          break;
        case 'result':
          result.types.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(ComplaintDType)]))!
              as BuiltList<Object?>);
          break;
        case 'result':
          result.parts.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(ComplaintDPart)]))!
              as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$ComplaintResponse extends ComplaintResponse {
  @override
  final bool success;
  @override
  final String error;
  @override
  final String errmsg;
  @override
  final BuiltList<ComplaintD>? items;
  @override
  final BuiltList<ComplaintDGroup>? groups;
  @override
  final BuiltList<ComplaintDType>? types;
  @override
  final BuiltList<ComplaintDPart>? parts;

  factory _$ComplaintResponse(
          [void Function(ComplaintResponseBuilder)? updates]) =>
      (new ComplaintResponseBuilder()..update(updates))._build();

  _$ComplaintResponse._(
      {required this.success,
      required this.error,
      required this.errmsg,
      this.items,
      this.groups,
      this.types,
      this.parts})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        success, r'ComplaintResponse', 'success');
    BuiltValueNullFieldError.checkNotNull(error, r'ComplaintResponse', 'error');
    BuiltValueNullFieldError.checkNotNull(
        errmsg, r'ComplaintResponse', 'errmsg');
  }

  @override
  ComplaintResponse rebuild(void Function(ComplaintResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ComplaintResponseBuilder toBuilder() =>
      new ComplaintResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ComplaintResponse &&
        success == other.success &&
        error == other.error &&
        errmsg == other.errmsg &&
        items == other.items &&
        groups == other.groups &&
        types == other.types &&
        parts == other.parts;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, success.hashCode);
    _$hash = $jc(_$hash, error.hashCode);
    _$hash = $jc(_$hash, errmsg.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, groups.hashCode);
    _$hash = $jc(_$hash, types.hashCode);
    _$hash = $jc(_$hash, parts.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ComplaintResponse')
          ..add('success', success)
          ..add('error', error)
          ..add('errmsg', errmsg)
          ..add('items', items)
          ..add('groups', groups)
          ..add('types', types)
          ..add('parts', parts))
        .toString();
  }
}

class ComplaintResponseBuilder
    implements Builder<ComplaintResponse, ComplaintResponseBuilder> {
  _$ComplaintResponse? _$v;

  bool? _success;
  bool? get success => _$this._success;
  set success(bool? success) => _$this._success = success;

  String? _error;
  String? get error => _$this._error;
  set error(String? error) => _$this._error = error;

  String? _errmsg;
  String? get errmsg => _$this._errmsg;
  set errmsg(String? errmsg) => _$this._errmsg = errmsg;

  ListBuilder<ComplaintD>? _items;
  ListBuilder<ComplaintD> get items =>
      _$this._items ??= new ListBuilder<ComplaintD>();
  set items(ListBuilder<ComplaintD>? items) => _$this._items = items;

  ListBuilder<ComplaintDGroup>? _groups;
  ListBuilder<ComplaintDGroup> get groups =>
      _$this._groups ??= new ListBuilder<ComplaintDGroup>();
  set groups(ListBuilder<ComplaintDGroup>? groups) => _$this._groups = groups;

  ListBuilder<ComplaintDType>? _types;
  ListBuilder<ComplaintDType> get types =>
      _$this._types ??= new ListBuilder<ComplaintDType>();
  set types(ListBuilder<ComplaintDType>? types) => _$this._types = types;

  ListBuilder<ComplaintDPart>? _parts;
  ListBuilder<ComplaintDPart> get parts =>
      _$this._parts ??= new ListBuilder<ComplaintDPart>();
  set parts(ListBuilder<ComplaintDPart>? parts) => _$this._parts = parts;

  ComplaintResponseBuilder();

  ComplaintResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _success = $v.success;
      _error = $v.error;
      _errmsg = $v.errmsg;
      _items = $v.items?.toBuilder();
      _groups = $v.groups?.toBuilder();
      _types = $v.types?.toBuilder();
      _parts = $v.parts?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ComplaintResponse other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ComplaintResponse;
  }

  @override
  void update(void Function(ComplaintResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ComplaintResponse build() => _build();

  _$ComplaintResponse _build() {
    _$ComplaintResponse _$result;
    try {
      _$result = _$v ??
          new _$ComplaintResponse._(
            success: BuiltValueNullFieldError.checkNotNull(
                success, r'ComplaintResponse', 'success'),
            error: BuiltValueNullFieldError.checkNotNull(
                error, r'ComplaintResponse', 'error'),
            errmsg: BuiltValueNullFieldError.checkNotNull(
                errmsg, r'ComplaintResponse', 'errmsg'),
            items: _items?.build(),
            groups: _groups?.build(),
            types: _types?.build(),
            parts: _parts?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        _items?.build();
        _$failedField = 'groups';
        _groups?.build();
        _$failedField = 'types';
        _types?.build();
        _$failedField = 'parts';
        _parts?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'ComplaintResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

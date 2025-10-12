// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gamificationInfo.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GamificationInfo> _$gamificationInfoSerializer =
    _$GamificationInfoSerializer();

class _$GamificationInfoSerializer
    implements StructuredSerializer<GamificationInfo> {
  @override
  final Iterable<Type> types = const [GamificationInfo, _$GamificationInfo];
  @override
  final String wireName = 'GamificationInfo';

  @override
  Iterable<Object?> serialize(Serializers serializers, GamificationInfo object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.gmiId;
    if (value != null) {
      result
        ..add('gmiId')
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
    value = object.siteId;
    if (value != null) {
      result
        ..add('siteId')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.gmiYear;
    if (value != null) {
      result
        ..add('gmiYear')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.gmiMonth;
    if (value != null) {
      result
        ..add('gmiMonth')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.gmiPpmTierName;
    if (value != null) {
      result
        ..add('gmiPpmTierName')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.gmiPpmTierPoint;
    if (value != null) {
      result
        ..add('gmiPpmTierPoint')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.gmiPpmTotal;
    if (value != null) {
      result
        ..add('gmiPpmTotal')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.gmiPpmCompleted;
    if (value != null) {
      result
        ..add('gmiPpmCompleted')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.gmiPpmOnTime;
    if (value != null) {
      result
        ..add('gmiPpmOnTime')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.gmiPpmLate;
    if (value != null) {
      result
        ..add('gmiPpmLate')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.gmiPpmWithin;
    if (value != null) {
      result
        ..add('gmiPpmWithin')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.gmiPpmRework;
    if (value != null) {
      result
        ..add('gmiPpmRework')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.gmiPpmAssist;
    if (value != null) {
      result
        ..add('gmiPpmAssist')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.gmiWoTierName;
    if (value != null) {
      result
        ..add('gmiWoTierName')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.gmiWoTierPoint;
    if (value != null) {
      result
        ..add('gmiWoTierPoint')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.gmiWoTotal;
    if (value != null) {
      result
        ..add('gmiWoTotal')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.gmiWoCompleted;
    if (value != null) {
      result
        ..add('gmiWoCompleted')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.gmiWoOnTime;
    if (value != null) {
      result
        ..add('gmiWoOnTime')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.gmiWoLate;
    if (value != null) {
      result
        ..add('gmiWoLate')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.gmiWoRework;
    if (value != null) {
      result
        ..add('gmiWoRework')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.gmiWoSelfFinding;
    if (value != null) {
      result
        ..add('gmiWoSelfFinding')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.gmiWoAssist;
    if (value != null) {
      result
        ..add('gmiWoAssist')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.gmiMbv;
    if (value != null) {
      result
        ..add('gmiMbv')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.gmiTierPoint;
    if (value != null) {
      result
        ..add('gmiTierPoint')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.gmiPointCompleted;
    if (value != null) {
      result
        ..add('gmiPointCompleted')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.gmiPointOnTime;
    if (value != null) {
      result
        ..add('gmiPointOnTime')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.gmiPointLate;
    if (value != null) {
      result
        ..add('gmiPointLate')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.gmiPointRework;
    if (value != null) {
      result
        ..add('gmiPointRework')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.gmiPointSelfFinding;
    if (value != null) {
      result
        ..add('gmiPointSelfFinding')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.gmiPointTotal;
    if (value != null) {
      result
        ..add('gmiPointTotal')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  GamificationInfo deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GamificationInfoBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'gmiId':
          result.gmiId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'userId':
          result.userId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'siteId':
          result.siteId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'gmiYear':
          result.gmiYear = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'gmiMonth':
          result.gmiMonth = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'gmiPpmTierName':
          result.gmiPpmTierName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'gmiPpmTierPoint':
          result.gmiPpmTierPoint = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'gmiPpmTotal':
          result.gmiPpmTotal = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'gmiPpmCompleted':
          result.gmiPpmCompleted = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'gmiPpmOnTime':
          result.gmiPpmOnTime = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'gmiPpmLate':
          result.gmiPpmLate = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'gmiPpmWithin':
          result.gmiPpmWithin = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'gmiPpmRework':
          result.gmiPpmRework = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'gmiPpmAssist':
          result.gmiPpmAssist = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'gmiWoTierName':
          result.gmiWoTierName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'gmiWoTierPoint':
          result.gmiWoTierPoint = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'gmiWoTotal':
          result.gmiWoTotal = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'gmiWoCompleted':
          result.gmiWoCompleted = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'gmiWoOnTime':
          result.gmiWoOnTime = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'gmiWoLate':
          result.gmiWoLate = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'gmiWoRework':
          result.gmiWoRework = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'gmiWoSelfFinding':
          result.gmiWoSelfFinding = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'gmiWoAssist':
          result.gmiWoAssist = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'gmiMbv':
          result.gmiMbv = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'gmiTierPoint':
          result.gmiTierPoint = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'gmiPointCompleted':
          result.gmiPointCompleted = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'gmiPointOnTime':
          result.gmiPointOnTime = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'gmiPointLate':
          result.gmiPointLate = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'gmiPointRework':
          result.gmiPointRework = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'gmiPointSelfFinding':
          result.gmiPointSelfFinding = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'gmiPointTotal':
          result.gmiPointTotal = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
      }
    }

    return result.build();
  }
}

class _$GamificationInfo extends GamificationInfo {
  @override
  final String? gmiId;
  @override
  final String? userId;
  @override
  final String? siteId;
  @override
  final String? gmiYear;
  @override
  final String? gmiMonth;
  @override
  final String? gmiPpmTierName;
  @override
  final String? gmiPpmTierPoint;
  @override
  final String? gmiPpmTotal;
  @override
  final String? gmiPpmCompleted;
  @override
  final String? gmiPpmOnTime;
  @override
  final String? gmiPpmLate;
  @override
  final String? gmiPpmWithin;
  @override
  final String? gmiPpmRework;
  @override
  final String? gmiPpmAssist;
  @override
  final String? gmiWoTierName;
  @override
  final String? gmiWoTierPoint;
  @override
  final String? gmiWoTotal;
  @override
  final String? gmiWoCompleted;
  @override
  final String? gmiWoOnTime;
  @override
  final String? gmiWoLate;
  @override
  final String? gmiWoRework;
  @override
  final String? gmiWoSelfFinding;
  @override
  final String? gmiWoAssist;
  @override
  final String? gmiMbv;
  @override
  final String? gmiTierPoint;
  @override
  final String? gmiPointCompleted;
  @override
  final String? gmiPointOnTime;
  @override
  final String? gmiPointLate;
  @override
  final String? gmiPointRework;
  @override
  final String? gmiPointSelfFinding;
  @override
  final String? gmiPointTotal;

  factory _$GamificationInfo(
          [void Function(GamificationInfoBuilder)? updates]) =>
      (GamificationInfoBuilder()..update(updates))._build();

  _$GamificationInfo._(
      {this.gmiId,
      this.userId,
      this.siteId,
      this.gmiYear,
      this.gmiMonth,
      this.gmiPpmTierName,
      this.gmiPpmTierPoint,
      this.gmiPpmTotal,
      this.gmiPpmCompleted,
      this.gmiPpmOnTime,
      this.gmiPpmLate,
      this.gmiPpmWithin,
      this.gmiPpmRework,
      this.gmiPpmAssist,
      this.gmiWoTierName,
      this.gmiWoTierPoint,
      this.gmiWoTotal,
      this.gmiWoCompleted,
      this.gmiWoOnTime,
      this.gmiWoLate,
      this.gmiWoRework,
      this.gmiWoSelfFinding,
      this.gmiWoAssist,
      this.gmiMbv,
      this.gmiTierPoint,
      this.gmiPointCompleted,
      this.gmiPointOnTime,
      this.gmiPointLate,
      this.gmiPointRework,
      this.gmiPointSelfFinding,
      this.gmiPointTotal})
      : super._();
  @override
  GamificationInfo rebuild(void Function(GamificationInfoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GamificationInfoBuilder toBuilder() =>
      GamificationInfoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GamificationInfo &&
        gmiId == other.gmiId &&
        userId == other.userId &&
        siteId == other.siteId &&
        gmiYear == other.gmiYear &&
        gmiMonth == other.gmiMonth &&
        gmiPpmTierName == other.gmiPpmTierName &&
        gmiPpmTierPoint == other.gmiPpmTierPoint &&
        gmiPpmTotal == other.gmiPpmTotal &&
        gmiPpmCompleted == other.gmiPpmCompleted &&
        gmiPpmOnTime == other.gmiPpmOnTime &&
        gmiPpmLate == other.gmiPpmLate &&
        gmiPpmWithin == other.gmiPpmWithin &&
        gmiPpmRework == other.gmiPpmRework &&
        gmiPpmAssist == other.gmiPpmAssist &&
        gmiWoTierName == other.gmiWoTierName &&
        gmiWoTierPoint == other.gmiWoTierPoint &&
        gmiWoTotal == other.gmiWoTotal &&
        gmiWoCompleted == other.gmiWoCompleted &&
        gmiWoOnTime == other.gmiWoOnTime &&
        gmiWoLate == other.gmiWoLate &&
        gmiWoRework == other.gmiWoRework &&
        gmiWoSelfFinding == other.gmiWoSelfFinding &&
        gmiWoAssist == other.gmiWoAssist &&
        gmiMbv == other.gmiMbv &&
        gmiTierPoint == other.gmiTierPoint &&
        gmiPointCompleted == other.gmiPointCompleted &&
        gmiPointOnTime == other.gmiPointOnTime &&
        gmiPointLate == other.gmiPointLate &&
        gmiPointRework == other.gmiPointRework &&
        gmiPointSelfFinding == other.gmiPointSelfFinding &&
        gmiPointTotal == other.gmiPointTotal;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, gmiId.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, siteId.hashCode);
    _$hash = $jc(_$hash, gmiYear.hashCode);
    _$hash = $jc(_$hash, gmiMonth.hashCode);
    _$hash = $jc(_$hash, gmiPpmTierName.hashCode);
    _$hash = $jc(_$hash, gmiPpmTierPoint.hashCode);
    _$hash = $jc(_$hash, gmiPpmTotal.hashCode);
    _$hash = $jc(_$hash, gmiPpmCompleted.hashCode);
    _$hash = $jc(_$hash, gmiPpmOnTime.hashCode);
    _$hash = $jc(_$hash, gmiPpmLate.hashCode);
    _$hash = $jc(_$hash, gmiPpmWithin.hashCode);
    _$hash = $jc(_$hash, gmiPpmRework.hashCode);
    _$hash = $jc(_$hash, gmiPpmAssist.hashCode);
    _$hash = $jc(_$hash, gmiWoTierName.hashCode);
    _$hash = $jc(_$hash, gmiWoTierPoint.hashCode);
    _$hash = $jc(_$hash, gmiWoTotal.hashCode);
    _$hash = $jc(_$hash, gmiWoCompleted.hashCode);
    _$hash = $jc(_$hash, gmiWoOnTime.hashCode);
    _$hash = $jc(_$hash, gmiWoLate.hashCode);
    _$hash = $jc(_$hash, gmiWoRework.hashCode);
    _$hash = $jc(_$hash, gmiWoSelfFinding.hashCode);
    _$hash = $jc(_$hash, gmiWoAssist.hashCode);
    _$hash = $jc(_$hash, gmiMbv.hashCode);
    _$hash = $jc(_$hash, gmiTierPoint.hashCode);
    _$hash = $jc(_$hash, gmiPointCompleted.hashCode);
    _$hash = $jc(_$hash, gmiPointOnTime.hashCode);
    _$hash = $jc(_$hash, gmiPointLate.hashCode);
    _$hash = $jc(_$hash, gmiPointRework.hashCode);
    _$hash = $jc(_$hash, gmiPointSelfFinding.hashCode);
    _$hash = $jc(_$hash, gmiPointTotal.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GamificationInfo')
          ..add('gmiId', gmiId)
          ..add('userId', userId)
          ..add('siteId', siteId)
          ..add('gmiYear', gmiYear)
          ..add('gmiMonth', gmiMonth)
          ..add('gmiPpmTierName', gmiPpmTierName)
          ..add('gmiPpmTierPoint', gmiPpmTierPoint)
          ..add('gmiPpmTotal', gmiPpmTotal)
          ..add('gmiPpmCompleted', gmiPpmCompleted)
          ..add('gmiPpmOnTime', gmiPpmOnTime)
          ..add('gmiPpmLate', gmiPpmLate)
          ..add('gmiPpmWithin', gmiPpmWithin)
          ..add('gmiPpmRework', gmiPpmRework)
          ..add('gmiPpmAssist', gmiPpmAssist)
          ..add('gmiWoTierName', gmiWoTierName)
          ..add('gmiWoTierPoint', gmiWoTierPoint)
          ..add('gmiWoTotal', gmiWoTotal)
          ..add('gmiWoCompleted', gmiWoCompleted)
          ..add('gmiWoOnTime', gmiWoOnTime)
          ..add('gmiWoLate', gmiWoLate)
          ..add('gmiWoRework', gmiWoRework)
          ..add('gmiWoSelfFinding', gmiWoSelfFinding)
          ..add('gmiWoAssist', gmiWoAssist)
          ..add('gmiMbv', gmiMbv)
          ..add('gmiTierPoint', gmiTierPoint)
          ..add('gmiPointCompleted', gmiPointCompleted)
          ..add('gmiPointOnTime', gmiPointOnTime)
          ..add('gmiPointLate', gmiPointLate)
          ..add('gmiPointRework', gmiPointRework)
          ..add('gmiPointSelfFinding', gmiPointSelfFinding)
          ..add('gmiPointTotal', gmiPointTotal))
        .toString();
  }
}

class GamificationInfoBuilder
    implements Builder<GamificationInfo, GamificationInfoBuilder> {
  _$GamificationInfo? _$v;

  String? _gmiId;
  String? get gmiId => _$this._gmiId;
  set gmiId(String? gmiId) => _$this._gmiId = gmiId;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  String? _siteId;
  String? get siteId => _$this._siteId;
  set siteId(String? siteId) => _$this._siteId = siteId;

  String? _gmiYear;
  String? get gmiYear => _$this._gmiYear;
  set gmiYear(String? gmiYear) => _$this._gmiYear = gmiYear;

  String? _gmiMonth;
  String? get gmiMonth => _$this._gmiMonth;
  set gmiMonth(String? gmiMonth) => _$this._gmiMonth = gmiMonth;

  String? _gmiPpmTierName;
  String? get gmiPpmTierName => _$this._gmiPpmTierName;
  set gmiPpmTierName(String? gmiPpmTierName) =>
      _$this._gmiPpmTierName = gmiPpmTierName;

  String? _gmiPpmTierPoint;
  String? get gmiPpmTierPoint => _$this._gmiPpmTierPoint;
  set gmiPpmTierPoint(String? gmiPpmTierPoint) =>
      _$this._gmiPpmTierPoint = gmiPpmTierPoint;

  String? _gmiPpmTotal;
  String? get gmiPpmTotal => _$this._gmiPpmTotal;
  set gmiPpmTotal(String? gmiPpmTotal) => _$this._gmiPpmTotal = gmiPpmTotal;

  String? _gmiPpmCompleted;
  String? get gmiPpmCompleted => _$this._gmiPpmCompleted;
  set gmiPpmCompleted(String? gmiPpmCompleted) =>
      _$this._gmiPpmCompleted = gmiPpmCompleted;

  String? _gmiPpmOnTime;
  String? get gmiPpmOnTime => _$this._gmiPpmOnTime;
  set gmiPpmOnTime(String? gmiPpmOnTime) => _$this._gmiPpmOnTime = gmiPpmOnTime;

  String? _gmiPpmLate;
  String? get gmiPpmLate => _$this._gmiPpmLate;
  set gmiPpmLate(String? gmiPpmLate) => _$this._gmiPpmLate = gmiPpmLate;

  String? _gmiPpmWithin;
  String? get gmiPpmWithin => _$this._gmiPpmWithin;
  set gmiPpmWithin(String? gmiPpmWithin) => _$this._gmiPpmWithin = gmiPpmWithin;

  String? _gmiPpmRework;
  String? get gmiPpmRework => _$this._gmiPpmRework;
  set gmiPpmRework(String? gmiPpmRework) => _$this._gmiPpmRework = gmiPpmRework;

  String? _gmiPpmAssist;
  String? get gmiPpmAssist => _$this._gmiPpmAssist;
  set gmiPpmAssist(String? gmiPpmAssist) => _$this._gmiPpmAssist = gmiPpmAssist;

  String? _gmiWoTierName;
  String? get gmiWoTierName => _$this._gmiWoTierName;
  set gmiWoTierName(String? gmiWoTierName) =>
      _$this._gmiWoTierName = gmiWoTierName;

  String? _gmiWoTierPoint;
  String? get gmiWoTierPoint => _$this._gmiWoTierPoint;
  set gmiWoTierPoint(String? gmiWoTierPoint) =>
      _$this._gmiWoTierPoint = gmiWoTierPoint;

  String? _gmiWoTotal;
  String? get gmiWoTotal => _$this._gmiWoTotal;
  set gmiWoTotal(String? gmiWoTotal) => _$this._gmiWoTotal = gmiWoTotal;

  String? _gmiWoCompleted;
  String? get gmiWoCompleted => _$this._gmiWoCompleted;
  set gmiWoCompleted(String? gmiWoCompleted) =>
      _$this._gmiWoCompleted = gmiWoCompleted;

  String? _gmiWoOnTime;
  String? get gmiWoOnTime => _$this._gmiWoOnTime;
  set gmiWoOnTime(String? gmiWoOnTime) => _$this._gmiWoOnTime = gmiWoOnTime;

  String? _gmiWoLate;
  String? get gmiWoLate => _$this._gmiWoLate;
  set gmiWoLate(String? gmiWoLate) => _$this._gmiWoLate = gmiWoLate;

  String? _gmiWoRework;
  String? get gmiWoRework => _$this._gmiWoRework;
  set gmiWoRework(String? gmiWoRework) => _$this._gmiWoRework = gmiWoRework;

  String? _gmiWoSelfFinding;
  String? get gmiWoSelfFinding => _$this._gmiWoSelfFinding;
  set gmiWoSelfFinding(String? gmiWoSelfFinding) =>
      _$this._gmiWoSelfFinding = gmiWoSelfFinding;

  String? _gmiWoAssist;
  String? get gmiWoAssist => _$this._gmiWoAssist;
  set gmiWoAssist(String? gmiWoAssist) => _$this._gmiWoAssist = gmiWoAssist;

  String? _gmiMbv;
  String? get gmiMbv => _$this._gmiMbv;
  set gmiMbv(String? gmiMbv) => _$this._gmiMbv = gmiMbv;

  String? _gmiTierPoint;
  String? get gmiTierPoint => _$this._gmiTierPoint;
  set gmiTierPoint(String? gmiTierPoint) => _$this._gmiTierPoint = gmiTierPoint;

  String? _gmiPointCompleted;
  String? get gmiPointCompleted => _$this._gmiPointCompleted;
  set gmiPointCompleted(String? gmiPointCompleted) =>
      _$this._gmiPointCompleted = gmiPointCompleted;

  String? _gmiPointOnTime;
  String? get gmiPointOnTime => _$this._gmiPointOnTime;
  set gmiPointOnTime(String? gmiPointOnTime) =>
      _$this._gmiPointOnTime = gmiPointOnTime;

  String? _gmiPointLate;
  String? get gmiPointLate => _$this._gmiPointLate;
  set gmiPointLate(String? gmiPointLate) => _$this._gmiPointLate = gmiPointLate;

  String? _gmiPointRework;
  String? get gmiPointRework => _$this._gmiPointRework;
  set gmiPointRework(String? gmiPointRework) =>
      _$this._gmiPointRework = gmiPointRework;

  String? _gmiPointSelfFinding;
  String? get gmiPointSelfFinding => _$this._gmiPointSelfFinding;
  set gmiPointSelfFinding(String? gmiPointSelfFinding) =>
      _$this._gmiPointSelfFinding = gmiPointSelfFinding;

  String? _gmiPointTotal;
  String? get gmiPointTotal => _$this._gmiPointTotal;
  set gmiPointTotal(String? gmiPointTotal) =>
      _$this._gmiPointTotal = gmiPointTotal;

  GamificationInfoBuilder();

  GamificationInfoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _gmiId = $v.gmiId;
      _userId = $v.userId;
      _siteId = $v.siteId;
      _gmiYear = $v.gmiYear;
      _gmiMonth = $v.gmiMonth;
      _gmiPpmTierName = $v.gmiPpmTierName;
      _gmiPpmTierPoint = $v.gmiPpmTierPoint;
      _gmiPpmTotal = $v.gmiPpmTotal;
      _gmiPpmCompleted = $v.gmiPpmCompleted;
      _gmiPpmOnTime = $v.gmiPpmOnTime;
      _gmiPpmLate = $v.gmiPpmLate;
      _gmiPpmWithin = $v.gmiPpmWithin;
      _gmiPpmRework = $v.gmiPpmRework;
      _gmiPpmAssist = $v.gmiPpmAssist;
      _gmiWoTierName = $v.gmiWoTierName;
      _gmiWoTierPoint = $v.gmiWoTierPoint;
      _gmiWoTotal = $v.gmiWoTotal;
      _gmiWoCompleted = $v.gmiWoCompleted;
      _gmiWoOnTime = $v.gmiWoOnTime;
      _gmiWoLate = $v.gmiWoLate;
      _gmiWoRework = $v.gmiWoRework;
      _gmiWoSelfFinding = $v.gmiWoSelfFinding;
      _gmiWoAssist = $v.gmiWoAssist;
      _gmiMbv = $v.gmiMbv;
      _gmiTierPoint = $v.gmiTierPoint;
      _gmiPointCompleted = $v.gmiPointCompleted;
      _gmiPointOnTime = $v.gmiPointOnTime;
      _gmiPointLate = $v.gmiPointLate;
      _gmiPointRework = $v.gmiPointRework;
      _gmiPointSelfFinding = $v.gmiPointSelfFinding;
      _gmiPointTotal = $v.gmiPointTotal;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GamificationInfo other) {
    _$v = other as _$GamificationInfo;
  }

  @override
  void update(void Function(GamificationInfoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GamificationInfo build() => _build();

  _$GamificationInfo _build() {
    final _$result = _$v ??
        _$GamificationInfo._(
          gmiId: gmiId,
          userId: userId,
          siteId: siteId,
          gmiYear: gmiYear,
          gmiMonth: gmiMonth,
          gmiPpmTierName: gmiPpmTierName,
          gmiPpmTierPoint: gmiPpmTierPoint,
          gmiPpmTotal: gmiPpmTotal,
          gmiPpmCompleted: gmiPpmCompleted,
          gmiPpmOnTime: gmiPpmOnTime,
          gmiPpmLate: gmiPpmLate,
          gmiPpmWithin: gmiPpmWithin,
          gmiPpmRework: gmiPpmRework,
          gmiPpmAssist: gmiPpmAssist,
          gmiWoTierName: gmiWoTierName,
          gmiWoTierPoint: gmiWoTierPoint,
          gmiWoTotal: gmiWoTotal,
          gmiWoCompleted: gmiWoCompleted,
          gmiWoOnTime: gmiWoOnTime,
          gmiWoLate: gmiWoLate,
          gmiWoRework: gmiWoRework,
          gmiWoSelfFinding: gmiWoSelfFinding,
          gmiWoAssist: gmiWoAssist,
          gmiMbv: gmiMbv,
          gmiTierPoint: gmiTierPoint,
          gmiPointCompleted: gmiPointCompleted,
          gmiPointOnTime: gmiPointOnTime,
          gmiPointLate: gmiPointLate,
          gmiPointRework: gmiPointRework,
          gmiPointSelfFinding: gmiPointSelfFinding,
          gmiPointTotal: gmiPointTotal,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

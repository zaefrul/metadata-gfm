// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meter.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Meter> _$meterSerializer = _$MeterSerializer();
Serializer<Reading> _$readingSerializer = _$ReadingSerializer();

class _$MeterSerializer implements StructuredSerializer<Meter> {
  @override
  final Iterable<Type> types = const [Meter, _$Meter];
  @override
  final String wireName = 'Meter';

  @override
  Iterable<Object?> serialize(Serializers serializers, Meter object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'meterId',
      serializers.serialize(object.meterId,
          specifiedType: const FullType(String)),
      'meterLocation',
      serializers.serialize(object.meterLocation,
          specifiedType: const FullType(String)),
      'meterName',
      serializers.serialize(object.meterName,
          specifiedType: const FullType(String)),
      'meterStatus',
      serializers.serialize(object.meterStatus,
          specifiedType: const FullType(String)),
      'meterType',
      serializers.serialize(object.meterType,
          specifiedType: const FullType(String)),
      'siteId',
      serializers.serialize(object.siteId,
          specifiedType: const FullType(String)),
    ];
    Object? value;
    value = object.dailyLatestDate;
    if (value != null) {
      result
        ..add('dailyLatestDate')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.dailyLatestReading;
    if (value != null) {
      result
        ..add('dailyLatestReading')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.dailyTotal;
    if (value != null) {
      result
        ..add('dailyTotal')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.monthlyTotalRm;
    if (value != null) {
      result
        ..add('monthlyTotalRm')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  Meter deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = MeterBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'meterId':
          result.meterId = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'meterLocation':
          result.meterLocation = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'meterName':
          result.meterName = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'meterStatus':
          result.meterStatus = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'meterType':
          result.meterType = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'siteId':
          result.siteId = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'dailyLatestDate':
          result.dailyLatestDate = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'dailyLatestReading':
          result.dailyLatestReading = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'dailyTotal':
          result.dailyTotal = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'monthlyTotalRm':
          result.monthlyTotalRm = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
      }
    }

    return result.build();
  }
}

class _$ReadingSerializer implements StructuredSerializer<Reading> {
  @override
  final Iterable<Type> types = const [Reading, _$Reading];
  @override
  final String wireName = 'Reading';

  @override
  Iterable<Object?> serialize(Serializers serializers, Reading object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.utilityId;
    if (value != null) {
      result
        ..add('utilityId')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.utilityType;
    if (value != null) {
      result
        ..add('utilityType')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.utilityReadingType;
    if (value != null) {
      result
        ..add('utilityReadingType')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.utilityReading;
    if (value != null) {
      result
        ..add('utilityReading')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.utilityDate;
    if (value != null) {
      result
        ..add('utilityDate')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.utilityTotalRm;
    if (value != null) {
      result
        ..add('utilityTotalRm')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.utilityMaxDemand;
    if (value != null) {
      result
        ..add('utilityMaxDemand')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.utilityTimestamp;
    if (value != null) {
      result
        ..add('utilityTimestamp')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.meterName;
    if (value != null) {
      result
        ..add('meterName')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.meterLocation;
    if (value != null) {
      result
        ..add('meterLocation')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.utilityRecordedBy;
    if (value != null) {
      result
        ..add('utilityRecordedBy')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.utilityImage;
    if (value != null) {
      result
        ..add('utilityImage')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.utilityShift;
    if (value != null) {
      result
        ..add('utilityShift')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  Reading deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = ReadingBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'utilityId':
          result.utilityId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'utilityType':
          result.utilityType = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'utilityReadingType':
          result.utilityReadingType = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'utilityReading':
          result.utilityReading = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'utilityDate':
          result.utilityDate = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'utilityTotalRm':
          result.utilityTotalRm = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'utilityMaxDemand':
          result.utilityMaxDemand = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'utilityTimestamp':
          result.utilityTimestamp = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'meterName':
          result.meterName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'meterLocation':
          result.meterLocation = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'utilityRecordedBy':
          result.utilityRecordedBy = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'utilityImage':
          result.utilityImage = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'utilityShift':
          result.utilityShift = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
      }
    }

    return result.build();
  }
}

class _$Meter extends Meter {
  @override
  final String meterId;
  @override
  final String meterLocation;
  @override
  final String meterName;
  @override
  final String meterStatus;
  @override
  final String meterType;
  @override
  final String siteId;
  @override
  final String? dailyLatestDate;
  @override
  final String? dailyLatestReading;
  @override
  final String? dailyTotal;
  @override
  final String? monthlyTotalRm;

  factory _$Meter([void Function(MeterBuilder)? updates]) =>
      (MeterBuilder()..update(updates))._build();

  _$Meter._(
      {required this.meterId,
      required this.meterLocation,
      required this.meterName,
      required this.meterStatus,
      required this.meterType,
      required this.siteId,
      this.dailyLatestDate,
      this.dailyLatestReading,
      this.dailyTotal,
      this.monthlyTotalRm})
      : super._();
  @override
  Meter rebuild(void Function(MeterBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MeterBuilder toBuilder() => MeterBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Meter &&
        meterId == other.meterId &&
        meterLocation == other.meterLocation &&
        meterName == other.meterName &&
        meterStatus == other.meterStatus &&
        meterType == other.meterType &&
        siteId == other.siteId &&
        dailyLatestDate == other.dailyLatestDate &&
        dailyLatestReading == other.dailyLatestReading &&
        dailyTotal == other.dailyTotal &&
        monthlyTotalRm == other.monthlyTotalRm;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, meterId.hashCode);
    _$hash = $jc(_$hash, meterLocation.hashCode);
    _$hash = $jc(_$hash, meterName.hashCode);
    _$hash = $jc(_$hash, meterStatus.hashCode);
    _$hash = $jc(_$hash, meterType.hashCode);
    _$hash = $jc(_$hash, siteId.hashCode);
    _$hash = $jc(_$hash, dailyLatestDate.hashCode);
    _$hash = $jc(_$hash, dailyLatestReading.hashCode);
    _$hash = $jc(_$hash, dailyTotal.hashCode);
    _$hash = $jc(_$hash, monthlyTotalRm.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Meter')
          ..add('meterId', meterId)
          ..add('meterLocation', meterLocation)
          ..add('meterName', meterName)
          ..add('meterStatus', meterStatus)
          ..add('meterType', meterType)
          ..add('siteId', siteId)
          ..add('dailyLatestDate', dailyLatestDate)
          ..add('dailyLatestReading', dailyLatestReading)
          ..add('dailyTotal', dailyTotal)
          ..add('monthlyTotalRm', monthlyTotalRm))
        .toString();
  }
}

class MeterBuilder implements Builder<Meter, MeterBuilder> {
  _$Meter? _$v;

  String? _meterId;
  String? get meterId => _$this._meterId;
  set meterId(String? meterId) => _$this._meterId = meterId;

  String? _meterLocation;
  String? get meterLocation => _$this._meterLocation;
  set meterLocation(String? meterLocation) =>
      _$this._meterLocation = meterLocation;

  String? _meterName;
  String? get meterName => _$this._meterName;
  set meterName(String? meterName) => _$this._meterName = meterName;

  String? _meterStatus;
  String? get meterStatus => _$this._meterStatus;
  set meterStatus(String? meterStatus) => _$this._meterStatus = meterStatus;

  String? _meterType;
  String? get meterType => _$this._meterType;
  set meterType(String? meterType) => _$this._meterType = meterType;

  String? _siteId;
  String? get siteId => _$this._siteId;
  set siteId(String? siteId) => _$this._siteId = siteId;

  String? _dailyLatestDate;
  String? get dailyLatestDate => _$this._dailyLatestDate;
  set dailyLatestDate(String? dailyLatestDate) =>
      _$this._dailyLatestDate = dailyLatestDate;

  String? _dailyLatestReading;
  String? get dailyLatestReading => _$this._dailyLatestReading;
  set dailyLatestReading(String? dailyLatestReading) =>
      _$this._dailyLatestReading = dailyLatestReading;

  String? _dailyTotal;
  String? get dailyTotal => _$this._dailyTotal;
  set dailyTotal(String? dailyTotal) => _$this._dailyTotal = dailyTotal;

  String? _monthlyTotalRm;
  String? get monthlyTotalRm => _$this._monthlyTotalRm;
  set monthlyTotalRm(String? monthlyTotalRm) =>
      _$this._monthlyTotalRm = monthlyTotalRm;

  MeterBuilder();

  MeterBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _meterId = $v.meterId;
      _meterLocation = $v.meterLocation;
      _meterName = $v.meterName;
      _meterStatus = $v.meterStatus;
      _meterType = $v.meterType;
      _siteId = $v.siteId;
      _dailyLatestDate = $v.dailyLatestDate;
      _dailyLatestReading = $v.dailyLatestReading;
      _dailyTotal = $v.dailyTotal;
      _monthlyTotalRm = $v.monthlyTotalRm;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Meter other) {
    _$v = other as _$Meter;
  }

  @override
  void update(void Function(MeterBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Meter build() => _build();

  _$Meter _build() {
    final _$result = _$v ??
        _$Meter._(
          meterId: BuiltValueNullFieldError.checkNotNull(
              meterId, r'Meter', 'meterId'),
          meterLocation: BuiltValueNullFieldError.checkNotNull(
              meterLocation, r'Meter', 'meterLocation'),
          meterName: BuiltValueNullFieldError.checkNotNull(
              meterName, r'Meter', 'meterName'),
          meterStatus: BuiltValueNullFieldError.checkNotNull(
              meterStatus, r'Meter', 'meterStatus'),
          meterType: BuiltValueNullFieldError.checkNotNull(
              meterType, r'Meter', 'meterType'),
          siteId:
              BuiltValueNullFieldError.checkNotNull(siteId, r'Meter', 'siteId'),
          dailyLatestDate: dailyLatestDate,
          dailyLatestReading: dailyLatestReading,
          dailyTotal: dailyTotal,
          monthlyTotalRm: monthlyTotalRm,
        );
    replace(_$result);
    return _$result;
  }
}

class _$Reading extends Reading {
  @override
  final String? utilityId;
  @override
  final String? utilityType;
  @override
  final String? utilityReadingType;
  @override
  final String? utilityReading;
  @override
  final String? utilityDate;
  @override
  final String? utilityTotalRm;
  @override
  final String? utilityMaxDemand;
  @override
  final String? utilityTimestamp;
  @override
  final String? meterName;
  @override
  final String? meterLocation;
  @override
  final String? utilityRecordedBy;
  @override
  final String? utilityImage;
  @override
  final String? utilityShift;

  factory _$Reading([void Function(ReadingBuilder)? updates]) =>
      (ReadingBuilder()..update(updates))._build();

  _$Reading._(
      {this.utilityId,
      this.utilityType,
      this.utilityReadingType,
      this.utilityReading,
      this.utilityDate,
      this.utilityTotalRm,
      this.utilityMaxDemand,
      this.utilityTimestamp,
      this.meterName,
      this.meterLocation,
      this.utilityRecordedBy,
      this.utilityImage,
      this.utilityShift})
      : super._();
  @override
  Reading rebuild(void Function(ReadingBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReadingBuilder toBuilder() => ReadingBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Reading &&
        utilityId == other.utilityId &&
        utilityType == other.utilityType &&
        utilityReadingType == other.utilityReadingType &&
        utilityReading == other.utilityReading &&
        utilityDate == other.utilityDate &&
        utilityTotalRm == other.utilityTotalRm &&
        utilityMaxDemand == other.utilityMaxDemand &&
        utilityTimestamp == other.utilityTimestamp &&
        meterName == other.meterName &&
        meterLocation == other.meterLocation &&
        utilityRecordedBy == other.utilityRecordedBy &&
        utilityImage == other.utilityImage &&
        utilityShift == other.utilityShift;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, utilityId.hashCode);
    _$hash = $jc(_$hash, utilityType.hashCode);
    _$hash = $jc(_$hash, utilityReadingType.hashCode);
    _$hash = $jc(_$hash, utilityReading.hashCode);
    _$hash = $jc(_$hash, utilityDate.hashCode);
    _$hash = $jc(_$hash, utilityTotalRm.hashCode);
    _$hash = $jc(_$hash, utilityMaxDemand.hashCode);
    _$hash = $jc(_$hash, utilityTimestamp.hashCode);
    _$hash = $jc(_$hash, meterName.hashCode);
    _$hash = $jc(_$hash, meterLocation.hashCode);
    _$hash = $jc(_$hash, utilityRecordedBy.hashCode);
    _$hash = $jc(_$hash, utilityImage.hashCode);
    _$hash = $jc(_$hash, utilityShift.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Reading')
          ..add('utilityId', utilityId)
          ..add('utilityType', utilityType)
          ..add('utilityReadingType', utilityReadingType)
          ..add('utilityReading', utilityReading)
          ..add('utilityDate', utilityDate)
          ..add('utilityTotalRm', utilityTotalRm)
          ..add('utilityMaxDemand', utilityMaxDemand)
          ..add('utilityTimestamp', utilityTimestamp)
          ..add('meterName', meterName)
          ..add('meterLocation', meterLocation)
          ..add('utilityRecordedBy', utilityRecordedBy)
          ..add('utilityImage', utilityImage)
          ..add('utilityShift', utilityShift))
        .toString();
  }
}

class ReadingBuilder implements Builder<Reading, ReadingBuilder> {
  _$Reading? _$v;

  String? _utilityId;
  String? get utilityId => _$this._utilityId;
  set utilityId(String? utilityId) => _$this._utilityId = utilityId;

  String? _utilityType;
  String? get utilityType => _$this._utilityType;
  set utilityType(String? utilityType) => _$this._utilityType = utilityType;

  String? _utilityReadingType;
  String? get utilityReadingType => _$this._utilityReadingType;
  set utilityReadingType(String? utilityReadingType) =>
      _$this._utilityReadingType = utilityReadingType;

  String? _utilityReading;
  String? get utilityReading => _$this._utilityReading;
  set utilityReading(String? utilityReading) =>
      _$this._utilityReading = utilityReading;

  String? _utilityDate;
  String? get utilityDate => _$this._utilityDate;
  set utilityDate(String? utilityDate) => _$this._utilityDate = utilityDate;

  String? _utilityTotalRm;
  String? get utilityTotalRm => _$this._utilityTotalRm;
  set utilityTotalRm(String? utilityTotalRm) =>
      _$this._utilityTotalRm = utilityTotalRm;

  String? _utilityMaxDemand;
  String? get utilityMaxDemand => _$this._utilityMaxDemand;
  set utilityMaxDemand(String? utilityMaxDemand) =>
      _$this._utilityMaxDemand = utilityMaxDemand;

  String? _utilityTimestamp;
  String? get utilityTimestamp => _$this._utilityTimestamp;
  set utilityTimestamp(String? utilityTimestamp) =>
      _$this._utilityTimestamp = utilityTimestamp;

  String? _meterName;
  String? get meterName => _$this._meterName;
  set meterName(String? meterName) => _$this._meterName = meterName;

  String? _meterLocation;
  String? get meterLocation => _$this._meterLocation;
  set meterLocation(String? meterLocation) =>
      _$this._meterLocation = meterLocation;

  String? _utilityRecordedBy;
  String? get utilityRecordedBy => _$this._utilityRecordedBy;
  set utilityRecordedBy(String? utilityRecordedBy) =>
      _$this._utilityRecordedBy = utilityRecordedBy;

  String? _utilityImage;
  String? get utilityImage => _$this._utilityImage;
  set utilityImage(String? utilityImage) => _$this._utilityImage = utilityImage;

  String? _utilityShift;
  String? get utilityShift => _$this._utilityShift;
  set utilityShift(String? utilityShift) => _$this._utilityShift = utilityShift;

  ReadingBuilder();

  ReadingBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _utilityId = $v.utilityId;
      _utilityType = $v.utilityType;
      _utilityReadingType = $v.utilityReadingType;
      _utilityReading = $v.utilityReading;
      _utilityDate = $v.utilityDate;
      _utilityTotalRm = $v.utilityTotalRm;
      _utilityMaxDemand = $v.utilityMaxDemand;
      _utilityTimestamp = $v.utilityTimestamp;
      _meterName = $v.meterName;
      _meterLocation = $v.meterLocation;
      _utilityRecordedBy = $v.utilityRecordedBy;
      _utilityImage = $v.utilityImage;
      _utilityShift = $v.utilityShift;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Reading other) {
    _$v = other as _$Reading;
  }

  @override
  void update(void Function(ReadingBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Reading build() => _build();

  _$Reading _build() {
    final _$result = _$v ??
        _$Reading._(
          utilityId: utilityId,
          utilityType: utilityType,
          utilityReadingType: utilityReadingType,
          utilityReading: utilityReading,
          utilityDate: utilityDate,
          utilityTotalRm: utilityTotalRm,
          utilityMaxDemand: utilityMaxDemand,
          utilityTimestamp: utilityTimestamp,
          meterName: meterName,
          meterLocation: meterLocation,
          utilityRecordedBy: utilityRecordedBy,
          utilityImage: utilityImage,
          utilityShift: utilityShift,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

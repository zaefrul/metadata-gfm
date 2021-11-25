// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meter.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Meter> _$meterSerializer = new _$MeterSerializer();
Serializer<Reading> _$readingSerializer = new _$ReadingSerializer();

class _$MeterSerializer implements StructuredSerializer<Meter> {
  @override
  final Iterable<Type> types = const [Meter, _$Meter];
  @override
  final String wireName = 'Meter';

  @override
  Iterable<Object> serialize(Serializers serializers, Meter object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
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
    if (object.dailyLatestDate != null) {
      result
        ..add('dailyLatestDate')
        ..add(serializers.serialize(object.dailyLatestDate,
            specifiedType: const FullType(String)));
    }
    if (object.dailyLatestReading != null) {
      result
        ..add('dailyLatestReading')
        ..add(serializers.serialize(object.dailyLatestReading,
            specifiedType: const FullType(String)));
    }
    if (object.dailyTotal != null) {
      result
        ..add('dailyTotal')
        ..add(serializers.serialize(object.dailyTotal,
            specifiedType: const FullType(String)));
    }
    if (object.monthlyTotalRm != null) {
      result
        ..add('monthlyTotalRm')
        ..add(serializers.serialize(object.monthlyTotalRm,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  Meter deserialize(Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new MeterBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'meterId':
          result.meterId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'meterLocation':
          result.meterLocation = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'meterName':
          result.meterName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'meterStatus':
          result.meterStatus = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'meterType':
          result.meterType = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'siteId':
          result.siteId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'dailyLatestDate':
          result.dailyLatestDate = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'dailyLatestReading':
          result.dailyLatestReading = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'dailyTotal':
          result.dailyTotal = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'monthlyTotalRm':
          result.monthlyTotalRm = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
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
  Iterable<Object> serialize(Serializers serializers, Reading object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[];
    if (object.utilityId != null) {
      result
        ..add('utilityId')
        ..add(serializers.serialize(object.utilityId,
            specifiedType: const FullType(String)));
    }
    if (object.utilityType != null) {
      result
        ..add('utilityType')
        ..add(serializers.serialize(object.utilityType,
            specifiedType: const FullType(String)));
    }
    if (object.utilityReadingType != null) {
      result
        ..add('utilityReadingType')
        ..add(serializers.serialize(object.utilityReadingType,
            specifiedType: const FullType(String)));
    }
    if (object.utilityReading != null) {
      result
        ..add('utilityReading')
        ..add(serializers.serialize(object.utilityReading,
            specifiedType: const FullType(String)));
    }
    if (object.utilityDate != null) {
      result
        ..add('utilityDate')
        ..add(serializers.serialize(object.utilityDate,
            specifiedType: const FullType(String)));
    }
    if (object.utilityTotalRm != null) {
      result
        ..add('utilityTotalRm')
        ..add(serializers.serialize(object.utilityTotalRm,
            specifiedType: const FullType(String)));
    }
    if (object.utilityMaxDemand != null) {
      result
        ..add('utilityMaxDemand')
        ..add(serializers.serialize(object.utilityMaxDemand,
            specifiedType: const FullType(String)));
    }
    if (object.utilityTimestamp != null) {
      result
        ..add('utilityTimestamp')
        ..add(serializers.serialize(object.utilityTimestamp,
            specifiedType: const FullType(String)));
    }
    if (object.meterName != null) {
      result
        ..add('meterName')
        ..add(serializers.serialize(object.meterName,
            specifiedType: const FullType(String)));
    }
    if (object.meterLocation != null) {
      result
        ..add('meterLocation')
        ..add(serializers.serialize(object.meterLocation,
            specifiedType: const FullType(String)));
    }
    if (object.utilityRecordedBy != null) {
      result
        ..add('utilityRecordedBy')
        ..add(serializers.serialize(object.utilityRecordedBy,
            specifiedType: const FullType(String)));
    }
    if (object.utilityImage != null) {
      result
        ..add('utilityImage')
        ..add(serializers.serialize(object.utilityImage,
            specifiedType: const FullType(String)));
    }
    if (object.utilityShift != null) {
      result
        ..add('utilityShift')
        ..add(serializers.serialize(object.utilityShift,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  Reading deserialize(Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new ReadingBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'utilityId':
          result.utilityId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'utilityType':
          result.utilityType = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'utilityReadingType':
          result.utilityReadingType = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'utilityReading':
          result.utilityReading = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'utilityDate':
          result.utilityDate = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'utilityTotalRm':
          result.utilityTotalRm = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'utilityMaxDemand':
          result.utilityMaxDemand = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'utilityTimestamp':
          result.utilityTimestamp = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'meterName':
          result.meterName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'meterLocation':
          result.meterLocation = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'utilityRecordedBy':
          result.utilityRecordedBy = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'utilityImage':
          result.utilityImage = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'utilityShift':
          result.utilityShift = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
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
  final String dailyLatestDate;
  @override
  final String dailyLatestReading;
  @override
  final String dailyTotal;
  @override
  final String monthlyTotalRm;

  factory _$Meter([void Function(MeterBuilder) updates]) =>
      (new MeterBuilder()..update(updates)).build();

  _$Meter._(
      {this.meterId,
      this.meterLocation,
      this.meterName,
      this.meterStatus,
      this.meterType,
      this.siteId,
      this.dailyLatestDate,
      this.dailyLatestReading,
      this.dailyTotal,
      this.monthlyTotalRm})
      : super._() {
    if (meterId == null) {
      throw new BuiltValueNullFieldError('Meter', 'meterId');
    }
    if (meterLocation == null) {
      throw new BuiltValueNullFieldError('Meter', 'meterLocation');
    }
    if (meterName == null) {
      throw new BuiltValueNullFieldError('Meter', 'meterName');
    }
    if (meterStatus == null) {
      throw new BuiltValueNullFieldError('Meter', 'meterStatus');
    }
    if (meterType == null) {
      throw new BuiltValueNullFieldError('Meter', 'meterType');
    }
    if (siteId == null) {
      throw new BuiltValueNullFieldError('Meter', 'siteId');
    }
  }

  @override
  Meter rebuild(void Function(MeterBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MeterBuilder toBuilder() => new MeterBuilder()..replace(this);

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
    return $jf($jc(
        $jc(
            $jc(
                $jc(
                    $jc(
                        $jc(
                            $jc(
                                $jc(
                                    $jc($jc(0, meterId.hashCode),
                                        meterLocation.hashCode),
                                    meterName.hashCode),
                                meterStatus.hashCode),
                            meterType.hashCode),
                        siteId.hashCode),
                    dailyLatestDate.hashCode),
                dailyLatestReading.hashCode),
            dailyTotal.hashCode),
        monthlyTotalRm.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Meter')
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
  _$Meter _$v;

  String _meterId;
  String get meterId => _$this._meterId;
  set meterId(String meterId) => _$this._meterId = meterId;

  String _meterLocation;
  String get meterLocation => _$this._meterLocation;
  set meterLocation(String meterLocation) =>
      _$this._meterLocation = meterLocation;

  String _meterName;
  String get meterName => _$this._meterName;
  set meterName(String meterName) => _$this._meterName = meterName;

  String _meterStatus;
  String get meterStatus => _$this._meterStatus;
  set meterStatus(String meterStatus) => _$this._meterStatus = meterStatus;

  String _meterType;
  String get meterType => _$this._meterType;
  set meterType(String meterType) => _$this._meterType = meterType;

  String _siteId;
  String get siteId => _$this._siteId;
  set siteId(String siteId) => _$this._siteId = siteId;

  String _dailyLatestDate;
  String get dailyLatestDate => _$this._dailyLatestDate;
  set dailyLatestDate(String dailyLatestDate) =>
      _$this._dailyLatestDate = dailyLatestDate;

  String _dailyLatestReading;
  String get dailyLatestReading => _$this._dailyLatestReading;
  set dailyLatestReading(String dailyLatestReading) =>
      _$this._dailyLatestReading = dailyLatestReading;

  String _dailyTotal;
  String get dailyTotal => _$this._dailyTotal;
  set dailyTotal(String dailyTotal) => _$this._dailyTotal = dailyTotal;

  String _monthlyTotalRm;
  String get monthlyTotalRm => _$this._monthlyTotalRm;
  set monthlyTotalRm(String monthlyTotalRm) =>
      _$this._monthlyTotalRm = monthlyTotalRm;

  MeterBuilder();

  MeterBuilder get _$this {
    if (_$v != null) {
      _meterId = _$v.meterId;
      _meterLocation = _$v.meterLocation;
      _meterName = _$v.meterName;
      _meterStatus = _$v.meterStatus;
      _meterType = _$v.meterType;
      _siteId = _$v.siteId;
      _dailyLatestDate = _$v.dailyLatestDate;
      _dailyLatestReading = _$v.dailyLatestReading;
      _dailyTotal = _$v.dailyTotal;
      _monthlyTotalRm = _$v.monthlyTotalRm;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Meter other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$Meter;
  }

  @override
  void update(void Function(MeterBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Meter build() {
    final _$result = _$v ??
        new _$Meter._(
            meterId: meterId,
            meterLocation: meterLocation,
            meterName: meterName,
            meterStatus: meterStatus,
            meterType: meterType,
            siteId: siteId,
            dailyLatestDate: dailyLatestDate,
            dailyLatestReading: dailyLatestReading,
            dailyTotal: dailyTotal,
            monthlyTotalRm: monthlyTotalRm);
    replace(_$result);
    return _$result;
  }
}

class _$Reading extends Reading {
  @override
  final String utilityId;
  @override
  final String utilityType;
  @override
  final String utilityReadingType;
  @override
  final String utilityReading;
  @override
  final String utilityDate;
  @override
  final String utilityTotalRm;
  @override
  final String utilityMaxDemand;
  @override
  final String utilityTimestamp;
  @override
  final String meterName;
  @override
  final String meterLocation;
  @override
  final String utilityRecordedBy;
  @override
  final String utilityImage;
  @override
  final String utilityShift;

  factory _$Reading([void Function(ReadingBuilder) updates]) =>
      (new ReadingBuilder()..update(updates)).build();

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
  ReadingBuilder toBuilder() => new ReadingBuilder()..replace(this);

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
                                                $jc($jc(0, utilityId.hashCode),
                                                    utilityType.hashCode),
                                                utilityReadingType.hashCode),
                                            utilityReading.hashCode),
                                        utilityDate.hashCode),
                                    utilityTotalRm.hashCode),
                                utilityMaxDemand.hashCode),
                            utilityTimestamp.hashCode),
                        meterName.hashCode),
                    meterLocation.hashCode),
                utilityRecordedBy.hashCode),
            utilityImage.hashCode),
        utilityShift.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Reading')
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
  _$Reading _$v;

  String _utilityId;
  String get utilityId => _$this._utilityId;
  set utilityId(String utilityId) => _$this._utilityId = utilityId;

  String _utilityType;
  String get utilityType => _$this._utilityType;
  set utilityType(String utilityType) => _$this._utilityType = utilityType;

  String _utilityReadingType;
  String get utilityReadingType => _$this._utilityReadingType;
  set utilityReadingType(String utilityReadingType) =>
      _$this._utilityReadingType = utilityReadingType;

  String _utilityReading;
  String get utilityReading => _$this._utilityReading;
  set utilityReading(String utilityReading) =>
      _$this._utilityReading = utilityReading;

  String _utilityDate;
  String get utilityDate => _$this._utilityDate;
  set utilityDate(String utilityDate) => _$this._utilityDate = utilityDate;

  String _utilityTotalRm;
  String get utilityTotalRm => _$this._utilityTotalRm;
  set utilityTotalRm(String utilityTotalRm) =>
      _$this._utilityTotalRm = utilityTotalRm;

  String _utilityMaxDemand;
  String get utilityMaxDemand => _$this._utilityMaxDemand;
  set utilityMaxDemand(String utilityMaxDemand) =>
      _$this._utilityMaxDemand = utilityMaxDemand;

  String _utilityTimestamp;
  String get utilityTimestamp => _$this._utilityTimestamp;
  set utilityTimestamp(String utilityTimestamp) =>
      _$this._utilityTimestamp = utilityTimestamp;

  String _meterName;
  String get meterName => _$this._meterName;
  set meterName(String meterName) => _$this._meterName = meterName;

  String _meterLocation;
  String get meterLocation => _$this._meterLocation;
  set meterLocation(String meterLocation) =>
      _$this._meterLocation = meterLocation;

  String _utilityRecordedBy;
  String get utilityRecordedBy => _$this._utilityRecordedBy;
  set utilityRecordedBy(String utilityRecordedBy) =>
      _$this._utilityRecordedBy = utilityRecordedBy;

  String _utilityImage;
  String get utilityImage => _$this._utilityImage;
  set utilityImage(String utilityImage) => _$this._utilityImage = utilityImage;

  String _utilityShift;
  String get utilityShift => _$this._utilityShift;
  set utilityShift(String utilityShift) => _$this._utilityShift = utilityShift;

  ReadingBuilder();

  ReadingBuilder get _$this {
    if (_$v != null) {
      _utilityId = _$v.utilityId;
      _utilityType = _$v.utilityType;
      _utilityReadingType = _$v.utilityReadingType;
      _utilityReading = _$v.utilityReading;
      _utilityDate = _$v.utilityDate;
      _utilityTotalRm = _$v.utilityTotalRm;
      _utilityMaxDemand = _$v.utilityMaxDemand;
      _utilityTimestamp = _$v.utilityTimestamp;
      _meterName = _$v.meterName;
      _meterLocation = _$v.meterLocation;
      _utilityRecordedBy = _$v.utilityRecordedBy;
      _utilityImage = _$v.utilityImage;
      _utilityShift = _$v.utilityShift;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Reading other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$Reading;
  }

  @override
  void update(void Function(ReadingBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Reading build() {
    final _$result = _$v ??
        new _$Reading._(
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
            utilityShift: utilityShift);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new

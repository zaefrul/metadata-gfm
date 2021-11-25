import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:intl/intl.dart';

part 'meter.g.dart';

abstract class Meter implements Built<Meter, MeterBuilder> {
  String get meterId;
  String get meterLocation;
  String get meterName;
  String get meterStatus;
  String get meterType;
  String get siteId;
  @nullable
  String get dailyLatestDate;
  @nullable
  String get dailyLatestReading;
  @nullable
  String get dailyTotal;
  @nullable
  String get monthlyTotalRm;

  Meter._();
  factory Meter([void Function(MeterBuilder) updates]) = _$Meter;

  static Serializer<Meter> get serializer => _$meterSerializer;
}

abstract class Reading implements Built<Reading, ReadingBuilder> {
  @nullable
  String get utilityId;
  @nullable
  String get utilityType;
  @nullable
  String get utilityReadingType;
  @nullable
  String get utilityReading;
  @nullable
  String get utilityDate;
  @nullable
  String get utilityTotalRm;
  @nullable
  String get utilityMaxDemand;
  @nullable
  String get utilityTimestamp;
  @nullable
  String get meterName;
  @nullable
  String get meterLocation;
  @nullable
  String get utilityRecordedBy;
  @nullable
  String get utilityImage;
  @nullable
  String get utilityShift;

  String get month => DateFormat.MMMM()
      .format(DateTime.parse(utilityDate))
      .substring(0, 3)
      .toUpperCase();
  String get day => DateTime.parse(utilityDate).day.toString();
  String get year => DateTime.parse(utilityDate).year.toString();
  String get time =>
      DateFormat("hh:ss a").format(DateTime.parse(utilityTimestamp));

  Reading._();
  factory Reading([void Function(ReadingBuilder) updates]) = _$Reading;

  static Serializer<Reading> get serializer => _$readingSerializer;
}

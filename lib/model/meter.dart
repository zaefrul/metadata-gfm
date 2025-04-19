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
  String? get dailyLatestDate;
  String? get dailyLatestReading;
  String? get dailyTotal;
  String? get monthlyTotalRm;

  Meter._();
  factory Meter([void Function(MeterBuilder) updates]) = _$Meter;

  static Serializer<Meter> get serializer => _$meterSerializer;

  // helper class to check if meter is empty
  static Meter empty() {
    return Meter((b) => b
      ..meterId = ""
      ..meterLocation = ""
      ..meterName = ""
      ..meterStatus = ""
      ..meterType = ""
      ..siteId = ""
      ..dailyLatestDate = ""
      ..dailyLatestReading = ""
      ..dailyTotal = ""
      ..monthlyTotalRm = "");
  }
}

abstract class Reading implements Built<Reading, ReadingBuilder> {
  String? get utilityId;
  String? get utilityType;
  String? get utilityReadingType;
  String? get utilityReading;
  String? get utilityDate;
  String? get utilityTotalRm;
  String? get utilityMaxDemand;
  String? get utilityTimestamp;
  String? get meterName;
  String? get meterLocation;
  String? get utilityRecordedBy;
  String? get utilityImage;
  String? get utilityShift;

  // These getters assume that utilityDate and utilityTimestamp are not null at usage.
  String get month => DateFormat.MMMM()
      .format(DateTime.parse(utilityDate!))
      .substring(0, 3)
      .toUpperCase();
  String get day => DateTime.parse(utilityDate!).day.toString();
  String get year => DateTime.parse(utilityDate!).year.toString();
  String get time =>
      DateFormat("hh:ss a").format(DateTime.parse(utilityTimestamp!));

  Reading._();
  factory Reading([void Function(ReadingBuilder) updates]) = _$Reading;

  static Serializer<Reading> get serializer => _$readingSerializer;
}

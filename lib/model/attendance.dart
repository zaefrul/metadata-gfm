import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:gfm_gems/model/serializers.dart';

part 'attendance.g.dart';

abstract class Attendance implements Built<Attendance, AttendanceBuilder> {
  @nullable
  String get date;
  @nullable
  int get attTransactionId;
  @nullable
  String get currentTime;
  @nullable
  String get currentShift;
  @nullable
  String get button;
  @nullable
  String get status;
  @nullable
  String get shiftStart;
  @nullable
  String get shiftEnd;
  @nullable
  String get timeClockIn;
  @nullable
  String get timeClockOut;
  @nullable
  String get duration;
  @nullable
  String get weeklyRequiredHours;
  @nullable
  String get weeklyDuration;
  @nullable
  String get weeklyProgress;
  @nullable
  String get nextShiftStart;
  @nullable
  String get remark;

  Attendance._();
  factory Attendance([void Function(AttendanceBuilder) updates]) = _$Attendance;

  static Attendance fromJson(Map<String, dynamic> json) {
    return serializers.deserializeWith(Attendance.serializer, json);
  }

  static Serializer<Attendance> get serializer => _$attendanceSerializer;
}

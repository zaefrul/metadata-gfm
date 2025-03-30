import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:gfm_gems/model/serializers.dart';

part 'attendance.g.dart';

abstract class Attendance implements Built<Attendance, AttendanceBuilder> {
  String? get date;
  int? get attTransactionId;
  String? get currentTime;
  String? get currentShift;
  String? get button;
  String? get status;
  String? get shiftStart;
  String? get shiftEnd;
  String? get timeClockIn;
  String? get timeClockOut;
  String? get duration;
  String? get weeklyRequiredHours;
  String? get weeklyDuration;
  String? get weeklyProgress;
  String? get nextShiftStart;
  String? get remark;

  Attendance._();
  factory Attendance([void Function(AttendanceBuilder) updates]) = _$Attendance;

  static Attendance fromJson(Map<String, dynamic> json) {
    return serializers.deserializeWith(Attendance.serializer, json)!;
  }

  static Serializer<Attendance> get serializer => _$attendanceSerializer;
}

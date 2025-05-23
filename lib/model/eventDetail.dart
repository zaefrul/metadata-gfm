import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:GEMS/model/serializers.dart';

part 'eventDetail.g.dart';

abstract class EventDetail implements Built<EventDetail, EventDetailBuilder> {
  String? get date;
  String? get currentTime;
  String? get currentShift;
  String? get status;
  String? get shiftStart;
  String? get shiftEnd;
  String? get timeClockIn;
  String? get timeClockOut;
  String? get duration;

  EventDetail._();
  factory EventDetail([void Function(EventDetailBuilder) updates]) = _$EventDetail;

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(EventDetail.serializer, this)
        as Map<String, dynamic>;
  }

  static EventDetail? fromJson(Map<String, dynamic> json) {
    return serializers.deserializeWith(EventDetail.serializer, json);
  }

  static Serializer<EventDetail> get serializer => _$eventDetailSerializer;
}

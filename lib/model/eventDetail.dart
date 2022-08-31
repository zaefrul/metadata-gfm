import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:gfm_gems/model/serializers.dart';

part 'eventDetail.g.dart';

abstract class EventDetail implements Built<EventDetail, EventDetailBuilder> {
  @nullable
  String get date;
  @nullable
  String get currentTime;
  @nullable
  String get currentShift;
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

  EventDetail._();
  factory EventDetail([void Function(EventDetailBuilder) updates]) =
      _$EventDetail;

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(EventDetail.serializer, this);
  }

  static EventDetail fromJson(Map<String, dynamic> json) {
    return serializers.deserializeWith(EventDetail.serializer, json);
  }

  static Serializer<EventDetail> get serializer => _$eventDetailSerializer;
}

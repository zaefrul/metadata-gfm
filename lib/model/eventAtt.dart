import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:gfm_gems/model/serializers.dart';

part 'eventAtt.g.dart';

abstract class EventAtt implements Built<EventAtt, EventAttBuilder> {
  @nullable
  String get date;

  @nullable
  String get status;
  @nullable
  String get color;

  EventAtt._();
  factory EventAtt([void Function(EventAttBuilder) updates]) = _$EventAtt;

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(EventAtt.serializer, this);
  }

  static EventAtt fromJson(Map<String, dynamic> json) {
    return serializers.deserializeWith(EventAtt.serializer, json);
  }

  static Serializer<EventAtt> get serializer => _$eventAttSerializer;
}

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'complaint.dart';

part 'complaintResponse.g.dart';

abstract class ComplaintResponse
    implements Built<ComplaintResponse, ComplaintResponseBuilder> {
  bool get success;
  String get error;
  String get errmsg;

  @nullable
  @BuiltValueField(wireName: 'result')
  BuiltList<ComplaintD> get items;
  @nullable
  @BuiltValueField(wireName: 'result')
  BuiltList<ComplaintDGroup> get groups;
  @nullable
  @BuiltValueField(wireName: 'result')
  BuiltList<ComplaintDType> get types;
  @nullable
  @BuiltValueField(wireName: 'result')
  BuiltList<ComplaintDPart> get parts;

  ComplaintResponse._();
  factory ComplaintResponse([void Function(ComplaintResponseBuilder) updates]) =
      _$ComplaintResponse;

  static Serializer<ComplaintResponse> get serializer =>
      _$complaintResponseSerializer;
}

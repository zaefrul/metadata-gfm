import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:gfm_gems/model/serializers.dart';

part 'gamificationInfo.g.dart';

abstract class GamificationInfo
    implements Built<GamificationInfo, GamificationInfoBuilder> {
  @nullable
  String get gmiId;
  @nullable
  String get userId;
  @nullable
  String get siteId;
  @nullable
  String get gmiYear;
  @nullable
  String get gmiMonth;
  @nullable
  String get gmiPpmTierName;
  @nullable
  String get gmiPpmTierPoint;
  @nullable
  String get gmiPpmTotal;
  @nullable
  String get gmiPpmCompleted;
  @nullable
  String get gmiPpmOnTime;
  @nullable
  String get gmiPpmLate;
  @nullable
  String get gmiPpmWithin;
  @nullable
  String get gmiPpmRework;
  @nullable
  String get gmiPpmAssist;
  @nullable
  String get gmiWoTierName;
  @nullable
  String get gmiWoTierPoint;
  @nullable
  String get gmiWoTotal;
  @nullable
  String get gmiWoCompleted;
  @nullable
  String get gmiWoOnTime;
  @nullable
  String get gmiWoLate;
  @nullable
  String get gmiWoRework;
  @nullable
  String get gmiWoSelfFinding;
  @nullable
  String get gmiWoAssist;
  @nullable
  String get gmiMbv;
  @nullable
  String get gmiTierPoint;
  @nullable
  String get gmiPointCompleted;
  @nullable
  String get gmiPointOnTime;
  @nullable
  String get gmiPointLate;
  @nullable
  String get gmiPointRework;
  @nullable
  String get gmiPointSelfFinding;
  @nullable
  String get gmiPointTotal;

  GamificationInfo._();
  factory GamificationInfo([void Function(GamificationInfoBuilder) updates]) =
      _$GamificationInfo;

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(GamificationInfo.serializer, this);
  }

  static GamificationInfo fromJson(Map<String, dynamic> json) {
    return serializers.deserializeWith(GamificationInfo.serializer, json);
  }

  static Serializer<GamificationInfo> get serializer =>
      _$gamificationInfoSerializer;
}

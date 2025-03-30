import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:gfm_gems/model/serializers.dart';

part 'gamificationInfo.g.dart';

abstract class GamificationInfo
    implements Built<GamificationInfo, GamificationInfoBuilder> {
  String? get gmiId;
  String? get userId;
  String? get siteId;
  String? get gmiYear;
  String? get gmiMonth;
  String? get gmiPpmTierName;
  String? get gmiPpmTierPoint;
  String? get gmiPpmTotal;
  String? get gmiPpmCompleted;
  String? get gmiPpmOnTime;
  String? get gmiPpmLate;
  String? get gmiPpmWithin;
  String? get gmiPpmRework;
  String? get gmiPpmAssist;
  String? get gmiWoTierName;
  String? get gmiWoTierPoint;
  String? get gmiWoTotal;
  String? get gmiWoCompleted;
  String? get gmiWoOnTime;
  String? get gmiWoLate;
  String? get gmiWoRework;
  String? get gmiWoSelfFinding;
  String? get gmiWoAssist;
  String? get gmiMbv;
  String? get gmiTierPoint;
  String? get gmiPointCompleted;
  String? get gmiPointOnTime;
  String? get gmiPointLate;
  String? get gmiPointRework;
  String? get gmiPointSelfFinding;
  String? get gmiPointTotal;

  GamificationInfo._();
  factory GamificationInfo([void Function(GamificationInfoBuilder) updates]) =
      _$GamificationInfo;

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(GamificationInfo.serializer, this)
        as Map<String, dynamic>;
  }

  static GamificationInfo? fromJson(Map<String, dynamic> json) {
    return serializers.deserializeWith(GamificationInfo.serializer, json);
  }

  static Serializer<GamificationInfo> get serializer =>
      _$gamificationInfoSerializer;
}

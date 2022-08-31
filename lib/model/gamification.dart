import 'package:intl/intl.dart';

extension StringExtension on String {
  String capitalize() {
    // return this;
    final list = this.split(" ");
    final newList = list.map((element) {
      if (element.length > 1) {
        final first = element.substring(0, 1).toUpperCase();

        final rest = element.substring(1, element.length).toLowerCase();
        return "$first$rest";
      } else {
        return element;
      }
    }).toList();
    return newList.join(" ");
  }
}

class IndividualGamification {
  final String category;
  final String name;
  final String project;
  final String score;

  IndividualGamification(this.category, this.name, this.project, this.score);

  factory IndividualGamification.fromJson(Map<String, dynamic> value) {
    return IndividualGamification(
      value['individualCategory'],
      value['individualName'],
      value['projectName'],
      NumberFormat('#,###,000').format(int.parse(value['totalScore'])),
    );
  }
}

class ProjectGamification {
  final String name;
  final String score;

  ProjectGamification(this.name, this.score);

  factory ProjectGamification.fromJson(Map<String, dynamic> json) =>
      ProjectGamification(json["siteName"],
          NumberFormat('#,###,000').format(int.parse(json["totalScore"])));
}

class GamificationInfo {
  final String gmiId;
  final String userId;
  final String siteId;
  final String gmiYear;
  final String gmiMonth;
  final String gmiPpmTierName;
  final String gmiPpmTierPoint;
  final String gmiPpmTotal;
  final String gmiPpmCompleted;
  final String gmiPpmOnTime;
  final String gmiPpmLate;
  final String gmiPpmWithin;
  final String gmiPpmRework;
  final String gmiPpmAssist;
  final String gmiWoTierName;
  final String gmiWoTierPoint;
  final String gmiWoTotal;
  final String gmiWoCompleted;
  final String gmiWoOnTime;
  final String gmiWoLate;
  final String gmiWoRework;
  final String gmiWoSelfFinding;
  final String gmiWoAssist;
  final String gmiMbv;
  final String gmiTierPoint;
  final String gmiPointCompleted;
  final String gmiPointOnTime;
  final String gmiPointLate;
  final String gmiPointRework;
  final String gmiPointSelfFinding;
  final String gmiPointTotal;

  GamificationInfo(
      this.gmiId,
      this.userId,
      this.siteId,
      this.gmiYear,
      this.gmiMonth,
      this.gmiPpmTierName,
      this.gmiPpmTierPoint,
      this.gmiPpmTotal,
      this.gmiPpmCompleted,
      this.gmiPpmOnTime,
      this.gmiPpmLate,
      this.gmiPpmWithin,
      this.gmiPpmRework,
      this.gmiPpmAssist,
      this.gmiWoTierName,
      this.gmiWoTierPoint,
      this.gmiWoTotal,
      this.gmiWoCompleted,
      this.gmiWoOnTime,
      this.gmiWoLate,
      this.gmiWoRework,
      this.gmiWoSelfFinding,
      this.gmiWoAssist,
      this.gmiMbv,
      this.gmiTierPoint,
      this.gmiPointCompleted,
      this.gmiPointOnTime,
      this.gmiPointLate,
      this.gmiPointRework,
      this.gmiPointSelfFinding,
      this.gmiPointTotal);

  factory GamificationInfo.fromJson(Map<String, dynamic> json) =>
      GamificationInfo(
        json['gmiId'],
        json['userId'],
        json['siteId'],
        json['gmiYear'],
        json['gmiMonth'],
        json['gmiPpmTierName'],
        json['gmiPpmTierPoint'],
        json['gmiPpmTotal'],
        json['gmiPpmCompleted'],
        json['gmiPpmOnTime'],
        json['gmiPpmLate'],
        json['gmiPpmWithin'],
        json['gmiPpmRework'],
        json['gmiPpmAssist'],
        json['gmiWoTierName'],
        json['gmiWoTierPoint'],
        json['gmiWoTotal'],
        json['gmiWoCompleted'],
        json['gmiWoOnTime'],
        json['gmiWoLate'],
        json['gmiWoRework'],
        json['gmiWoSelfFinding'],
        json['gmiWoAssist'],
        json['gmiMbv'],
        json['gmiTierPoint'],
        json['gmiPointCompleted'],
        json['gmiPointOnTime'],
        json['gmiPointLate'],
        json['gmiPointRework'],
        json['gmiPointSelfFinding'],
        json['gmiPointTotal'],
      );
}

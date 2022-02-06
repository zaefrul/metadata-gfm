import 'package:intl/intl.dart';

extension StringExtension on String {
  String capitalize() {
    final list = this.split(" ");
    final newList = list.map((element) {
      final first = element.substring(0, 1).toUpperCase();
      final rest = element.substring(1, element.length).toLowerCase();
      return "$first$rest";
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

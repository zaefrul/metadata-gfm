/// Plain models for the Energy API (`/energy/*`).
///
/// Values arrive as numbers from PHP and sometimes as strings, so parsing
/// accepts both.
class EnergyMe {
  const EnergyMe({
    required this.userId,
    required this.siteId,
    required this.isAdmin,
    required this.canRecord,
    required this.canSetup,
    required this.canView,
  });

  final String userId;
  final String siteId;
  final bool isAdmin;
  final bool canRecord;
  final bool canSetup;
  final bool canView;

  factory EnergyMe.fromJson(Map<String, dynamic> json) {
    return EnergyMe(
      userId: _asString(json['userId']),
      siteId: _asString(json['siteId']),
      isAdmin: _asBool(json['isAdmin']),
      canRecord: _asBool(json['canRecord']),
      canSetup: _asBool(json['canSetup']),
      canView: _asBool(json['canView']),
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'siteId': siteId,
        'isAdmin': isAdmin,
        'canRecord': canRecord,
        'canSetup': canSetup,
        'canView': canView,
      };
}

class EnergyMeter {
  const EnergyMeter({
    required this.meterId,
    required this.siteId,
    required this.meterName,
    required this.meterDesc,
    required this.sortOrder,
    required this.meterStatus,
  });

  final String meterId;
  final String siteId;
  final String meterName;
  final String meterDesc;
  final int sortOrder;
  final int meterStatus;

  String get label {
    if (meterDesc.isEmpty) return meterName;
    return '$meterName ($meterDesc)';
  }

  factory EnergyMeter.fromJson(Map<String, dynamic> json) {
    return EnergyMeter(
      meterId: _asString(json['meterId']),
      siteId: _asString(json['siteId']),
      meterName: _asString(json['meterName']),
      meterDesc: _asString(json['meterDesc']),
      sortOrder: _asInt(json['sortOrder']),
      meterStatus: _asInt(json['meterStatus']),
    );
  }

  Map<String, dynamic> toJson() => {
        'meterId': meterId,
        'siteId': siteId,
        'meterName': meterName,
        'meterDesc': meterDesc,
        'sortOrder': sortOrder,
        'meterStatus': meterStatus,
      };
}

class EnergyCell {
  const EnergyCell({
    required this.meterId,
    required this.meterName,
    required this.readingId,
    required this.cumulativeKwh,
    required this.maxDemandKw,
    required this.remark,
    required this.consumptionKwh,
  });

  final String meterId;
  final String meterName;
  final String? readingId;
  final double? cumulativeKwh;
  final double? maxDemandKw;
  final String remark;
  final double? consumptionKwh;

  bool get hasReading => cumulativeKwh != null || consumptionKwh != null;

  factory EnergyCell.fromJson(Map<String, dynamic> json) {
    return EnergyCell(
      meterId: _asString(json['meterId']),
      meterName: _asString(json['meterName']),
      readingId: _asOptionalString(json['readingId']),
      cumulativeKwh: _asDouble(json['cumulativeKwh']),
      maxDemandKw: _asDouble(json['maxDemandKw']),
      remark: _asString(json['remark']),
      consumptionKwh: _asDouble(json['consumptionKwh']),
    );
  }
}

class EnergyDay {
  const EnergyDay({
    required this.date,
    required this.day,
    required this.dayName,
    required this.meters,
    required this.totalKwh,
    required this.remark,
  });

  final String date;
  final String day;
  final String dayName;
  final List<EnergyCell> meters;
  final double? totalKwh;
  final String remark;

  EnergyCell? cellFor(String meterId) {
    for (final cell in meters) {
      if (cell.meterId == meterId) return cell;
    }
    return null;
  }

  factory EnergyDay.fromJson(Map<String, dynamic> json) {
    return EnergyDay(
      date: _asString(json['date']),
      day: _asString(json['day']),
      dayName: _asString(json['dayName']),
      meters: _asList(json['meters']).map((row) => EnergyCell.fromJson(_asMap(row))).toList(),
      totalKwh: _asDouble(json['totalKwh']),
      remark: _asString(json['remark']),
    );
  }
}

class EnergyMeterTotal {
  const EnergyMeterTotal({
    required this.meterId,
    required this.meterName,
    required this.totalKwh,
  });

  final String meterId;
  final String meterName;
  final double totalKwh;

  factory EnergyMeterTotal.fromJson(Map<String, dynamic> json) {
    return EnergyMeterTotal(
      meterId: _asString(json['meterId']),
      meterName: _asString(json['meterName']),
      totalKwh: _asDouble(json['totalKwh']) ?? 0,
    );
  }
}

class EnergyLatest {
  const EnergyLatest(this.date, this.cell);

  final String date;
  final EnergyCell cell;
}

class EnergyMonth {
  const EnergyMonth({
    required this.year,
    required this.month,
    required this.periodLabel,
    required this.meters,
    required this.rows,
    required this.meterTotals,
    required this.totalKwh,
    required this.canRecord,
  });

  final int year;
  final int month;
  final String periodLabel;
  final List<EnergyMeter> meters;
  final List<EnergyDay> rows;
  final List<EnergyMeterTotal> meterTotals;
  final double totalKwh;
  final bool canRecord;

  double? totalFor(String meterId) {
    for (final total in meterTotals) {
      if (total.meterId == meterId) return total.totalKwh;
    }
    return null;
  }

  /// Last entered cumulative reading in this month, and the date it was taken.
  EnergyLatest? latestFor(String meterId) {
    EnergyLatest? latest;
    for (final row in rows) {
      final cell = row.cellFor(meterId);
      if (cell != null && cell.cumulativeKwh != null) {
        latest = EnergyLatest(row.date, cell);
      }
    }
    return latest;
  }

  factory EnergyMonth.fromJson(Map<String, dynamic> json) {
    return EnergyMonth(
      year: _asInt(json['year']),
      month: _asInt(json['month']),
      periodLabel: _asString(json['periodLabel']),
      meters: _asList(json['meters']).map((row) => EnergyMeter.fromJson(_asMap(row))).toList(),
      rows: _asList(json['rows']).map((row) => EnergyDay.fromJson(_asMap(row))).toList(),
      meterTotals: _asList(json['meterTotals'])
          .map((row) => EnergyMeterTotal.fromJson(_asMap(row)))
          .toList(),
      totalKwh: _asDouble(json['totalKwh']) ?? 0,
      canRecord: _asBool(json['canRecord']),
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return <String, dynamic>{};
}

List<dynamic> _asList(dynamic value) => value is List ? value : const [];

String _asString(dynamic value) => value == null ? '' : value.toString();

String? _asOptionalString(dynamic value) {
  if (value == null) return null;
  final text = value.toString();
  return text.isEmpty ? null : text;
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double? _asDouble(dynamic value) {
  if (value == null || value == '') return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value?.toString().toLowerCase();
  return text == 'true' || text == '1';
}

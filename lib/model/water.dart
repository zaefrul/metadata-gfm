import 'package:GEMS/model/energy.dart';

/// Daily grid from the Water API (`/water/daily`).
///
/// Meter setup and permissions use the same shape as electricity, so those
/// stay on [EnergyMeter] and [EnergyMe].
class WaterCell {
  const WaterCell({
    required this.meterId,
    required this.meterName,
    required this.readingId,
    required this.cumulativeVolume,
    required this.consumptionVolume,
    required this.estimated,
    required this.iotVolume,
    required this.variancePct,
    required this.remark,
  });

  final String meterId;
  final String meterName;
  final String? readingId;
  final double? cumulativeVolume;
  final double? consumptionVolume;
  final bool estimated;
  final double? iotVolume;
  final double? variancePct;
  final String remark;

  bool get hasReading =>
      cumulativeVolume != null || consumptionVolume != null || iotVolume != null;

  factory WaterCell.fromJson(Map<String, dynamic> json) {
    return WaterCell(
      meterId: _text(json['meterId']),
      meterName: _text(json['meterName']),
      readingId: _optional(json['readingId']),
      cumulativeVolume: _number(json['cumulativeVolume']),
      consumptionVolume: _number(json['consumptionVolume']),
      estimated: _flag(json['estimated']),
      iotVolume: _number(json['iotVolume']),
      variancePct: _number(json['variancePct']),
      remark: _text(json['remark']),
    );
  }
}

class WaterDay {
  const WaterDay({
    required this.date,
    required this.day,
    required this.dayName,
    required this.meters,
    required this.totalVolume,
    required this.estimated,
  });

  final String date;
  final String day;
  final String dayName;
  final List<WaterCell> meters;
  final double? totalVolume;
  final bool estimated;

  WaterCell? cellFor(String meterId) {
    for (final cell in meters) {
      if (cell.meterId == meterId) return cell;
    }
    return null;
  }

  factory WaterDay.fromJson(Map<String, dynamic> json) {
    return WaterDay(
      date: _text(json['date']),
      day: _text(json['day']),
      dayName: _text(json['dayName']),
      meters: _list(json['meters']).map((row) => WaterCell.fromJson(_map(row))).toList(),
      totalVolume: _number(json['totalVolume']),
      estimated: _flag(json['estimated']),
    );
  }
}

class WaterMeterTotal {
  const WaterMeterTotal({
    required this.meterId,
    required this.meterName,
    required this.totalVolume,
  });

  final String meterId;
  final String meterName;
  final double totalVolume;

  factory WaterMeterTotal.fromJson(Map<String, dynamic> json) {
    return WaterMeterTotal(
      meterId: _text(json['meterId']),
      meterName: _text(json['meterName']),
      totalVolume: _number(json['totalVolume']) ?? 0,
    );
  }
}

class WaterLatest {
  const WaterLatest(this.date, this.cell);

  final String date;
  final WaterCell cell;
}

class WaterMonth {
  const WaterMonth({
    required this.year,
    required this.month,
    required this.periodLabel,
    required this.meters,
    required this.rows,
    required this.meterTotals,
    required this.totalVolume,
    required this.canRecord,
  });

  final int year;
  final int month;
  final String periodLabel;
  final List<EnergyMeter> meters;
  final List<WaterDay> rows;
  final List<WaterMeterTotal> meterTotals;
  final double totalVolume;
  final bool canRecord;

  double? totalFor(String meterId) {
    for (final total in meterTotals) {
      if (total.meterId == meterId) return total.totalVolume;
    }
    return null;
  }

  /// Last cumulative reading entered in this month.
  WaterLatest? latestFor(String meterId) {
    WaterLatest? latest;
    for (final row in rows) {
      final cell = row.cellFor(meterId);
      if (cell != null && cell.cumulativeVolume != null) {
        latest = WaterLatest(row.date, cell);
      }
    }
    return latest;
  }

  factory WaterMonth.fromJson(Map<String, dynamic> json) {
    return WaterMonth(
      year: _whole(json['year']),
      month: _whole(json['month']),
      periodLabel: _text(json['periodLabel']),
      meters: _list(json['meters']).map((row) => EnergyMeter.fromJson(_map(row))).toList(),
      rows: _list(json['rows']).map((row) => WaterDay.fromJson(_map(row))).toList(),
      meterTotals:
          _list(json['meterTotals']).map((row) => WaterMeterTotal.fromJson(_map(row))).toList(),
      totalVolume: _number(json['totalVolume']) ?? 0,
      canRecord: _flag(json['canRecord']),
    );
  }
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return <String, dynamic>{};
}

List<dynamic> _list(dynamic value) => value is List ? value : const [];

String _text(dynamic value) => value == null ? '' : value.toString();

String? _optional(dynamic value) {
  if (value == null) return null;
  final text = value.toString();
  return text.isEmpty ? null : text;
}

int _whole(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double? _number(dynamic value) {
  if (value == null || value == '') return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

bool _flag(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value?.toString().toLowerCase();
  return text == 'true' || text == '1';
}

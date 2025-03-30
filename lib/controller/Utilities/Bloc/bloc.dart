import 'package:gfm_gems/model/meter.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:rxdart/subjects.dart';

const String meterAPI = "/utility_meter/";
const String readingAPI = "/utility/list_utility_mobile/";
const String elec = "Electricity/";
const String water = "Water/";

enum api {
  MetersE,
  MetersW,
  Reading,
  ReadingW,
  ReadingE,
  ReadingDW,
  ReadingMW,
  ReadingDE,
  ReadingME,
}

class Bloc {
  // VARIABLES
  final _metersE = BehaviorSubject<List<Meter>>.seeded([]);
  final _metersW = BehaviorSubject<List<Meter>>.seeded([]);
  final _readings = BehaviorSubject<List<Reading>>.seeded([]);
  final _readingsW = BehaviorSubject<List<Reading>>.seeded([]);
  final _readingsE = BehaviorSubject<List<Reading>>.seeded([]);
  final _readingsDW = BehaviorSubject<List<Reading>>.seeded([]);
  final _readingsMW = BehaviorSubject<List<Reading>>.seeded([]);
  final _readingsDE = BehaviorSubject<List<Reading>>.seeded([]);
  final _readingsME = BehaviorSubject<List<Reading>>.seeded([]);
  final _selectedMeter = BehaviorSubject<Meter>();

  final _errMsg = BehaviorSubject<String>();
  final _loadingState = BehaviorSubject<bool>();

  final _request = Request();

  // GET
  Stream<List<Meter>> get me$ => _metersE.stream;
  Stream<List<Meter>> get mw$ => _metersW.stream;
  Stream<List<Reading>> get r$ => _readings.stream;
  Stream<List<Reading>> get rw$ => _readingsW.stream;
  Stream<List<Reading>> get re$ => _readingsE.stream;
  Stream<List<Reading>> get rdw$ => _readingsDW.stream;
  Stream<List<Reading>> get rmw$ => _readingsMW.stream;
  Stream<List<Reading>> get rde$ => _readingsDE.stream;
  Stream<List<Reading>> get rme$ => _readingsME.stream;
  Stream<String> get err$ => _errMsg.stream;
  Stream<bool> get loadingState$ => _loadingState.stream;

  // SET
  set me(List values) => _metersE.sink.add(meterMap(values));
  set mw(List values) => _metersW.sink.add(meterMap(values));
  set r(List values) => _readings.sink.add(readingMap(values));
  set rw(List values) => _readingsW.sink.add(readingMap(values));
  set re(List values) => _readingsE.sink.add(readingMap(values));
  set rdw(List values) => _readingsDW.sink.add(readingMap(values));
  set rmw(List values) => _readingsMW.sink.add(readingMap(values));
  set rde(List values) => _readingsDE.sink.add(readingMap(values));
  set rme(List values) => _readingsME.sink.add(readingMap(values));
  set sMeter(Meter value) => _selectedMeter.sink.add(value);
  set errMsg(String value) => _errMsg.sink.add(value);
  void loading() => _loadingState.sink.add(true);
  void done() => _loadingState.sink.add(false);
  void close() => _loadingState.sink.add(false);
  List<Reading> readingMap(List values) =>
      values.map((e) => e as Reading).toList();
  List<Meter> meterMap(List values) => values.map((e) => e as Meter).toList();

  // METHOD
  Future checker(Future value) {
    loading();

    return value.catchError((value) {
      errMsg = value.toString();
      throw value;
    }).whenComplete(() {
      done();
      close();
    });
  }

  void dispose() {
    _metersE.close();
    _metersW.close();
    _readings.close();
    _readingsW.close();
    _readingsE.close();
    _readingsDW.close();
    _readingsMW.close();
    _readingsDE.close();
    _readingsME.close();
    _selectedMeter.close();
    _errMsg.close();
    _loadingState.close();
  }

  Future<void> fetch(api value) async {
    switch (value) {
      case api.MetersE:
        return checker(_request.fetchMetersE().then((values) => me = values));
      case api.MetersW:
        return checker(_request.fetchMetersW().then((values) => mw = values));
      case api.Reading:
        return checker(_request.fetchReading().then((values) => r = values));
      case api.ReadingW:
        return checker(_request.fetchReadingW().then((values) => rw = values));
      case api.ReadingE:
        return checker(_request.fetchReadingE().then((values) => re = values));
      case api.ReadingDW:
        return checker(_request
            .fetchReadingDW(_selectedMeter.value.meterId)
            .then((values) => rdw = values));
      case api.ReadingMW:
        return checker(_request
            .fetchReadingMW(_selectedMeter.value.meterId)
            .then((values) => rmw = values));
      case api.ReadingDE:
        return checker(_request
            .fetchReadingDE(_selectedMeter.value.meterId)
            .then((values) => rde = values));
      case api.ReadingME:
        return checker(_request
            .fetchReadingME(_selectedMeter.value.meterId)
            .then((values) => rme = values));
    }
  }
}

class Request {
  final _pMetersE = Provider(fetchURL: meterAPI + elec);
  final _pMetersW = Provider(fetchURL: meterAPI + water);
  final _pReading = Provider(fetchURL: readingAPI);
  final _pReadingW = Provider(fetchURL: readingAPI + water);
  final _pReadingE = Provider(fetchURL: readingAPI + elec);
  final _pReadingDW = Provider(fetchURL: readingAPI + water + "Daily");
  final _pReadingMW = Provider(fetchURL: readingAPI + water + "Monthly");
  final _pReadingDE = Provider(fetchURL: readingAPI + elec + "Daily");
  final _pReadingME = Provider(fetchURL: readingAPI + elec + "Monthly");

  Future<List> fetchMetersE() => _pMetersE.fetchUtilities(meter: true);
  Future<List> fetchMetersW() => _pMetersW.fetchUtilities(meter: true);
  Future<List> fetchReading() => _pReading.fetchUtilities(reading: true);
  Future<List> fetchReadingW() => _pReadingW.fetchUtilities(reading: true);
  Future<List> fetchReadingE() => _pReadingE.fetchUtilities(reading: true);
  Future<List> fetchReadingDW(String id) =>
      _pReadingDW.fetchUtilities(reading: true, id: id);
  Future<List> fetchReadingMW(String id) =>
      _pReadingMW.fetchUtilities(reading: true, id: id);
  Future<List> fetchReadingDE(String id) =>
      _pReadingDE.fetchUtilities(reading: true, id: id);
  Future<List> fetchReadingME(String id) =>
      _pReadingME.fetchUtilities(reading: true, id: id);
}

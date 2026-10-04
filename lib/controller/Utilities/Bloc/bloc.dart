import 'package:GEMS/data/repository/utility_repository.dart';
import 'package:GEMS/model/energy.dart';
import 'package:GEMS/model/meter.dart';
import 'package:GEMS/utils/network.dart';
import 'package:rxdart/subjects.dart';

const String readingAPI = "/utility/list_utility_mobile/";
const String water = "Water/";

enum api {
  MetersW,
  Reading,
  ReadingW,
  ReadingDW,
  ReadingMW,
}

class Bloc {
  final _metersW = BehaviorSubject<List<Meter>>.seeded([]);
  final _readings = BehaviorSubject<List<Reading>>.seeded([]);
  final _readingsW = BehaviorSubject<List<Reading>>.seeded([]);
  final _readingsDW = BehaviorSubject<List<Reading>>.seeded([]);
  final _readingsMW = BehaviorSubject<List<Reading>>.seeded([]);
  final _selectedMeter = BehaviorSubject<Meter>();

  final _energyMe = BehaviorSubject<EnergyMe?>.seeded(null);
  final _energyMeters = BehaviorSubject<List<EnergyMeter>>.seeded([]);
  final _energyMonth = BehaviorSubject<EnergyMonth?>.seeded(null);
  final _fromCache = BehaviorSubject<bool>.seeded(false);

  final _errMsg = BehaviorSubject<String>();
  final _loadingState = BehaviorSubject<bool>();

  final _request = Request();
  final _utility = UtilityRepository.instance;

  Stream<List<Meter>> get mw$ => _metersW.stream;
  Stream<List<Reading>> get r$ => _readings.stream;
  Stream<List<Reading>> get rw$ => _readingsW.stream;
  Stream<List<Reading>> get rdw$ => _readingsDW.stream;
  Stream<List<Reading>> get rmw$ => _readingsMW.stream;
  Stream<EnergyMe?> get energyMe$ => _energyMe.stream;
  Stream<List<EnergyMeter>> get energyMeters$ => _energyMeters.stream;
  Stream<EnergyMonth?> get energyMonth$ => _energyMonth.stream;
  Stream<bool> get fromCache$ => _fromCache.stream;
  Stream<String> get err$ => _errMsg.stream;
  Stream<bool> get loadingState$ => _loadingState.stream;

  set mw(List values) => _metersW.sink.add(meterMap(values));
  set r(List values) => _readings.sink.add(readingMap(values));
  set rw(List values) => _readingsW.sink.add(readingMap(values));
  set rdw(List values) => _readingsDW.sink.add(readingMap(values));
  set rmw(List values) => _readingsMW.sink.add(readingMap(values));
  set sMeter(Meter value) => _selectedMeter.sink.add(value);
  set errMsg(String value) => _errMsg.sink.add(value);
  void loading() => _loadingState.sink.add(true);
  void done() => _loadingState.sink.add(false);
  void close() => _loadingState.sink.add(false);
  List<Reading> readingMap(List values) =>
      values.map((e) => e as Reading).toList();
  List<Meter> meterMap(List values) => values.map((e) => e as Meter).toList();

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
    _metersW.close();
    _readings.close();
    _readingsW.close();
    _readingsDW.close();
    _readingsMW.close();
    _selectedMeter.close();
    _energyMe.close();
    _energyMeters.close();
    _energyMonth.close();
    _fromCache.close();
    _errMsg.close();
    _loadingState.close();
  }

  Future<void> fetch(api value) async {
    switch (value) {
      case api.MetersW:
        return checker(
          _utility.loadWaterMeters().then((values) => mw = values),
        );
      case api.Reading:
        return checker(_request.fetchReading().then((values) => r = values));
      case api.ReadingW:
        return checker(_request.fetchReadingW().then((values) => rw = values));
      case api.ReadingDW:
        return checker(_request
            .fetchReadingDW(_selectedMeter.value.meterId)
            .then((values) => rdw = values));
      case api.ReadingMW:
        return checker(_request
            .fetchReadingMW(_selectedMeter.value.meterId)
            .then((values) => rmw = values));
    }
  }

  Future<void> fetchEnergy({int? year, int? month}) {
    return checker(
      _utility.loadEnergyHome(year: year, month: month).then((data) {
        _energyMe.add(data.me);
        _energyMeters.add(data.meters);
        _energyMonth.add(data.month);
        _fromCache.add(data.fromCache);
      }),
    );
  }
}

class Request {
  final _pReading = Provider(fetchURL: readingAPI);
  final _pReadingW = Provider(fetchURL: readingAPI + water);
  final _pReadingDW = Provider(fetchURL: "$readingAPI${water}Daily");
  final _pReadingMW = Provider(fetchURL: "$readingAPI${water}Monthly");

  Future<List> fetchReading() => _pReading.fetchUtilities(reading: true);
  Future<List> fetchReadingW() => _pReadingW.fetchUtilities(reading: true);
  Future<List> fetchReadingDW(String id) =>
      _pReadingDW.fetchUtilities(reading: true, id: id);
  Future<List> fetchReadingMW(String id) =>
      _pReadingMW.fetchUtilities(reading: true, id: id);
}

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gfm_gems/model/attendance.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:rxdart/subjects.dart';
import 'dart:collection';
import 'package:intl/intl.dart';

import 'package:table_calendar/table_calendar.dart';

import 'bloc.dart';

class BlocAttendance extends Bloc {
  final BehaviorSubject<TabController> _tabController = BehaviorSubject();
  final BehaviorSubject<DateTime> _calendarDay =
      BehaviorSubject<DateTime>.seeded(DateTime.now());
  final BehaviorSubject<LinkedHashMap<DateTime, List<Event>>> _kEvents =
      BehaviorSubject<LinkedHashMap<DateTime, List<Event>>>();
  final BehaviorSubject<Event> _kEvent = BehaviorSubject<Event>();
  final BehaviorSubject<Attendance> _kAttendance =
      BehaviorSubject<Attendance>();
  final BehaviorSubject<bool> _buttonStatus = BehaviorSubject<bool>();

  final _kEventSource = <DateTime, List<Event>>{};

  String attndId = "";

  BlocAttendance() {
    final DateTime kToday = DateTime.now();
    final _kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
    final f = DateFormat('dd-MM-yyyy');
    _kEventSource.addAll({
      for (var item in List.generate(50, (index) => index))
        DateTime.utc(_kFirstDay.year, _kFirstDay.month, item * 5): [
          Event(f
              .format(DateTime.utc(_kFirstDay.year, _kFirstDay.month, item * 5))
              .toString())
        ]
    }..addAll({
        kToday: [Event(f.format(DateTime.now()))]
      }));
    _kEvents.sink.add(LinkedHashMap<DateTime, List<Event>>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(_kEventSource));

    _calendarDay.listen((value) {
      final events = _kEvents.value[value];
      if (events != null) {
        _kEvent.sink.add(events.first);
      }
    });

    refreshAttendance;
  }

  set tabController(TabController value) => _tabController.sink.add(value);
  get tab => _tabController.value;
  bool get tabIndex {
    if (_tabController.value == null)
      return false;
    else if (_tabController.value.index == 0) return false;
    return true;
  }

  set selected(DateTime value) => _calendarDay.sink.add(value);
  get calendarDate$ => _calendarDay.stream;

  get events$ => _kEvents.stream;
  get event$ => _kEvent.stream;

  get buttonStatus$ => _buttonStatus.stream;

  get attendance$ => _kAttendance.stream;

  @override
  void dispose() {
    _tabController.value.dispose();
    _tabController.close();
    _calendarDay.close();
    _kEvents.close();
    _kEvent.close();
    super.dispose();
  }

  List<Event> getEventsForDay(DateTime day) {
    return _kEvents.value[day] ?? [];
  }

  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  void get refreshAttendance {
    final Provider _provider =
        Provider(fetchURL: "/att_transaction/mobile/main_info");

    _provider
        .getJson()
        .then((value) => Attendance.fromJson(value))
        .then((value) {
      _kAttendance.sink.add(value);
      attndId = value.attTransactionId.toString();
      if (value.button == "Check In") _buttonStatus.sink.add(true);
      if (value.button == "Check Out") _buttonStatus.sink.add(false);
      if (value.button == null) _buttonStatus.sink.add(null);
    });
  }

  void clockedIn(BuildContext context) async {
    final value = await position;

    Map<String, String> data = {
      "latitude": value.latitude.toString(),
      "longitude": value.longitude.toString(),
    };

    Provider provider =
        Provider(fetchURL: "/att_transaction/check_in/", taskID: attndId);
    provider.context = context;
    provider.put(body: data).whenComplete(() => refreshAttendance);
  }

  void clockedOut(BuildContext context) async {
    final value = await position;

    Map<String, String> data = {
      "latitude": value.latitude.toString(),
      "longitude": value.longitude.toString(),
    };

    Provider provider =
        Provider(fetchURL: "/att_transaction/check_out/", taskID: attndId);
    provider.context = context;
    provider.put(body: data).whenComplete(() => refreshAttendance);
  }

  Future<Position> get position async {
    LocationPermission permission = await Geolocator.checkPermission();
    bool value = permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;

    while (value == false) {
      Geolocator.requestPermission().then((value) => permission = value);
      value = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    }
    var position = await Geolocator.getLastKnownPosition(
        forceAndroidLocationManager: true);
    if (position == null)
      position = await Geolocator.getCurrentPosition(
          forceAndroidLocationManager: true);

    return position;
  }
}

/// Example event class.
class Event {
  final String title;

  const Event(this.title);

  @override
  String toString() => title;
}

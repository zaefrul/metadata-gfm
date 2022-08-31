import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gfm_gems/model/attendance.dart';
import 'package:gfm_gems/model/eventAtt.dart';
import 'package:gfm_gems/model/eventDetail.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:rxdart/subjects.dart';
import 'dart:collection';
import 'package:intl/intl.dart';

import 'package:table_calendar/table_calendar.dart';

import 'bloc.dart';

import 'dart:async';

class BlocAttendance extends Bloc {
  Timer _timer;

  final BehaviorSubject<TabController> _tabController = BehaviorSubject();
  final BehaviorSubject<DateTime> _calendarDay =
      BehaviorSubject<DateTime>.seeded(DateTime.now());
  final BehaviorSubject<LinkedHashMap<DateTime, List<EventAtt>>> _kEvents =
      BehaviorSubject<LinkedHashMap<DateTime, List<EventAtt>>>();
  final BehaviorSubject<EventDetail> _kEvent = BehaviorSubject<EventDetail>();
  final BehaviorSubject<Attendance> _kAttendance =
      BehaviorSubject<Attendance>();
  final BehaviorSubject<bool> _buttonStatus = BehaviorSubject<bool>();
  final BehaviorSubject<String> _clock = BehaviorSubject<String>();

  final _kEventSource = <DateTime, List<EventAtt>>{};

  String attndId = "";

  BlocAttendance() {
    refreshCalendar;

    _calendarDay.listen(
        (value) => refreshAttendanceInfo(value.year, value.month, value.day));

    _timer = Timer.periodic(
        const Duration(seconds: 1),
        (Timer t) =>
            _clock.sink.add(DateFormat("hh:mm:ss").format(DateTime.now())));

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
  Stream<EventDetail> get event$ => _kEvent.stream;

  get buttonStatus$ => _buttonStatus.stream;

  get attendance$ => _kAttendance.stream;

  Stream<String> get clock$ => _clock.stream;

  @override
  void dispose() {
    _tabController.value.dispose();
    _tabController.close();
    _calendarDay.close();
    _kEvents.close();
    _kEvent.close();
    _kAttendance.close();
    _buttonStatus.close();
    _clock.close();

    _timer?.cancel();
    super.dispose();
  }

  List<EventAtt> getEventsForDay(DateTime day) {
    if (_kEvents.value != null) return _kEvents.value[day];
    return [];
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

  void refreshAttendanceInfo(int year, int month, int day) {
    final Provider _provider = Provider(
        fetchURL:
            "/att_transaction/mobile/calendar_daily_info/$year-$month-$day");

    _provider
        .getJson()
        .then((value) => EventDetail.fromJson(value))
        .then((value) {
      _kEvent.sink.add(value);
    });
  }

  void get refreshCalendar async {
    final DateTime datetime = DateTime.now();
    final curentYear = datetime.year;
    final currentMonth = datetime.month;
    int startedMonth = 8;
    final List<EventAtt> eventsDate = [];

    while (currentMonth > startedMonth) {
      final Provider _provider = Provider(
          fetchURL:
              "/att_transaction/mobile/calendar_dot/$curentYear/$startedMonth");

      final Map<String, dynamic> result = await _provider.getJson();
      final List<String> keys = result.keys.map((e) => e).toList();
      List<EventAtt> values =
          keys.map((e) => EventAtt.fromJson(result[e])).toList();

      List<EventAtt> filteredValues =
          values.where((e) => e.color != null).toList();
      eventsDate.addAll(filteredValues);

      for (EventAtt e in eventsDate) {
        final String eventDate = e.date;
        final DateTime key = DateTime.parse(eventDate);
        _kEventSource.addAll({
          key: [e]
        });
      }

      _kEvents.sink.add(LinkedHashMap<DateTime, List<EventAtt>>(
        equals: isSameDay,
        hashCode: getHashCode,
      )..addAll(_kEventSource));

      startedMonth++;
    }
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

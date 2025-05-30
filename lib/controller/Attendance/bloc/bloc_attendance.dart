import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:GEMS/model/attendance.dart';
import 'package:GEMS/model/eventAtt.dart';
import 'package:GEMS/model/eventDetail.dart';
import 'package:GEMS/utils/network.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:rxdart/rxdart.dart';

import 'bloc.dart';

class BlocAttendance extends Bloc {
  late Timer _timer;

  // Using non-nullable BehaviorSubjects (if initial values are available)
  final BehaviorSubject<TabController> _tabController = BehaviorSubject<TabController>();
  final BehaviorSubject<DateTime> _calendarDay =
      BehaviorSubject<DateTime>.seeded(DateTime.now());
  final BehaviorSubject<LinkedHashMap<DateTime, List<EventAtt>>> _kEvents =
      BehaviorSubject<LinkedHashMap<DateTime, List<EventAtt>>>();
  final BehaviorSubject<EventDetail> _kEvent = BehaviorSubject<EventDetail>();
  final BehaviorSubject<Attendance> _kAttendance = BehaviorSubject<Attendance>();
  final BehaviorSubject<bool> _buttonStatus = BehaviorSubject<bool>();
  final BehaviorSubject<String> _clock = BehaviorSubject<String>();

  // Internal event source map.
  final Map<DateTime, List<EventAtt>> _kEventSource = {};

  String attndId = "";

  BlocAttendance() {
    // Call refreshCalendar and refreshAttendance explicitly.
    refreshCalendar();
    refreshAttendance();

    // Listen to calendar day changes to update attendance info.
    _calendarDay.listen((value) =>
        refreshAttendanceInfo(value.year, value.month, value.day));

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      _clock.sink.add(DateFormat("hh:mm:ss").format(DateTime.now()));
    });
  }

  set tabController(TabController value) => _tabController.sink.add(value);
  TabController get tab => _tabController.value;
  bool get tabIndex => _tabController.value.index != 0;

  set selected(DateTime value) => _calendarDay.sink.add(value);
  Stream<DateTime> get calendarDate$ => _calendarDay.stream;

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
    _timer.cancel();
    super.dispose();
  }

  // Returns the events for a given day (or an empty list if none).
  List<EventAtt> getEventsForDay(DateTime day) {
    return _kEvents.value[day] ?? [];
  }

  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  /// Refreshes the main attendance info.
  Future<void> refreshAttendance() async {
    final Provider provider =
        Provider(fetchURL: "/att_transaction/mobile/main_info");

    provider.getJson(url: "/att_transaction/mobile/main_info")
        .then((value) => Attendance.fromJson(value))
        .then((value) {
      _kAttendance.sink.add(value);
      attndId = value.attTransactionId.toString();
      if (value.button == "Check In") _buttonStatus.sink.add(true);
      if (value.button == "Check Out") _buttonStatus.sink.add(false);
    });
  }

  /// Refreshes the attendance detail for a specific day.
  void refreshAttendanceInfo(int year, int month, int day) {
    final Provider provider = Provider(
        fetchURL: "/att_transaction/mobile/calendar_daily_info/$year-$month-$day");

    provider.getJson(url: "/att_transaction/mobile/calendar_daily_info/$year-$month-$day")
        .then((value) => EventDetail.fromJson(value))
        .then((value) {
      if (value != null) {
        _kEvent.sink.add(value);
      }
    });
  }

  /// Refreshes the calendar events.
  Future<void> refreshCalendar() async {
    final DateTime datetime = DateTime.now();
    final int currentYear = datetime.year;
    final int currentMonth = datetime.month;

    final List<EventAtt> eventsDate = [];

    // Loop for previous months (if needed)
    for (int startedMonth = 1; startedMonth < currentMonth; startedMonth++) {
      final list = await fillCalendar(currentYear, startedMonth);
      eventsDate.addAll(list);
    }

    final list = await fillCalendar(currentYear, currentMonth);
    eventsDate.addAll(list);

    for (EventAtt e in eventsDate) {
      final String eventDate = e.date ?? '';
      final DateTime key = DateTime.parse(eventDate);
      // If multiple events per day are needed, you might want to append to a list:
      _kEventSource.update(key, (existing) => existing..add(e),
          ifAbsent: () => [e]);
    }

    _kEvents.sink.add(LinkedHashMap<DateTime, List<EventAtt>>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(_kEventSource));
  }

  Future<List<EventAtt>> fillCalendar(int year, int month) async {
    final Provider provider =
        Provider(fetchURL: "/att_transaction/mobile/calendar_dot/$year/$month");

    final Map<String, dynamic> result = await provider.getJson(url: "/att_transaction/mobile/calendar_dot/$year/$month");
    final List<String> keys = result.keys.toList();
    List<EventAtt> values = keys.map((e) => EventAtt.fromJson(result[e])).whereType<EventAtt>().toList();

    return values.where((e) => e.color != null).toList();
  }

  void clockedIn(BuildContext context) async {
    final Position value = await position;

    Map<String, String> data = {
      "latitude": value.latitude.toString(),
      "longitude": value.longitude.toString(),
    };

    Provider provider = Provider(fetchURL: "/att_transaction/check_in/", taskID: attndId);
    provider.context = context;
    provider.put(body: data).whenComplete(() => refreshAttendance());
  }

  void clockedOut(BuildContext context) async {
    final Position value = await position;

    Map<String, String> data = {
      "latitude": value.latitude.toString(),
      "longitude": value.longitude.toString(),
    };

    Provider provider = Provider(fetchURL: "/att_transaction/check_out/", taskID: attndId);
    provider.context = context;
    provider.put(body: data).whenComplete(() => refreshAttendance());
  }

  Future<Position> get position async {
    LocationPermission permission = await Geolocator.checkPermission();
    bool hasPermission = permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;

    while (!hasPermission) {
      permission = await Geolocator.requestPermission();
      hasPermission = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    }
    var pos = await Geolocator.getLastKnownPosition(forceAndroidLocationManager: true);
    pos ??= await Geolocator.getCurrentPosition(forceAndroidLocationManager: true);
    return pos;
  }
}

/// Example event class.
class Event {
  final String title;

  const Event(this.title);

  @override
  String toString() => title;
}

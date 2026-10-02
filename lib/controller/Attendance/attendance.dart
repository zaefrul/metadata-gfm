import 'package:flutter/material.dart';
import 'package:GEMS/model/attendance.dart';
import 'package:GEMS/model/eventAtt.dart';
import 'package:GEMS/model/eventDetail.dart';
import 'dart:async';

import 'bloc/bloc_attendance.dart';

import 'package:table_calendar/table_calendar.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';

import '../../main.dart';
import 'package:GEMS/view/gems_chrome.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  final BlocAttendance _bloc = BlocAttendance();

  final DateFormat f = DateFormat('hh:mm:ss a');
  String? _timeClockIn;
  String? _timeClockOut;
  String? _duration;
  String _timeString = "";

  void duration() {
    // Ensure there is a valid clock in/clock out string.
    final clockin = (_timeClockIn ?? "").substring(0, 8);
    final clockout = (_timeClockOut ?? "").substring(0, 8);
    try {
      final t1 = DateTime.parse("2021-09-09 $clockin");
      final t2 = DateTime.parse("2021-09-09 $clockout");
      final d = t2.difference(t1);
      String sDuration =
          "${d.inHours} Hours ${d.inMinutes.remainder(60)} Minutes ${d.inSeconds.remainder(60)} Seconds";
      setState(() {
        _duration = sDuration;
      });
    } catch (e) {
      setState(() {
        _duration = "0 Hours 0 Minutes 0 Seconds";
      });
    }
  }

  void clear() {
    setState(() {
      _timeClockIn = null;
      _timeClockOut = null;
      _duration = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _bloc.tabController = TabController(length: 2, vsync: this);
    _timeString = f.format(DateTime.now());
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: GemsChrome.page,
        appBar: gemsAppBar(
          title: const Text('Attendance'),
          bottom: TabBar(
            controller: _bloc.tab,
            labelColor: GemsChrome.primary,
            unselectedLabelColor: GemsChrome.textSoft,
            indicatorColor: GemsChrome.teal,
            indicatorWeight: 3,
            dividerColor: GemsChrome.border,
            physics: const NeverScrollableScrollPhysics(),
            tabs: const [Tab(text: 'Calendar'), Tab(text: 'Weekly Progress')],
          ),
        ),
        body: TabBarView(
          controller: _bloc.tab,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 70),
              child: Column(
                children: [_Calendar(_bloc), _Details(_bloc.event$)],
              ),
            ),
            ProgressClock(_timeClockIn, _timeClockOut, _duration, _bloc.attendance$, _bloc.clock$),
          ],
        ),
        floatingActionButton: StreamBuilder<bool>(
            stream: _bloc.buttonStatus$,
            builder: (_, snapshot) {
              if (snapshot.data == null) return Container();
              final result = snapshot.data!;
              return FloatingActionButton.extended(
                backgroundColor: result ? GemsChrome.primary : GemsChrome.danger,
                foregroundColor: Colors.white,
                onPressed: () {
                  if (!result) {
                    confirmationCheckOut();
                  } else {
                    confirmationCheckIn();
                  }
                },
                label: Text(
                  result ? 'Check In' : 'Check Out',
                  style: GemsChrome.body(weight: FontWeight.w600, color: Colors.white),
                ),
              );
            }));
  }

  void confirmationCheckIn() {
    FocusScope.of(context).unfocus();
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (_) => AlertDialog(
        title: Text('Confirmation', style: GemsChrome.heading(size: 18)),
        content: Text('Please confirm your Check In?', style: GemsChrome.body()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel', style: GemsChrome.body(color: GemsChrome.textSoft)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _bloc.clockedIn(context);
            },
            child: Text(
              'OK',
              style: GemsChrome.body(weight: FontWeight.w600, color: GemsChrome.primary),
            ),
          ),
        ],
      ),
    );
  }

  void confirmationCheckOut() {
    FocusScope.of(context).unfocus();
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (_) => AlertDialog(
        title: Text('Confirmation', style: GemsChrome.heading(size: 18)),
        content: Text('Please confirm your Check Out?', style: GemsChrome.body()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel', style: GemsChrome.body(color: GemsChrome.textSoft)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _bloc.clockedOut(context);
            },
            child: Text(
              'OK',
              style: GemsChrome.body(weight: FontWeight.w600, color: GemsChrome.danger),
            ),
          ),
        ],
      ),
    );
  }
}

class _Calendar extends StatelessWidget {
  final BlocAttendance _bloc;
  final DateTime kToday = DateTime.now();
  late final DateTime _kFirstDay;
  late final DateTime _kLastDay;

  _Calendar(this._bloc, {super.key}) {
    _kFirstDay = DateTime(kToday.year, 1, 1);
    _kLastDay = DateTime(kToday.year, kToday.month + 1, kToday.day);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _bloc.events$,
        builder: (_, evnt) {
          return StreamBuilder<DateTime>(
            stream: _bloc.calendarDate$,
            builder: (context, snapshot) {
              final selectedDay = snapshot.data ?? DateTime.now();
              return Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(GemsChrome.radius),
                    border: Border.all(color: GemsChrome.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
                    child: TableCalendar<EventAtt>(
                      firstDay: _kFirstDay,
                      lastDay: _kLastDay,
                      focusedDay: selectedDay,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: GemsChrome.heading(size: 16),
                        leftChevronIcon: const Icon(Icons.chevron_left, color: GemsChrome.text),
                        rightChevronIcon: const Icon(Icons.chevron_right, color: GemsChrome.text),
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: GemsChrome.body(
                          size: 12,
                          weight: FontWeight.w600,
                          color: GemsChrome.textSoft,
                        ),
                        weekendStyle: GemsChrome.body(
                          size: 12,
                          weight: FontWeight.w600,
                          color: GemsChrome.muted,
                        ),
                      ),
                      calendarStyle: CalendarStyle(
                        cellMargin: const EdgeInsets.all(4),
                        defaultTextStyle: GemsChrome.body(size: 14),
                        weekendTextStyle: GemsChrome.body(size: 14, color: GemsChrome.textSoft),
                        outsideTextStyle: GemsChrome.body(size: 14, color: GemsChrome.muted),
                        selectedTextStyle: GemsChrome.body(
                          size: 14,
                          weight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        todayTextStyle: GemsChrome.body(
                          size: 14,
                          weight: FontWeight.w600,
                          color: GemsChrome.primaryDark,
                        ),
                        selectedDecoration: const BoxDecoration(
                          color: GemsChrome.primary,
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: GemsChrome.primary.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: const BoxDecoration(
                          color: GemsChrome.teal,
                          shape: BoxShape.circle,
                        ),
                      ),
                      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                      onDaySelected: (selectedDay, _) => _bloc.selected = selectedDay,
                      eventLoader: (day) {
                        return _bloc.getEventsForDay(day);
                      },
                      onFormatChanged: (value) => value,
                    ),
                  ),
                ),
              );
            },
          );
        });
  }
}

class _Details extends StatelessWidget {
  final Stream<EventDetail> stream;
  const _Details(this.stream, {super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<EventDetail>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: GemsFormSection(
                title: 'Attendance details',
                icon: Icons.event_available_outlined,
                child: Text(
                  'No event',
                  style: GemsChrome.body(color: GemsChrome.textSoft),
                ),
              ),
            );
          }
          return ItemDetail(snapshot.data!);
        });
  }
}

class ItemDetail extends StatelessWidget {
  final EventDetail event;
  const ItemDetail(this.event, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GemsFormSection(
        title: 'Attendance details',
        icon: Icons.event_available_outlined,
        child: Column(
          children: [
            _infoRow('Status', event.status ?? '-'),
            _infoRow('Date', event.date ?? '-'),
            _infoRow('Start time', event.shiftStart ?? '-'),
            _infoRow('End time', event.shiftEnd ?? '-'),
            const Divider(height: 24, color: GemsChrome.border),
            _infoRow('Clock in', event.timeClockIn ?? '-'),
            _infoRow('Clock out', event.timeClockOut ?? '-'),
            _infoRow('Duration', event.duration ?? '-'),
          ],
        ),
      ),
    );
  }
}

Widget _infoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: GemsChrome.body(size: 13, color: GemsChrome.textSoft)),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Text(
            value.isEmpty ? '-' : value,
            style: GemsChrome.body(size: 14, weight: FontWeight.w500),
          ),
        ),
      ],
    ),
  );
}

class ProgressClock extends StatelessWidget {
  final String? clockin;
  final String? clockout;
  final String? duration;

  final Stream<Attendance> stream;
  final Stream<String> clock;

  const ProgressClock(this.clockin, this.clockout, this.duration, this.stream, this.clock, {super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Attendance>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: GemsChrome.primary),
            );
          }
          final data = snapshot.data!;
          final progress = (double.tryParse((data.weeklyProgress ?? '0').replaceAll('%', '')) ?? 0) / 100;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GemsFormSection(
                  title: 'Clocking session',
                  icon: Icons.access_time,
                  child: Column(
                    children: [
                      StreamBuilder<String>(
                        stream: clock,
                        builder: (context, snapshot) {
                          final time = snapshot.data ?? DateFormat('hh:mm:ss').format(DateTime.now());
                          return _infoRow('Current time', time);
                        },
                      ),
                      _infoRow('Clock in', data.timeClockIn ?? '-'),
                      _infoRow('Clock out', data.timeClockOut ?? '-'),
                      _infoRow('Duration', data.duration ?? '-'),
                      _infoRow('Remark', data.remark ?? '-'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GemsFormSection(
                  title: 'Weekly completion',
                  icon: Icons.pie_chart_outline,
                  child: Column(
                    children: [
                      CircularPercentIndicator(
                        radius: 72,
                        lineWidth: 10,
                        percent: progress.clamp(0, 1),
                        circularStrokeCap: CircularStrokeCap.round,
                        backgroundColor: GemsChrome.border,
                        progressColor: GemsChrome.primary,
                        center: Text(
                          data.weeklyProgress ?? '0%',
                          style: GemsChrome.heading(size: 18, color: GemsChrome.primary),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Total work duration: ${data.weeklyRequiredHours ?? 0}',
                        style: GemsChrome.body(color: GemsChrome.textSoft),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}

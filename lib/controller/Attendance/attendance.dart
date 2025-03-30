import 'package:flutter/material.dart';
import 'package:gfm_gems/model/attendance.dart';
import 'package:gfm_gems/model/eventAtt.dart';
import 'package:gfm_gems/model/eventDetail.dart';
import 'dart:async';

import 'bloc/bloc_attendance.dart';

import 'package:gfm_gems/utils/reference.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);
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
      final t1 = DateTime.parse("2021-09-09 " + clockin);
      final t2 = DateTime.parse("2021-09-09 " + clockout);
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
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            "Attendance",
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          bottom: TabBar(
            controller: _bloc.tab,
            labelColor: Colors.black,
            physics: const NeverScrollableScrollPhysics(),
            tabs: const [Tab(text: "Calendar"), Tab(text: "Weekly Progress")],
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
                backgroundColor: result ? colorTheme3 : colorTheme4,
                onPressed: () {
                  if (!result) {
                    confirmationCheckOut();
                  } else {
                    confirmationCheckIn();
                  }
                },
                label: _TextCell(result ? "Check In" : "Check Out"),
              );
            }));
  }

  void confirmationCheckIn() {
    FocusScope.of(context).unfocus();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmation"),
        content: const Text("Please confirm your Check In?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _bloc.clockedIn(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void confirmationCheckOut() {
    FocusScope.of(context).unfocus();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmation"),
        content: const Text("Please confirm your Check Out?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _bloc.clockedOut(context);
            },
            child: const Text("OK"),
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

  _Calendar(this._bloc, {Key? key}) : super(key: key) {
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
              return TableCalendar<EventAtt>(
                firstDay: _kFirstDay,
                lastDay: _kLastDay,
                focusedDay: selectedDay,
                selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                onDaySelected: (selectedDay, _) => _bloc.selected = selectedDay,
                eventLoader: (day) {
                  return _bloc.getEventsForDay(day);
                },
                onFormatChanged: (value) => value,
              );
            },
          );
        });
  }
}

class _Details extends StatelessWidget {
  final Stream<EventDetail> stream;
  const _Details(this.stream, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<EventDetail>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Column(children: const [
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  "Attendance Details",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(
                color: Colors.black87,
                height: 2,
                indent: 12,
                endIndent: 12,
              ),
              SizedBox(height: 20),
              Text(
                "No Event",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ]);
          }
          return ItemDetail(snapshot.data!);
        });
  }
}

class ItemDetail extends StatelessWidget {
  final EventDetail event;
  const ItemDetail(this.event, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            "Attendance Details",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Divider(
          color: Colors.black87,
          height: 2,
          indent: 12,
          endIndent: 12,
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Table(
            columnWidths: const {
              0: FractionColumnWidth(0.40),
              1: FractionColumnWidth(0.60),
            },
            children: [
              TableRow(children: [
                TableCell(child: _TextCell("Attendance Status : ", bold: true)),
                TableCell(child: _TextCell(event.status ?? "")),
              ]),
              TableRow(children: [
                const TableCell(child: _TextCell("Date Attendance : ", bold: true)),
                TableCell(child: _TextCell(event.date)),
              ]),
              TableRow(children: [
                TableCell(child: _TextCell("Start Time : ", bold: true)),
                TableCell(child: _TextCell(event.shiftStart ?? "")),
              ]),
              TableRow(children: [
                TableCell(child: _TextCell("End Time : ", bold: true)),
                TableCell(child: _TextCell(event.shiftEnd ?? "")),
              ]),
              const TableRow(children: [
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(
                      color: Colors.black87,
                      height: 2,
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(
                      color: Colors.black87,
                      height: 2,
                    ),
                  ),
                ),
              ]),
              TableRow(children: [
                TableCell(child: _TextCell("Clock In : ", bold: true)),
                TableCell(child: _TextCell(event.timeClockIn ?? "")),
              ]),
              TableRow(children: [
                TableCell(child: _TextCell("Clock Out : ", bold: true)),
                TableCell(child: _TextCell(event.timeClockOut ?? "")),
              ]),
              TableRow(children: [
                TableCell(child: _TextCell("Duration : ", bold: true)),
                TableCell(child: _TextCell(event.duration ?? "")),
              ]),
            ],
          ),
        ),
      ],
    );
  }
}

class _TextCell extends StatelessWidget {
  final String? value;
  final bool bold;
  final double size;
  const _TextCell(this.value, {this.bold = false, this.size = 14, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Text(
        value ?? "0%",
        style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, fontSize: size),
      ),
    );
  }
}

class ProgressClock extends StatelessWidget {
  final String? clockin;
  final String? clockout;
  final String? duration;

  final Stream<Attendance> stream;
  final Stream<String> clock;

  const ProgressClock(this.clockin, this.clockout, this.duration, this.stream, this.clock, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Attendance>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final data = snapshot.data!;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: _TextCell("Clocking Session", bold: true, size: 24),
                  ),
                  Table(
                    columnWidths: const {
                      0: FractionColumnWidth(0.35),
                      1: FractionColumnWidth(0.65),
                    },
                    children: [
                      TableRow(children: [
                        const TableCell(child: _TextCell("Current Time : ", bold: true, size: 16)),
                        TableCell(
                            child: StreamBuilder<String>(
                                stream: clock,
                                builder: (context, snapshot) {
                                  final time = snapshot.data ?? DateFormat("hh:mm:ss").format(DateTime.now());
                                  return _TextCell(time, size: 16);
                                })),
                      ]),
                      TableRow(children: [
                        const TableCell(child: _TextCell("Clock In : ", bold: true, size: 16)),
                        TableCell(child: _TextCell(data.timeClockIn ?? "", size: 16)),
                      ]),
                      TableRow(children: [
                        const TableCell(child: _TextCell("Clock Out : ", bold: true, size: 16)),
                        TableCell(child: _TextCell(data.timeClockOut ?? "", size: 16)),
                      ]),
                      TableRow(children: [
                        const TableCell(child: _TextCell("Duration : ", bold: true, size: 16)),
                        TableCell(child: _TextCell(data.duration ?? "", size: 16)),
                      ]),
                      TableRow(children: [
                        const TableCell(child: _TextCell("Remark : ", bold: true, size: 16)),
                        TableCell(child: _TextCell(data.remark ?? "", size: 16)),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(
                    color: Colors.black87,
                    height: 2,
                    indent: 12,
                    endIndent: 12,
                  ),
                  const SizedBox(height: 12),
                  CircularPercentIndicator(
                    radius: MediaQuery.of(context).size.width / 3,
                    lineWidth: 10.0,
                    percent: double.tryParse(
                              (data.weeklyProgress ?? "0").replaceAll("%", ""))! /
                        100,
                    footer: _TextCell("Total Work Duration : ${data.weeklyRequiredHours ?? 0}"),
                    header: const _TextCell("Weekly Completion", bold: true, size: 24),
                    center: _TextCell(data.weeklyProgress, size: 20),
                    progressColor: Colors.green,
                  ),
                ],
              ),
            ),
          );
        });
  }
}

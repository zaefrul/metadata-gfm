import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:GEMS/controller/PPM/task_view.dart';
import 'package:GEMS/model/task.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/view/gems_chrome.dart';
import 'package:table_calendar/table_calendar.dart';

import 'Form/form_view.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late DateTime _selectedDay;
  final Map<DateTime, List<String>> _events = {};
  Map<DateTime, List<String>> _visibleEvents = {};
  final List<Task> _selectedEvents = [];
  final Map<String, List<int>> _monthsCollected = {};
  late AnimationController _controller;
  bool typeViewCalendar = true;
  bool typeViewListAll = false;
  DateTime currentDate = DateTime.now();
  late DateTime firstDate;
  late DateTime lastDate;

  final TaskView taskView = TaskView();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    firstDate = DateTime(_selectedDay.year, 1, 1);
    lastDate = DateTime(_selectedDay.year, 12, 31);
    fetch(DateTime.now());

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  void _checkAndFetch(DateTime date) {
    String year = "${date.year}";
    if (_monthsCollected[year]?.contains(date.month) ?? false) return;
    fetch(date);
  }

  void fetch(DateTime time) {
    Provider provider = Provider(
      fetchURL: "/api/m_ppm.php?type=calendar_dot&month=${time.month}&year=${time.year}",
    );

    provider.context = context;

    provider.fetch().then((value) {
      if (value.dotList != null) {
        for (var f in value.dotList!) {
          DateTime date = DateTime.parse(f.date);
          _events[date] = f.status.toList();
        }
      }
      setState(() {
        _monthsCollected.putIfAbsent("${time.year}", () => []).add(time.month);
        _visibleEvents = _events;
      });
    }).catchError((err) {
      debugPrint(err.toString());
    });
  }

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      _selectedDay = day;
    });
  }

  void _onPageChanged(DateTime focusedDay) {
    _checkAndFetch(focusedDay);
    setState(() {
      _selectedDay = DateTime(focusedDay.year, focusedDay.month, _selectedDay.day);
      _visibleEvents = _events;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        children: [
          header,
          if (typeViewCalendar) ...[
            _buildTableCalendar(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  DateFormat('EEE, d MMM yyyy').format(_selectedDay),
                  style: GemsChrome.body(
                    size: 13,
                    weight: FontWeight.w600,
                    color: GemsChrome.textSoft,
                  ),
                ),
              ),
            ),
            Expanded(child: _buildEventList()),
          ] else if (typeViewListAll)
            Expanded(child: taskView),
        ],
      ),
    );
  }

  Widget _buildTableCalendar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(GemsChrome.radius),
          border: Border.all(color: GemsChrome.border),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
          child: TableCalendar<String>(
            locale: 'en_US',
            eventLoader: (day) => _visibleEvents[day] ?? [],
            startingDayOfWeek: StartingDayOfWeek.monday,
            sixWeekMonthsEnforced: true,
            rowHeight: 42,
            daysOfWeekHeight: 28,
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
              markersMaxCount: 3,
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: GemsChrome.heading(size: 16),
              leftChevronIcon: const Icon(Icons.chevron_left, color: GemsChrome.text),
              rightChevronIcon: const Icon(Icons.chevron_right, color: GemsChrome.text),
              headerPadding: const EdgeInsets.symmetric(vertical: 2),
            ),
            firstDay: firstDate,
            lastDay: lastDate,
            focusedDay: _selectedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            onPageChanged: _onPageChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildEventList() {
    return FutureBuilder<List<Task>>(
      future: fetchCalendar(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
        if (snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No tasks on this day',
              style: GemsChrome.body(color: GemsChrome.muted),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            children: snapshot.data!.map(tile).toList(),
          ),
        );
      },
    );
  }

  Widget get header => Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(Icons.calendar_today, color: typeViewCalendar ? GemsChrome.primary : GemsChrome.muted),
              onPressed: () => setState(() {
                typeViewCalendar = true;
                typeViewListAll = false;
              }),
            ),
            IconButton(
              icon: Icon(Icons.list, color: typeViewListAll ? GemsChrome.primary : GemsChrome.muted),
              onPressed: () => setState(() {
                typeViewCalendar = false;
                typeViewListAll = true;
              }),
            ),
          ],
        ),
      );

  Widget tile(Task task) {
    final style = _statusStyle(task.statusDesc);
    return GemsAccentCard(
      margin: const EdgeInsets.only(bottom: 10),
      accent: style.foreground,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FormView(
              id: task.ppmTaskId,
              siteName: task.siteName,
              taskNo: task.transactionNo,
              taskStatus: task.statusDesc,
              refresh: () => fetch(_selectedDay),
              viewer: true,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    task.transactionNo,
                    style: GemsChrome.body(size: 15, weight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                status(task.statusDesc),
              ],
            ),
            const SizedBox(height: 4),
            Text(task.siteName, style: GemsChrome.body(size: 13, color: GemsChrome.textSoft)),
            Text(task.assetTypeName, style: GemsChrome.body(size: 12, color: GemsChrome.textSoft)),
            Text(task.taskDateDue, style: GemsChrome.body(size: 12, color: GemsChrome.textSoft)),
          ],
        ),
      ),
    );
  }

  Widget getTitle(String text, {bool bold = false}) => Text(
        text,
        style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal),
      );

  GemsStatusStyle _statusStyle(String value) {
    switch (value) {
      case 'In Progress':
        return GemsStatusStyle.primary;
      case 'Closed':
      case 'Completed':
        return GemsStatusStyle.success;
      case 'Pending Check':
      case 'Check':
        return GemsStatusStyle.info;
      case 'Pending Verification':
      case 'Verify':
      case 'Re-Open':
        return GemsStatusStyle.warning;
      default:
        return GemsStatusStyle.neutral;
    }
  }

  Widget status(String value) {
    final style = _statusStyle(value);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        value,
        style: GemsChrome.body(
          size: 11,
          weight: FontWeight.w600,
          color: style.foreground,
        ),
      ),
    );
  }

  Future<List<Task>> fetchCalendar() async {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDay);
    Provider provider = Provider(fetchURL: "/api/m_ppm.php?type=calendar_list&date=$dateStr");
    try {
      final result = await provider.fetch();
      return result.taskList?.toList() ?? [];
    } catch (err) {
      debugPrint(err.toString());
      return [];
    }
  }
}

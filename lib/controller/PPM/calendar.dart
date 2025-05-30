import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:GEMS/controller/PPM/task_view.dart';
import 'package:GEMS/model/task.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/utils/reference.dart';
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
  late DateTime _currentMonth;
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
    _currentMonth = DateTime.now();
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
      _currentMonth = day;
      _selectedDay = day;
    });
  }

  void _onPageChanged(DateTime focusedDay) {
    _checkAndFetch(focusedDay);
    setState(() {
      _currentMonth = focusedDay;
      _selectedDay = DateTime(focusedDay.year, focusedDay.month, _selectedDay.day);
      _visibleEvents = _events;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Column(
        children: [
          header,
          if (typeViewCalendar) ...[
            _buildTableCalendar(),
            const SizedBox(height: 8.0),
            Expanded(child: _buildEventList()),
          ] else if (typeViewListAll)
            Expanded(child: taskView),
        ],
      ),
    );
  }

  Widget _buildTableCalendar() {
    return TableCalendar<String>(
      headerVisible: false,
      locale: 'en_US',
      eventLoader: (day) => _visibleEvents[day] ?? [],
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        selectedDecoration: BoxDecoration(color: colorTheme2, shape: BoxShape.circle),
        todayDecoration: BoxDecoration(color: colorTheme2.withOpacity(0.5), shape: BoxShape.circle),
        markerDecoration: BoxDecoration(color: colorTheme1, shape: BoxShape.circle),
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
      ),
      firstDay: firstDate,
      lastDay: lastDate,
      focusedDay: _selectedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: _onDaySelected,
      onPageChanged: _onPageChanged,
    );
  }

  Widget _buildEventList() {
    return FutureBuilder<List<Task>>(
      future: fetchCalendar(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
        if (snapshot.data!.isEmpty) return Container();
        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView(
            children: snapshot.data!.map(tile).toList(),
          ),
        );
      },
    );
  }

  Widget get header => ListTile(
        title: Text(
          DateFormat.yMMMM("en_US").format(_currentMonth),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.calendar_today, color: typeViewCalendar ? colorTheme2 : Colors.grey),
              onPressed: () => setState(() {
                typeViewCalendar = true;
                typeViewListAll = false;
              }),
            ),
            IconButton(
              icon: Icon(Icons.list, color: typeViewListAll ? colorTheme2 : Colors.grey),
              onPressed: () => setState(() {
                typeViewCalendar = false;
                typeViewListAll = true;
              }),
            ),
          ],
        ),
      );

  Widget tile(Task task) => ListTile(
        contentPadding: EdgeInsets.all(12),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            getTitle(task.transactionNo, bold: true),
            getTitle(task.siteName),
            getTitle(task.assetTypeName),
            getTitle(task.taskDateDue),
          ],
        ),
        trailing: status(task.statusDesc),
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
      );

  Widget getTitle(String text, {bool bold = false}) => Text(
        text,
        style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal),
      );

  Widget status(String value) {
    var color = colorTheme1;
    switch (value) {
      case "In Progress":
        color = colorTheme5;
        break;
      case "Closed":
        color = colorTheme4;
        break;
      case "Pending Check":
        color = colorTheme2;
        break;
      case "Pending Verification":
        color = colorTheme3;
        break;
    }
    return Container(
      alignment: Alignment.center,
      height: 30.0,
      width: 100.0,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20.0)),
      child: Text(value, style: TextStyle(color: Colors.white)),
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

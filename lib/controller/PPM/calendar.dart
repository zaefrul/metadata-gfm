import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gfm_gems/controller/PPM/task_view.dart';
import 'package:gfm_gems/model/task.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:table_calendar/table_calendar.dart';

import 'Form/form_view.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<Calendar> {
  DateTime _selectedDay;
  DateTime _currentMonth;
  Map<DateTime, List> _events = Map<DateTime, List>();
  Map<DateTime, List> _visibleEvents = Map<DateTime, List>();
  List _selectedEvents = List();
  Map<String, List<int>> _monthsCollected = Map<String, List<int>>();
  AnimationController _controller;
  bool typeViewCalendar = true;
  bool typeViewListAll = false;
  DateTime currentDate = DateTime.now();
  DateTime firstDate;
  DateTime lastDate;

  final TaskView taskView = new TaskView();

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
    );

    _controller.forward();
  }

  void _checkAndFetch(DateTime date) {
    String year = "${date.year}";
    var keys = _monthsCollected.keys;
    if (keys.contains(year)) if (_monthsCollected[year].contains(date.month))
      return;

    fetch(date);
  }

  fetch(DateTime time) {
    Provider provider = Provider(
        fetchURL:
            "/api/m_ppm.php?type=calendar_dot&month=${time.month}&year=${time.year}");

    provider.context = context;

    provider.fetch().then((value) {
      value.dotList.forEach((f) {
        var splitTime = f.date.split("-");
        var year = int.parse(splitTime[0]);
        var month = int.parse(splitTime[1]);
        var day = int.parse(splitTime[2]);
        var date = new DateTime.utc(year, month, day);
        // new DateTime.fromMicrosecondsSinceEpoch(int.parse(f.date));
        _events[date] = f.status.toList();
      });
      setState(() {
        String year = "${time.year}";

        if (_monthsCollected[year] == null)
          _monthsCollected[year] = [time.month];
        else
          _monthsCollected[year].add(time.month);

        _selectedEvents = _events[time] ?? [];
        _visibleEvents = _events;
      });
    }).catchError((err) {
      print(err);
    });
  }

  void _onDaySelected(DateTime day, List events) {
    setState(() {
      _currentMonth = day;
      _selectedDay = day;
      _selectedEvents = events;
    });
  }

  void _onVisibleDaysChanged(DateTime first, DateTime last) async {
    bool checkDay(DateTime date) => date.day != 1;

    var date = first;
    last = DateTime(date.year, date.month, 31);

    if (checkDay(date)) {
      if (date.month == 12)
        date = new DateTime(date.year + 1, 1, 1);
      else
        date = new DateTime(date.year, date.month + 1, 1);
    }
    _checkAndFetch(date);
    setState(() {
      _currentMonth = date;
      _selectedDay = DateTime(date.year, date.month, _selectedDay.day);

      _visibleEvents = Map.fromEntries(
        _events.entries.where(
          (entry) =>
              entry.key.isAfter(first.subtract(const Duration(days: 1))) &&
              entry.key.isBefore(last.add(const Duration(days: 1))),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var children;

    if (typeViewCalendar)
      children = <Widget>[
        header,
        _buildTableCalendar(),
        const SizedBox(height: 8.0),
        Expanded(child: _buildEventList()),
      ];
    else if (typeViewListAll)
      children = <Widget>[
        header,
        Expanded(child: taskView),
      ];
    return Padding(
      padding: EdgeInsets.only(top: 12.0),
      child: Column(mainAxisSize: MainAxisSize.max, children: children),
    );
  }

  // Simple TableCalendar configuration (using Styles)
  Widget _buildTableCalendar() {
    return TableCalendar<String>(
      headerVisible: false,
      locale: 'en_US',

      eventLoader: (day) => _visibleEvents[day],
      // events: _visibleEvents,
      // initialCalendarFormat: CalendarFormat.month,
      // formatAnimation: FormatAnimation.slide,
      startingDayOfWeek: StartingDayOfWeek.monday,
      availableGestures: AvailableGestures.all,
      calendarStyle: CalendarStyle(
          selectedDecoration:
              BoxDecoration(color: colorTheme2, shape: BoxShape.circle),
          todayDecoration: BoxDecoration(
              color: colorTheme2.withOpacity(0.5), shape: BoxShape.circle),
          markerDecoration:
              BoxDecoration(color: colorTheme1, shape: BoxShape.circle)),
      headerStyle: HeaderStyle(
        formatButtonTextStyle:
            TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
        formatButtonDecoration: BoxDecoration(
          color: colorTheme3,
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      firstDay: firstDate ?? DateTime(currentDate.year, currentDate.month),
      focusedDay: _selectedDay,
      lastDay: lastDate ?? currentDate,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (day, _) => _onDaySelected(day, _visibleEvents[day]),
      onFormatChanged: (value) => value,
      onPageChanged: (date) => _onVisibleDaysChanged(
        date,
        null,
      ),
    );
  }

  Widget _buildEventList() {
    return FutureBuilder(
      future: fetchCalendar(),
      builder: (context, AsyncSnapshot<List<Task>> snapshot) {
        if (snapshot.data == null)
          return new Container(
              child: Center(
            child: CircularProgressIndicator(),
          ));
        else if (snapshot.data.length == 0)
          return new Container();
        else if (snapshot.data is List<Task>)
          return RefreshIndicator(
              onRefresh: () {
                setState(() {});
                return Future.value();
              },
              child: ListView(
                  children: List.generate(snapshot.data.length,
                      (item) => tile(snapshot.data[item]))));

        return new Container();
      },
    );
  }

  Widget get header {
    return ListTile(
        title: new Text(new DateFormat.yMMMM("en_US").format(_currentMonth),
            style: TextStyle(fontWeight: FontWeight.bold)),
        trailing: Container(
          child: new Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              GestureDetector(
                child: Icon(
                  Icons.calendar_today,
                  color: typeViewCalendar ? colorTheme2 : Colors.grey,
                ),
                onTap: () {
                  setState(() {
                    typeViewCalendar = true;
                    typeViewListAll = false;
                  });
                },
              ),
              new SizedBox(
                width: 12.0,
              ),
              GestureDetector(
                child: Icon(
                  Icons.list,
                  color: typeViewListAll ? colorTheme2 : Colors.grey,
                ),
                onTap: () {
                  setState(() {
                    typeViewCalendar = false;
                    typeViewListAll = true;
                  });
                },
              ),
            ],
          ),
        ));
  }

  ListTile tile(Task task) => new ListTile(
        contentPadding: EdgeInsets.all(12),
        title: new Row(
          children: <Widget>[
            new Expanded(
                child: new Column(
              children: <Widget>[
                getTitle(task.transactionNo, bold: true),
                getTitle(task.siteName),
                getTitle(task.assetTypeName),
                getTitle(task.taskDateDue),
              ],
            )),
            status(task.statusDesc)
          ],
        ),
        onTap: () {
          Object page = new FormView(
            id: task.ppmTaskId,
            siteName: task.siteName,
            taskNo: task.transactionNo,
            taskStatus: task.statusDesc,
            refresh: fetch,
            viewer: true,
          );
          Navigator.of(context)
              .push(new MaterialPageRoute(
            builder: (BuildContext context) => page,
          ))
              .then((onValue) {
            fetch(null);
          });
        },
      );

  Widget getTitle(String text, {bold = false}) => new Container(
        alignment: Alignment.centerLeft,
        child: new Text(text,
            style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      );

  Widget status(String value) {
    var text = value;
    var color = colorTheme1;
    if (text == "In Progress")
      color = colorTheme5;
    else if (text == "Closed")
      color = colorTheme4;
    else if (text == "Pending Check") {
      text = "Check";
      color = colorTheme2;
    } else if (text == "Pending Verification") {
      text = "Verify";
      color = colorTheme3;
    }

    return new Container(
        alignment: Alignment.center,
        height: 30.0,
        width: 100.0,
        decoration: BoxDecoration(
            color: color, borderRadius: new BorderRadius.circular(20.0)),
        child: new Text(text,
            style: TextStyle(
              color: Colors.white,
            )));
  }

  Future<List<Task>> fetchCalendar() async {
    final f = new DateFormat('yyyy-MM-dd');
    var newDate = f.format(_selectedDay);
    Provider _provider =
        Provider(fetchURL: "/api/m_ppm.php?type=calendar_list&date=$newDate");

    try {
      var result = await _provider.fetch();
      return result.taskList.toList();
    } catch (err) {
      print(err);
      return List<Task>();
    }
  }
}

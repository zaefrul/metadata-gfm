import 'package:flutter/material.dart';
import 'package:GEMS/model/gamification.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:GEMS/view/drawer.dart';
import 'package:month_year_picker/month_year_picker.dart';
import '../../../main.dart';

class LeaderboardView extends StatefulWidget {
  @override
  _LeaderboardViewState createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<LeaderboardView>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;
  late _Controller _controller;

  final DateTime now = DateTime.now();
  int month = DateTime.now().month;
  int year = DateTime.now().year;

  String selectedIndividual = "Monthly";
  String selectedProjects = "Monthly";

  List<IndividualGamification> _individuals = [];
  List<ProjectGamification> _projects = [];
  GamificationInfo? _score;
  List<Widget> _individualTiles = [];
  List<Widget> _projectsTiles = [];

  _LeaderboardViewState() {
    _controller = _Controller(month, year);
    refresh();
  }

  Future<void> refresh() async {
    _individuals = await _controller.individuals;
    _projects = await _controller.projects;
    _score = await _controller.score;
    _individualTiles = [];
    _projectsTiles = [];
    _individualTiles.add(_header(0, changeDate));
    _projectsTiles.add(_header(1, changeDate));

    setState(() {
      _individualTiles.addAll(
        _individuals
            .map((e) => individualTile(e.name, e.project, e.category, e.score))
            .toList(),
      );
      _projectsTiles.addAll(
        _projects.map((e) => projectTile(e.name, e.score)).toList(),
      );
    });
  }

  void changeDate() async {
    final currentDate = DateTime.now();
    final lastDate = DateTime(currentDate.year, currentDate.month + 1);
    final selected = await showMonthYearPicker(
      context: navigatorKey.currentContext!,
      initialDate: DateTime(year, month),
      firstDate: DateTime(2022),
      lastDate: lastDate,
    );
    if (selected != null) {
      month = selected.month;
      year = selected.year;
      _controller.month = selected.month;
      _controller.year = selected.year;
      refresh();
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Leaderboard", style: TextStyle(color: colorTheme3)),
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: Image.asset("assets/icon_trans.png", width: 30.0),
          color: Colors.black,
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colorTheme2,
          labelColor: colorTheme3,
          tabs: [
            Tab(text: "Individual"),
            Tab(text: "Projects"),
          ],
        ),
      ),
      drawer: BuildDrawer(() => Navigator.pop(context)),
      body: TabBarView(
        controller: _tabController,
        children: [
          RefreshIndicator(
              onRefresh: refresh, child: ListView(children: _individualTiles)),
          RefreshIndicator(
              onRefresh: refresh, child: ListView(children: _projectsTiles)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: null,
        label: Text(
            "Current Scoring Point : ${_score?.gmiPointTotal ?? 0}"),
        backgroundColor: colorTheme1,
      ),
    );
  }

  void individual(String value) => setState(() => selectedIndividual = value);
  void project(String value) => setState(() => selectedProjects = value);

  Widget getDropdown(VoidCallback onChange(String), String item) {
    return DropdownButton<String>(
      underline: Container(),
      value: item,
      items: ["Yearly", "Monthly", "Weekly"]
          .map<DropdownMenuItem<String>>((e) => DropdownMenuItem(
                child: Text(e),
                value: e,
              ))
          .toList(),
      onChanged: onChange,
    );
  }

  Widget individualTile(String name, String place, String type, String score) {
    return ListTile(
      title: Text(name.capitalize()),
      subtitle: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Text(place.toUpperCase()),
      ),
      trailing: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: colorTheme1,
        ),
        child: Text(score, style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget projectTile(String place, String score) {
    return ListTile(
      title: Text(place),
      trailing: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: colorTheme1,
        ),
        child: Text(score, style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _header(int index, VoidCallback onTap) {
    List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return Column(
      children: [
        ListTile(
          title: Text(
            "${months[month - 1]} $year",
            style: TextStyle(fontSize: 20, color: colorTheme2),
          ),
          trailing: Icon(Icons.calendar_month, color: colorTheme2),
          onTap: onTap,
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                index == 0 ? "Individual" : "Project",
                style: TextStyle(fontSize: 16),
              ),
              Spacer(),
              Text("Score", style: TextStyle(fontSize: 16)),
              SizedBox(width: 26)
            ],
          ),
        ),
        Divider(),
      ],
    );
  }
}

class _Controller {
  int month;
  int year;

  _Controller(this.month, this.year);

  Future<List<IndividualGamification>> get individuals =>
      Provider(fetchURL: "/gamification/gmi_monthly_top_5_m/$year/$month")
          .getJson(url: "/gamification/gmi_monthly_top_5_m/$year/$month")
          .then((value) => value
              .map<IndividualGamification>(
                  (v) => IndividualGamification.fromJson(v))
              .toList());

  Future<List<ProjectGamification>> get projects =>
      Provider(fetchURL: "/gamification/gmi_monthly_top_5_project_m/$year/$month")
          .getJson(url: "/gamification/gmi_monthly_top_5_project_m/$year/$month")
          .then((value) => value
              .map<ProjectGamification>((v) => ProjectGamification.fromJson(v))
              .toList());

  Future<GamificationInfo> get score =>
      Provider(fetchURL: "/gamification/current_score")
          .getJson(url: "/gamification/current_score")
          .then((value) => GamificationInfo.fromJson(value))
          .catchError((e) {
        print(e);
        throw e;
      });
}

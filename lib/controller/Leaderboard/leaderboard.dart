import 'package:flutter/material.dart';
import 'package:gfm_gems/model/gamification.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:gfm_gems/view/drawer.dart';
import 'package:month_year_picker/month_year_picker.dart';

class LeaderboardView extends StatefulWidget {
  @override
  _LeaderboardViewState createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<LeaderboardView>
    with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TabController _tabController;
  _Controller _controller;

  final now;
  int month;
  int year;

  String selectedIndividual = "Monthly";
  String selectedProjects = "Monthly";

  List<IndividualGamification> _individuals = [];
  List<ProjectGamification> _projects = [];
  GamificationInfo _score;
  List<Widget> _individualTiles = [];
  List<Widget> _projectsTiles = [];

  _LeaderboardViewState()
      : this.now = DateTime.now(),
        this.month = DateTime.now().month,
        this.year = DateTime.now().year {
    _controller = _Controller(this.month, this.year);
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
      context: context,
      initialDate: DateTime(year, month + 1),
      firstDate: DateTime(2022),
      lastDate: lastDate,
    );
    if (selected != null) {
      this.month = selected.month - 1;
      this.year = selected.year;

      _controller.month = selected.month - 1;
      _controller.year = selected.year;
      refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_tabController == null) {
      _tabController = TabController(length: 2, vsync: this);
      _tabController.addListener(() => refresh());
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Leaderboard", style: TextStyle(color: colorTheme3)),
          backgroundColor: Colors.white,
          centerTitle: true,
          leading: new IconButton(
              icon: new Image.asset("assets/icon_trans.png", width: 30.0),
              color: Colors.black,
              onPressed: () {
                _scaffoldKey.currentState.openDrawer();
              }),
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
                onRefresh: refresh,
                child: ListView(children: _individualTiles)),
            RefreshIndicator(
                onRefresh: refresh, child: ListView(children: _projectsTiles)),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: null,
          label: Text("Current Scoring Point : ${_score?.gmiPointTotal ?? 0}"),
          backgroundColor: colorTheme1,
        ),
      ),
    );
  }

  individual(String value) => setState(() => selectedIndividual = value);
  project(String value) => setState(() => selectedProjects = value);

  Widget getDropdown(Function(String) onChange, String item) {
    return DropdownButton<String>(
      underline: new Container(),
      value: item,
      items: [
        "Yearly",
        "Monthly",
        "Weekly",
      ]
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
      // Padding(
      //   padding: EdgeInsets.all(4),
      //   child: Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [Text(place), SizedBox(height: 6), Text(type)],
      //   ),
      // ),
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

  Widget _header(int index, Function onTap) {
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
            "${months[month]} $year",
            style: TextStyle(fontSize: 20, color: colorTheme2),
          ),
          trailing: Icon(Icons.calendar_month, color: colorTheme2),
          onTap: onTap,
          // index == 0
          //     ? getDropdown(individual, selectedIndividual)
          //     : getDropdown(project, selectedProjects),
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
          .getJson()
          .then((value) => value
              .map<IndividualGamification>(
                  (v) => IndividualGamification.fromJson(v))
              .toList());
  Future<List<ProjectGamification>> get projects => Provider(
          fetchURL: "/gamification/gmi_monthly_top_5_project_m/$year/$month")
      .getJson()
      .then((value) => value
          .map<ProjectGamification>((v) => ProjectGamification.fromJson(v))
          .toList());
  Future<GamificationInfo> get score =>
      Provider(fetchURL: "/gamification/current_score")
          .getJson()
          .then((value) => GamificationInfo.fromJson(value))
          .catchError((e) {
        print(e);
      });
}

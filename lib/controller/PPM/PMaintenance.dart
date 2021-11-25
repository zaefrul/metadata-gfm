import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/PPM/search.dart';
import 'package:gfm_gems/controller/Homepage/test.dart';
import 'package:gfm_gems/utils/reference.dart';

import '../../view/bar.dart';
import '../../view/drawer.dart';
import 'calendar.dart';
import 'task_view.dart';

class PreventiveMaintenance extends StatefulWidget {
  @override
  _PreventiveMaintenanceState createState() => _PreventiveMaintenanceState();
}

class _PreventiveMaintenanceState extends State<PreventiveMaintenance>
    with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TabController _tabController;
  bool isOpened = false;

  _PreventiveMaintenanceState() {
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TabBarView barview = TabBarView(
      children: <Widget>[Calendar(), new TaskView(index: 1)],
      controller: _tabController,
    );

    return Scaffold(
      key: _scaffoldKey,
      appBar: bar(_scaffoldKey,
          text: "Planned Preventive Maintenance", search: true, onTap: () {
        print(_tabController.index);
        Navigator.pushNamed(context, "/search",
            arguments: SearchArguments(index: _tabController.index));
      }, controller: _tabController, dimmer: isOpened),
      drawer: BuildDrawer(() => Navigator.pop(context)),
      body: LayoutBuilder(
        builder: (context, constraint) {
          return Stack(
              children: isOpened
                  ? [
                      barview,
                      new Container(
                        color: Colors.black.withOpacity(0.5),
                      )
                    ]
                  : [barview]);
        },
      ),
      // floatingActionButton: fab
    );
  }

  Widget get fab => new FloatingActionButton(
        heroTag: "FAB",
        child: isOpened ? new Icon(Icons.close) : new Icon(Icons.menu),
        backgroundColor: colorTheme4,
        onPressed: () {
          Navigator.push(
              context,
              PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (BuildContext context, __, _) =>
                      AwesomeFAB())).then((value) {
            print(value);
          });
        },
      );
}

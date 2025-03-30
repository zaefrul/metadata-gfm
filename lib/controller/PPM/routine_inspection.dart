import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/PPM/ri_search.dart';

import '../../view/bar.dart';
import '../../view/drawer.dart';
import 'ri_task_view.dart';

class RoutineInspection extends StatefulWidget {
  @override
  _RoutineInspectionState createState() => _RoutineInspectionState();
}

class _RoutineInspectionState extends State<RoutineInspection>
    with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool isOpened = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: RITaskView(index: 1),
      drawer: BuildDrawer(() => Navigator.pop(context)),
      appBar: AppBar(
        title: Text("Routine Inspection"),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(
              context,
              SearchRI.routeName,
              arguments: SearchRIArguments(index: 1),
            ),
          ),
        ],
      ),
    );
  }
}

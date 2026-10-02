import 'package:flutter/material.dart';
import 'package:GEMS/controller/PPM/ri_search.dart';

import '../../view/drawer.dart';
import '../../view/gems_chrome.dart';
import 'ri_task_view.dart';

class RoutineInspection extends StatefulWidget {
  const RoutineInspection({super.key});

  @override
  _RoutineInspectionState createState() => _RoutineInspectionState();
}

class _RoutineInspectionState extends State<RoutineInspection>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isOpened = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: GemsChrome.page,
      body: RITaskView(index: 1),
      drawer: BuildDrawer(() => Navigator.pop(context)),
      appBar: gemsAppBar(
        title: const Text('Routine Inspection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
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

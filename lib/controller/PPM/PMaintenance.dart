import 'package:flutter/material.dart';
import 'package:GEMS/controller/PPM/search.dart';
import 'package:GEMS/controller/Homepage/test.dart';
import '../../view/drawer.dart';
import '../../view/gems_chrome.dart';
import 'calendar.dart';
import 'task_view.dart';

class PreventiveMaintenance extends StatefulWidget {
  const PreventiveMaintenance({super.key});

  @override
  _PreventiveMaintenanceState createState() => _PreventiveMaintenanceState();
}

class _PreventiveMaintenanceState extends State<PreventiveMaintenance>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final TabController _tabController;
  bool isOpened = false;

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
    final TabBarView barView = TabBarView(
      controller: _tabController,
      children: <Widget>[
        const Calendar(),
        TaskView(index: 1),
      ],
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: GemsChrome.page,
      drawer: BuildDrawer(() => Navigator.pop(context)),
      appBar: gemsAppBar(
        title: const Text('Preventive Maintenance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(
                context,
                "/search",
                arguments: SearchArguments(index: _tabController.index),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: GemsChrome.primary,
          unselectedLabelColor: GemsChrome.textSoft,
          indicatorColor: GemsChrome.teal,
          indicatorWeight: 3,
          dividerColor: GemsChrome.border,
          labelStyle: GemsChrome.body(size: 13, weight: FontWeight.w600),
          unselectedLabelStyle: GemsChrome.body(size: 13, weight: FontWeight.w500),
          tabs: const [
            Tab(text: 'Schedule'),
            Tab(text: 'My Task'),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: [
            barView,
            if (isOpened)
              Container(color: Colors.black.withOpacity(0.5)),
          ],
        ),
      ),
      // floatingActionButton: fab,
    );
  }

//   Widget get fab => FloatingActionButton(
//         heroTag: "FAB",
//         backgroundColor: colorTheme4,
//         child: Icon(isOpened ? Icons.close : Icons.menu),
//         onPressed: () {
//           Navigator.push(
//             context,
//             PageRouteBuilder(
//               opaque: false,
//               pageBuilder: (_, __, ___) => AwesomeFAB(),
//             ),
//           ).then((value) {
//             debugPrint('FAB returned: $value');
//           });
//         },
//       );
}

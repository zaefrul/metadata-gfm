import 'package:flutter/material.dart';
import 'package:GEMS/controller/WorkOrder/complaintSearch.dart';
import 'package:GEMS/controller/WorkOrder/complaintView.dart';
import 'package:GEMS/main.dart';
import 'package:GEMS/model/user.dart';
import 'package:GEMS/view/drawer.dart';
import 'package:GEMS/view/gems_chrome.dart';

import 'complaintForm.dart';
import 'mrRequest.dart';

class WorkOrderView extends StatefulWidget {
  const WorkOrderView({super.key});

  @override
  _WorkOrderState createState() => _WorkOrderState();
}

class _WorkOrderState extends State<WorkOrderView> with TickerProviderStateMixin, RouteAware {
  final String selfFindingURL = "/api/m_wo.php?type=submitted_wo";
  final String myTaskURL = "/api/m_wo.php?type=pending_task";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TabController? _tabController;
  bool isSupervisor = false;

  @override
  void initState() {
    super.initState();
    // Retrieve user preferences asynchronously
    User.getPrefUser
        .then((value) => User.fromMap(value))
        .then((user) {
          // Role 17 historically owns the MR Approval tab; MR Reviewer uses role 27.
          // Allow either role to see the MR Approval task list.
          isSupervisor = user.roles.any((element) => element.id == "17" || element.id == "27");
          int length = isSupervisor ? 3 : 2;
          setState(() {
            _tabController = TabController(vsync: this, length: length);
          });
        });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route observer
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
    
    if (_tabController != null) {
      _tabController!.addListener(() {
        if (_tabController!.indexIsChanging) {
          debugPrint("Tab changed to: ${_tabController!.index}");
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Refresh the data here
    _refreshWorkOrderList();
  }

  void _refreshWorkOrderList() {
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_tabController == null) {
      return const Scaffold(
        backgroundColor: GemsChrome.page,
        body: Center(
          child: CircularProgressIndicator(color: GemsChrome.primary),
        ),
      );
    }

    TabBarView barview = TabBarView(
      controller: _tabController,
      children: <Widget>[
        ComplaintView(selfFindingURL, _addComplaint, 0),
        ComplaintView(myTaskURL, null, 1),
        if (isSupervisor) MRTaskList(),
      ],
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: GemsChrome.page,
      drawer: BuildDrawer(() => Navigator.pop(context)),
      appBar: _workOrderBar(),
      body: barview,
    );
  }

  PreferredSizeWidget _workOrderBar() {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: GemsChrome.text),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: Text('Work Order', style: GemsChrome.heading(size: 20)),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: GemsChrome.text),
          onPressed: () {
            final index = _tabController!.index;
            final url = index == 0 ? selfFindingURL : myTaskURL;
            Navigator.pushNamed(
              context,
              "/search_complaint",
              arguments: SearchComplaintArguments(url: url, index: index),
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
        tabs: [
          const Tab(text: 'My Complaint'),
          const Tab(text: 'My Task'),
          if (isSupervisor) const Tab(text: 'MR Approval'),
        ],
      ),
    );
  }

  Widget get _addComplaint {
    return Material(
      color: GemsChrome.primary,
      borderRadius: BorderRadius.circular(GemsChrome.radius),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => FormComplaint()),
          );
        },
        borderRadius: BorderRadius.circular(GemsChrome.radius),
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(Icons.add, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

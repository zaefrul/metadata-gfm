import 'package:flutter/material.dart';
import 'package:GEMS/controller/WorkOrder/complaintSearch.dart';
import 'package:GEMS/controller/WorkOrder/complaintView.dart';
import 'package:GEMS/main.dart';
import 'package:GEMS/model/user.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:GEMS/view/bar.dart';
import 'package:GEMS/view/drawer.dart';

import 'complaintForm.dart';
import 'mrRequest.dart';

class WorkOrderView extends StatefulWidget {
  @override
  _WorkOrderState createState() => _WorkOrderState();
}

class _WorkOrderState extends State<WorkOrderView> with TickerProviderStateMixin, RouteAware {
  final String selfFindingURL = "/api/m_wo.php?type=submitted_wo";
  final String myTaskURL = "/api/m_wo.php?type=pending_task";
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TabController? _tabController;
  bool isSupervisor = false;

  @override
  void initState() {
    super.initState();
    // Retrieve user preferences asynchronously
    User.getPrefUser
        .then((value) => User.fromMap(value))
        .then((user) {
          isSupervisor = user.roles.any((element) => element.id == "17");
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
      return Scaffold(
          body: Center(child: CircularProgressIndicator()));
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
      appBar: bar(
        _scaffoldKey,
        isSupervisor: isSupervisor,
        text: "Work Order",
        search: true,
        tabtitle: "My Complaint",
        controller: _tabController!,
        onTap: () {
          var url = _tabController!.index == 0 ? selfFindingURL : myTaskURL;
          Navigator.pushNamed(
            context,
            "/search_complaint",
            arguments: SearchComplaintArguments(
              url: url,
              index: _tabController!.index,
            ),
          );
        },
      ) as PreferredSizeWidget?,
      drawer: BuildDrawer(() => Navigator.pop(context)),
      body: LayoutBuilder(
          builder: (context, constraints) => barview),
    );
  }

  Widget get _addComplaint {
    Text _text(String word) => Text(
          word,
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24),
        );

    return GestureDetector(
      child: Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: colorTheme2),
          child: _text("+")),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => FormComplaint()));
      },
    );
  }
}

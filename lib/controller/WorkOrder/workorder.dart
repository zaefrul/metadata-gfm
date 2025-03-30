import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/WorkOrder/complaintSearch.dart';
import 'package:gfm_gems/controller/WorkOrder/complaintView.dart';
import 'package:gfm_gems/model/user.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:gfm_gems/view/bar.dart';
import 'package:gfm_gems/view/drawer.dart';

import 'complaintForm.dart';
import 'mrRequest.dart';

class WorkOrderView extends StatefulWidget {
  @override
  _WorkOrderState createState() => _WorkOrderState();
}

class _WorkOrderState extends State<WorkOrderView>
    with TickerProviderStateMixin {
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
  void dispose() {
    _tabController?.dispose();
    super.dispose();
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

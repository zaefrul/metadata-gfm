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
  final selfFindingURL = "/api/m_wo.php?type=submitted_wo";
  final myTaskURL = "/api/m_wo.php?type=pending_task";
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TabController _tabController;
  bool isSupervisor = false;

  _WorkOrderState() {
    User.getPrefUser.then((value) => User.fromMap(value)).then((value) {
      isSupervisor =
          value.roles.where((element) => element.id == "17").length == 1;
      if (isSupervisor)
        setState(() {
          _tabController = TabController(vsync: this, length: 3);
        });
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      appBar: bar(_scaffoldKey,
          isSupervisor: isSupervisor,
          text: "Work Order",
          search: true,
          tabtitle: "My Complaint",
          controller: _tabController, onTap: () {
        var url = _tabController.index == 0 ? selfFindingURL : myTaskURL;

        Navigator.pushNamed(context, "/search_complaint",
            arguments: SearchComplaintArguments(
                url: url, index: _tabController.index));
      }),
      drawer: BuildDrawer(() => Navigator.pop(context)),
      body: LayoutBuilder(builder: (context, constraint) => barview),
    );
  }

  Widget get _addComplaint {
    Text _text(String word) => new Text(
          word,
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        );

    return GestureDetector(
      child: new Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(shape: BoxShape.circle, color: colorTheme2),
          child: _text("+")),
      onTap: () {
        Navigator.of(context)
            .push(new MaterialPageRoute(builder: (context) => FormComplaint()));
      },
    );
  }
}

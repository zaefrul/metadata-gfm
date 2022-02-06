import 'package:flutter/material.dart';
import 'package:gfm_gems/model/responseValue.dart';
import 'package:gfm_gems/model/workorder.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:toast/toast.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'addTechnician.dart';

class ComplaintAssign extends StatefulWidget {
  final String id;
  final bool viewer;

  ComplaintAssign({this.id, this.viewer});

  @override
  _ComplaintAssignState createState() => _ComplaintAssignState();
}

class _ComplaintAssignState extends State<ComplaintAssign> {
  List<WorkOrderStatus> groupList = List<WorkOrderStatus>();
  List<WorkOrderStatus> executorList = List<WorkOrderStatus>();
  List<WorkOrderStatus> assistantList = List<WorkOrderStatus>();
  List<WorkOrderStatus> selectedassistantList = List<WorkOrderStatus>();
  List<WorkOrderStatus> severityList = [
    WorkOrderStatus((b) => b
      ..severityName = "Non-Critical"
      ..severityId = "1"),
    WorkOrderStatus((b) => b
      ..severityName = "Critical"
      ..severityId = "2")
  ];

  List<String> assistUserId = List<String>();

  TechnicianDetails technicianDetails;

  TextEditingController _controller = TextEditingController();

  String dropdownValue1;
  String dropdownValue2;
  String dropdownValue3;
  String dropdownValue4;
  String dropdownId1;
  String dropdownId2;
  String dropdownId3;
  String dropdownId4;
  String dropdownAssist;

  String typeCategory;
  List<WorkOrderStatus> _internalCategory = List<WorkOrderStatus>();
  List<WorkOrderStatus> _externalCategory = List<WorkOrderStatus>();

  bool loading = true;

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  void initState() {
    super.initState();

    Map<String, String> list1 = {
      "Self Finding": "2",
      "Request": "3",
      "Breakdown": "4",
      "Defect": "5"
    };
    Map<String, String> list2 = {
      "Complaint": "1",
      "Request": "3",
      "Breakdown": "4",
      "Defect": "5"
    };

    list1.forEach((k, v) => _internalCategory.add(WorkOrderStatus(
          (b) => b
            ..groupName = k
            ..groupId = v,
        )));

    list2.forEach((k, v) => _externalCategory.add(WorkOrderStatus(
          (b) => b
            ..groupName = k
            ..groupId = v,
        )));

    Provider(
            fetchURL: "/api/m_wo.php?type=wo_severity_list&woTaskId=",
            taskID: widget.id)
        .fetch()
        .then((value) {
      setState(() {
        severityList = value.wostatusList.toList();
      });
    });

    _fetchGroup
        .then((value) {
          groupList = value.wostatusList.toList();
          Provider provider = Provider(
            fetchURL:
                "/wo_v2/assign_and_severity/", //"/api/m_wo.php?type=assign_and_severity&woTaskId=",
            taskID: widget.id,
          );
          return provider.fetch();
        })
        .then((onValue) {
          var data = onValue.technicianAssign;

          typeCategory = data.userCategory;

          if (data.assistUserId != null)
            assistUserId = data.assistUserId.toList();

          if (data.woTaskMaxAssistant != null) {
            dropdownAssist = data.woTaskMaxAssistant;
          }

          if (data.userId != "" && data.groupId != "" && data.severity != "") {
            dropdownId1 = data.groupId;
            dropdownValue1 = _fetchId(groupList, dropdownId1).groupName;
            dropdownId2 = data.userId;
            dropdownId3 = data.severity;
            dropdownValue3 =
                _fetchSeverityId(severityList, data.severity).severityName;
            dropdownId4 = data.woTaskCategory;
            dropdownValue4 = _fetchId(
                    typeCategory == "Internal"
                        ? _internalCategory
                        : _externalCategory,
                    dropdownId4)
                .groupName;
            return _fetchExecutor;
          }

          return Future.error("no value");
        })
        .then((value) {
          executorList = value.wostatusList.toList();
          dropdownValue2 = _fetchuserId(executorList, dropdownId2).userName;
          _controller.text = dropdownValue2;

          if (executorList.length > 0 && dropdownId2 != null) {
            assistantList.addAll(executorList);
            assistantList.removeWhere((test) => test.userId == dropdownId2);
          }

          if (assistUserId.length > 0)
            assistUserId.forEach((id) {
              var value = executorList.firstWhere((test) => test.userId == id);
              if (value != null) selectedassistantList.add(value);
            });

          return _fetchTechnician;
        })
        .then((value) {
          technicianDetails = value.technicianDetails;
          print(technicianDetails);
        })
        .catchError((err) => print(err))
        .whenComplete(() {
          setState(() => loading = false);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: new Text("B. Assign Executor"),
        backgroundColor: Colors.white,
      ),
      body: loading
          ? _loading
          : ListView(children: <Widget>[
              _getTitle("Select Executor Group"),
              widget.viewer
                  ? _disableField(dropdownValue1)
                  : _dropdown(groupList, "Group"),
              _getTitle("Select Executor"),
              widget.viewer ? _disableField(dropdownValue2) : autocomplete,
              _getTitle("Select Severity"),
              widget.viewer
                  ? _disableField(dropdownValue3)
                  : _dropdown(severityList, "Severity"),
              _getTitle("Select Category"),
              widget.viewer
                  ? _disableField(dropdownValue4)
                  : _dropdown(
                      typeCategory == "Internal"
                          ? _internalCategory
                          : _externalCategory,
                      "Category",
                    ),
              _getTitle("Select Number of Assistant"),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: DropdownButton(
                  hint: Text("Max 5"),
                  isExpanded: true,
                  items: ["0", "1", "2", "3", "4", "5"]
                      .map<DropdownMenuItem<String>>(
                        (e) => DropdownMenuItem(child: Text(e), value: e),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => dropdownAssist = value),
                  value: dropdownAssist,
                ),
              ),
              // assistantList.length > 0 ? _addAssistant : new Container(),
              // assistantList.length > 0 ? _listAssistant : new Container(),
              SizedBox(height: 12),
              technicianDetails == null ? new Container() : _getAllDetails(),
              technicianDetails == null ? new Container() : _getTable(),
              SizedBox(height: 100)
            ]),
      floatingActionButton: widget.viewer
          ? null
          : FloatingActionButton.extended(
              label: new Text("Save"),
              onPressed: () {
                setState(() => loading = true);
                Provider provider = Provider();

                if (context != null) provider.context = context;

                var body = {
                  "action": "save_assigned_technician",
                  "woTaskId": widget.id,
                  "groupId": dropdownId1,
                  "userId": dropdownId2,
                  "severity": dropdownId3,
                  "woTaskCategory": dropdownId4,
                  "woTaskMaxAssistant": dropdownAssist ?? "0",
                };

                selectedassistantList.forEach((f) =>
                    body["assistUserId[${selectedassistantList.indexOf(f)}]"] =
                        f.userId);

                provider
                    .post(
                        url: "/wo_v2/save_assigned_technician/${widget.id}",
                        body: body)
                    .then((value) => Toast.show("Assignation Saved", context))
                    .catchError((err) => Toast.show(err, context))
                    .whenComplete(() => setState(() => loading = false));
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget get _loading => new Container(
        child: new Center(
          child: CircularProgressIndicator(),
        ),
      );

  Widget get _addAssistant => ListTile(
        title: new Text((selectedassistantList.length > 0 ? "Edit" : "Add") +
            " Technician Assistant"),
        trailing: new Icon(
            selectedassistantList.length > 0 ? Icons.arrow_right : Icons.add),
        onTap: () {
          if (widget.viewer) return;
          Navigator.of(context)
              .push(MaterialPageRoute(
                  builder: (context) => AddTechnicianCheckList(
                        id: widget.id,
                        viewer: true,
                      )))
              .then((value) {
            if (value != null) {
              print(value);
              setState(() {
                selectedassistantList = List<WorkOrderStatus>();
                if (value.length > 0) selectedassistantList = value;
              });
            }
          });
        },
      );

  Widget get _listAssistant => Container(
        height: 150,
        decoration:
            BoxDecoration(border: Border.all(color: Colors.black, width: 1)),
        margin: EdgeInsets.symmetric(horizontal: 12),
        child: selectedassistantList.length > 0
            ? ListView(
                children: selectedassistantList
                    .map((f) => ListTile(
                          title: new Text(
                              ((selectedassistantList.indexOf(f) + 1)
                                      .toString()) +
                                  ". " +
                                  f.userName),
                        ))
                    .toList(),
              )
            : Center(
                child: new Text("No selected assistant technician"),
              ),
      );

  Widget get autocomplete {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: TypeAheadFormField(
        getImmediateSuggestions: true,
        textFieldConfiguration: TextFieldConfiguration(
            controller: _controller,
            decoration: InputDecoration(labelText: 'Executor')),
        suggestionsCallback: (pattern) {
          return Future.value(executorList);
        },
        itemBuilder: (context, WorkOrderStatus suggestion) => ListTile(
          title: Text(suggestion.userName),
        ),
        transitionBuilder: (context, suggestionsBox, controller) {
          return suggestionsBox;
        },
        onSuggestionSelected: (WorkOrderStatus suggestion) {
          this._controller.text = suggestion.userName;
          dropdownValue2 = suggestion.userName;
          dropdownId2 = suggestion.userId;

          assistantList = List<WorkOrderStatus>();
          selectedassistantList = List<WorkOrderStatus>();
          assistantList.addAll(executorList);
          assistantList
              .removeWhere((test) => test.userName == suggestion.userName);

          _fetchTechnician.then((value) => setState(() {
                technicianDetails = value.technicianDetails;
                loading = false;
              }));
        },
      ),
    );
  }

  Widget _dropdown(List<WorkOrderStatus> value, String hint) => Padding(
        padding: const EdgeInsets.all(12.0),
        child: DropdownButton<String>(
          isExpanded: true,
          hint: new Text(hint),
          value: hint == "Group"
              ? dropdownValue1
              : hint == "Executor"
                  ? dropdownValue2
                  : hint == "Category"
                      ? dropdownValue4
                      : dropdownValue3,
          onChanged: (String newValue) {
            setState(() {
              if (hint == "Group") {
                loading = true;
                dropdownValue1 = newValue;
                dropdownValue2 = null;
                technicianDetails = null;
                assistantList = List<WorkOrderStatus>();
                _controller.text = "";

                dropdownId1 = _fetchStatus(groupList, newValue).groupId;
                _fetchExecutor.then((value) {
                  setState(() {
                    executorList = value.wostatusList.toList();
                    loading = false;
                  });
                });
              } else if (hint == "Severity") {
                dropdownValue3 = newValue;
                dropdownId3 =
                    _fetchSeverityStatus(severityList, newValue).severityId;
              } else if (hint == "Category") {
                dropdownValue4 = newValue;
                dropdownId4 = _fetchStatus(value, newValue).groupId;
              }
            });
          },
          items: value.map<DropdownMenuItem<String>>((WorkOrderStatus value) {
            return DropdownMenuItem<String>(
              value: (hint == "Group" || hint == "Category")
                  ? value.groupName
                  : hint == "Severity"
                      ? value.severityName
                      : value.userName,
              child: Text((hint == "Group" || hint == "Category")
                  ? value.groupName
                  : hint == "Severity"
                      ? value.severityName
                      : value.userName),
            );
          }).toList(),
        ),
      );

  Widget _getTitle(String value) => Padding(
        padding: const EdgeInsets.all(12.0),
        child: new Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );

  Widget _getDetails(String title, String subTitle) {
    return Row(
      children: <Widget>[_getTitle(title), new Text(subTitle)],
    );
  }

  Widget _getAllDetails() => Column(
        children: <Widget>[
          _getTitle("Executor Details"),
          _getDetails("Name: ", technicianDetails.name),
          _getDetails("Phone No: ", technicianDetails.phoneNo),
          _getDetails("Email: ", technicianDetails.email),
          _getDetails("Group: ", technicianDetails.group),
          _getDetails("Current Task in hands: ",
              technicianDetails.totalCurrentTask.toString()),
        ],
      );

  Widget _getTable() {
    var header = TableRow(
        children: [
          TableCell(
            child: _getTitle("No."),
          ),
          TableCell(
            child: _getTitle("Task No."),
          ),
          TableCell(
            child: _getTitle("Date Received"),
          ),
        ],
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: colorTheme3),
            color: Colors.grey.withOpacity(0.3)));

    Text text(String text) => Text(
          text,
          textAlign: TextAlign.center,
        );

    var children = List.generate(technicianDetails.currentTask.length, (index) {
      return TableRow(
          children: [
            TableCell(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: text("${index + 1}"),
              ),
            ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: text(
                    technicianDetails.currentTask.toList()[index].woTaskNo),
              ),
            ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: text(
                    technicianDetails.currentTask.toList()[index].dateReceived),
              ),
            ),
          ],
          decoration:
              BoxDecoration(border: Border.all(width: 1, color: colorTheme3)));
    });

    children.insert(0, header);

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Table(
        columnWidths: {
          0: FractionColumnWidth(0.15),
          2: FractionColumnWidth(0.35)
        },
        border: TableBorder.all(width: 1, color: colorTheme3),
        children: children,
      ),
    );
  }

  Widget _disableField(String text) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            new Text(
              text ?? "",
              style: TextStyle(fontSize: 16),
            ),
            Divider(
              color: Colors.black,
            )
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      );

  WorkOrderStatus _fetchuserId(List<WorkOrderStatus> listing, String id) =>
      listing.firstWhere((f) => f.userId == id);
  WorkOrderStatus _fetchId(List<WorkOrderStatus> listing, String id) =>
      listing.firstWhere((f) => f.groupId == id);
  WorkOrderStatus _fetchUserStatus(
          List<WorkOrderStatus> listing, String result) =>
      listing.firstWhere((f) => f.userName == result);
  WorkOrderStatus _fetchStatus(List<WorkOrderStatus> listing, String result) =>
      listing.firstWhere((f) => f.groupName == result);
  WorkOrderStatus _fetchSeverityId(List<WorkOrderStatus> listing, String id) =>
      listing.firstWhere((f) => f.severityId == id);
  WorkOrderStatus _fetchSeverityStatus(
          List<WorkOrderStatus> listing, String result) =>
      listing.firstWhere((f) => f.severityName == result);

  Future<ResponseValue> get _fetchGroup {
    Provider provider = Provider(
        fetchURL: "/api/m_wo.php?type=wo_group_list&woTaskId=",
        taskID: widget.id);
    return provider.fetch();
  }

  Future<ResponseValue> get _fetchExecutor {
    Provider provider = Provider(
        fetchURL: "/api/m_wo.php?type=wo_technician_list&groupId=",
        taskID: dropdownId1);
    return provider.fetch();
  }

  Future<ResponseValue> get _fetchTechnician {
    Provider provider = Provider(
        fetchURL:
            "/api/m_wo.php?type=technician_details&groupId=$dropdownId1&userId=",
        taskID: dropdownId2);
    return provider.fetch();
  }
}

class TableItem {
  final String taskNo;
  final String date;

  TableItem({this.taskNo, this.date});
}

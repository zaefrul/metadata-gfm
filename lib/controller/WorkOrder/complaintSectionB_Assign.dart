import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:toast/toast.dart';
import 'package:gfm_gems/model/workorder.dart';
import 'package:gfm_gems/model/responseValue.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:google_fonts/google_fonts.dart';

class ComplaintAssign extends StatefulWidget {
  final String id;
  final bool viewer;

  const ComplaintAssign({
    Key? key,
    required this.id,
    required this.viewer,
  }) : super(key: key);

  @override
  _ComplaintAssignState createState() => _ComplaintAssignState();
}

class _ComplaintAssignState extends State<ComplaintAssign> {
  bool loading = true;

  String typeCategory = '';
  List<String> assistUserId = [];

  List<WorkOrderStatus> groupList = [];
  List<WorkOrderStatus> executorList = [];
  List<WorkOrderStatus> severityList = [];
  List<WorkOrderStatus> _internalCategory = [];
  List<WorkOrderStatus> _externalCategory = [];

  String? dropdownValue1, dropdownValue2, dropdownValue3, dropdownValue4, dropdownAssist;
  String? dropdownId1, dropdownId2, dropdownId3, dropdownId4;

  TechnicianDetails? technicianDetails;
  final TextEditingController _controller = TextEditingController();

  

  @override
  void initState() {
    super.initState();
    ToastContext().init(context);
    _prepareCategories();
    _loadInitial();
  }

  void _prepareCategories() {
    final m1 = {"Self Finding":"2","Request":"3","Breakdown":"4","Defect":"5"};
    final m2 = {"Complaint":"1","Request":"3","Breakdown":"4","Defect":"5"};
    m1.forEach((k,v)=> _internalCategory.add(WorkOrderStatus((b)=>b
      ..groupName=k..groupId=v)));
    m2.forEach((k,v)=> _externalCategory.add(WorkOrderStatus((b)=>b
      ..groupName=k..groupId=v)));
  }

  Future<void> _loadInitial() async {
    // 1) Severity
    try {
      final resp = await Provider(
        fetchURL: "/api/m_wo.php?type=wo_severity_list&woTaskId=",
        taskID: widget.id,
      ).fetch();
      severityList = resp.wostatusList?.toList() ?? [];
    } catch (e, st) {
    }

    // 2) Groups
    try {
      final resp = await Provider(
        fetchURL: "/api/m_wo.php?type=wo_group_list&woTaskId=",
        taskID: widget.id,
      ).fetch();
      groupList = resp.wostatusList?.toList() ?? [];
    } catch (e, st) {
    }

    // 3) Existing assignment & severity (the missing bit!)
    try {
      final resp = await Provider(
        fetchURL: "/wo_v2/assign_and_severity/",
        taskID: widget.id,
      ).fetch();
      final a = resp.technicianAssign;
      if (a != null) {
        typeCategory      = a.userCategory ?? '';
        assistUserId      = a.assistUserId.toList();
        dropdownAssist    = a.woTaskMaxAssistant;
        dropdownId1       = a.groupId;
        dropdownValue1    = _fetchStatus(groupList, dropdownId1!).groupName;
        dropdownId2       = a.userId;
        dropdownId3       = a.severity;
        dropdownValue3    = _fetchSeverityId(severityList, dropdownId3!).severityName;
        dropdownId4       = a.woTaskCategory;
        dropdownValue4    = _fetchStatus(
                              typeCategory == "Internal"
                                ? _internalCategory
                                : _externalCategory,
                              dropdownId4!
                          ).groupName;
      }
    } catch (e, st) {
      debugPrint("❌ Assign&Severity error: $e\n$st");
    }

    // 4) Executor list for that group
    if (dropdownId1 != null) {
      try {
        final resp = await _fetchExecutor;
        executorList = resp.wostatusList?.toList() ?? [];
        // if we had a pre‑selected user, fill the text field
        if (dropdownId2 != null) {
          final sel = executorList.firstWhere((e) => e.userId == dropdownId2);
          dropdownValue2 = sel.userName;
          _controller.text = dropdownValue2!;
        }
      } catch (e, st) {
        debugPrint("❌ Executor fetch error: $e\n$st");
      }
    }

    // 5) Technician details for that user
    if (dropdownId2 != null) {
      try {
        final resp = await _fetchTechnician;
        technicianDetails = resp.technicianDetails;
      } catch (e, st) {
        debugPrint("❌ Technician details error: $e\n$st");
      }
    }

    setState(() => loading = false);
  }

  Future<ResponseValue> get _fetchExecutor => Provider(
    fetchURL:"/api/m_wo.php?type=wo_technician_list&groupId=",
    taskID:dropdownId1??''
  ).fetch();

  Future<ResponseValue> get _fetchTechnician => Provider(
    fetchURL:"/api/m_wo.php?type=technician_details&groupId=$dropdownId1&userId=",
    taskID:dropdownId2??''
  ).fetch();

  /// Lookup a group/category by its id or name
  WorkOrderStatus _fetchStatus(List<WorkOrderStatus> list, String idOrName) {
    return list.firstWhere((w) =>
        w.groupId   == idOrName ||
        w.groupName == idOrName
    );
  }

  /// Lookup a severity by its id
  WorkOrderStatus _fetchSeverityId(List<WorkOrderStatus> list, String id) {
    return list.firstWhere((w) => w.severityId == id);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text("B. Assign Executor"),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("B. Assign Executor"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _rowGroup(),
            Divider(),
            _rowExecutor(),
            Divider(),
            _rowSeverity(),
            Divider(),
            _rowCategory(),
            Divider(),
            _rowAssistCount(),
            const SizedBox(height: 24),
            if (!widget.viewer) _saveButton(),
            if (technicianDetails != null) ...[
              const SizedBox(height: 32),
              _detailsCard(),
              const SizedBox(height: 16),
              _tasksCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _rowGroup() {
    return _row(
      icon: Icons.group,
      label: "Executor Group",
      child: widget.viewer
          ? Text(dropdownValue1 ?? "-", style: _valueStyle)
          : DropdownButton<String>(
              value: dropdownValue1,
              hint: Text("Select Group"),
              items: groupList
                  .map((g) => DropdownMenuItem(
                        child: Text(g.groupName!),
                        value: g.groupName,
                      ))
                  .toList(),
              onChanged: (v) async {
                setState(() {
                  dropdownValue1 = v;
                  dropdownId1 = groupList
                      .firstWhere((g) => g.groupName == v)
                      .groupId;
                  loading = true;
                  dropdownValue2 = null;
                  dropdownId2 = null;
                  technicianDetails = null;
                });
                final resp = await _fetchExecutor;
                setState(() {
                  executorList = resp.wostatusList?.toList() ?? [];
                  loading = false;
                });
              },
            ),
    );
  }

  Widget _rowExecutor() {
    return _row(
      icon: Icons.person,
      label: "Executor",
      child: widget.viewer
          ? Text(dropdownValue2 ?? "-", style: _valueStyle)
          : SizedBox(
              width: 200,
              child: TypeAheadFormField<WorkOrderStatus>(
                getImmediateSuggestions: true,
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _controller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    hintText: "Select Executor",
                  ),
                ),
                suggestionsCallback: (_) => Future.value(executorList),
                itemBuilder: (_, s) => ListTile(title: Text(s.userName!)),
                onSuggestionSelected: (s) async {
                  setState(() {
                    _controller.text = s.userName!;
                    dropdownValue2 = s.userName;
                    dropdownId2 = s.userId;
                    loading = true;
                    technicianDetails = null;
                  });
                  final resp = await _fetchTechnician;
                  setState(() {
                    technicianDetails = resp.technicianDetails;
                    loading = false;
                  });
                },
              ),
            ),
    );
  }

  Widget _rowSeverity() {
    return _row(
      icon: Icons.report_problem,
      label: "Severity",
      child: widget.viewer
          ? Text(dropdownValue3 ?? "-", style: _valueStyle)
          : DropdownButton<String>(
              value: dropdownValue3,
              hint: Text("Select Severity"),
              items: severityList
                  .map((s) => DropdownMenuItem(
                        child: Text(s.severityName!),
                        value: s.severityName,
                      ))
                  .toList(),
              onChanged: (v) {
                setState(() {
                  dropdownValue3 = v;
                  dropdownId3 = severityList
                      .firstWhere((s) => s.severityName == v)
                      .severityId;
                });
              },
            ),
    );
  }

  Widget _rowCategory() {
    final list = dropdownValue1 == "Internal"
        ? _internalCategory
        : _externalCategory;
    return _row(
      icon: Icons.category,
      label: "Category",
      child: widget.viewer
          ? Text(dropdownValue4 ?? "-", style: _valueStyle)
          : DropdownButton<String>(
              value: dropdownValue4,
              hint: Text("Select Category"),
              items: list
                  .map((c) => DropdownMenuItem(
                        child: Text(c.groupName!),
                        value: c.groupName,
                      ))
                  .toList(),
              onChanged: (v) {
                setState(() {
                  dropdownValue4 = v;
                  dropdownId4 =
                      list.firstWhere((c) => c.groupName == v).groupId;
                });
              },
            ),
    );
  }

  Widget _rowAssistCount() {
    return _row(
      icon: Icons.people,
      label: "Max Assistants",
      child: widget.viewer
          ? Text(dropdownAssist ?? "0", style: _valueStyle)
          : DropdownButton<String>(
              value: dropdownAssist,
              hint: Text("0"),
              items: ["0","1","2","3","4","5"]
                  .map((e) => DropdownMenuItem(child: Text(e), value: e))
                  .toList(),
              onChanged: (v) => setState(() => dropdownAssist = v),
            ),
    );
  }

  Widget _saveButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 48),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: AppColors.primary,
      ),
      child: Text("Save", style: TextStyle(fontSize: 16, color: Colors.white)),
      onPressed: _onSavePressed,
    );
  }

  Widget _detailsSection() {
    final d = technicianDetails!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text("Executor Details",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        _detailRow("Name", d.name),
        _detailRow("Phone No.", d.phoneNo),
        _detailRow("Email", d.email),
        _detailRow("Group", d.group),
        _detailRow("Current Tasks", d.totalCurrentTask.toString()),
      ],
    );
  }

  Widget _tasksTable() {
    final rows = <TableRow>[];
    rows.add(TableRow(
      decoration: BoxDecoration(color: Colors.grey[200]),
      children: [
        _tc("No."), _tc("Task No."), _tc("Date Received"),
      ],
    ));
    for (var i = 0; i < technicianDetails!.currentTask.length; i++) {
      final t = technicianDetails!.currentTask[i];
      rows.add(TableRow(children: [
        _tc("${i+1}"),
        _tc(t.woTaskNo),
        _tc(t.dateReceived),
      ]));
    }
    return Table(
      border: TableBorder.all(color: AppColors.primary),
      columnWidths: {0: FractionColumnWidth(.15), 2: FractionColumnWidth(.35)},
      children: rows,
    );
  }

  Widget _detailsCard() {
  final d = technicianDetails!;
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 3,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Executor Details",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              )),
          const SizedBox(height: 12),
          _detailTile("Name", d.name),
          _detailTile("Phone No.", d.phoneNo),
          _detailTile("Email", d.email),
          _detailTile("Group", d.group),
          _detailTile("Current Tasks", d.totalCurrentTask.toString()),
        ],
      ),
    ),
  );
}

Widget _detailTile(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            "$label:",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ),
      ],
    ),
  );
}

/// A card‑wrapped DataTable for current tasks
Widget _tasksCard() {
  final tasks = technicianDetails!.currentTask.toList();
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 3,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Current Tasks",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              )),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(AppColors.primary),
              columnSpacing: 10,
              columns: [
                DataColumn(
                    label: Text("No.", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                DataColumn(
                    label:
                        Text("Task No.", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                DataColumn(
                    label: Text("Date Received",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
              ],
              rows: List<DataRow>.generate(tasks.length, (i) {
                final t = tasks[i];
                return DataRow(cells: [
                  DataCell(Text('${i + 1}')),
                  DataCell(Text(t.woTaskNo)),
                  DataCell(Text(t.dateReceived)),
                ]);
              }),
            ),
          ),
        ],
      ),
    ),
  );
}

  // ---- util widgets ----

  TextStyle get _valueStyle => TextStyle(fontSize: 16);

  Widget _row({
    required IconData icon,
    required String label,
    required Widget child,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: colorTheme2),
            SizedBox(width: 16),
            Expanded(
                child: Text(label,
                    style: TextStyle(fontWeight: FontWeight.w600))),
            child,
            if (onTap != null) ...[
              SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Text("$label:",
                  style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(flex: 3, child: Text(value)),
        ],
      ),
    );
  }

  TableCell _tc(String txt) => TableCell(
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Text(txt, textAlign: TextAlign.center),
        ),
      );

  // ---- save ----

  void _onSavePressed() async {
    setState(() => loading = true);
    final provider = Provider(
      fetchURL: "/wo_v2/save_assigned_technician/${widget.id}",
      taskID: widget.id,
    )..context = context;

    final body = {
      "action": "save_assigned_technician",
      "woTaskId": widget.id,
      "groupId": dropdownId1,
      "userId": dropdownId2,
      "severity": dropdownId3,
      "woTaskCategory": dropdownId4,
      "woTaskMaxAssistant": dropdownAssist ?? "0",
    };

    try {
      await provider.post(url: provider.fetchURL, body: body);
      Toast.show("Assignation Saved");
      Navigator.pop(context);
    } catch (e) {
      Toast.show(e.toString());
    } finally {
      setState(() => loading = false);
    }
  }
}

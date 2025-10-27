import 'dart:async';

import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:GEMS/model/workorder.dart';
import 'package:GEMS/model/responseValue.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:GEMS/controller/WorkOrder/pending_sync.dart';
import 'package:GEMS/controller/WorkOrder/widgets/pending_sync_banner.dart';
import 'package:GEMS/data/repository/work_order_detail_repository.dart';

class ComplaintAssign extends StatefulWidget {
  final String id;
  final bool viewer;
  final PendingSyncController? pendingSync;
  final Stream<WorkOrderSnapshotData?>? snapshotStream;
  final WorkOrderSnapshotData? initialSnapshot;

  const ComplaintAssign({
    super.key,
    required this.id,
    required this.viewer,
    this.pendingSync,
    this.snapshotStream,
    this.initialSnapshot,
  });

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
  final List<WorkOrderStatus> _internalCategory = [];
  final List<WorkOrderStatus> _externalCategory = [];
  final List<WorkOrderStatus> _publicCategory = [];

  String? dropdownValue1, dropdownValue2, dropdownValue3, dropdownValue4, dropdownAssist;
  String? dropdownId1, dropdownId2, dropdownId3, dropdownId4;

  TechnicianDetails? technicianDetails;
  final TextEditingController _controller = TextEditingController();
  StreamSubscription<WorkOrderSnapshotData?>? _snapshotSub;
  bool _hasUserEdited = false;

  @override
  void initState() {
    super.initState();
    ToastContext().init(context);
    _prepareCategories();
    _applySnapshot(widget.initialSnapshot);
    _listenToSnapshots();
    _loadInitial();
  }

  void _prepareCategories() {
    // internal complaint
    final m1 = {
      "Breakdown": "4",
      "Defect": "5",
      "Request": "3",
      "Self Finding": "2"
    };

    final m2 = {
      "Breakdown": "4",
      "Complaint": "1",
      "Defect": "5",
      "Request": "3"
    };

    final m3 = {
      "Breakdown": "4",
      "Complaint": "1",
      "Defect": "5"
    };

    m1.forEach((k,v) => _internalCategory.add(WorkOrderStatus((b) => b
      ..groupName = k..groupId = v)));
    m2.forEach((k,v) => _externalCategory.add(WorkOrderStatus((b) => b
      ..groupName = k..groupId = v)));
    m3.forEach((k,v) => _publicCategory.add(WorkOrderStatus((b) => b
      ..groupName = k..groupId = v)));
  }

  bool get isInternal => typeCategory == "Internal";
  bool get isExternal => typeCategory == "External";

  List<WorkOrderStatus> getDropdown4() {
    if (isExternal) {
      return _externalCategory;
    } else if (isInternal) {
      return _internalCategory;
    } else {
      return _publicCategory;
    }
  }

  void _listenToSnapshots() {
    final stream = widget.snapshotStream;
    if (stream == null) return;
    _snapshotSub = stream.listen((snapshot) {
      if (!mounted) return;
      _applySnapshot(snapshot);
    });
  }

  void _applySnapshot(WorkOrderSnapshotData? snapshot) {
    if (snapshot == null) return;

    final assignment = snapshot.assignment;
    final hasGroups = snapshot.groupOptions.isNotEmpty;
    final hasSeverity = snapshot.severityOptions.isNotEmpty;
    final hasExecutors = snapshot.executorOptions.isNotEmpty;
    final hasDetails = snapshot.technicianDetails != null;
    final shouldHydrateAssignment = assignment != null && !_hasUserEdited;

    if (!hasGroups &&
        !hasSeverity &&
        !hasExecutors &&
        !hasDetails &&
        !shouldHydrateAssignment) {
      return;
    }

    setState(() {
      if (hasGroups) {
        groupList = snapshot.groupOptions;
      }
      if (hasSeverity) {
        severityList = snapshot.severityOptions;
      }
      if (hasExecutors) {
        executorList = snapshot.executorOptions;
      }
      if (hasDetails) {
        technicianDetails = snapshot.technicianDetails;
      }
      if (shouldHydrateAssignment) {
        _hydrateFromAssignmentInternal(assignment);
      }
      loading = false;
    });
  }

  void _hydrateFromAssignmentInternal(TechnicianAssign assignment) {
    typeCategory = assignment.userCategory;
    assistUserId = assignment.assistUserId.toList(growable: false);
    dropdownAssist = assignment.woTaskMaxAssistant;

    dropdownId1 = assignment.groupId;
    dropdownValue1 = _safeFetchStatus(groupList, dropdownId1 ?? '')?.groupName;

    dropdownId2 = assignment.userId;
    String? executorName =
        _safeFetchStatus(executorList, dropdownId2 ?? '')?.userName;
    if ((dropdownId2 ?? '').isNotEmpty && executorName == null) {
      executorName = assignment.userId;
      executorList = List<WorkOrderStatus>.from(executorList)
        ..add(
          WorkOrderStatus((b) => b
            ..userId = dropdownId2
            ..userName = executorName),
        );
    }
    dropdownValue2 = executorName;

    dropdownId3 = assignment.severity;
    dropdownValue3 =
        _safeFetchSeverity(severityList, dropdownId3 ?? '')?.severityName;

    dropdownId4 = assignment.woTaskCategory;
    dropdownValue4 = _findCategoryName(dropdownId4, typeCategory);

    _controller.text = dropdownValue2 ?? assignment.userId;
  }

  String? _findCategoryName(String? categoryId, String categoryType) {
    if (categoryId == null || categoryId.isEmpty) {
      return null;
    }
    final source = categoryType == 'Internal'
        ? _internalCategory
        : categoryType == 'External'
            ? _externalCategory
            : _publicCategory;
    try {
      return source.firstWhere((item) => item.groupId == categoryId).groupName;
    } catch (_) {
      return null;
    }
  }

  void _markUserEdited() {
    if (!_hasUserEdited) {
      _hasUserEdited = true;
    }
  }


  Future<void> _loadInitial() async {
    setState(() => loading = true);
    
    try {
      // 1) Load Severity
      final severityResp = await Provider(
        fetchURL: "/api/m_wo.php?type=wo_severity_list&woTaskId=",
        taskID: widget.id,
      ).fetch();
      severityList = severityResp.wostatusList?.toList() ?? [];

      // 2) Load Groups
      final groupResp = await Provider(
        fetchURL: "/api/m_wo.php?type=wo_group_list&woTaskId=",
        taskID: widget.id,
      ).fetch();
      groupList = groupResp.wostatusList?.toList() ?? [];

      // 3) Load Existing Assignment
      final assignResp = await Provider(
        fetchURL: "/wo_v2/assign_and_severity/",
        taskID: widget.id,
      ).fetch();
      
      if (assignResp.technicianAssign != null) {
        final a = assignResp.technicianAssign!;
  typeCategory = a.userCategory;
        assistUserId = a.assistUserId.toList();
        dropdownAssist = a.woTaskMaxAssistant;
        dropdownId1 = a.groupId;
        
        if (dropdownId1 != null) {
          dropdownValue1 = _safeFetchStatus(groupList, dropdownId1!)?.groupName;
          await _loadExecutorsForGroup(dropdownId1!);
          
          dropdownId2 = a.userId;
          if (dropdownId2 != null) {
            final sel = _safeFetchStatus(executorList, dropdownId2!);
            if (sel != null) {
              dropdownValue2 = sel.userName;
              _controller.text = dropdownValue2!;
              await _loadTechnicianDetails(dropdownId1!, dropdownId2!);
            }
          }
        }
        
        dropdownId3 = a.severity;
        if (dropdownId3 != null) {
          dropdownValue3 = _safeFetchSeverity(severityList, dropdownId3!)?.severityName;
        }
        
        dropdownId4 = a.woTaskCategory;
        if (dropdownId4 != null) {
          dropdownValue4 = _safeFetchStatus(
            typeCategory == "Internal" ? _internalCategory : _externalCategory, 
            dropdownId4!
          )?.groupName;
        }
      }
    } catch (e, st) {
      debugPrint("❌ Initial load error: $e\n$st");
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _loadExecutorsForGroup(String groupId) async {
    if (groupId.isEmpty) return;
    setState(() => loading = true);
    try {
      final executorResp = await Provider(
        fetchURL: "/api/m_wo.php?type=wo_technician_list&groupId=",
        taskID: groupId,
      ).fetch();
      executorList = executorResp.wostatusList?.toList() ?? [];
    } catch (e, st) {
      debugPrint("❌ Executor load error: $e\n$st");
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _loadTechnicianDetails(String groupId, String userId) async {
    setState(() => loading = true);
    try {
      final techResp = await _fetchTechnician;
      technicianDetails = techResp.technicianDetails;
    } catch (e, st) {
      debugPrint("❌ Technician load error: $e\n$st");
    } finally {
      setState(() => loading = false);
    }
  }

  Future<ResponseValue> get _fetchTechnician => Provider(
    fetchURL: "/api/m_wo.php?type=technician_details&groupId=$dropdownId1&userId=",
    taskID: dropdownId2 ?? ''
  ).fetch();

  WorkOrderStatus? _safeFetchStatus(List<WorkOrderStatus> list, String idOrName) {
    debugPrint("Fetching status with id/name: $idOrName");
    debugPrint("List: ${list.map((e) => e.toString()).toList()}");
    try {
      return list.firstWhere((w) => 
          (w.groupId != null && w.groupId == idOrName) || 
          (w.groupName != null && w.groupName == idOrName) ||
          (w.userId != null && w.userId == idOrName) ||
          (w.userName != null && w.userName == idOrName));
    } catch (e) {
      debugPrint("Could not find status with id/name: $idOrName");
      return null;
    }
  }

  WorkOrderStatus? _safeFetchSeverity(List<WorkOrderStatus> list, String id) {
    try {
      return list.firstWhere((w) => w.severityId == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final banner = widget.pendingSync != null
        ? PendingSyncIndicator(controller: widget.pendingSync!)
        : const SizedBox.shrink();
    if (loading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(),
        body: Column(
          children: [
            banner,
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading assignment data...',
                      style: GoogleFonts.poppins(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          banner,
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assign Executor',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Select the appropriate team and personnel for this task',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 24),
                  
                  _buildSection(
                    title: 'Assignment Details',
                    icon: Icons.assignment_ind_outlined,
                    child: Column(
                      children: [
                        _buildDropdownRow(
                          icon: Icons.group,
                          label: "Executor Group",
                          value: dropdownValue1,
                          items: groupList.map((g) => g.groupName ?? '').whereType<String>().toList(),
                          onChanged: widget.viewer ? null : (v) async {
                            if (v == null) return;
                            _markUserEdited();
                            setState(() {
                              dropdownValue1 = v;
                              dropdownId1 = groupList.firstWhere((g) => g.groupName == v).groupId;
                              loading = true;
                              dropdownValue2 = null;
                              dropdownId2 = null;
                              _controller.clear();
                              technicianDetails = null;
                            });
                            await _loadExecutorsForGroup(dropdownId1!);
                          },
                        ),
                        SizedBox(height: 16),
                        _buildExecutorRow(),
                        SizedBox(height: 16),
                        _buildDropdownRow(
                          icon: Icons.report_problem,
                          label: "Severity Level",
                          value: dropdownValue3,
                          items: severityList.map((s) => s.severityName ?? '').whereType<String>().toList(),
                          onChanged: widget.viewer ? null : (v) {
                            if (v == null) return;
                            _markUserEdited();
                            setState(() {
                              dropdownValue3 = v;
                              dropdownId3 = severityList.firstWhere((s) => s.severityName == v).severityId;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        _buildDropdownRow(
                          icon: Icons.category,
                          label: "Task Category",
                          value: dropdownValue4,
                          items: getDropdown4()
                              .map((c) => c.groupName ?? '')
                              .whereType<String>()
                              .toList(),
                          onChanged: widget.viewer ? null : (v) {
                            if (v == null) return;
                            _markUserEdited();
                            setState(() {
                              dropdownValue4 = v;
                              dropdownId4 = getDropdown4()
                                  .firstWhere((c) => c.groupName == v)
                                  .groupId;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        _buildDropdownRow(
                          icon: Icons.people,
                          label: "Max Assistants",
                          value: dropdownAssist,
                          items: ["0","1","2","3","4","5"],
                          onChanged: widget.viewer ? null : (v) {
                            if (v == null) return;
                            _markUserEdited();
                            setState(() => dropdownAssist = v);
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  if (!widget.viewer) ...[
                    SizedBox(height: 20),
                    _buildSaveButton(),
                  ],
                  if (technicianDetails != null) ...[
                    SizedBox(height: 20),
                    _buildTechnicianDetailsCard(),
                    SizedBox(height: 20),
                    _buildCurrentTasksCard(),
                  ],
                  SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Assign Executor',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.black87),
      actions: [
        IconButton(
          icon: Icon(Icons.help_outline, size: 22),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildDropdownRow({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?)? onChanged,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: items.contains(value) ? value : null,
            decoration: InputDecoration(
              labelText: label,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              filled: true,
              fillColor: onChanged == null ? Colors.grey[100] : Colors.white,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onChanged,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }

  Widget _buildExecutorRow() {
    return Row(
      children: [
        Icon(Icons.person, color: AppColors.primary, size: 20),
        SizedBox(width: 12),
        Expanded(
          child: widget.viewer
              ? TextFormField(
                  controller: _controller,
                  readOnly: true,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: InputDecoration(
                    labelText: "Executor",
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                )
              : DropdownButtonFormField<String>(
                  value: dropdownValue2,
                  decoration: InputDecoration(
                    labelText: "Executor",
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  items: executorList.map((WorkOrderStatus status) {
                    return DropdownMenuItem<String>(
                      value: status.userName,
                      child: Text(status.userName ?? ''),
                    );
                  }).toList(),
                  onChanged: (String? newValue) async {
                    if (newValue == null) return;
                    _markUserEdited();
                    final selected = _safeFetchStatus(executorList, newValue);
                    final resolvedUserId = selected?.userId;
                    if (resolvedUserId == null || resolvedUserId.isEmpty) {
                      setState(() => dropdownValue2 = newValue);
                      _controller.text = newValue;
                      return;
                    }
                    setState(() {
                      dropdownValue2 = newValue;
                      dropdownId2 = resolvedUserId;
                      loading = true;
                      technicianDetails = null;
                      _controller.text = newValue;
                    });
                    final resp = await _fetchTechnician;
                    setState(() {
                      technicianDetails = resp.technicianDetails;
                      loading = false;
                    });
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTechnicianDetailsCard() {
    final d = technicianDetails!;
    return _buildSection(
      title: 'Executor Details',
      icon: Icons.badge_outlined,
      child: Column(
        children: [
          _buildDetailTile(Icons.person_outline, "Name", d.name),
          _buildDetailTile(Icons.phone_outlined, "Phone No.", d.phoneNo),
          _buildDetailTile(Icons.email_outlined, "Email", d.email),
          _buildDetailTile(Icons.group_outlined, "Group", d.group),
          _buildDetailTile(Icons.task_outlined, "Current Tasks", 
              d.totalCurrentTask.toString()),
        ],
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 14),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTasksCard() {
    final tasks = technicianDetails!.currentTask.toList();
    return _buildSection(
      title: 'Current Tasks',
      icon: Icons.list_alt_outlined,
      child: Column(
        children: [
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No current tasks assigned',
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              ),
            )
          else
            ...tasks.map((task) => _buildTaskItem(task)),
        ],
      ),
    );
  }

  Widget _buildTaskItem(TechnicianTask task) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.task_outlined, 
                size: 18, color: AppColors.primary),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.woTaskNo,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Received: ${task.dateReceived}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _snapshotSub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _onSavePressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Text(
            'SAVE ASSIGNMENT',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _onSavePressed() async {
    // Validate required fields
    if (dropdownId1 == null || dropdownId2 == null || dropdownId3 == null || dropdownId4 == null) {
      Toast.show('Please complete all required fields');
      return;
    }

    debugPrint("Saving assignment with: "
        "Group: $dropdownId1, "
        "Executor: $dropdownId2, "
        "Severity: $dropdownId3, "
        "Category: $dropdownId4, "
        "Assistants: $dropdownAssist");

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
      Toast.show("Assignment Saved");
      Navigator.pop(context);
    } catch (e) {
      Toast.show(e.toString());
    } finally {
      setState(() => loading = false);
    }
  }
}
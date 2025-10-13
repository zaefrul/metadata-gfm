import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

import 'package:GEMS/controller/WorkOrder/pending_sync.dart';
import 'package:GEMS/controller/WorkOrder/widgets/pending_sync_banner.dart';
import 'package:GEMS/model/responseValue.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/utils/reference.dart';

class AddTechnicianCheckList extends StatefulWidget {
  final String id;
  final bool viewer;
  final PendingSyncController? pendingSync;

  const AddTechnicianCheckList({
    super.key,
    required this.id,
    required this.viewer,
    this.pendingSync,
  });

  @override
  _AddTechnicianCheckListState createState() => _AddTechnicianCheckListState();
}

class _AddTechnicianCheckListState extends State<AddTechnicianCheckList> {
  final TextEditingController _searchCtr = TextEditingController();
  final List<_Model> _allTechs = [];
  final List<_Model> _filteredTechs = [];
  final List<_Model> _selectedTechs = [];
  late final _Controller _ctrl;
  int _maxAssistants = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    ToastContext().init(context);

    _ctrl = _Controller(widget.id);

    // load data
    _loadData();

    // search listener
    _searchCtr.addListener(_applySearch);
  }

  Future<void> _loadData() async {
    try {
      // Load all data in parallel
      final results = await Future.wait([
        _ctrl.list,
        _ctrl.selected,
        Provider(
          fetchURL: "/wo_v2/assign_and_severity/",
          taskID: widget.id,
        ).fetch(),
      ]);

      // Extract results from the list
      final listResult = results[0] as List<_Model>;
      final selectedResult = results[1] as List<_Model>;
      final maxResult = results[2] as ResponseValue;

      setState(() {
        _allTechs.addAll(listResult);
        _filteredTechs.addAll(listResult);
        _selectedTechs.addAll(selectedResult);
        _maxAssistants = int.parse(maxResult.technicianAssign?.woTaskMaxAssistant ?? "0");
        _isLoading = false;
      });
    } catch (e) {
      Toast.show("Failed to load data", duration: Toast.lengthLong);
      setState(() => _isLoading = false);
    }
  }

  void _applySearch() {
    final q = _searchCtr.text.toLowerCase();
    setState(() {
      _filteredTechs
        ..clear()
        ..addAll(_allTechs.where((t) => t.userFullName.toLowerCase().contains(q)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray100,
      appBar: AppBar(
        title: Text(
          "Add Technician Assistant",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.bgAppBar,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primary),
        centerTitle: false,
      ),
      body: Column(
        children: [
          if (widget.pendingSync != null)
            PendingSyncIndicator(controller: widget.pendingSync!),
          _buildSearchCard(),
          const SizedBox(height: 8),
          _buildSelectionInfo(),
          const SizedBox(height: 8),
          Expanded(child: _buildContent()),
          if (!widget.viewer) _buildDoneButton(),
        ],
      ),
    );
  }

  Widget _buildSearchCard() {
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.search, color: AppColors.primary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchCtr,
                decoration: InputDecoration(
                  hintText: "Search technicians...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: AppColors.textHint),
                ),
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.info, size: 18),
          const SizedBox(width: 8),
          Text(
            "Selected ${_selectedTechs.length}/$_maxAssistants",
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredTechs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_off, size: 48, color: AppColors.gray400),
            const SizedBox(height: 16),
            Text(
              "No technicians found",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            if (_searchCtr.text.isNotEmpty)
              TextButton(
                onPressed: () {
                  _searchCtr.clear();
                  _applySearch();
                },
                child: Text(
                  "Clear search",
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _filteredTechs.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        indent: 72,
        color: AppColors.gray200,
      ),
      itemBuilder: (_, i) {
        final tech = _filteredTechs[i];
        final isSel = _selectedTechs.contains(tech);

        return _buildTechItem(tech, isSel);
      },
    );
  }

  Widget _buildTechItem(_Model tech, bool isSelected) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primaryLight : AppColors.gray200,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: widget.viewer ? null : () => _onToggle(tech, !isSelected),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tech.userFullName,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isSelected)
                      Text(
                        "Selected",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.success,
                        ),
                      ),
                  ],
                ),
              ),
              if (!widget.viewer)
                Checkbox(
                  value: isSelected,
                  onChanged: (v) => _onToggle(tech, v!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.primary;
                    }
                    return AppColors.gray300;
                  }),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onToggle(_Model tech, bool select) async {
    // First check if we're already at max capacity
    if (select && _selectedTechs.length >= _maxAssistants) {
      Toast.show(
        "Maximum of $_maxAssistants technicians allowed",
        duration: Toast.lengthLong,
        gravity: Toast.bottom,
      );
      return;
    }

    // Create local copies for state management
    final wasSelected = _selectedTechs.any((t) => t.userId == tech.userId);
    final previousSelection = List<_Model>.from(_selectedTechs);

    try {
      if (select && !wasSelected) {
        // Add case
        await _ctrl.add(tech);
      } else if (!select && wasSelected) {
        // Remove case - find the complete record
        final completeTech = await _findCompleteTechRecord(tech);
        if (completeTech.assistantId.isNotEmpty) {
          await _ctrl.delete(completeTech);
        }
      }

      // Refresh from server after any modification
      final freshSelection = await _ctrl.selected;
      setState(() {
        _selectedTechs
          ..clear()
          ..addAll(freshSelection);
      });
    } catch (e) {
      // On failure, revert to previous selection
      setState(() {
        _selectedTechs
          ..clear()
          ..addAll(previousSelection);
      });
      Toast.show(
        select ? "Failed to add technician" : "Failed to remove technician",
        duration: Toast.lengthLong,
      );
    }
  }

  Future<_Model> _findCompleteTechRecord(_Model tech) async {
    try {
      // First check in our current selection
      final inSelection = _selectedTechs.firstWhere(
        (t) => t.userId == tech.userId,
        orElse: () => _Model("", "", ""),
      );
      if (inSelection.assistantId.isNotEmpty) return inSelection;

      // If not found, check the full list from server
      final completeList = await _ctrl.selected;
      return completeList.firstWhere(
        (t) => t.userId == tech.userId,
        orElse: () => tech,
      );
    } catch (e) {
      return tech;
    }
  }

  Widget _buildDoneButton() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          onPressed: () async {
            try {
              await _ctrl.submit();
              if (mounted) {
                Navigator.of(context).pop(_selectedTechs);
              }
            } catch (e) {
              Toast.show("Failed to submit changes");
            }
          },
          child: const Text("Done"),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchCtr.dispose();
    super.dispose();
  }
}


class _Controller {
  final String id;
  _Controller(this.id);

  Future<List<_Model>> get list async {
    final url = "/wo_task_assist/dropdown_list/";
    final Provider provider = Provider(fetchURL: url, taskID: id);

    try {
      final result = await provider.getJson(url: url);
      if (result.length > 0) {
        return result.map<_Model>((v) => _Model.fromJson(v)).toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<_Model>> get selected async {
    final url = "/wo_task_assist/assistant_list/";
    final Provider provider = Provider(fetchURL: url, taskID: id);
    try {
      final result = await provider.getJson(url: url);
      if (result.length > 0) {
        return result.map<_Model>((v) => _Model.fromJson(v)).toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> add(_Model model) async {
    final url = "/wo_task_assist";
    final Provider provider = Provider(fetchURL: url);

    final body = {
      "woTaskId": id,
      "assistant": model.userId,
    };

    try {
      final _ = await provider.post(url: url, body: body);
      return;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> delete(_Model model) async {
    final url = "/wo_task_assist/${model.assistantId}";
    final Provider provider = Provider(fetchURL: url, taskID: id);
    try {
      final _ = await provider.delete(url: url);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> submit() async {
    final url = "/wo_v2/save_assistant_list/$id";
    final Provider provider = Provider(fetchURL: url);
    try {
      final _ = await provider.post(url: url);

      return;
    } catch (e) {
      rethrow;
    }
  }

  Future<ResponseValue> detail(_Model model) {
    Provider provider = Provider(
        fetchURL:
            "/api/m_wo.php?type=technician_details&groupId=${model.assistantId}&userId=",
        taskID: id);
    return provider.fetch();
  }
}

class _Model {
  final String assistantId;
  final String userId;
  final String userFullName;

  _Model(this.assistantId, this.userId, this.userFullName);

  factory _Model.fromJson(Map<String, dynamic> json) => _Model(
      json["woTaskAssistId"] ?? "", 
      json["userId"] ?? "", 
      json["userFullName"] ?? ""
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _Model &&
           other.userId == userId;
  }

  @override
  String toString() {
    return 'Model(assistantId: $assistantId, userId: $userId, userFullName: $userFullName)';
  }

  @override
  int get hashCode => assistantId.hashCode ^ userId.hashCode;
}

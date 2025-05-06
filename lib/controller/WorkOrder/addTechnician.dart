import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/constant.dart';
import 'package:gfm_gems/model/responseValue.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:toast/toast.dart';
import '../../../main.dart';

import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';
import '../../../main.dart';

class AddTechnicianCheckList extends StatefulWidget {
  final String id;
  final bool viewer;

  const AddTechnicianCheckList({
    Key? key,
    required this.id,
    required this.viewer,
  }) : super(key: key);

  @override
  _AddTechnicianCheckListState createState() =>
      _AddTechnicianCheckListState();
}

class _AddTechnicianCheckListState extends State<AddTechnicianCheckList> {
  final TextEditingController _searchCtr = TextEditingController();
  final List<_Model> _allTechs = [];
  final List<_Model> _filteredTechs = [];
  final List<_Model> _selectedTechs = [];
  late final _Controller _ctrl;
  int _maxAssistants = 0;

  @override
  void initState() {
    super.initState();
    ToastContext().init(context);

    _ctrl = _Controller(widget.id);

    // load full list and selection
    _ctrl.list.then((v) {
      setState(() {
        _allTechs.addAll(v);
        _filteredTechs.addAll(v);
      });
    });
    _ctrl.selected.then((v) {
      setState(() {
        _selectedTechs.addAll(v);
      });
    });
    // load max assistants
    Provider(
      fetchURL: "/wo_v2/assign_and_severity/",
      taskID: widget.id,
    ).fetch().then((resp) {
      setState(() {
        _maxAssistants = int.parse(resp.technicianAssign?.woTaskMaxAssistant ?? "0");
      });
    });

    // search listener
    _searchCtr.addListener(_applySearch);
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
      appBar: AppBar(
        title: Text("F. Add Technician Assistant"),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: AppColors.secondary),
      ),
      body: Column(
        children: [
          _buildSearchRow(),
          const Divider(height: 1),
          Expanded(child: _buildList()),
          if (!widget.viewer) _buildDoneButton(),
        ],
      ),
    );
  }

  Widget _buildSearchRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.search, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchCtr,
              decoration: InputDecoration(
                hintText: "Search technicians…",
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      itemCount: _filteredTechs.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[200]),
      itemBuilder: (_, i) {
        final tech = _filteredTechs[i];
        final isSel = _selectedTechs.contains(tech);

        return InkWell(
          onTap: widget.viewer
              ? null
              : () => _onToggle(tech, !isSel),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.person, color: AppColors.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(tech.userFullName,
                      style: TextStyle(fontSize: 16)),
                ),
                Checkbox(
                  value: isSel,
                  onChanged: widget.viewer
                      ? null
                      : (v) => _onToggle(tech, v!),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _onToggle(_Model tech, bool select) async {
  if (select) {
    // guard max-assistant count
    if (_selectedTechs.length >= _maxAssistants) {
      Toast.show(
        "Max $_maxAssistants technician(s) allowed",
        duration: Toast.lengthLong,
        gravity: Toast.bottom,
      );
      return;
    }

    try {
      // call your add API
      await _ctrl.add(tech);

      // now re-fetch the full selected list from server
      final fresh = await _ctrl.selected;
      setState(() {
        _selectedTechs
          ..clear()
          ..addAll(fresh);
      });
    } catch (e) {
      // on failure, keep the old selection and show error
      Toast.show("Failed to add");
    }
  } else {
    // removing: if it was never on server, just drop it locally
    final stored = _selectedTechs.firstWhere(
      (t) => t.userId == tech.userId,
      orElse: () => _Model("", "", ""),
    );
    if (stored.assistantId.isEmpty) {
      setState(() => _selectedTechs.removeWhere((t) => t.userId == tech.userId));
      return;
    }

    // else, call delete API
    final ok = await _ctrl.delete(stored);
    if (ok) {
      // re-fetch after delete too
      final fresh = await _ctrl.selected;
      setState(() {
        _selectedTechs
          ..clear()
          ..addAll(fresh);
      });
    } else {
      Toast.show("Failed to remove");
    }
  }
}

  Widget _buildDoneButton() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text("Done", style: TextStyle(color: Colors.white)),
            onPressed: () async {
              await _ctrl.submit();
              Navigator.of(context).pop(_selectedTechs);
            },
          ),
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
    final Provider _provider = Provider(fetchURL: url, taskID: id);

    try {
      final result = await _provider.getJson(url: url);
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
    final Provider _provider = Provider(fetchURL: url, taskID: id);
    try {
      final result = await _provider.getJson(url: url);
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
    final Provider _provider = Provider(fetchURL: url);

    final body = {
      "woTaskId": id,
      "assistant": model.userId,
    };

    try {
      final _ = await _provider.post(url: url, body: body);
      return;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> delete(_Model model) async {
    final url = "/wo_task_assist/${model.assistantId}";
    final Provider _provider = Provider(fetchURL: url, taskID: id);
    try {
      final _ = await _provider.delete(url: url);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> submit() async {
    final url = "/wo_v2/save_assistant_list/$id";
    final Provider _provider = Provider(fetchURL: url);
    try {
      final _ = await _provider.post(url: url);

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

import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/constant.dart';
import 'package:gfm_gems/model/responseValue.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:toast/toast.dart';

class AddTechnicianCheckList extends StatefulWidget {
  final String id;
  final bool viewer;

  AddTechnicianCheckList({this.id, this.viewer});

  @override
  _AddTechnicianCheckListState createState() =>
      _AddTechnicianCheckListState(this.id);
}

class _AddTechnicianCheckListState extends State<AddTechnicianCheckList> {
  final TextEditingController _controller = TextEditingController();

  final List<_Model> listTechnician = [];
  final List<_Model> listTechnicianSearch = [];
  final List<_Model> listTechnicianSelected = [];
  final _Controller _provider;
  int max;

  _AddTechnicianCheckListState(String id) : _provider = _Controller(id) {
    _provider.list.then(
      (value) => setState(() {
        listTechnician.addAll(value);
        listTechnicianSearch.addAll(value);
      }),
    );

    _provider.selected.then(
      (value) => setState(() => listTechnicianSelected.addAll(value)),
    );

    _controller.addListener(() {
      setState(() {
        listTechnicianSearch.clear();
        if (_controller.text.length > 0)
          listTechnicianSearch.addAll(
            listTechnician.where(
              (element) => element.userFullName.toLowerCase().contains(
                    _controller.text.toLowerCase(),
                  ),
            ),
          );
        else
          listTechnicianSearch.addAll(listTechnician);
      });
    });

    Provider(
      fetchURL:
          "/wo_v2/assign_and_severity/", //"/api/m_wo.php?type=assign_and_severity&woTaskId=",
      taskID: id,
    ).fetch().then((onValue) {
      var data = onValue.technicianAssign;
      max = int.parse(data.woTaskMaxAssistant);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("Add Technician Assistant"),
        backgroundColor: Colors.white,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Search",
                icon: Icon(
                  Icons.search,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: listTechnicianSearch
                    .map(
                      (f) => new CheckboxListTile(
                        title: new Text(f.userFullName),
                        value: listTechnicianSelected.contains(f),
                        onChanged: (value) {
                          if (widget.viewer) return;
                          // if (value) showsheet();
                          // print(value);
                          if (listTechnicianSelected.length == max) {
                            Toast.show("Assistant allowed $max!", duration: 2);
                          }
                          if (value && listTechnicianSelected.length < max) {
                            if (listTechnicianSelected.contains(f) == false) {
                              setState(() => listTechnicianSelected.add(f));
                              _provider.add(f);
                            }
                          } else
                            setState(() {
                              listTechnicianSelected
                                  .removeWhere((technician) => technician == f);
                              _provider.delete(f);
                            });
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: widget.viewer
          ? null
          : FloatingActionButton.extended(
              label: new Text("Done"),
              onPressed: () async {
                await _provider.submit();
                Navigator.of(context).pop(listTechnicianSelected);
              },
            ),
    );
  }

  void showsheet() {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return ListView(children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
              child: Text(
                "Task In Hand",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            _getTable(),
          ]);
        });
  }

  Widget _getTable() {
    var header = TableRow(
        children: [
          TableCell(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: Text("No.")),
            ),
          ),
          TableCell(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: Text("Task No.")),
            ),
          ),
          TableCell(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: Text("Date Received")),
            ),
          ),
        ],
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: colorTheme3),
            color: Colors.grey.withOpacity(0.3)));

    Text text(String text) => Text(
          text,
          textAlign: TextAlign.center,
        );

    var children = List.generate(6, (index) {
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
                child: text("WRDEMO20042100001"),
              ),
            ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: text("2021/07/23"),
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
}

class _Controller {
  final String id;
  _Controller(this.id);

  Future<List<_Model>> get list async {
    final url = "/wo_task_assist/dropdown_list/";
    final Provider _provider = Provider(fetchURL: url, taskID: id);

    try {
      final result = await _provider.getJson();
      if (result.length > 0) {
        return result.map<_Model>((v) => _Model.fromJson(v)).toList();
      }

      return [];
    } catch (e) {
      return e;
    }
  }

  Future<List<_Model>> get selected async {
    final url = "/wo_task_assist/assistant_list/";
    final Provider _provider = Provider(fetchURL: url, taskID: id);
    try {
      final result = await _provider.getJson();
      if (result.length > 0) {
        return result.map<_Model>((v) => _Model.fromJson(v)).toList();
      }

      return [];
    } catch (e) {
      return e;
    }
  }

  Future<void> add(_Model model) async {
    final url = "/wo_task_assist";
    final Provider _provider = Provider();

    final body = {
      "ppmTaskId": id,
      "assistant": model.assistantId,
    };

    try {
      final _ = await _provider.post(url: url, body: body);
      return;
    } catch (e) {
      return e;
    }
  }

  Future<void> delete(_Model model) async {
    final url = "/wo_task_assist/${model.assistantId}";
    final Provider _provider = Provider(fetchURL: url, taskID: id);
    try {
      final _ = await _provider.delete(url: url);

      return;
    } catch (e) {
      return e;
    }
  }

  Future<void> submit() async {
    final url = "/wo_v2/save_assistant_list/$id";
    final Provider _provider = Provider();
    try {
      final _ = await _provider.post(url: url);

      return;
    } catch (e) {
      return e;
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

  factory _Model.fromJson(Map<String, dynamic> json) =>
      _Model(json["woTaskAssistId"], json["userId"], json["userFullName"]);
}

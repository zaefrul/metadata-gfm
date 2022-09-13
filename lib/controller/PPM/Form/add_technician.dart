import 'package:flutter/material.dart';
import 'package:gfm_gems/model/responseValue.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:toast/toast.dart';

class PPMAddTechnician extends StatefulWidget {
  final String id;
  final bool verified;
  final Function refreshStatus;
  final bool disable;

  PPMAddTechnician(this.id, this.verified, this.refreshStatus, this.disable);

  @override
  PPMAddTechnicianState createState() => PPMAddTechnicianState(this.id);
}

// ignore: camel_case_types
class PPMAddTechnicianState extends State<PPMAddTechnician> {
  final TextEditingController _controller = TextEditingController();

  final List<_Model> listTechnician = [];
  final List<_Model> listTechnicianSearch = [];
  final List<_Model> listTechnicianSelected = [];
  final _Controller _provider;

  PPMAddTechnicianState(String id) : _provider = _Controller(id) {
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
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);

    return WillPopScope(
      onWillPop: () async {
        widget.refreshStatus();

        return true;
      },
      child: Scaffold(
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
                          value: checkSelected(f),
                          onChanged: (value) {
                            if (widget.disable) return;
                            // if (value) showsheet();
                            // print(value);
                            if (value) {
                              if (listTechnicianSelected.contains(f) == false) {
                                setState(() => listTechnicianSelected.add(f));
                                _provider.add(f);
                              }
                            } else
                              setState(() {
                                listTechnicianSelected.removeWhere(
                                    (technician) =>
                                        technician.userId == f.userId);
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
        floatingActionButton: widget.disable
            ? null
            : FloatingActionButton.extended(
                label: new Text("Done"),
                onPressed: () async {
                  await _provider.submit();
                  Navigator.of(context).pop(listTechnicianSelected);
                },
              ),
      ),
    );
  }

  bool checkSelected(_Model value) {
    bool exist = false;

    if (listTechnicianSelected.isEmpty) return exist;

    for (_Model model in listTechnicianSelected) {
      if (model.userId == value.userId) {
        exist = true;

        break;
      }
    }

    return exist;
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
    final url = "/ppm_task_assist/dropdown_list/";
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
    final url = "/ppm_task_assist/assistant_list/";
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
    final url = "/ppm_task_assist";
    final Provider _provider = Provider();

    final body = {
      "ppmTaskId": id,
      "assistant": model.userId,
    };

    try {
      final result = await _provider.post(url: url, body: body);
      print(result);

      Toast.show(result.toString());
      return;
    } catch (e) {
      return e;
    }
  }

  Future<void> delete(_Model model) async {
    final url = "/ppm_task_assist/${model.userId}";
    final Provider _provider = Provider(fetchURL: url, taskID: id);
    try {
      final result = await _provider.delete(url: url);

      print(result);

      Toast.show(result.toString());

      return;
    } catch (e) {
      return e;
    }
  }

  Future<void> submit() async {
    final url = "/ppm_v2/save_assistant_list/$id";
    final Provider _provider = Provider();
    try {
      final result = await _provider.post(url: url);

      Toast.show(result.toString());

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

  _Model getModel(List<_Model> list, _Model value) {
    if (list.length == 0) return null;
    final item = list.firstWhere((element) => element.userId == value.userId,
        orElse: () => null);

    return item;
  }
}

class _Model {
  final String assistantId;
  final String userId;
  final String userFullName;

  _Model(this.assistantId, this.userId, this.userFullName);

  factory _Model.fromJson(Map<String, dynamic> json) =>
      _Model(json["ppmTaskAssistId"], json["userId"], json["userFullName"]);
}

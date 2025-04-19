import 'package:flutter/material.dart';
import 'package:gfm_gems/model/responseValue.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:toast/toast.dart';

class PPMAddTechnician extends StatefulWidget {
  final String id;
  final bool verified;
  final VoidCallback refreshStatus;
  final bool disable;

  const PPMAddTechnician(
      this.id, this.verified, this.refreshStatus, this.disable,
      {Key? key})
      : super(key: key);

  @override
  PPMAddTechnicianState createState() => PPMAddTechnicianState(id);
}

class PPMAddTechnicianState extends State<PPMAddTechnician> {
  final TextEditingController _controller = TextEditingController();

  final List<_Model> listTechnician = [];
  final List<_Model> listTechnicianSearch = [];
  final List<_Model> listTechnicianSelected = [];
  final _Controller _provider;

  PPMAddTechnicianState(String id) : _provider = _Controller(id) {
    _provider.list.then((value) {
      // Use addPostFrameCallback to safely call setState after build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          listTechnician.addAll(value);
          listTechnicianSearch.addAll(value);
        });
      });
    });

    _provider.selected.then((value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          listTechnicianSelected.addAll(value);
        });
      });
    });

    _controller.addListener(() {
      setState(() {
        listTechnicianSearch.clear();
        if (_controller.text.isNotEmpty) {
          listTechnicianSearch.addAll(
            listTechnician.where((element) => element.userFullName
                .toLowerCase()
                .contains(_controller.text.toLowerCase())),
          );
        } else {
          listTechnicianSearch.addAll(listTechnician);
        }
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
          title: const Text("Add Technician Assistant"),
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              widget.refreshStatus();
              Navigator.pop(context);
            },
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: "Search",
                  icon: Icon(Icons.search),
                ),
              ),
              Expanded(
                child: ListView(
                  children: listTechnicianSearch.map((f) {
                    return CheckboxListTile(
                      title: Text(f.userFullName),
                      value: checkSelected(f),
                      onChanged: widget.disable
                          ? null
                          : (bool? value) {
                              if (value == true) {
                                if (!listTechnicianSelected.contains(f)) {
                                  setState(() {
                                    listTechnicianSelected.add(f);
                                  });
                                  _provider.add(f);
                                }
                              } else {
                                setState(() {
                                  listTechnicianSelected.removeWhere(
                                      (technician) =>
                                          technician.userId == f.userId);
                                });
                                _provider.delete(f);
                              }
                            },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: widget.disable
            ? null
            : FloatingActionButton.extended(
                label: const Text("Done"),
                onPressed: () async {
                  await _provider.submit();
                  Navigator.of(context).pop(listTechnicianSelected);
                },
              ),
      ),
    );
  }

  bool checkSelected(_Model value) {
    for (final _Model model in listTechnicianSelected) {
      if (model.userId == value.userId) {
        return true;
      }
    }
    return false;
  }

  void showsheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return ListView(
          children: [
            const Padding(
              padding:
                  EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                "Task In Hand",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            _getTable(),
          ],
        );
      },
    );
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
        color: Colors.grey.withOpacity(0.3),
      ),
    );

    Text text(String txt) => Text(
          txt,
          textAlign: TextAlign.center,
        );

    var children = List<TableRow>.generate(6, (index) {
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
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: colorTheme3),
        ),
      );
    });

    children.insert(0, header);

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Table(
        columnWidths: const {
          0: FractionColumnWidth(0.15),
          2: FractionColumnWidth(0.35),
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
      final result = await _provider.getJson(url: url);
      if (result.length > 0) {
        return result.map<_Model>((v) => _Model.fromJson(v)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<_Model>> get selected async {
    final url = "/ppm_task_assist/assistant_list/";
    final Provider _provider = Provider(fetchURL: url, taskID: id);
    try {
      final result = await _provider.getJson(url: url);
      if (result.length > 0) {
        return result.map<_Model>((v) => _Model.fromJson(v)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> add(_Model model) async {
    final url = "/ppm_task_assist";
    final Provider _provider = Provider(fetchURL: url, taskID: id);

    final body = {
      "ppmTaskId": id,
      "assistant": model.userId,
    };

    try {
      final result = await _provider.post(url: url, body: body);
      print(result);
      Toast.show(result.toString());
    } catch (e) {
      // Optionally handle error here
    }
  }

  Future<void> delete(_Model model) async {
    final url = "/ppm_task_assist/${model.userId}";
    final Provider _provider = Provider(fetchURL: url, taskID: id);
    try {
      final result = await _provider.delete(url: url);
      print(result);
      Toast.show(result.toString());
    } catch (e) {
      // Optionally handle error here
    }
  }

  Future<void> submit() async {
    final url = "/ppm_v2/save_assistant_list/$id";
    final Provider _provider = Provider(fetchURL: url, taskID: id);
    try {
      final result = await _provider.post(url: url);
      Toast.show(result.toString());
    } catch (e) {
      // Optionally handle error here
    }
  }

  Future<ResponseValue> detail(_Model model) {
    final Provider provider = Provider(
      fetchURL:
          "/api/m_wo.php?type=technician_details&groupId=${model.assistantId}&userId=",
      taskID: id,
    );
    return provider.fetch();
  }

  _Model? getModel(List<_Model> list, _Model value) {
    try {
      return list.firstWhere((element) => element.userId == value.userId);
    } catch (e) {
      return null;
    }
  }
}

class _Model {
  final String assistantId;
  final String userId;
  final String userFullName;

  _Model(this.assistantId, this.userId, this.userFullName);

  factory _Model.fromJson(Map<String, dynamic> json) => _Model(
      json["ppmTaskAssistId"], json["userId"], json["userFullName"]);
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:GEMS/main.dart';
import 'package:GEMS/model/responseValue.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:GEMS/data/repository/ppm_repository.dart';
import 'package:toast/toast.dart';

class PPMAddTechnician extends StatefulWidget {
  final String id;
  final bool verified;
  final VoidCallback refreshStatus;
  final bool disable;

  const PPMAddTechnician(
      this.id, this.verified, this.refreshStatus, this.disable,
      {super.key});

  @override
  PPMAddTechnicianState createState() => PPMAddTechnicianState(id);
}

class PPMAddTechnicianState extends State<PPMAddTechnician> {
  final TextEditingController _controller = TextEditingController();

  final List<_Model> listTechnician = [];
  final List<_Model> listTechnicianSearch = [];
  final List<_Model> listTechnicianSelected = [];
  final _Controller _provider;
  bool _isLoading = false; // Start as false to prevent initial spinner
  bool _hasConnection = true;
  String? _errorMessage;

  PPMAddTechnicianState(String id) : _provider = _Controller(id) {
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
  void initState() {
    super.initState();
    // Load data after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  /// Check if device has internet connectivity
  Future<bool> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Initialize data - check cache first, then connectivity if needed
  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
      _hasConnection = true;
      _errorMessage = null;
    });

    final repository = PPMRepository();
    
    // Check if we have cached data
    final hasCache = await repository.hasCachedTechnicians(widget.id);
    
    if (hasCache) {
      // Load from cache
      try {
        final cachedTechnicians = await repository.getTechnicians(widget.id);
        final cachedSelected = await repository.getSelectedTechnicians(widget.id);
        
        final technicians = cachedTechnicians.map((t) => _Model(
          t['assistant_id'] ?? '',
          t['user_id'],
          t['user_full_name'],
        )).toList();
        
        final selected = cachedSelected.map((t) => _Model(
          t['assistant_id'] ?? '',
          t['user_id'],
          t['user_full_name'],
        )).toList();
        
        if (mounted) {
          setState(() {
            listTechnician.addAll(technicians);
            listTechnicianSearch.addAll(technicians);
            listTechnicianSelected.addAll(selected);
            _isLoading = false;
          });
        }
        return;
      } catch (e) {
        debugPrint('Failed to load from cache: $e');
        // Continue to online loading
      }
    }

    // No cache, check connectivity
    final hasInternet = await _checkConnectivity();
    
    if (!hasInternet) {
      setState(() {
        _isLoading = false;
        _hasConnection = false;
        _errorMessage = 'This feature requires internet connection. Please enable offline mode when connected to cache technician list.';
      });
      return;
    }

    // Load data from API
    try {
      final technicians = await _provider.list;
      final selected = await _provider.selected;
      
      if (mounted) {
        setState(() {
          listTechnician.addAll(technicians);
          listTechnicianSearch.addAll(technicians);
          listTechnicianSelected.addAll(selected);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasConnection = false;
          _errorMessage = 'Failed to load technician list: ${e.toString()}';
        });
      }
    }
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
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : !_hasConnection
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        color: Colors.orange[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.cloud_off, size: 48, color: Colors.orange),
                              const SizedBox(height: 16),
                              const Text(
                                'Internet Connection Required',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _errorMessage ?? 'This feature requires an active internet connection.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _initializeData,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorTheme2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(
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
      context: navigatorKey.currentContext!,
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
    final Provider provider = Provider(fetchURL: url, taskID: id);

    try {
      final result = await provider.getJson(url: url);
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
    final Provider provider = Provider(fetchURL: url, taskID: id);
    try {
      final result = await provider.getJson(url: url);
      if (result.length > 0) {
        return result.map<_Model>((v) => _Model.fromJson(v)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> add(_Model model) async {
    final repository = PPMRepository();
    
    try {
      final result = await repository.addTechnicianAssistant(
        ppmTaskId: id,
        userId: model.userId,
      );

      if (result == PPMActionResult.success) {
        Toast.show("Technician added successfully");
      } else {
        Toast.show("Technician added. Will sync when online.");
      }
    } catch (e) {
      Toast.show("Failed to add technician: ${e.toString()}");
    }
  }

  Future<void> delete(_Model model) async {
    final repository = PPMRepository();
    
    try {
      final result = await repository.removeTechnicianAssistant(
        ppmTaskId: id,
        userId: model.userId,
      );

      if (result == PPMActionResult.success) {
        Toast.show("Technician removed successfully");
      } else {
        Toast.show("Technician removed. Will sync when online.");
      }
    } catch (e) {
      Toast.show("Failed to remove technician: ${e.toString()}");
    }
  }

  Future<void> submit() async {
    final repository = PPMRepository();

    try {
      final result = await repository.submitAssistantList(ppmTaskId: id);

      if (result == PPMActionResult.success) {
        Toast.show("Technician list submitted successfully");
      } else {
        Toast.show("Technician list saved. Will sync when online.");
      }
    } catch (e) {
      Toast.show("Failed to submit technician list: ${e.toString()}");
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

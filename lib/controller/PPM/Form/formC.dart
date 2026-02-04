import 'dart:io';

import 'package:flutter/material.dart';
import 'package:GEMS/model/form.dart';
import 'package:GEMS/model/responseValue.dart';
import 'package:GEMS/model/serializers.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:GEMS/view/dialog.dart';
import 'package:GEMS/view/field.dart';
import 'package:toast/toast.dart';
import 'package:GEMS/data/repository/ppm_repository.dart';
import 'package:GEMS/controller/PPM/pending_sync.dart';
import 'package:GEMS/controller/PPM/widgets/pending_sync_banner.dart';

class FormC extends StatefulWidget {
  final String id;
  final bool verified;
  final ValueChanged<bool> refreshStatus;
  final bool disable;

  const FormC(this.id, this.verified, this.refreshStatus, this.disable, {super.key});

  @override
  _FormCState createState() => _FormCState();
}

class _FormCState extends State<FormC> {
  late Provider provider;
  late PPMRepository _repository;
  PPMPendingSyncController? _pendingSync;
  
  bool loading = false;
  String? dropdownValue;
  List<UploadItem> items = [];
  Future<ResponseValue>? _sectionDataFuture; // Cache the future

  String? assetNo;
  String? model;
  String? capacity;
  String? pmStart;
  String? pmEnd;

  @override
  void initState() {
    super.initState();
    provider = Provider(
      taskID: widget.id,
      fetchURL: "/api/m_ppm.php?type=ppm_section_c&ppmTaskId=",
    );
    
    _repository = PPMRepository();
    _pendingSync = PPMPendingSyncController();
    _pendingSync?.setPPMTaskId(widget.id);
    
    _sectionDataFuture = _fetchSectionData(); // Initialize the future
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

  /// Fetch section data - checks offline mode first
  Future<ResponseValue> _fetchSectionData() async {
    // Check if offline mode is enabled
    final isOffline = await _repository.isOfflineModeEnabled(widget.id);
    
    if (isOffline) {
      debugPrint('FormC: Loading from offline cache');
      final sectionData = await _repository.loadSectionData(widget.id, 'C');
      
      if (sectionData != null) {
        debugPrint('FormC: Cached section data found');
        
        // The cached data is already parsed as a Map
        // Wrap it in the expected API response format
        final cachedResponse = {
          'success': true,
          'result': sectionData,
          'error': '',
          'errmsg': '',
        };
        
        try {
          // Deserialize using the same serializer as Provider.fetch()
          final responseValue = serializers.deserializeWith(
            ResponseValue.serializer, 
            cachedResponse
          );
          
          if (responseValue != null) {
            debugPrint('FormC: Successfully loaded ${responseValue.sectionCList?.length ?? 0} tasks from cache');
            return responseValue;
          }
        } catch (err) {
          debugPrint('FormC: Failed to deserialize cached data: $err');
        }
      } else {
        debugPrint('FormC: No cached data found');
      }
    }
    
    // Check connectivity before trying API
    final isOnline = await _checkConnectivity();
    if (!isOnline) {
      debugPrint('FormC: No internet connection and no cache available');
      // Return empty response to prevent hanging
      return ResponseValue((b) => b
        ..success = false
        ..error = 'NO_CONNECTION'
        ..errmsg = 'No internet connection. Please enable offline mode when connected.'
        ..result = ''
        ..sectionCList = null);
    }
    
    // Fetch from API (online mode or offline cache miss)
    return await provider.fetch();
  }

  @override
  void dispose() {
    _pendingSync?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    provider.context = context;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: colorTheme3),
        title: getTitle("C. Qualitative Task", bold: true),
      ),
      body: FutureBuilder<ResponseValue>(
        future: _sectionDataFuture,
        builder: (context, AsyncSnapshot<ResponseValue> snapshot) {
          List<Widget> children = [
            // Add pending sync banner
            if (_pendingSync != null)
              PPMPendingSyncIndicator(controller: _pendingSync!),
            ListTile(
              title: Text("Enviromental Check"),
            )
          ];

          // Show error message if no connection and no cache
          if (snapshot.hasData && snapshot.data?.error == 'NO_CONNECTION') {
            children.add(
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: Colors.orange[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(Icons.cloud_off, size: 48, color: Colors.orange),
                        SizedBox(height: 8),
                        Text(
                          'No Internet Connection',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Please enable offline mode when connected to internet to access this section offline.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          if (snapshot.hasData && items.isEmpty && snapshot.data?.sectionCList != null) {
            snapshot.data!.sectionCList?.forEach((f) {
              var updateItem = UploadItem.from(index: items.length.toString(), item: f);
              items.add(updateItem);
            });
          }

          if (items.isNotEmpty) {
            children.addAll(items.map((x) =>
                widget.disable ? getFormDisabled(x) : getForm(x)).toList());
          }

          return loading || !snapshot.hasData
              ? Stack(
                  children: <Widget>[
                    ListView(children: children),
                    Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  ],
                )
              : ListView(children: children);
        },
      ),
      floatingActionButton: widget.disable
          ? null
          : FloatingActionButton.extended(
              label: Text("Save"),
              backgroundColor: colorTheme2,
              onPressed: () async {
                if (widget.verified) {
                  print('[FormC] Save button pressed with ${items.length} tasks');
                  setState(() => loading = true);

                  try {
                    // Convert items to list of maps
                    final tasks = items.map((item) => {
                      'id': item.id,
                      'result': item.statusCheck,
                      'remark': item.remark,
                    }).toList();

                    final result = await _repository.saveQualitativeTasks(
                      ppmTaskId: widget.id,
                      tasks: tasks,
                    );

                    if (result == PPMActionResult.success) {
                      print('[FormC] Tasks saved successfully');
                      Toast.show(
                        "Tasks saved successfully",
                        duration: Toast.lengthShort,
                        gravity: Toast.bottom,
                      );
                      
                      // Reload the section data to reflect changes
                      setState(() {
                        items.clear();
                        _sectionDataFuture = _fetchSectionData();
                      });
                    } else {
                      print('[FormC] Tasks queued for offline sync');
                      Toast.show(
                        "Tasks saved. Will sync when online.",
                        duration: Toast.lengthLong,
                        gravity: Toast.bottom,
                      );
                      
                      // Refresh pending count immediately so banner shows
                      await _pendingSync?.refreshPendingCount();
                      
                      // In offline mode, we need to reload to show the updated cache
                      setState(() {
                        items.clear();
                        _sectionDataFuture = _fetchSectionData();
                      });
                    }

                    widget.refreshStatus(true);
                  } catch (err) {
                    print('[FormC] Error saving tasks: $err');
                    alert(err.toString());
                  } finally {
                    setState(() => loading = false);
                  }
                } else {
                  Toast.show("Please verified this task.");
                }
              },
            ),
    );
  }

  Widget getTitle(String text, {bool bold = false}) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          color: colorTheme3,
        ),
      ),
    );
  }

  ListTile getForm(UploadItem item) {
    print(item);
    return ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          getTitle("${item.number}. ${item.desc}"),
          filter(item),
          field(
            "Remark",
            (text) => item.remark = text,
            horizontal: 0.0,
            value: item.remark,
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  ListTile getFormDisabled(UploadItem item) {
    return ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          getTitle("${item.number}. ${item.desc}"),
          field("Status", (_) {},
              value: item.statusCheck == "N/A" ? "N/A" : item.result,
              horizontal: 0.0,
              enable: false),
          field("Remark", (text) => item.remark = text,
              horizontal: 0.0, value: item.remark, enable: false),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  DropdownButton<String> filter(UploadItem item) {
    return DropdownButton<String>(
      hint: Text("Status"),
      isExpanded: true,
      style: TextStyle(fontFamily: "Avenir", color: colorTheme3),
      value: item.dropDownValue,
      onChanged: (String? newValue) {
        setState(() => item.result = newValue ?? "");
      },
      items: [
        DropdownMenuItem(value: "Pass", child: Text("Pass")),
        DropdownMenuItem(value: "Fail", child: Text("Fail")),
        DropdownMenuItem(value: "N/A", child: Text("N/A")),
      ],
    );
  }

  void alert(String txt) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        description: txt,
        buttonText: "Okay",
        image: Image.asset("assets/icon_trans.png", height: 40),
      ),
    );
  }
}

class UploadItem {
  final String index;
  final String id;
  final String number;
  final String desc;
  String result;
  String remark;

  UploadItem({
    required this.index,
    required this.id,
    required this.number,
    required this.desc,
    this.result = "",
    this.remark = "",
  });

  factory UploadItem.from({required String index, required FormCItem item}) {
    return UploadItem(
      index: index,
      id: item.ppmTaskQualId,
      number: item.ppmTaskQualNumb,
      desc: item.ppmTaskQualDesc,
      result: item.ppmTaskQualResult,
      remark: item.ppmTaskQualRemark,
    );
  }

  String? get dropDownValue {
    switch (result) {
      case "Pass":
        return "Pass";
      case "Fail":
        return "Fail";
      case "N/A":
        return "N/A";
      default:
        return null;
    }
  }

  String get statusCheck {
    if (result == "Pass") {
      return "1";
    } else if (result == "Fail")
      return "0";
    else if (result == "N/A")
      return "2";
    else
      return "";
  }

  Map<String, dynamic> get body => {
        "ppmTaskQual[$index][id]": id,
        "ppmTaskQual[$index][result]": statusCheck,
        "ppmTaskQual[$index][remark]": remark,
      };
}

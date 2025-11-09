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

class FormD extends StatefulWidget {
  final String id;
  final bool verified;
  final VoidCallback refreshStatus;
  final bool disable;

  const FormD(this.id, this.verified, this.refreshStatus, this.disable, {super.key});

  @override
  _FormDState createState() => _FormDState();
}

class _FormDState extends State<FormD> {
  late Provider provider;
  late PPMRepository _repository;
  PPMPendingSyncController? _pendingSync;
  
  bool loading = false;
  List<UploadItem> items = [];
  Future<ResponseValue>? _sectionDataFuture; // Cache the future

  @override
  void initState() {
    super.initState();
    provider = Provider(
      taskID: widget.id,
      fetchURL: "/api/m_ppm.php?type=ppm_section_d&ppmTaskId=",
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
      debugPrint('FormD: Loading from offline cache');
      final sectionData = await _repository.loadSectionData(widget.id, 'D');
      
      if (sectionData != null) {
        debugPrint('FormD: Cached section data found');
        
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
            debugPrint('FormD: Successfully loaded ${responseValue.sectionDList?.length ?? 0} tasks from cache');
            return responseValue;
          }
        } catch (err) {
          debugPrint('FormD: Failed to deserialize cached data: $err');
        }
      } else {
        debugPrint('FormD: No cached data found');
      }
    }
    
    // Check connectivity before trying API
    final isOnline = await _checkConnectivity();
    if (!isOnline) {
      debugPrint('FormD: No internet connection and no cache available');
      // Return empty response to prevent hanging
      return ResponseValue((b) => b
        ..success = false
        ..error = 'NO_CONNECTION'
        ..errmsg = 'No internet connection. Please enable offline mode when connected.'
        ..result = ''
        ..sectionDList = null);
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
        iconTheme: IconThemeData(
          color: colorTheme3,
        ),
        title: getTitle("D. Quantitative Task", bold: true),
      ),
      body: FutureBuilder<ResponseValue>(
        future: _sectionDataFuture,
        builder: (context, AsyncSnapshot<ResponseValue> snapshot) {
          List<Widget> children = [
            // Add pending sync banner
            if (_pendingSync != null)
              PPMPendingSyncIndicator(controller: _pendingSync!),
          ];
          
          // Show error message if no connection and no cache
          if (snapshot.hasData && snapshot.data?.error == 'NO_CONNECTION') {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: Colors.orange[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
          
          if (snapshot.error != null) {
            return Center(
              child: Text("No Task for Quantitative."),
            );
          }
          if (snapshot.hasData && items.isEmpty && snapshot.data?.sectionDList != null) {
            snapshot.data!.sectionDList?.forEach((f) {
              var updateItem = UploadItem.from(
                  index: items.length.toString(), item: f);
              items.add(updateItem);
            });
          }

          if (items.isNotEmpty) {
            children.addAll(
              items
                  .map((x) => widget.disable ? getFormDisabled(x) : getForm(x))
                  .toList()
                ..add(SizedBox(height: 60)),
            );
          }

          return !snapshot.hasData
              ? Center(child: CircularProgressIndicator())
              : (loading
                  ? Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.0),
                          child: ListView(children: children),
                        ),
                        Container(
                          color: Colors.black.withOpacity(0.5),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      padding: EdgeInsets.all(16.0),
                      child: ListView(children: children),
                    ));
        },
      ),
      floatingActionButton: widget.disable
          ? null
          : FloatingActionButton.extended(
              label: Text("Save"),
              backgroundColor: colorTheme2,
              onPressed: () async {
                if (widget.verified) {
                  print('[FormD] Save button pressed with ${items.length} tasks');
                  setState(() => loading = true);

                  try {
                    // Convert items to list of maps with all fields
                    final tasks = items.map((item) => {
                      'id': item.id,
                      'setValues': item.setValues,
                      'measuredValues': item.measuredValues,
                      'limit': item.limit,
                      'result': item.statusCheck,
                      'remark': item.remark,
                    }).toList();

                    final result = await _repository.saveQuantitativeTasks(
                      ppmTaskId: widget.id,
                      tasks: tasks,
                    );

                    if (result == PPMActionResult.success) {
                      print('[FormD] Tasks saved successfully');
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
                      print('[FormD] Tasks queued for offline sync');
                      Toast.show(
                        "Tasks saved. Will sync when online.",
                        duration: Toast.lengthLong,
                        gravity: Toast.bottom,
                      );
                      
                      // In offline mode, we need to update the cache with saved values
                      // Reload to show the saved state
                      setState(() {
                        items.clear();
                        _sectionDataFuture = _fetchSectionData();
                      });
                    }

                    widget.refreshStatus();
                  } catch (err) {
                    print('[FormD] Error saving tasks: $err');
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

  Widget getForm(UploadItem item) {
    return Container(
      padding: EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          getTitle("${item.number}. ${item.desc}"),
          Row(
            children: <Widget>[
              Flexible(
                child: field("Units", (text) {},
                    horizontal: 0.0, value: item.unit, enable: false),
              ),
              SizedBox(width: 16),
              Flexible(
                child: field("Set Values", (text) => item.setValues = text,
                    horizontal: 0.0, value: item.setValues, enable: false),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Flexible(
                child: field("Measured Values", (text) => item.measuredValues = text,
                    horizontal: 0.0, value: item.measuredValues),
              ),
              SizedBox(width: 16),
              Flexible(
                child: field("Limit/ Tolerance", (text) => item.limit = text,
                    horizontal: 0.0, value: item.limit),
              ),
            ],
          ),
          filter(item),
          field("Remarks", (text) => item.remark = text,
              horizontal: 0.0, value: item.remark, enable: item.result != "N/A"),
        ],
      ),
    );
  }

  Widget getFormDisabled(UploadItem item) {
    return Container(
      padding: EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          getTitle("${item.number}. ${item.desc}"),
          field("Units", (text) {},
              horizontal: 0.0, value: item.unit, enable: false),
          field("Set Values", (text) => item.setValues = text,
              horizontal: 0.0, value: item.setValues, enable: false),
          field("Measured Values", (text) => item.measuredValues = text,
              horizontal: 0.0, value: item.measuredValues, enable: false),
          field("Limit/ Tolerance", (text) => item.limit = text,
              horizontal: 0.0, value: item.limit, enable: false),
          field("Status", (_) {},
              horizontal: 0.0, value: item.result, enable: false),
          field("Remarks", (text) => item.remark = text,
              horizontal: 0.0, value: item.remark, enable: false),
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
        print(newValue);
        var value = items.firstWhere((test) => test.id == item.id, orElse: () => item);
        setState(() {
          value.result = newValue ?? "";
        });
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
  final String unit;
  final String number;
  final String desc;
  String setValues;
  String measuredValues;
  String limit;
  String result;
  String remark;

  UploadItem({
    required this.index,
    required this.id,
    required this.unit,
    required this.number,
    required this.desc,
    this.setValues = "",
    this.measuredValues = "",
    this.limit = "",
    this.result = "",
    this.remark = "",
  });

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

  factory UploadItem.from({required String index, required FormDItem item}) {
    return UploadItem(
      index: index,
      id: item.ppmTaskQuanId,
      unit: item.ppmTaskQuanUnit,
      number: item.ppmTaskQuanNumb,
      desc: item.ppmTaskQuanDesc,
      setValues: item.ppmTaskQuanSetValues,
      measuredValues: item.ppmTaskQuanMeasuredValues,
      limit: item.ppmTaskQuanLimit,
      result: item.ppmTaskQuanResult,
      remark: item.ppmTaskQuanRemark,
    );
  }

  String get statusCheck {
    if (result == "Pass") {
      return "1";
    } else if (result == "Fail") {
      return "0";
    } else if (result == "N/A" || result.isEmpty) {
      return "2";
    } else {
      return "N/A";
    }
  }

  Map<String, dynamic> get body => {
        "ppmTaskQuan[$index][id]": id,
        "ppmTaskQuan[$index][setValues]": setValues,
        "ppmTaskQuan[$index][measuredValues]": measuredValues,
        "ppmTaskQuan[$index][limit]": limit,
        "ppmTaskQuan[$index][result]": statusCheck,
        "ppmTaskQuan[$index][remark]": remark,
      };
}

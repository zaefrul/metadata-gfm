import 'package:flutter/material.dart';
import 'package:GEMS/model/form.dart';
import 'package:GEMS/model/responseValue.dart';
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
        future: provider.fetch(),
        builder: (context, AsyncSnapshot<ResponseValue> snapshot) {
          List<Widget> children = [
            // Add pending sync banner
            if (_pendingSync != null)
              PPMPendingSyncIndicator(controller: _pendingSync!),
          ];
          
          if (snapshot.error != null) {
            return Center(
              child: Text("No Task for Quantitative."),
            );
          }
          if (snapshot.hasData && items.isEmpty) {
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
                    // Convert items to list of maps
                    final tasks = items.map((item) => {
                      'id': item.id,
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
                    } else {
                      print('[FormD] Tasks queued for offline sync');
                      Toast.show(
                        "Tasks saved. Will sync when online.",
                        duration: Toast.lengthLong,
                        gravity: Toast.bottom,
                      );
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

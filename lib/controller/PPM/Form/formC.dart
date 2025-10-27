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
        future: provider.fetch(),
        builder: (context, AsyncSnapshot<ResponseValue> snapshot) {
          List<Widget> children = [
            // Add pending sync banner
            if (_pendingSync != null)
              PPMPendingSyncIndicator(controller: _pendingSync!),
            ListTile(
              title: Text("Enviromental Check"),
            )
          ];

          if (snapshot.hasData && items.isEmpty) {
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
                    } else {
                      print('[FormC] Tasks queued for offline sync');
                      Toast.show(
                        "Tasks saved. Will sync when online.",
                        duration: Toast.lengthLong,
                        gravity: Toast.bottom,
                      );
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

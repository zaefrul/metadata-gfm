import 'package:flutter/material.dart';
import 'package:GEMS/main.dart';
import 'package:GEMS/model/form.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:GEMS/view/dialog.dart';
import 'package:toast/toast.dart';

class FormE extends StatefulWidget {
  final String id;
  final bool verified;
  final VoidCallback refreshStatus;
  final bool disable;
  final String status;

  const FormE(
    this.id,
    this.verified,
    this.refreshStatus,
    this.disable,
    this.status, {
    super.key,
  });

  @override
  _FormEState createState() => _FormEState();
}

class _FormEState extends State<FormE> {
  late Provider provider;
  bool enableButton = false;
  int? groupValue;
  bool loading = false;
  List<Widget> children2 = [];
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Determine initial groupValue based on widget.status.
    if (widget.status.isEmpty || widget.status == "N/A") {
      groupValue = null;
    } else {
      groupValue = int.tryParse(widget.status);
    }
    enableButton = groupValue == 1;

    provider = Provider(
      taskID: widget.id,
      fetchURL: "/api/m_ppm.php?type=ppm_section_e&ppmTaskId=",
    );

    getListItem();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    provider.context = context;

    Widget body = Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          TextField(
            maxLength: 20,
            enabled: !widget.disable,
            controller: controller,
            decoration:
                InputDecoration(labelText: "Spare Parts/ Material Used"),
          ),
          widget.disable
              ? Container()
              : Row(
                  children: <Widget>[
                    Radio<int>(
                      value: 1,
                      groupValue: groupValue,
                      activeColor: Colors.blueAccent,
                      onChanged: (int? value) => onChange(value!),
                    ),
                    Text(
                      'Yes',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    Radio<int>(
                      groupValue: groupValue,
                      value: 0,
                      activeColor: Colors.blueAccent,
                      onChanged: (int? value) => onChange(value!),
                    ),
                    Text(
                      'No',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
          children2.isEmpty
              ? Container()
              : Expanded(
                  child: ListView.builder(
                  itemCount: children2.length,
                  itemBuilder: (context, item) {
                    return Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: children2[item],
                    );
                  },
                ))
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: colorTheme3),
        title: Text(
          "E. Spare Parts/ Material Used",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: loading
          ? Stack(
              children: <Widget>[
                body,
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              ],
            )
          : body,
      floatingActionButton: widget.disable
          ? null
          : FloatingActionButton(
              onPressed: () {
                setState(() {
                  if (widget.verified) {
                    if (enableButton == true) {
                      String text = controller.text;
                      if (text.isNotEmpty) {
                        if (text.length < 21) {
                          setState(() {
                            loading = true;
                          });
                          upload(text);
                        } else {
                          Toast.show("Maximum 20 Character.");
                        }
                      } else {
                        Toast.show("Please fill field.");
                      }
                      controller.text = "";
                    } else {
                      Toast.show("Please select 'yes' to continue");
                    }
                  } else {
                    Toast.show("Please verified this task.");
                  }
                });
              },
              child: Icon(Icons.add),
            ),
    );
  }

  Widget getTitle(int index, FormEItem item, {bool bold = false}) {
    return ListTile(
      title: Text(
        "$index. ${item.ppmTaskPartsDesc}",
        style: TextStyle(
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          color: colorTheme3,
        ),
      ),
      trailing: widget.disable
          ? null
          : TextButton(
              child: Icon(Icons.remove),
              onPressed: () async {
                setState(() => loading = true);
                await provider
                    .delete(
                      url:
                          "/api/m_ppm.php?action=delete_ppm_parts&ppmTaskPartsId=${item.ppmTaskPartsId}",
                    )
                    .whenComplete(() {
                  getListItem();
                  widget.refreshStatus(); // Pass the required argument
                });
              },
            ),
    );
  }

  void getListItem() {
    provider.fetch().then((value) {
      if (value.sectionEList != null && value.sectionEList!.isNotEmpty) {
        int count = 0;
        setState(() {
          children2 = value.sectionEList!.map((f) {
            count++;
            return getTitle(count, f);
          }).toList();
        });
      } else {
        setState(() {
          children2 = [];
        });
      }
    }).catchError((err) {
      if (err == "Please try again.") {
        setState(() {
          children2 = [];
        });
      }
    }).whenComplete(() => setState(() => loading = false));
  }

  void upload(String text) async {
    var item = UploadItem("add_ppm_parts", widget.id, desc: text);
    await provider.post(url: "/api/m_ppm.php", body: item.body).then((value) {
      setState(() {
        loading = false;
      });
      getListItem();
      widget.refreshStatus();
      alert(value);
    }).catchError((err) => alert(err));
  }

  void onChange(int value) {
    setState(() {
      enableButton = value == 0 ? false : true;
      groupValue = value;
    });
    provider.post(url: "/api/m_ppm.php", body: {
      "action": "check_ppm_parts",
      "ppmTaskId": widget.id,
      "checked": value.toString()
    }).then((value) {
      print(value);
      widget.refreshStatus();
    });
  }

  void alert(String txt) {
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) => CustomDialog(
        description: txt,
        buttonText: "Okay",
        image: Image.asset(
          "assets/icon_trans.png",
          height: 40,
        ),
      ),
    );
  }
}

class UploadItem extends Upload {
  final String desc;

  UploadItem(String action, String ppmTaskId, {required this.desc})
      : super(action: action, ppmTaskId: ppmTaskId);

  @override
  Map<String, dynamic> get body =>
      {"action": action, "ppmTaskId": ppmTaskId, "ppmTaskPartsDesc": desc};
}

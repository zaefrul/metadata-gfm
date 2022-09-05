import 'package:flutter/material.dart';
import 'package:gfm_gems/model/form.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:gfm_gems/view/dialog.dart';
import 'package:toast/toast.dart';

class FormE extends StatefulWidget {
  final String id;
  final bool verified;
  final Function refreshStatus;
  final bool disable;
  final String status;

  FormE(this.id, this.verified, this.refreshStatus, this.disable, this.status);

  @override
  _FormEState createState() => _FormEState();
}

class _FormEState extends State<FormE> {
  Provider provider;
  bool enableButton = false;
  int groupValue;
  bool loading = false;
  var children2 = <Widget>[];
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.status.length == 0) {
      groupValue = null;
    } else if (widget.status == "N/A") {
      groupValue = null;
    } else {
      groupValue = int.parse(widget.status);
    }

    enableButton = groupValue == 1;

    provider = Provider(
        taskID: widget.id,
        fetchURL: "/api/m_ppm.php?type=ppm_section_e&ppmTaskId=");

    getListItem();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    provider.context = context;

    var body = Container(
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
              ? new Container()
              : new Row(
                  children: <Widget>[
                    new Radio(
                      value: 1,
                      groupValue: groupValue,
                      activeColor: Colors.blueAccent,
                      onChanged: (value) => onChange(value),
                    ),
                    new Text(
                      'Yes',
                      style: new TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                    new Radio(
                      groupValue: groupValue,
                      value: 0,
                      activeColor: Colors.blueAccent,
                      onChanged: (value) => onChange(value),
                    ),
                    new Text(
                      'No',
                      style: new TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
          children2.length == 0
              ? new Container()
              : new Expanded(
                  child: ListView.builder(
                  itemCount: children2.length,
                  itemBuilder: (context, item) {
                    return new Padding(
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
        iconTheme: IconThemeData(
          color: colorTheme3,
        ),
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
                      var text = controller.text;
                      if (text.length > 0) {
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
              child: new Icon(Icons.add),
            ),
    );
  }

  Widget getTitle(int index, FormEItem item, {bold = false}) => new ListTile(
        title: new Text("$index. " + item.ppmTaskPartsDesc,
            style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: colorTheme3)),
        trailing: widget.disable
            ? null
            : new FlatButton(
                child: new Icon(Icons.remove),
                onPressed: () async {
                  setState(() => loading = true);
                  await provider
                      .delete(
                          url:
                              "/api/m_ppm.php?action=delete_ppm_parts&ppmTaskPartsId=${item.ppmTaskPartsId}")
                      .whenComplete(() {
                    getListItem();
                    widget.refreshStatus();
                  });
                },
              ),
      );

  void getListItem() {
    provider.fetch().then((value) {
      if (value.sectionEList.length > 0) {
        var count = 0;
        children2 = value.sectionEList.map((f) {
          count++;
          return getTitle(count, f);
        }).toList();
      } else {
        children2 = List<Widget>();
      }
    }).catchError((err) {
      if (err == "Please try again.")
        setState(() => children2 = List<Widget>());
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
        context: context,
        builder: (BuildContext context) => CustomDialog(
            description: txt,
            buttonText: "Okay",
            image: Image.asset(
              "assets/icon_trans.png",
              height: 40,
            )));
  }
}

class UploadItem extends Upload {
  final String desc;

  UploadItem(action, ppmTaskId, {this.desc})
      : super(action: action, ppmTaskId: ppmTaskId);

  @override
  Map<String, dynamic> get body =>
      {"action": action, "ppmTaskId": ppmTaskId, "ppmTaskPartsDesc": desc};
}

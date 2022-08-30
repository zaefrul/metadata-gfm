import 'package:flutter/material.dart';
import 'package:gfm_gems/model/responseValue.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:gfm_gems/view/dialog.dart';
import 'package:toast/toast.dart';

class ComplaintSectionB extends StatefulWidget {
  final String id;
  final String name;
  final bool viewer;

  ComplaintSectionB({
    this.name = "B",
    this.id,
    this.viewer,
  });

  @override
  _ComplaintSectionBState createState() => _ComplaintSectionBState(this.id);
}

class _ComplaintSectionBState extends State<ComplaintSectionB> {
  bool loading = true;
  String remark = "";
  Provider provider;

  _ComplaintSectionBState(String id) {
    provider = Provider(
        taskID: id, fetchURL: "/api/m_wo.php?type=wo_repair_work&woTaskId=");
    provider
        .fetch()
        .then((value) => setState(() => remark = value.result))
        .catchError((err) => print(err))
        .whenComplete(() => setState(() => loading = false));
  }

  @override
  Widget build(BuildContext context) {
    if (provider != null) provider.context = context;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: colorTheme3,
        ),
        title:
            getTitle("${widget.name}. Description of Repair Work", bold: true),
      ),
      body: loading == false
          ? _body()
          : Stack(
              children: <Widget>[
                _body(),
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(child: CircularProgressIndicator()),
                )
              ],
            ),
      floatingActionButton: widget.viewer
          ? null
          : FloatingActionButton.extended(
              label: new Text("Save"),
              onPressed: () {
                if (remark.length > 2) {
                  provider
                      .post(url: "/api/m_wo.php", body: {
                        "action": "save_wo_repair_work",
                        "woTaskId": widget.id,
                        "repairWork": remark
                      })
                      .then((onValue) => alert(onValue))
                      .then((value) {
                        setState(() => loading = false);
                      })
                      .catchError((err) => alert(err));
                } else {
                  Toast.show("You must enter at least total of 2 characters");
                }
              }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _body() {
    var textField = new TextField(
      enabled: !widget.viewer,
      controller: TextEditingController(text: remark),
      keyboardType: TextInputType.multiline,
      maxLength: 1000,
      maxLines: null,
      onChanged: (value) {
        remark = value;
      },
    );

    return new Padding(padding: EdgeInsets.all(16), child: textField);
  }

  Widget getTitle(String text, {bold = false}) => new Container(
        alignment: Alignment.centerLeft,
        child: new Text(text,
            style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: colorTheme3)),
      );

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

import 'package:flutter/material.dart';
import 'package:gfm_gems/model/responseValue.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:gfm_gems/view/dialog.dart';
import 'package:toast/toast.dart';

class FormG extends StatefulWidget {
  final String id;
  final UploadItem _uploadItem;
  final bool verified;
  final Function refreshStatus;
  final bool disable;

  FormG(this.id, this.verified, this.refreshStatus, this.disable)
      : _uploadItem = UploadItem("save_ppm_remark", id);

  @override
  _FormGState createState() => _FormGState();
}

class _FormGState extends State<FormG> {
  bool loading = false;
  Provider provider;

  @override
  void initState() {
    super.initState();

    provider = Provider(
        taskID: widget.id,
        fetchURL: "/api/m_ppm.php?type=ppm_section_g&ppmTaskId=");
  }

  @override
  Widget build(BuildContext context) {
    provider.context = context;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: colorTheme3,
        ),
        title: getTitle("G. Remark", bold: true),
      ),
      body: FutureBuilder(
        future: provider.fetch(),
        builder: (context, AsyncSnapshot<ResponseValue> snapshot) {
          if (snapshot.data != null)
            widget._uploadItem.ppmTaskRemark =
                snapshot.data.sectionGList.ppmTaskRemark;
          return snapshot.data == null
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : (loading
                  ? Stack(
                      children: <Widget>[
                        new Padding(
                            padding: EdgeInsets.all(16),
                            child: new TextField(
                              enabled: !widget.disable,
                              controller: TextEditingController(
                                  text:
                                      snapshot.data.sectionGList.ppmTaskRemark),
                              keyboardType: TextInputType.multiline,
                              maxLength: 500,
                              maxLines: null,
                              onChanged: (value) {
                                widget._uploadItem.ppmTaskRemark = value;
                              },
                            )),
                        Container(
                          color: Colors.black.withOpacity(0.5),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      ],
                    )
                  : new Padding(
                      padding: EdgeInsets.all(16),
                      child: new TextField(
                        enabled: !widget.disable,
                        controller: TextEditingController(
                            text: snapshot.data.sectionGList.ppmTaskRemark),
                        keyboardType: TextInputType.multiline,
                        maxLength: 500,
                        maxLines: null,
                        onChanged: (value) {
                          widget._uploadItem.ppmTaskRemark = value;
                        },
                      )));
        },
      ),
      floatingActionButton: widget.disable
          ? null
          : FloatingActionButton.extended(
              label: new Text("Save"),
              onPressed: () {
                if (this.widget.verified) {
                  setState(() {
                    loading = true;
                  });
                  provider
                      .post(
                          url: "/api/m_ppm.php", body: widget._uploadItem.body)
                      .then((onValue) => alert(onValue))
                      .then((value) {
                    setState(() {
                      loading = false;
                    });
                    widget.refreshStatus();
                  }).catchError((err) => alert(err));
                } else
                  Toast.show("Please verified this task.");
              },
            ),
    );
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

class UploadItem extends Upload {
  String ppmTaskRemark;

  UploadItem(action, ppmTaskId, {this.ppmTaskRemark})
      : super(action: action, ppmTaskId: ppmTaskId);

  @override
  Map<String, dynamic> get body => {
        "action": action,
        "ppmTaskId": ppmTaskId,
        "ppmTaskRemark": ppmTaskRemark == null ? "" : ppmTaskRemark
      };
}

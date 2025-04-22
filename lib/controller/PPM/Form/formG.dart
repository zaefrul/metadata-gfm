import 'package:flutter/material.dart';
import 'package:gfm_gems/model/responseValue.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:gfm_gems/view/dialog.dart';
import 'package:toast/toast.dart';
import '../../../main.dart';

class FormG extends StatefulWidget {
  final String id;
  final bool verified;
  final ValueChanged<bool> refreshStatus;
  final bool disable;

  const FormG(
    this.id,
    this.verified,
    this.refreshStatus,
    this.disable, {
    Key? key,
  }) : super(key: key);

  @override
  _FormGState createState() => _FormGState();
}

class _FormGState extends State<FormG> {
  bool loading = false;
  late Provider provider;
  late UploadItem _uploadItem;  // <-- Initialize it here instead.

  @override
  void initState() {
    super.initState();
    provider = Provider(
      taskID: widget.id,
      fetchURL: "/api/m_ppm.php?type=ppm_section_g&ppmTaskId=",
    );

    _uploadItem = UploadItem("save_ppm_remark", widget.id); // initialization here
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    provider.context = context;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: colorTheme3),
        title: getTitle("G. Remark", bold: true),
      ),
      body: FutureBuilder<ResponseValue>(
        future: provider.fetch(),
        builder: (context, AsyncSnapshot<ResponseValue> snapshot) {
          if (snapshot.hasData) {
            _uploadItem.ppmTaskRemark =
                snapshot.data!.sectionGList?.ppmTaskRemark ?? "";
          }
          return !snapshot.hasData
              ? Center(child: CircularProgressIndicator())
              : (loading
                  ? Stack(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: TextField(
                            enabled: !widget.disable,
                            controller: TextEditingController(
                                text: snapshot.data!.sectionGList?.ppmTaskRemark ?? ""),
                            keyboardType: TextInputType.multiline,
                            maxLength: 500,
                            maxLines: null,
                            onChanged: (value) {
                              _uploadItem.ppmTaskRemark = value;
                            },
                          ),
                        ),
                        Container(
                          color: Colors.black.withOpacity(0.5),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      ],
                    )
                  : Padding(
                      padding: EdgeInsets.all(16),
                      child: TextField(
                        enabled: !widget.disable,
                        controller: TextEditingController(
                            text: snapshot.data!.sectionGList?.ppmTaskRemark ?? ""),
                        keyboardType: TextInputType.multiline,
                        maxLength: 500,
                        maxLines: null,
                        onChanged: (value) {
                          _uploadItem.ppmTaskRemark = value;
                        },
                      ),
                    ));
        },
      ),
      floatingActionButton: widget.disable
          ? null
          : FloatingActionButton.extended(
              label: Text("Save"),
              onPressed: () {
                if (widget.verified) {
                  setState(() {
                    loading = true;
                  });
                  provider
                      .post(
                          url: "/api/m_ppm.php",
                          body: _uploadItem.body)
                      .then((onValue) => alert(onValue))
                      .then((_) {
                    setState(() {
                      loading = false;
                    });
                    widget.refreshStatus(true);
                  }).catchError((err) => alert(err));
                } else {
                  Toast.show("Please verified this task.");
                }
              },
            ),
    );
  }

  Widget getTitle(String text, {bool bold = false}) => Container(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: colorTheme3,
          ),
        ),
      );

  void alert(String txt) {
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) => CustomDialog(
        description: txt,
        buttonText: "Okay",
        image: Image.asset("assets/icon_trans.png", height: 40),
      ),
    );
  }
}

class UploadItem extends Upload {
  String? ppmTaskRemark;

  UploadItem(String action, String ppmTaskId, {this.ppmTaskRemark = ""})
      : super(action: action, ppmTaskId: ppmTaskId);

  @override
  Map<String, dynamic> get body => {
        "action": action,
        "ppmTaskId": ppmTaskId,
        "ppmTaskRemark": ppmTaskRemark ?? ""
      };
}

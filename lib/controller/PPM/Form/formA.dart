import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gfm_gems/model/form.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/services.dart';

import 'package:gfm_gems/model/responseValue.dart';
import 'package:gfm_gems/view/dialog.dart';
import 'package:toast/toast.dart';

class FormA extends StatefulWidget {
  String id;
  Function verification;
  final bool viewer;
  final bool verified;

  FormA(this.id, {this.verification, this.viewer, this.verified});

  @override
  _FormAState createState() => _FormAState();
}

class _FormAState extends State<FormA> {
  String keyword;

  String startDate;

  String assetNo;

  String taskNo;

  String model;

  String capacity;

  String pmStart;

  String pmEnd;

  Provider provider;

  bool verified;
  @override
  void initState() {
    super.initState();
    verified = widget.verified;

    provider = Provider(
        taskID: widget.id,
        fetchURL: "/api/m_ppm.php?type=ppm_section_a&ppmTaskId=");
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
          title: getTitle("A. Asset Details", bold: true),
          actions: widget.viewer
              ? null
              : verified
                  ? null
                  : <Widget>[
                      new GestureDetector(
                          child: Icon(
                            Icons.camera,
                            color: colorTheme3,
                            size: 30,
                          ),
                          onTap: scan),
                      new SizedBox(width: 20),
                    ],
        ),
        body: FutureBuilder(
            future: provider.fetch(),
            builder: (context, AsyncSnapshot<ResponseValue> snapshot) {
              if (snapshot.data != null)
                assetNo = snapshot.data.sectionAList.assetNo;
              return snapshot.data == null
                  ? Center(child: CircularProgressIndicator())
                  : body(snapshot.data.sectionAList);
            }));
  }

  Future scan() async {
    try {
      var barcode = await BarcodeScanner.scan();
      if (barcode.rawContent == assetNo) {
        startDate =
            new DateFormat("yyyy/MM/dd hh:mm:ss").format(DateTime.now());
        verified = true;
        widget.verification(true);
        await provider
            .post(url: "/api/m_ppm.php", body: {
              "action": "save_scan_start_time",
              "ppmTaskId": widget.id
            })
            .then((value) => setState(() => alert(value)))
            .catchError((err) {
              verified = false;
              alert(err);
            });
        return;
      } else
        this.keyword = "Incorrect Asset No.";
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied)
        this.keyword = 'The user did not grant the camera permission!';
      else
        this.keyword = 'image scanning fail, please try again';
    } on FormatException {
      this.keyword = 'image scanning fail, please try again';
    } catch (e) {
      this.keyword = 'image scanning fail, please try again';
    }

    Toast.show(this.keyword);
  }

  Widget body(FormAItem object) {
    return new Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          getTitle("Asset Group : ${object.assetGroupName}"),
          getTitle("Asset Category : ${object.assetCategoryName}"),
          getTitle("Asset Type : ${object.assetTypeName}"),
          getTitle("Asset No. : ${object.assetNo}"),
          getTitle("Task No : ${object.assetName}"),
          getTitle("Model : ${object.assetModelName}"),
          getTitle("Capacity : ${object.assetCapacity}"),
          getTitle("PM Start Date/Time : ${object.ppmTaskTimeStart}"),
          getTitle("PM End Date/Time : ${object.ppmTaskTimeServiced}"),
        ],
      ),
    );
  }

  Widget getTitle(String text, {bold = false}) => new Container(
        alignment: Alignment.centerLeft,
        padding: bold == false ? EdgeInsets.only(top: 12) : null,
        child: new Text(text,
            style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: colorTheme3)),
      );

  void alert(String txt) => showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
            description: txt,
            buttonText: "Okay",
            image: Image.asset(
              "assets/icon_trans.png",
              height: 40,
            ),
          ));
}

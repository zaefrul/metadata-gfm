import 'package:flutter/material.dart';
import 'package:gfm_gems/main.dart';
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
  final String id;
  final ValueChanged<bool>? verification;
  final bool viewer;
  final bool verified;

  const FormA(
    this.id, {
    this.verification,
    this.viewer = false,
    this.verified = false,
    Key? key,
  }) : super(key: key);

  @override
  _FormAState createState() => _FormAState();
}

class _FormAState extends State<FormA> {
  String keyword = "";
  String startDate = "";
  String assetNo = "";
  String taskNo = "";
  String model = "";
  String capacity = "";
  String pmStart = "";
  String pmEnd = "";

  late Provider provider;
  late bool verified;

  @override
  void initState() {
    super.initState();
    verified = widget.verified;
    provider = Provider(
      taskID: widget.id,
      fetchURL: "/api/m_ppm.php?type=ppm_section_a&ppmTaskId=",
    );
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
        actions: widget.viewer || verified
            ? null
            : <Widget>[
                GestureDetector(
                  child: Icon(
                    Icons.camera,
                    color: colorTheme3,
                    size: 30,
                  ),
                  onTap: scan,
                ),
                SizedBox(width: 20),
              ],
      ),
      body: FutureBuilder<ResponseValue>(
        future: provider.fetch(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            assetNo = snapshot.data?.sectionAList?.assetNo ?? "";
          }
          return !snapshot.hasData
              ? Center(child: CircularProgressIndicator())
              : body(snapshot.data!.sectionAList ?? FormAItem());
        },
      ),
    );
  }

  Future<void> scan() async {
    try {
      var barcode = await BarcodeScanner.scan();
      if (barcode.rawContent == assetNo) {
        startDate = DateFormat("yyyy/MM/dd hh:mm:ss").format(DateTime.now());
        verified = true;
        widget.verification?.call(true);
        await provider
            .post(url: "/api/m_ppm.php", body: {
              "action": "save_scan_start_time",
              "ppmTaskId": widget.id,
            })
            .then((value) => setState(() => alert(value)))
            .catchError((err) {
          verified = false;
          alert(err);
        });
        return;
      } else {
        keyword = "Incorrect Asset No.";
      }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        keyword = 'The user did not grant the camera permission!';
      } else {
        keyword = 'Image scanning failed, please try again';
      }
    } on FormatException {
      keyword = 'Image scanning failed, please try again';
    } catch (e) {
      keyword = 'Image scanning failed, please try again';
    }

    Toast.show(keyword);
  }

  Widget body(FormAItem object) {
    return Padding(
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

  Widget getTitle(String text, {bool bold = false}) => Container(
        alignment: Alignment.centerLeft,
        padding: bold ? null : EdgeInsets.only(top: 12),
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
        image: Image.asset(
          "assets/icon_trans.png",
          height: 40,
        ),
      ),
    );
  }
}

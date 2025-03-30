import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:gfm_gems/view/dialog.dart';
import 'package:toast/toast.dart';
import 'package:flutter/services.dart';

class ComplaintSectionD extends StatefulWidget {
  final String id;
  final bool viewer;
  final String name;

  ComplaintSectionD({
    this.name = "D",
    required this.id,
    required this.viewer,
  });

  @override
  _ComplaintSectionDState createState() => _ComplaintSectionDState(this.id);
}

class _ComplaintSectionDState extends State<ComplaintSectionD> {
  bool loading = false;
  String remark = "";
  late Provider provider;
  late String keyword;
  TextEditingController controller = TextEditingController();

  _ComplaintSectionDState(String id) {
    provider = Provider(
        taskID: id, fetchURL: "/api/m_wo.php?type=wo_repair_work&woTaskId=");
    // provider
    //     .fetch()
    //     .then((value) => setState(() => remark = value.result))
    //     .catchError((err) => print(err))
    //     .whenComplete(() => setState(() => loading = false));
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
        title: getTitle("${widget.name}. Asset No", bold: true),
        actions: widget.viewer
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
                //   if (remark.length > 2) {
                setState(() => loading = true);
                provider
                    .post(url: "/api/m_wo.php", body: {
                      "action": "save_asset_no",
                      "woTaskId": widget.id,
                      "assetNo": remark
                    })
                    .then((onValue) => alert(onValue))
                    .then((value) {
                      setState(() => loading = false);
                    })
                    .catchError((err) => alert(err))
                    .whenComplete(() => setState(() => loading = false));
                // } else {
                //   Toast.show("You must enter at least total of 2 characters",gravity: Toast.CENTER);
                // }
              }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _body() {
    var textField = new TextField(
      enabled: !widget.viewer,
      controller: controller,
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

  Future scan() async {
    try {
      var barcode = await BarcodeScanner.scan();
      controller.text = barcode.rawContent;
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

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }
}

class ComplaintSectionE extends StatelessWidget {
  final String text;
  final String sect;

  ComplaintSectionE(this.text, this.sect);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text(sect + ". Comment"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: new Container(
        padding: EdgeInsets.all(12),
        child: new Text(
          text,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

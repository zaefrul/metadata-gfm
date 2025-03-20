import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/WorkOrder/complaintView.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:toast/toast.dart';
import 'package:flutter/services.dart';

class SearchComplaintArguments {
  final String url;
  final int index;

  SearchComplaintArguments({this.url = "", this.index});
}

class SearchComplaint extends StatefulWidget {
  static const routeName = '/search_complaint';

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<SearchComplaint> {
  String _url;
  int index;
  String keyword = "";
  String searchText = "";
  ComplaintView body;
  final TextEditingController controller;

  _SearchState() : controller = TextEditingController();

  Future scan() async {
    try {
      var barcode = await BarcodeScanner.scan();
      keyword = "Success";

      // _fetchQR(barcode.rawContent);

      Toast.show("Loading", duration: 2);

      _fetchQuery(controller.text, index);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied)
        setState(() =>
            this.keyword = 'The user did not grant the camera permission!');
      else
        setState(() => this.keyword = 'Unknown error: $e');
    } on FormatException {
      setState(() => this.keyword = 'Cancel');
    } catch (e) {
      setState(() => this.keyword = 'Unknown error: $e');
    }

    Toast.show(this.keyword);
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);

    return new Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: colorTheme3),
        backgroundColor: Colors.white,
        title: new TextField(
            controller: controller,
            style: new TextStyle(fontFamily: 'Avenir', color: colorTheme3),
            autofocus: true,
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Search",
                hintStyle: TextStyle(color: Color(0xcc022c41))),
            onChanged: (text) => setState(() => keyword = text),
            textInputAction: TextInputAction.search,
            onSubmitted: (value) {
              Toast.show("Loading", duration: 2);
              if (controller.text != searchText) {
                searchText = controller.text;
                _fetchQuery(controller.text, index);
              }
            }),
        actions: <Widget>[
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
      body: body,
    );
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  _fetchQR(String text) {
    var url = _url;
    url += "" + text;

    setState(() {
      controller.text = this.searchText = text;
      body = ComplaintView(url, null, 1);
    });
  }

  _fetchQuery(String text, int index) {
    var url = _url;
    url += "&searchTxt=" + text;

    setState(() => body = new ComplaintView(url, null, index));
  }
}

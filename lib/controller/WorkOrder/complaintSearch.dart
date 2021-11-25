import 'package:barcode_scan/barcode_scan.dart';
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

  _SearchState() : controller = TextEditingController() {
    controller
      ..addListener(() {
        if (controller.text != searchText) {
          searchText = controller.text;
          _fetchQuery(controller.text, index);
        }
      });
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      keyword = "Success";

      _fetchQR(barcode);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied)
        setState(() =>
            this.keyword = 'The user did not grant the camera permission!');
      else
        setState(() => this.keyword = 'Unknown error: $e');
    } on FormatException {
      setState(() => this.keyword = 'Cancel');
    } catch (e) {
      setState(() => this.keyword = 'Unknown error: $e');
    }

    Toast.show(this.keyword, context);
  }

  @override
  Widget build(BuildContext context) {
    if (_url == null || body == null) {
      final SearchComplaintArguments args =
          ModalRoute.of(context).settings.arguments;
      _url = args.url;
      index = args.index;

      body = ComplaintView(args.url, null, args.index);
    }

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
            onChanged: (text) => setState(() => keyword = text)),
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
    if (text != null) url += "" + text;

    setState(() {
      controller.text = this.searchText = text;
      body = ComplaintView(url, null, 1);
    });
  }

  _fetchQuery(String text, int index) {
    var url = _url;
    if (text != null) url += "&searchTxt=" + text;

    setState(() => body = new ComplaintView(url, null, index));
  }
}

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:GEMS/controller/WorkOrder/complaintView.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:toast/toast.dart';
import 'package:flutter/services.dart';

class SearchComplaintArguments {
  final String url;
  final int index;

  SearchComplaintArguments({this.url = "", this.index = 0});
}

class SearchComplaint extends StatefulWidget {
  static const routeName = '/search_complaint';

  const SearchComplaint({super.key});

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<SearchComplaint> {
  late String _url;
  late int index;
  String keyword = "";
  String searchText = "";
  late ComplaintView body;
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize default values.
    _url = "";
    index = 1;
    // Optionally, initialize body. For example, an empty view:
    body = ComplaintView(_url, Container(), index);
  }

  Future<void> scan() async {
    try {
      var barcode = await BarcodeScanner.scan();
      setState(() {
        keyword = "Success";
      });
      // Optionally process QR data:
      // _fetchQR(barcode.rawContent);
      Toast.show("Loading", duration: 2);
      _fetchQuery(controller.text, index);
    } on PlatformException catch (e) {
      setState(() {
        if (e.code == BarcodeScanner.cameraAccessDenied) {
          keyword = 'The user did not grant the camera permission!';
        } else {
          keyword = 'Unknown error: $e';
        }
      });
    } on FormatException {
      setState(() => keyword = 'Cancel');
    } catch (e) {
      setState(() => keyword = 'Unknown error: $e');
    }
    Toast.show(keyword);
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: colorTheme3),
        backgroundColor: Colors.white,
        title: TextField(
          controller: controller,
          style: TextStyle(fontFamily: 'Avenir', color: colorTheme3),
          autofocus: true,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Search",
            hintStyle: TextStyle(color: const Color(0xcc022c41)),
          ),
          onChanged: (text) => setState(() => keyword = text),
          textInputAction: TextInputAction.search,
          onSubmitted: (value) {
            Toast.show("Loading", duration: 2);
            if (controller.text != searchText) {
              searchText = controller.text;
              _fetchQuery(controller.text, index);
            }
          },
        ),
        actions: <Widget>[
          GestureDetector(
            onTap: scan,
            child: Icon(
              Icons.camera,
              color: colorTheme3,
              size: 30,
            ),
          ),
          SizedBox(width: 20),
        ],
      ),
      body: body,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _fetchQR(String text) {
    var url = _url;
    url += text;
    setState(() {
      controller.text = searchText = text;
      body = ComplaintView(url, Container(), 1);
    });
  }

  void _fetchQuery(String text, int index) {
    var url = _url;
    url += "&searchTxt=$text";
    setState(() {
      body = ComplaintView(url, Container(), index);
    });
  }
}

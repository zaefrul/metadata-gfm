import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import '../../utils/reference.dart';
import 'ri_task_view.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/services.dart';

class SearchRIArguments {
  final int index;

  SearchRIArguments({this.index = 0});
}

class SearchRI extends StatefulWidget {
  static const routeName = '/search_ri';

  @override
  _SearchStateRI createState() => _SearchStateRI();
}

class _SearchStateRI extends State<SearchRI> {
  String keyword = "";
  String searchText = "";
  final TextEditingController controller;
  final RITaskView taskView = RITaskView(index: 1);
  final RITaskView allTaskView = RITaskView(index: 0);
  int index = 0;

  _SearchStateRI() : controller = TextEditingController();

  Future scan() async {
    try {
      var barcode = await BarcodeScanner.scan();
      keyword = "Success";

      // if (index == 0)
      //   allTaskView.updateQRAll(controller.text);
      // else if (index == 1) taskView.updateQR(controller.text);

      setState(() => controller.text = this.searchText = barcode.rawContent);

      Toast.show("Loading", duration: 2);

      if (index == 0)
        allTaskView.updateAll(controller.text);
      else if (index == 1) taskView.update(controller.text);
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
    final SearchRIArguments args = ModalRoute.of(context).settings.arguments;
    index = args.index;

    var body = allTaskView;
    if (index == 1) body = taskView;

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
              if (index == 0)
                allTaskView.updateAll(controller.text);
              else if (index == 1) taskView.update(controller.text);
            }
          },
        ),
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
}

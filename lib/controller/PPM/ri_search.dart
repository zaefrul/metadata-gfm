import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import '../../view/gems_chrome.dart';
import 'ri_task_view.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/services.dart';

class SearchRIArguments {
  final int index;
  const SearchRIArguments({this.index = 0});
}

class SearchRI extends StatefulWidget {
  static const routeName = '/search_ri';

  const SearchRI({super.key});

  @override
  _SearchStateRI createState() => _SearchStateRI();
}

class _SearchStateRI extends State<SearchRI> {
  String keyword = "";
  String searchText = "";
  late final TextEditingController controller;
  final RITaskView taskView = RITaskView(index: 1);
  final RITaskView allTaskView = RITaskView(index: 0);
  int index = 0;

  _SearchStateRI() {
    controller = TextEditingController();
  }

  Future<void> scan() async {
    try {
      final ScanResult barcode = await BarcodeScanner.scan();

      setState(() {
        controller.text = searchText = barcode.rawContent;
      });

      Toast.show("Loading", duration: 2);

      if (index == 0) {
        allTaskView.updateAll(controller.text);
      } else if (index == 1) {
        taskView.update(controller.text);
      }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          keyword = 'The user did not grant camera permission!';
        });
      } else {
        setState(() {
          keyword = 'Unknown error: $e';
        });
      }
      Toast.show(keyword);
    } on FormatException {
      setState(() {
        keyword = 'Scan cancelled by user';
      });
      Toast.show(keyword);
    } catch (e) {
      setState(() {
        keyword = 'Unknown error: $e';
      });
      Toast.show(keyword);
    }
  }

  @override
  void initState() {
    super.initState();
    ToastContext().init(context);
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as SearchRIArguments?;
    index = args?.index ?? 0;

    Widget body = index == 1 ? taskView : allTaskView;

    return Scaffold(
      backgroundColor: GemsChrome.page,
      appBar: gemsAppBar(
        title: TextField(
          controller: controller,
          style: GemsChrome.body(size: 16),
          autofocus: true,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Search',
            hintStyle: GemsChrome.body(color: GemsChrome.muted),
          ),
          onChanged: (text) => setState(() => keyword = text),
          textInputAction: TextInputAction.search,
          onSubmitted: (value) {
            Toast.show("Loading", duration: 2);
            if (controller.text != searchText) {
              searchText = controller.text;
              if (index == 0) {
                allTaskView.updateAll(controller.text);
              } else if (index == 1) {
                taskView.update(controller.text);
              }
            }
          },
        ),
        actions: [
          IconButton(
            onPressed: scan,
            icon: const Icon(Icons.photo_camera_outlined),
          ),
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
}

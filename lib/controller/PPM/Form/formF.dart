import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_native_image_v2/flutter_native_image_v2.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gfm_gems/model/form.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:gfm_gems/view/dialog.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

import 'openImage.dart';

class FormF extends StatefulWidget {
  final String id;
  final bool verified;
  final Function refreshStatus;
  final bool disable;
  final String status;

  const FormF(this.id, this.verified, this.refreshStatus, this.disable, this.status, {Key? key}) : super(key: key);

  @override
  _FormFState createState() => _FormFState();
}

class _FormFState extends State<FormF> {
  late Provider provider;
  List<Widget> items = [];
  List<UploadItem> uploadItems = [];
  int? groupValue;
  bool enableButton = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.status.isEmpty || widget.status == "N/A") {
      groupValue = null;
    } else {
      groupValue = int.tryParse(widget.status);
    }
    enableButton = groupValue == 1;

    provider = Provider(
        taskID: widget.id,
        fetchURL: "/api/m_ppm.php?type=ppm_section_f&ppmTaskId=");

    fetch();
  }

  void fetch() {
    provider.fetch().then((value) {
      setState(() {
        items = [];
      });
      for (var i = 0; i < (value.sectionHList?.length ?? 0); i++) {
        var item = value.sectionHList?[i];
        setState(() {
          items.add(getListTile(i + 1, item: item));
        });
      }
    }).catchError((err) {
      setState(() => items = []);
    }).whenComplete(() => setState(() => loading = false));
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    provider.context = context;

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

    var children = <Widget>[
      ListTile(
          title: widget.disable
              ? Container()
              : Row(
                  children: <Widget>[
                    Radio<int>(
                      value: 1,
                      groupValue: groupValue,
                      activeColor: Colors.blueAccent,
                      onChanged: widget.disable ? null : (value) => onChange(value),
                    ),
                    const Text(
                      'Yes',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    Radio<int>(
                      value: 0,
                      groupValue: groupValue,
                      activeColor: Colors.blueAccent,
                      onChanged: widget.disable ? null : (value) => onChange(value),
                    ),
                    const Text(
                      'No',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ],
                ))
    ];

    children.addAll(items);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: colorTheme3,
        ),
        title: getTitle("F. Additional Reports", bold: true),
      ),
      body: loading
          ? Stack(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: children,
                  ),
                ),
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              ],
            )
          : children.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Container(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: children,
                  ),
                ),
      floatingActionButton: widget.disable
          ? null
          : FloatingActionButton.extended(
              label: const Text("Upload Image"),
              onPressed: () async {
                if (widget.verified) {
                  if (enableButton == true) {
                    try {
                      var result = await uploadFile;
                      alert(result.toString());
                    } catch (err) {
                      setState(() => loading = false);
                      alert(err.toString());
                    }
                  } else {
                    Toast.show("Please select 'yes' to continue", duration: Toast.lengthShort, gravity: Toast.bottom);
                  }
                } else {
                  Toast.show("Please verified this task.", duration: Toast.lengthShort, gravity: Toast.bottom);
                }
              }),
    );
  }

  Widget getTitle(String text, {bool bold = false}) => Container(
        alignment: Alignment.centerLeft,
        child: Text(text,
            style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: colorTheme3)),
      );

  Widget getListTile(int index, {FormHItem? item, UploadItem? unsaveItem}) {
    return ListTile(
      title: Text("$index. " + (item != null ? item.uploadName : unsaveItem!.name)),
      trailing: Container(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            GestureDetector(
              child: const Icon(
                Icons.image,
                color: Colors.blueAccent,
              ),
              onTap: () {
                if (unsaveItem == null) {
                  _openViewer(src: "http:" + item!.documentSrc);
                } else {
                  _openViewer(path: unsaveItem.path);
                }
              },
            ),
            const SizedBox(
              width: 20,
            ),
            widget.disable
                ? Container()
                : GestureDetector(
                    child: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onTap: () {
                      setState(() => loading = true);
                      provider
                          .delete(
                              url:
                                  "/api/m_ppm.php?action=delete_ppm_additional_report&ppmTaskUploadId=${item!.ppmTaskUploadId}")
                          .then((value) {
                        print(value);
                      }).whenComplete(() {
                        fetch();
                        widget.refreshStatus();
                      });
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> get uploadFile async {
    final XFile? file = await ImagePicker().pickImage(source: ImageSource.camera);
    if (file == null) {
      throw Exception("No file selected");
    }
    Uint8List? bytes = await compressFile(File(file.path));
    if (bytes == null) {
      throw Exception("Failed to compress image");
    }
    String size = bytes.length.toString();
    String base64Image = base64Encode(bytes);
    String desc = "${file.path}.jpg";

    var item = UploadItem("upload_additional_report", widget.id,
        path: file.path,
        name: desc,
        fileName: desc,
        size: size,
        data: base64Image,
        index: uploadItems.length.toString());
    uploadItems.add(item);

    var tile = getListTile(items.length + 1, unsaveItem: item);
    setState(() => items.add(tile));

    try {
      var result = await provider.post(url: "/api/m_ppm.php", body: item.body);
      fetch();
      widget.refreshStatus();
      return result;
    } catch (err) {
      setState(() => loading = false);
      widget.refreshStatus();
      return err;
    }
  }

  void onChange(int? value) {
    if (value == null) return;
    setState(() {
      enableButton = value == 1;
      groupValue = value;
    });
    provider.post(url: "/api/m_ppm.php", body: {
      "action": "check_additional_report",
      "ppmTaskId": widget.id,
      "checked": value.toString()
    }).then((_) {
      widget.refreshStatus();
    });
  }

  void _openViewer({String? path, String? src}) => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ImageViewer(path: path, url: src)));

  Future<Uint8List?> compressFile(File file) async {
    try {
      // Use flutter_native_image_v2 package for compression.
      File compressedFile = await FlutterNativeImage.compressImage(
        file.path,
        quality: Platform.isIOS ? 60 : 100,
        targetWidth: 540,
        targetHeight: 720,
      );
      print("Original size: ${file.lengthSync()}");
      print("Compressed size: ${await compressedFile.length()}");
      return await compressedFile.readAsBytes();
    } catch (e) {
      print("Compression error: $e");
      return null;
    }
  }
}

class UploadItem extends Upload {
  final String path;
  final String name;
  final String fileName;
  final String size;
  final String type = "data:image/jpeg;base64";
  final String data;
  final String index;

  UploadItem(String action, String ppmTaskId,
      {required this.path,
      required this.name,
      required this.fileName,
      required this.size,
      required this.data,
      required this.index})
      : super(action: action, ppmTaskId: ppmTaskId);

  @override
  Map<String, dynamic> get body => {
        "action": action,
        "ppmTaskId": ppmTaskId,
        "fileUpload[name]": name,
        "fileUpload[filename]": fileName,
        "fileUpload[size]": size,
        "fileUpload[type]": type,
        "fileUpload[data]": data,
      };
}

import 'dart:convert';
import 'dart:io';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_native_image_v2/flutter_native_image_v2.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gfm_gems/view/dialog.dart';

// import 'package:path/path.dart';

import 'package:flutter/material.dart';
import 'package:gfm_gems/model/form.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:toast/toast.dart';

import 'openImage.dart';

class FormF extends StatefulWidget {
  final String id;
  final bool verified;
  final Function refreshStatus;
  final bool disable;
  final String status;

  FormF(this.id, this.verified, this.refreshStatus, this.disable, this.status);

  @override
  _FormFState createState() => _FormFState();
}

class _FormFState extends State<FormF> {
  Provider provider;
  var items = List<ListTile>();
  List<UploadItem> uploadItems = List<UploadItem>();
  int groupValue;
  bool enableButton = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.status.length == 0) {
      groupValue = null;
    } else if (widget.status == "N/A") {
      groupValue = null;
    } else {
      groupValue = int.parse(widget.status);
    }

    groupValue = widget.status.length > 0 ? int.parse(widget.status) : null;
    enableButton = groupValue == 1;

    provider = Provider(
        taskID: widget.id,
        fetchURL: "/api/m_ppm.php?type=ppm_section_f&ppmTaskId=");

    fetch();
  }

  fetch() {
    provider.fetch().then((value) {
      items = List<ListTile>();
      for (var i = 0; i < value.sectionHList.length; i++) {
        var item = value.sectionHList[i];
        setState(() => items.add(getListTile(i + 1, item: item)));
      }
    }).catchError((err) {
      setState(() => items = List<ListTile>());
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

    var children = [
      ListTile(
          title: widget.disable
              ? new Container()
              : new Row(
                  children: <Widget>[
                    new Radio(
                      value: 1,
                      groupValue: groupValue,
                      activeColor: Colors.blueAccent,
                      onChanged: (value) => onChange(value),
                    ),
                    new Text(
                      'Yes',
                      style: new TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                    new Radio(
                      groupValue: groupValue,
                      value: 0,
                      activeColor: Colors.blueAccent,
                      onChanged: (value) => onChange(value),
                    ),
                    new Text(
                      'No',
                      style: new TextStyle(fontSize: 16.0),
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
                new Container(
                  padding: EdgeInsets.all(16.0),
                  child: new ListView(
                    children: children,
                  ),
                ),
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              ],
            )
          : children.length == 0
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Container(
                  padding: EdgeInsets.all(16.0),
                  child: new ListView(
                    children: children,
                  ),
                ),
      floatingActionButton: widget.disable
          ? null
          : FloatingActionButton.extended(
              label: new Text("Upload Image"),
              onPressed: () {
                if (widget.verified) {
                  enableButton == true
                      ? uploadFile
                          .then((value) => alert(value))
                          .catchError((err) {
                          setState(() => loading = false);
                          alert(err);
                        })
                      : Toast.show("Please select 'yes' to continue");
                } else {
                  Toast.show("Please verified this task.");
                }
              }),
    );
  }

  Widget getTitle(String text, {bold = false}) => new Container(
        alignment: Alignment.centerLeft,
        child: new Text(text,
            style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: colorTheme3)),
      );

  Widget getListTile(int index, {FormHItem item, UploadItem unsaveItem}) {
    return ListTile(
      title: new Text(
          "$index. " + (item != null ? item.uploadName : unsaveItem.name)),
      trailing: Container(
        child: new Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            GestureDetector(
              child: new Icon(
                Icons.image,
                color: Colors.blueAccent,
              ),
              onTap: () {
                unsaveItem == null
                    ? _openViewer(src: "http:" + item.documentSrc)
                    : _openViewer(path: unsaveItem.path);
              },
            ),
            SizedBox(
              width: 20,
            ),
            widget.disable
                ? new Container()
                : GestureDetector(
                    child: new Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onTap: () {
                      setState(() => loading = true);
                      provider
                          .delete(
                              url:
                                  "/api/m_ppm.php?action=delete_ppm_additional_report&ppmTaskUploadId=${item.ppmTaskUploadId}")
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

  // Future<dynamic> get uploadFile async {
  //   setState(() {
  //     loading = true;
  //   });
  //   String basename(String path) => context.basename(path);

  //   var path = await FilePicker.getFilePath(
  //       type: FileType.CUSTOM, fileExtension: 'pdf');

  //   if (path.length == 0) {
  //     return Future.error("no file selected");
  //   }

  //   var file = File(path);
  //   var bytes = await file.readAsBytes();
  //   String size = bytes.length.toString();
  //   String base64Image = base64Encode(bytes);
  //   String fileName = basename(path);

  //   if (int.parse(size) > 600000)
  //     return Future.error("file selected too big");

  //   var item = UploadItem("upload_additional_report", widget.id,
  //       path: path,
  //       name: fileName,
  //       fileName: fileName,
  //       size: size,
  //       data: base64Image,
  //       index: uploadItems.length.toString());

  //   uploadItems.add(item);

  //   var tile = getListTile(items.length + 1, unsaveItem: item);
  //   setState(() => items.add(tile));

  // try {
  //   var result = await provider.post(url: "/api/m_ppm.php", body: item.body);
  //   fetch();
  //     widget.refreshStatus();
  //   return result;
  // } catch (err){
  //   setState(() => loading = false);
  //     widget.refreshStatus();
  //   return err;
  // }

  // }

  Future<dynamic> get uploadFile async {
    var file = await ImagePicker().pickImage(source: ImageSource.camera);

    final bytes = await compressFile(File(file.path));
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

  void onChange(int value) {
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

  _openViewer({path, src}) => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ImageViewer(path: path, url: src)));

  Future<List<int>> compressFile(File file) async {
    // Compress the image using flutter_native_image.
    File compressedFile = await FlutterNativeImage.compressImage(
      file.absolute.path,
      quality: Platform.isIOS ? 60 : 100, // Adjust quality as needed
      targetWidth: 540,
      targetHeight: 720,
    );

    // Read the bytes from the compressed file.
    final bytes = await compressedFile.readAsBytes();
    print("Original file size: ${file.lengthSync()}");
    print("Compressed file size: ${bytes.length}");
    return bytes;
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

  UploadItem(action, ppmTaskId,
      {this.path, this.name, this.fileName, this.size, this.data, this.index})
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

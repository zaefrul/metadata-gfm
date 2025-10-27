import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:GEMS/model/form.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:GEMS/view/dialog.dart';
import 'package:toast/toast.dart';
import 'package:GEMS/utils/image_compressor.dart';
import 'package:GEMS/data/repository/ppm_repository.dart';
import 'package:GEMS/controller/PPM/pending_sync.dart';
import 'package:GEMS/controller/PPM/widgets/pending_sync_banner.dart';
import 'package:GEMS/utils/biometric_lock_manager.dart';

import 'openImage.dart';

class FormF extends StatefulWidget {
  final String id;
  final bool verified;
  final Function refreshStatus;
  final bool disable;
  final String status;

  const FormF(this.id, this.verified, this.refreshStatus, this.disable, this.status, {super.key});

  @override
  _FormFState createState() => _FormFState();
}

class _FormFState extends State<FormF> {
  late Provider provider;
  late PPMRepository _repository;
  PPMPendingSyncController? _pendingSync;
  
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

    _repository = PPMRepository();
    _pendingSync = PPMPendingSyncController();
    _pendingSync?.setPPMTaskId(widget.id);

    fetch();
  }

  @override
  void dispose() {
    _pendingSync?.dispose();
    super.dispose();
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
      // Add pending sync banner
      if (_pendingSync != null)
        PPMPendingSyncIndicator(controller: _pendingSync!),
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
      title: Text("$index. ${item != null ? item.uploadName : unsaveItem!.name}"),
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
                  _openViewer(src: "http:${item!.documentSrc}");
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
    print('[FormF] uploadFile called');
    
    BiometricLockManager.suppressNextLock();
    
    final XFile? file = await ImagePicker().pickImage(source: ImageSource.camera);
    if (file == null) {
      print('[FormF] User cancelled camera');
      throw Exception("No file selected");
    }

    print('[FormF] Image captured: ${file.path}');
    setState(() => loading = true);

    try {
      Uint8List? bytes = await compressFile(File(file.path), settings: {
        "quality": Platform.isIOS ? 60 : 100,
        "minWidth": 540,
        "minHeight": 720,
      });
      
      if (bytes == null) {
        throw Exception("Failed to compress image");
      }

      print('[FormF] Image compressed: ${bytes.length} bytes');
      String desc = "${file.path.split('/').last}.jpg";

      // Upload via repository (handles online/offline)
      final result = await _repository.uploadAdditionalReport(
        ppmTaskId: widget.id,
        displayName: desc,
        filename: desc,
        sizeBytes: bytes.length,
        base64Data: base64Encode(bytes),
      );

      if (result == PPMActionResult.success) {
        print('[FormF] Upload successful');
        Toast.show(
          "Report uploaded successfully",
          duration: Toast.lengthShort,
          gravity: Toast.bottom,
        );
      } else {
        print('[FormF] Upload queued for offline sync');
        Toast.show(
          "Report saved. Will sync when online.",
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
        );
      }

      fetch();
      widget.refreshStatus();
      return "Success";
    } catch (err) {
      print('[FormF] Error uploading: $err');
      setState(() => loading = false);
      widget.refreshStatus();
      rethrow;
    }
  }

  void onChange(int? value) async {
    if (value == null) return;
    
    print('[FormF] onChange called with value: $value');
    setState(() {
      enableButton = value == 1;
      groupValue = value;
    });

    try {
      final result = await _repository.checkAdditionalReport(
        ppmTaskId: widget.id,
        hasAdditionalReport: value == 1,
      );

      if (result == PPMActionResult.success) {
        print('[FormF] Check status saved successfully');
      } else {
        print('[FormF] Check status queued for offline sync');
      }

      widget.refreshStatus();
    } catch (err) {
      print('[FormF] Error saving check status: $err');
    }
  }

  void _openViewer({String? path, String? src}) => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ImageViewer(path: path, url: src)));

  // Future<Uint8List?> compressFile(File file) async {
  //   final compressedBytes = await FlutterImageCompress.compressWithFile(
  //     file.absolute.path,
  //     quality: Platform.isIOS ? 60 : 100,
  //     minWidth: 540,
  //     minHeight: 720,
  //   );
    
  //   if (compressedBytes == null) {
  //     return null;
  //   }
  //   return Uint8List.fromList(compressedBytes);
  // }
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

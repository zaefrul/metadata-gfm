import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gfm_gems/utils/image_compressor.dart';
import 'package:intl/intl.dart';
import 'package:gfm_gems/controller/PPM/Form/openImage.dart';
import 'package:gfm_gems/model/workorder.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gfm_gems/view/dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../main.dart';

class ComplaintSectionC extends StatefulWidget {
  final String id;
  final bool disable;

  const ComplaintSectionC(this.id, this.disable, {Key? key}) : super(key: key);

  @override
  _ComplaintSectionCState createState() => _ComplaintSectionCState();
}

class _ComplaintSectionCState extends State<ComplaintSectionC> {
  // FINAL VARIABLE: Section Titles
  final List<String> _sectionName = [
    "Image Before",
    "Image During",
    "Image After"
  ];

  // IMMUTABLE VARIABLES
  late Provider _provider;
  bool _loading = false;
  List<Widget> _children = [];
  Map<String, String> _notes = {};

  @override
  void initState() {
    super.initState();
    // Initialize with a header title
    _children = [
      _getTitle(
          "Requires at least one photo for each of the following image section below:")
    ];

    _provider = Provider(
        taskID: widget.id,
        fetchURL: "/api/m_wo.php?type=wo_repair_images&woTaskId=");
    _fetchImages();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    _provider.context = context;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: colorTheme3),
        title: _getTitle("D. Image", bold: true),
      ),
      body: _loading
          ? Stack(
              children: <Widget>[
                _builtBody,
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              ],
            )
          : _builtBody,
      floatingActionButton: widget.disable
          ? null
          : FloatingActionButton.extended(
              label: Text("Save"),
              backgroundColor: colorTheme2,
              onPressed: _notes.isNotEmpty ? () => _postNotes() : null,
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget get _builtBody {
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: _children,
    );
  }

  Widget _getTitle(String text, {bool bold = false}) => Container(
      alignment: Alignment.centerLeft,
      child: Text(text,
          style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: colorTheme3)));

  Widget _emptySection(int index) {
    return Column(
      children: <Widget>[
        ListTile(
            contentPadding: EdgeInsets.only(top: 6.0),
            leading: Icon(Icons.camera_alt),
            title: Text("Tap to upload image"),
            onTap: widget.disable ? null : () => _createUploadItem(index)),
        TextField(
          enabled: false,
          decoration: InputDecoration(labelText: "Image Description"),
        )
      ],
    );
  }

  Widget _section(TechnicianImageRepair item) {
    var iconButton = IconButton(
      icon: Icon(Icons.delete),
      color: Colors.red,
      onPressed: widget.disable ? null : () { _delete(item.woTaskUploadId); },
    );

    var latitude = item.woTaskUploadLatitude;
    var longitude = item.woTaskUploadLongitude;
    var src = "http:" + item.documentSrc;

    return Column(
      children: <Widget>[
        ListTile(
          contentPadding: EdgeInsets.only(top: 6.0),
          leading: Image.network(src),
          trailing: widget.disable ? null : iconButton,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(item.woTaskUploadTimestamp),
              Text(latitude + ", " + longitude)
            ],
          ),
          onTap: () async =>
              _bottomSheet(latitude: latitude, longitude: longitude, src: src),
        ),
        TextField(
          controller:
              TextEditingController(text: item.woTaskUploadDesc),
          enabled: !widget.disable,
          decoration: InputDecoration(
            labelText: "Image Description",
          ),
          onChanged: (text) {
            _notes[item.woTaskUploadId] = text;
          },
        )
      ],
    );
  }

  void _fetchImages() {
    _provider.context = context;
    setState(() {
      _loading = true;
    });
    _provider.fetch().then((response) {
      var value = response.technicianImages?.toList() ?? [];
      _notes = {};

      TechnicianImageRepair? before;
      List<TechnicianImageRepair> during = [];
      TechnicianImageRepair? after;

      if (value.isNotEmpty) {
        for (var f in value) {
          _notes[f.woTaskUploadId] = f.woTaskUploadDesc;
          if (f.woTaskUploadType == "Before") {
            before = f;
          } else if (f.woTaskUploadType == "During") {
            during.add(f);
          } else if (f.woTaskUploadType == "After") {
            after = f;
          }
        }
      }

      List<dynamic> sectionItem = [before, during, after];
      _generateChildren(sectionItem);
      setState(() {
        _loading = false;
      });
    }).catchError((err) {
      _generateChildren([null, [null, null, null], null]);
      setState(() {
        _loading = false;
      });
    });
  }

  void _generateChildren(List<dynamic> sectionItem) {
    _children = [
      _getTitle(
          "Requires at least one photo for each of the following image section below:")
    ];

    for (var i = 0; i < 3; i++) {
      _children.add(SizedBox(height: 20.0));
      _children.add(_getTitle(_sectionName[i], bold: true));
      var item = sectionItem[i];
      if (item == null) {
        // Add an empty section if the item is null
        _children.add(_emptySection(i));
      } else if (item is TechnicianImageRepair) {
        // Add a single section if the item is a TechnicianImageRepair
        _children.add(_section(item));
      } else if (item is List) {
        // Handle lists of TechnicianImageRepair
        if (item.isEmpty || item.every((element) => element == null)) {
          _children.add(_emptySection(i));
        } else {
          for (var j = 0; j < item.length; j++) {
            if (item[j] != null) {
              _children.add(_section(item[j]));
            }
          }
        }
      } else {
        // Fallback to an empty section for unexpected cases
        _children.add(_emptySection(i));
      }

      debugPrint("User is disable: ${widget.disable}");
    }
  }

  void _createUploadItem(int number) async {
    dynamic latitude;
    dynamic longitude;

    Future<File?> getImage() async {
      var value = await ImagePicker().pickImage(source: ImageSource.camera);
      if (value != null) {
        return File(value.path);
      }
      return null;
    }

    Future<bool> openLocationSetting() async {
      final prefs = await SharedPreferences.getInstance();
      latitude = prefs.getString(prefsLATITUDE) ?? "0.0";
      longitude = prefs.getString(prefsLONGITUDE) ?? "0.0";
      return !(latitude == "0.0" || longitude == "0.0");
    }

    String date() => DateFormat('kk:mm:ss EEE d MMM').format(DateTime.now());

    void createObject(File file) async {
      final bytes = await compressFile(file, settings: {
        'quality': Platform.isIOS ? 20 : 60,
        'minWidth': 480,
        'minHeight': 640,
      }) ?? Uint8List(0);
      String size = bytes.length.toString();
      String base64Image = base64Encode(bytes);

      String filename = "${file.path}.jpg";

      UploadItem uploadItem = UploadItem(
        "upload_repair_image",
        widget.id,
        date: date(),
        uploadType: (number + 2).toString(),
        longitude: latitude,
        latitude: longitude,
        name: "Image Repair",
        filename: filename,
        size: size,
        data: base64Image,
      );
      _postImage(uploadItem);
    }

    setState(() {
      _loading = true;
    });

    if (await openLocationSetting()) {
      File? imageFile = await getImage();
      if (imageFile != null) {
        createObject(imageFile);
      } else {
        setState(() {
          _loading = false;
        });
      }
    } else {
      Toast.show("Please Relogin");
      setState(() {
        _loading = false;
      });
    }
  }

  void _postImage(UploadItem item) {
    _provider.context = context;
    _provider.post(url: "/api/m_wo.php", body: item.body).then((value) {
      _alert(value);
      _fetchImages();
    }).catchError((err) {
      _alert(err.toString());
    }).whenComplete(() {
      setState(() {
        _loading = false;
      });
    });
  }

  void _postNotes() {
    setState(() {
      _loading = true;
    });
    UploadDesc uploadDesc = UploadDesc("save_wo_repair_image_desc", widget.id, notes: _notes);
    _provider.context = context;
    _provider.post(url: "/api/m_wo.php", body: uploadDesc.body).then((value) {
      _notes = {};
      setState(() {
        _loading = false;
      });
      _alert(value, backOneScreen: true);
      _fetchImages();
    }).catchError((err) {
      setState(() {
        _loading = false;
      });
      _alert(err.toString());
    });
  }

  void _delete(String id) {
    setState(() {
      _loading = true;
    });
    _provider.context = context;
    _provider
        .delete(url: "/api/m_wo.php?action=delete_wo_repair_image&woTaskId=${widget.id}&woTaskUploadId=$id")
        .then((value) {
      _fetchImages();
    }).catchError((err) {
      print(err);
    });
  }

  void _bottomSheet({required String latitude, required String longitude, required String src}) {
    Future<void> _openMap() async {
      String googleUrl =
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
      String appleUrl = 'https://maps.apple.com/?sll=$latitude,$longitude';

      if (await canLaunch(googleUrl))
        await launch(googleUrl);
      else if (await canLaunch(appleUrl))
        await launch(appleUrl);
      else
        throw 'Could not launch url';
    }

    _openViewer() {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => ImageViewer(url: src)));
    }

    showModalBottomSheet(
        context: navigatorKey.currentContext!,
        builder: (BuildContext bc) => Container(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                      leading: Icon(Icons.image),
                      title: Text('View Image'),
                      onTap: () => _openViewer()),
                  ListTile(
                      leading: Icon(Icons.map),
                      title: Text('Open Map'),
                      onTap: () => _openMap()),
                ],
              ),
            ));
  }

  void _alert(String desc, {bool? backOneScreen = false}) {
    showDialog(
        context: navigatorKey.currentContext!,
        builder: (BuildContext context) => CustomDialog(
            goBackOnDismiss: backOneScreen,
            description: desc,
            buttonText: "Okay",
            image: Image.asset(
              "assets/icon_trans.png",
              height: 40,
            )));
  }
}

class UploadItem extends Upload {
  final String uploadType;
  final String longitude;
  final String latitude;
  String name;
  final String filename;
  final String size;
  final String type = "data:image/jpeg;base64";
  final String data;
  final String date;

  UploadItem(
    action,
    ppmTaskId, {
    required this.date,
    required this.uploadType,
    required this.longitude,
    required this.latitude,
    required this.name,
    required this.filename,
    required this.size,
    required this.data,
  }) : super(action: action, ppmTaskId: ppmTaskId);

  @override
  Map<String, dynamic> get body => {
        "action": action,
        "woTaskId": ppmTaskId,
        "uploadType": uploadType,
        "longitude": longitude,
        "latitude": latitude,
        "fileUpload[name]": name,
        "fileUpload[filename]": filename,
        "fileUpload[size]": size,
        "fileUpload[type]": type,
        "fileUpload[data]": data,
      };
}

class UploadDesc extends Upload {
  final Map<String, String> notes;

  UploadDesc(action, ppmTaskId, {required this.notes})
      : super(action: action, ppmTaskId: ppmTaskId);

  @override
  Map<String, String> get body {
    Map<String, String> b = {"action": action, "woTaskId": ppmTaskId};
    int i = 0;
    for (var key in notes.keys) {
      b["woTaskUpload[$i][woTaskUploadId]"] = key;
      b["woTaskUpload[$i][woTaskUploadDesc]"] = notes[key]!;
      i++;
    }
    return b;
  }
}

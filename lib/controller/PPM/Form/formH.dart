import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gfm_gems/controller/PPM/Form/openImage.dart';
import 'package:gfm_gems/model/form.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gfm_gems/view/dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_native_image_v2/flutter_native_image_v2.dart';

class FormH extends StatefulWidget {
  final String id;
  final bool verified;
  final bool disable;
  final Function refreshStatus;

  const FormH(
    this.id,
    this.verified,
    this.refreshStatus,
    this.disable, {
    Key? key,
  }) : super(key: key);

  @override
  _FormHState createState() => _FormHState();
}

class _FormHState extends State<FormH> {
  // FINAL VARIABLE
  final List<String> _sectionName = [
    "Image Before",
    "Image During",
    "Image After"
  ];

  // IMMUTABLE VARIABLES
  late Provider _provider;
  bool _loading = false;
  late List<Widget> _children = [];
  Map<String, String> _notes = {};

  @override
  void initState() {
    super.initState();
    _children = [
      _getTitle(
          "Requires at least one photo for each of the following image section below:")
    ];

    _provider = Provider(
      taskID: widget.id,
      fetchURL: "/api/m_ppm.php?type=ppm_section_h&ppmTaskId=",
    );
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    _provider.context = context;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: colorTheme3),
        title: _getTitle("C. Maintenance Image", bold: true),
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
              onPressed: () => widget.verified
                  ? _notes.isNotEmpty
                      ? _postNotes()
                      : null
                  : Toast.show("Please verified this task."),
            ),
    );
  }

  // WIDGETS

  Widget _getTitle(String text, {bool bold = false}) => Container(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: colorTheme3),
        ),
      );

  Widget? get _floatingButton {
    return widget.disable
        ? null
        : FloatingActionButton.extended(
            label: Text("Save"),
            backgroundColor: colorTheme2,
            onPressed: () => widget.verified
                ? _notes.isNotEmpty
                    ? _postNotes()
                    : null
                : Toast.show("Please verified this task."),
          );
  }

  Widget get _builtBody {
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: _children,
    );
  }

  Widget _emptySection(int index) {
    return Column(
      children: <Widget>[
        ListTile(
          contentPadding: EdgeInsets.only(top: 6.0),
          leading: Icon(Icons.camera_alt),
          title: Text("Tap to upload image"),
          onTap: () async =>
              widget.disable ? null : _createUploadItem(index),
        ),
        TextField(
          enabled: false,
          decoration: InputDecoration(labelText: "Image Description"),
        )
      ],
    );
  }

  Widget _section(FormHItem item) {
    var iconButton = IconButton(
      icon: Icon(Icons.delete),
      color: Colors.red,
      onPressed: widget.disable
          ? null
          : () {
              _delete(item.ppmTaskUploadId);
            },
    );

    var latitude = item.ppmTaskUploadLatitude;
    var longitude = item.ppmTaskUploadLongitude;
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
              Text(item.ppmTaskUploadTimestamp),
              Text("$latitude, $longitude"),
            ],
          ),
          onTap: () async =>
              _bottomSheet(latitude: latitude, longitude: longitude, src: src),
        ),
        TextField(
          controller: TextEditingController(text: item.ppmTaskUploadDesc),
          enabled: !widget.disable,
          decoration: InputDecoration(
            labelText: "Image Description",
          ),
          onChanged: (text) {
            _notes[item.ppmTaskUploadId] = text;
          },
        )
      ],
    );
  }

  // FUNCTIONALITY - API

  void _fetch() {
    setState(() => _loading = true);

    _provider.fetch().then((response) {
      var value = response.sectionHList?.toList() ?? [];
      _notes = {};

      FormHItem? before;
      List<FormHItem> during = [];
      FormHItem? after;

      if (value.isNotEmpty) {
        for (var f in value) {
          _notes[f.ppmTaskUploadId] = f.ppmTaskUploadDesc;
          if (f.ppmTaskUploadType == "Before")
            before = f;
          else if (f.ppmTaskUploadType == "During")
            during.add(f);
          else if (f.ppmTaskUploadType == "After") after = f;
        }
      }

      List<dynamic> sectionItem = [before, during, after];

      _generateChildren(sectionItem);

      setState(() => _loading = false);
    }).catchError((err) {
      _generateChildren([null, [null, null, null], null]);
      setState(() => _loading = false);
    });
  }

  void _postImage(UploadItem item) {
    _provider.post(url: "/api/m_ppm.php", body: item.body).then((value) {
      widget.refreshStatus();
      _alert(value);
      _fetch();
    }).catchError((err) {
      setState(() => _loading = false);
      _alert(err);
    });
  }

  void _postNotes() {
    setState(() => _loading = true);

    var uploadDesc = UploadDesc("save_image_desc", widget.id, notes: _notes);

    _provider.post(url: "/api/m_ppm.php", body: uploadDesc.body).then((value) {
      _notes = {};
      setState(() => _loading = false);
      _alert(value);
      _fetch();
    }).catchError((err) {
      setState(() => _loading = false);
      _alert(err);
    });
  }

  void _delete(String id) {
    setState(() => _loading = true);
    _provider
        .delete(
            url:
                "/api/m_ppm.php?action=delete_ppm_maintenance_image&ppmTaskUploadId=$id")
        .then((value) {
      _fetch();
    }).catchError((err) {
      print(err);
    }).whenComplete(() {
      widget.refreshStatus();
    });
  }

  // FUNCTIONALITY - CUSTOM

  void _generateChildren(List<dynamic> sectionItem) {
    _children = [
      _getTitle(
          "Requires at least one photo for each of the following image section below:")
    ];

    for (var i = 0; i < 3; i++) {
      _children.add(SizedBox(height: 20.0));
      _children.add(_getTitle(_sectionName[i], bold: true));
      var item = sectionItem[i];

      if (item is FormHItem) {
        _children.add(_section(item));
      } else if (item is List) {
        List<FormHItem> duringList = item.cast<FormHItem>();
        for (var j = 0; j < 3; j++) {
          if (j < duringList.length)
            _children.add(_section(duringList[j]));
          else
            _children.add(_emptySection(i));
        }
      } else if (item == null) {
        _children.add(_emptySection(i));
      }
    }
  }

  void _createUploadItem(int number) async {
    var latitude;
    var longitude;

    Future<File> getImage() async {
      var value = await ImagePicker().pickImage(source: ImageSource.camera);
      if (value != null) return File(value.path);
      throw "No image selected";
    }

    Future<bool> openLocationSetting() async {
      var prefs = await SharedPreferences.getInstance();
      latitude = prefs.getString(prefsLATITUDE) ?? "0.0";
      longitude = prefs.getString(prefsLONGITUDE) ?? "0.0";
      return (latitude != "0.0" && longitude != "0.0");
    }

    String date() =>
        DateFormat('kk:mm:ss EEE d MMM').format(DateTime.now());

    void createObject(File file) async {
      final bytes = await compressFile(file);
      String size = bytes.length.toString();
      String base64Image = base64Encode(bytes);
      String desc = "${file.path}.jpg";

      print(desc);
      print(size);

      UploadItem uploadItem = UploadItem(
        "upload_maintenance_image",
        widget.id,
        date: date(),
        uploadType: number.toString(),
        longitude: latitude,
        latitude: latitude,
        name: desc,
        filename: desc,
        size: size,
        data: base64Image,
      );

      _postImage(uploadItem);
    }

    setState(() => _loading = true);

    if (await openLocationSetting()) {
      getImage().then((value) {
        createObject(value);
      }).catchError((err) {
        setState(() => _loading = false);
      });
    } else {
      setState(() => _loading = true);
    }
  }

  Future<List<int>> compressFile(File file) async {
    File compressedFile = await FlutterNativeImage.compressImage(
      file.absolute.path,
      quality: Platform.isIOS ? 60 : 100,
      targetWidth: 540,
      targetHeight: 720,
    );
    final bytes = await compressedFile.readAsBytes();
    print("Original file size: ${file.lengthSync()}");
    print("Compressed file size: ${bytes.length}");
    return bytes;
  }

  Widget _bottomSheet({required String latitude, required String longitude, required String src}) {
    _openMap() async {
      final googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
      final appleUrl = 'https://maps.apple.com/?sll=$latitude,$longitude';
      final Uri googleUri = Uri.parse(googleUrl);
      final Uri appleUri = Uri.parse(appleUrl);
      if (await canLaunchUrl(googleUri))
        await launchUrl(googleUri);
      else if (await canLaunchUrl(appleUri))
        await launchUrl(appleUri);
      else
        throw 'Could not launch url';
    }

    _openViewer() => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ImageViewer(url: src)),
        );

    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) => Container(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.image),
              title: Text('View Image'),
              onTap: () => _openViewer(),
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text('Open Map'),
              onTap: () => _openMap(),
            ),
          ],
        ),
      ),
    );
    return Container();
  }

  void _alert(String desc) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        description: desc,
        buttonText: "Okay",
        image: Image.asset("assets/icon_trans.png", height: 40),
      ),
    );
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
    String action,
    String ppmTaskId, {
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
        "ppmTaskId": ppmTaskId,
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

  UploadDesc(
    String action,
    String ppmTaskId, {
    required this.notes,
  }) : super(action: action, ppmTaskId: ppmTaskId);

  @override
  Map<String, String> get body {
    Map<String, String> b = {"action": action, "ppmTaskId": ppmTaskId};
    var i = 0;
    for (var key in notes.keys) {
      b["ppmTaskUpload[$i][ppmTaskUploadId]"] = key;
      b["ppmTaskUpload[$i][ppmTaskUploadDesc]"] = notes[key]!;
      i++;
    }
    return b;
  }
}

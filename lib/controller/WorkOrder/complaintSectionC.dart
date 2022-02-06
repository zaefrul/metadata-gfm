import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gfm_gems/controller/PPM/Form/openImage.dart';
import 'package:gfm_gems/model/workorder.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:image_picker/image_picker.dart';

import 'package:gfm_gems/view/dialog.dart';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class ComplaintSectionC extends StatefulWidget {
  final String id;
  final bool disable;

  ComplaintSectionC(this.id, this.disable);

  @override
  _ComplaintSectionCState createState() => _ComplaintSectionCState();
}

class _ComplaintSectionCState extends State<ComplaintSectionC> {
  // FINAL VARIABLE
  final List<String> _sectionName = [
    "Image Before",
    "Image During",
    "Image After"
  ];

  // IMMUTABLE VARIABLE
  Provider _provider;
  bool _loading = false;
  List<Widget> _children;
  Map<String, String> _notes = Map<String, String>();

  @override
  void initState() {
    super.initState();

    _children = [
      _getTitle(
          "Requires at least one photo for each of the following image section below:")
    ];

    _provider = Provider(
        taskID: widget.id,
        fetchURL: "/api/m_wo.php?type=wo_repair_images&woTaskId=");
    _fetch;
  }

  @override
  Widget build(BuildContext context) {
    _provider.context = context;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(
            color: colorTheme3,
          ),
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
        floatingActionButton: _floatingButton);
  }

  // WIDGET
  Widget _getTitle(String text, {bold = false}) => new Container(
      alignment: Alignment.centerLeft,
      child: new Text(text,
          style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: colorTheme3)));

  Widget get _floatingButton {
    return widget.disable
        ? null
        : FloatingActionButton.extended(
            label: new Text("Save"),
            backgroundColor: colorTheme2,
            onPressed: () => _notes.length > 0 ? _postNotes : null,
          );
  }

  Widget get _builtBody {
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: _children,
    );
  }

  Widget _emptySection(int index) {
    return Column(children: <Widget>[
      ListTile(
          contentPadding: EdgeInsets.only(top: 6.0),
          leading: new Icon(Icons.camera_alt),
          title: new Text("Tap to upload image"),
          onTap: () async => widget.disable ? null : _createUploadItem(index)),
      TextField(
        enabled: false,
        decoration: InputDecoration(labelText: "Image Description"),
      )
    ]);
  }

  Widget _section(TechnicianImageRepair item) {
    var iconButton = new IconButton(
      icon: new Icon(Icons.delete),
      color: Colors.red,
      onPressed: widget.disable
          ? null
          : () {
              _delete(item.woTaskUploadId);
            },
    );

    var latitude = item.woTaskUploadLatitude;
    var longitude = item.woTaskUploadLongitude;
    var src = "http:" + item.documentSrc;

    return Column(children: <Widget>[
      ListTile(
          contentPadding: EdgeInsets.only(top: 6.0),
          leading: new Image.network(src),
          trailing: widget.disable ? null : iconButton,
          title: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text(item.woTaskUploadTimestamp),
              new Text(latitude + ", " + longitude)
            ],
          ),
          onTap: () async =>
              _bottomSheet(latitude: latitude, longitude: longitude, src: src)),
      TextField(
        controller: TextEditingController(text: item.woTaskUploadDesc),
        enabled: !widget.disable,
        decoration: InputDecoration(
          labelText: "Image Description",
        ),
        onChanged: (text) {
          _notes[item.woTaskUploadId] = text;
        },
      )
    ]);
  }

  // MARK: FUNCTIONALITY - API

  void get _fetch {
    if (context != null) _provider.context = context;

    _provider.fetch().then((response) {
      var value = response.technicianImages.toList();
      _notes = Map<String, String>();

      TechnicianImageRepair before;
      List<TechnicianImageRepair> during = List<TechnicianImageRepair>();
      TechnicianImageRepair after;

      if (value != null && value.length > 0) {
        value.forEach((f) => _notes[f.woTaskUploadId] = f.woTaskUploadDesc);

        value.forEach((f) {
          if (f.woTaskUploadType == "Before")
            before = f;
          else if (f.woTaskUploadType == "During")
            during.add(f);
          else if (f.woTaskUploadType == "After") after = f;
        });
      }

      List<dynamic> sectionItem = [before, during, after];

      _generateChildren(sectionItem);

      setState(() => _loading = false);
    }).catchError((err) {
      _generateChildren([
        null,
        [null, null, null],
        null
      ]);
      setState(() => _loading = false);
    });
  }

  void _postImage(UploadItem item) {
    if (context != null) _provider.context = context;

    _provider.post(url: "/api/m_wo.php", body: item.body).then((value) {
      _alert(value);

      return _fetch;
    }).catchError((err) {
      _alert(err);
    }).whenComplete(() => setState(() => _loading = false));
  }

  void get _postNotes {
    setState(() => _loading = true);

    var uploadDesc =
        UploadDesc("save_wo_repair_image_desc", widget.id, notes: _notes);

    if (context != null) _provider.context = context;

    _provider.post(url: "/api/m_wo.php", body: uploadDesc.body).then((value) {
      _notes = Map<String, String>();

      setState(() => _loading = false);
      _alert(value);

      return _fetch;
    }).catchError((err) {
      setState(() => _loading = false);
      _alert(err);
    });
  }

  void _delete(String id) {
    setState(() => _loading = true);

    if (context != null) _provider.context = context;

    _provider
        .delete(
            url:
                "/api/m_wo.php?action=delete_wo_repair_image&woTaskId=${widget.id}&woTaskUploadId=$id")
        .then((value) {
      return _fetch;
    }).catchError((err) {
      print(err);
    });
  }

  // MARK: FUNCTIONALITY - CUSTOM

  void _generateChildren(List<dynamic> sectionItem) {
    _children = [
      _getTitle(
          "Requires at least one photo for each of the following image section below:")
    ];

    for (var i = 0; i < 3; i++) {
      _children.add(new SizedBox(height: 20.0));
      _children.add(_getTitle(_sectionName[i], bold: true));
      var item = sectionItem[i];

      if (item is TechnicianImageRepair) {
        _children.add(_section(item));
      } else if (item is List) {
        List<TechnicianImageRepair> during = item;
        for (var j = 0; j < 3; j++)
          if (during != null) {
            if (j < during.length && during[j] != null)
              _children.add(_section(during[j]));
            else
              _children.add(_emptySection(i));
          } else
            _children.add(_emptySection(i));
      } else if (item == null) {
        _children.add(_emptySection(i));
      }
    }
  }

  void _createUploadItem(int number) async {
    var latitude;
    var longitude;

    Future<File> getImage() async {
      var value = await ImagePicker.pickImage(source: ImageSource.camera);
      return value;
    }

    Future<bool> openLocationSetting() async {
      var prefs = await SharedPreferences.getInstance();
      latitude = prefs.getString(prefsLATITUDE) ?? "0.0";
      longitude = prefs.getString(prefsLONGITUDE) ?? "0.0";

      if (latitude == "0.0" || longitude == "0.0") return false;
      return true;
    }

    String date() => DateFormat('kk:mm:ss EEE d MMM').format(DateTime.now());

    void createObject(File file) async {
      final bytes = await compressFile(file);
      String size = bytes.length.toString();
      String base64Image = base64Encode(bytes);

      String desc = "${file.path}.jpg";

      UploadItem uploadItem = UploadItem(
        "upload_repair_image",
        widget.id,
        date: date(),
        uploadType: (number + 2).toString(),
        longitude: longitude,
        latitude: latitude,
        name: "Image Repair",
        filename: desc,
        size: size,
        data: base64Image,
      );

      _postImage(uploadItem);
    }

    setState(() => _loading = true);

    if (await openLocationSetting()) {
      getImage().then((value) {
        if (value == null)
          setState(() => _loading = false);
        else
          createObject(value);
      }).catchError((err) => setState(() => _loading = false));
    } else {
      Toast.show("Please Relogin", context);
      setState(() => _loading = true);
    }
  }

  // MARK: FUNCTIONALITY - WIDGET

  Future<List<int>> compressFile(File file) async {
    var result = await FlutterImageCompress.compressWithFile(file.absolute.path,
        quality: Platform.isIOS ? 20 : 60, minWidth: 480, minHeight: 640);
    print(file.lengthSync());
    print(result.length);
    return result;
  }

  Widget _bottomSheet({latitude, longitude, src}) {
    _openMap() async {
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

    _openViewer() => Navigator.push(context,
        MaterialPageRoute(builder: (context) => ImageViewer(url: src)));

    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) => Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.image),
                      title: new Text('View Image'),
                      onTap: () => _openViewer()),
                  new ListTile(
                      leading: new Icon(Icons.map),
                      title: new Text('Open Map'),
                      onTap: () => _openMap()),
                ],
              ),
            ));
  }

  void _alert(String desc) {
    showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
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
    this.date,
    this.uploadType,
    this.longitude,
    this.latitude,
    this.name,
    this.filename,
    this.size,
    this.data,
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

  UploadDesc(action, ppmTaskId, {this.notes})
      : super(action: action, ppmTaskId: ppmTaskId);

  @override
  Map<String, String> get body {
    Map<String, String> b = {"action": action, "woTaskId": ppmTaskId};

    var i = 0;

    for (var key in notes.keys) {
      b["woTaskUpload[$i][woTaskUploadId]"] = key;
      b["woTaskUpload[$i][woTaskUploadDesc]"] = notes[key];
      i++;
    }

    return b;
  }
}

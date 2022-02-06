import 'dart:convert';
import 'dart:io';

import 'package:gfm_gems/controller/PPM/Form/openImage.dart';
import 'package:gfm_gems/model/form.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:gfm_gems/model/responseValue.dart';
import 'package:gfm_gems/view/dialog.dart';
import 'package:gfm_gems/view/field.dart';

import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:android_intent/android_intent.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FormH extends StatefulWidget {
  final String id;
  final bool verified;
  final Function refreshStatus;
  final bool disable;

  FormH(this.id, this.verified, this.refreshStatus, this.disable);

  @override
  _FormHState createState() => _FormHState();
}

class _FormHState extends State<FormH> {
  Provider provider;
  String latitude;
  String longitude;
  bool loading = false;

  ResponseValue responseValue;
  List<UploadItem> uploadItems = List<UploadItem>();
  Map<String, String> mapNotes = Map<String, String>();

  Future<File> getImage() async => await ImagePicker.pickImage(
      source: ImageSource.camera, maxWidth: 900, maxHeight: 1600);

  @override
  void initState() {
    super.initState();

    this.provider = Provider(
        taskID: widget.id,
        fetchURL: "/api/m_ppm.php?type=ppm_section_h&ppmTaskId=");

    getItems();
  }

  @override
  Widget build(BuildContext context) {
    this.provider.context = context;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: colorTheme3,
        ),
        title: getTitle("H. Maintance Image", bold: true),
      ),
      body: body(responseValue == null
          ? null
          : responseValue.sectionHList == null
              ? null
              : responseValue.sectionHList.toList()),
      floatingActionButton: widget.disable
          ? null
          : FloatingActionButton.extended(
              label: new Text("Save"),
              backgroundColor: colorTheme2,
              onPressed: () => widget.verified
                  ? post()
                  : Toast.show("Please verified this task.", context),
            ),
    );
  }

  Widget body(List<FormHItem> items) {
    if (items != null)
      items.forEach((f) => mapNotes[f.ppmTaskUploadId] = f.ppmTaskUploadDesc);

    return new ListView(
      padding: EdgeInsets.all(16.0),
      children: <Widget>[
        getTitle(
            "Requires at least one photo for each of the following image section below:"),
        new SizedBox(
          height: 20.0,
        ),
        getTitle("Image Before", bold: true),
        getSection(0,
            item: items == null
                ? null
                : items.length >= 1
                    ? items[0]
                    : null),
        new SizedBox(
          height: 12.0,
        ),
        getTitle("Image During", bold: true),
        getSection(1,
            item: items == null
                ? null
                : items.length >= 2
                    ? items[1]
                    : null),
        getSection(2,
            item: items == null
                ? null
                : items.length >= 3
                    ? items[2]
                    : null),
        getSection(3,
            item: items == null
                ? null
                : items.length >= 4
                    ? items[3]
                    : null),
        new SizedBox(
          height: 12.0,
        ),
        getTitle("Image After", bold: true),
        getSection(4,
            item: items == null
                ? null
                : items.length >= 5
                    ? items[4]
                    : null),
        new SizedBox(
          height: 100.0,
        ),
      ],
    );
  }

  Widget getTitle(String text, {bold = false}) => new Container(
        alignment: Alignment.centerLeft,
        child: new Text(text,
            style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: colorTheme3)),
      );

  ListTile getTile(int number, {UploadItem uploadItem, FormHItem item}) {
    String date() => DateFormat('kk:mm:ss EEE d MMM').format(DateTime.now());

    openBottomSheet() =>
        _settingModalBottomSheet(context, item1: uploadItem, item2: item);

    void createObject(File file) async {
      final bytes = await file.readAsBytes();
      String size = bytes.length.toString();
      String base64Image = base64Encode(bytes);
      String desc = "";

      UploadItem uploadItem = UploadItem("upload_maintenance_image", widget.id,
          date: date(),
          uploadType: (number == 4)
              ? "2"
              : (number == 2 || number == 3)
                  ? "1"
                  : number.toString(),
          longitude: longitude,
          latitude: latitude,
          name: desc,
          filename: "$number.jpg",
          size: size,
          data: base64Image,
          index: number);

      setState(() => uploadItems.add(uploadItem));
    }

    uploadImage() async {
      // var geo = Geolocator();
      // GeolocationStatus geolocationStatus =
      //     await geo.checkGeolocationPermissionStatus();
      // if (await geo.isLocationServiceEnabled()) {
      //   Position position = await geo.getCurrentPosition(
      //       desiredAccuracy: LocationAccuracy.high);
      //   if (geolocationStatus == GeolocationStatus.granted) {
      //     latitude = position.latitude.toString();
      //     longitude = position.longitude.toString();
      //     if (position != null) {
      //       setState(() {
      //         loading = true;
      //       });
      //       await getImage().then((value) {
      //         createObject(value);
      //         setState(() {
      //           loading = false;
      //         });
      //       });
      //     }
      //   }
      // } else {
      //   openLocationSetting;
      // }
    }

    var leading = uploadItem == null
        ? (item == null
            ? new Icon(Icons.camera_alt)
            : new Image.network("http:" + item.documentSrc))
        : Image.memory(base64Decode(uploadItem.data));

    var iconButton = new IconButton(
      icon: new Icon(Icons.delete),
      color: Colors.red,
      onPressed: () {
        delete(item.ppmTaskUploadId);
        if (uploadItems.length > 0)
          uploadItems.remove((test) => setState(() => test == uploadItem));
      },
    );

    var trailing;

    if (uploadItem != null)
      trailing = iconButton;
    else if (item != null)
      trailing = iconButton;
    else if (widget.disable == false) trailing = iconButton;

    Column row(String firstText, String secondText) => new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[new Text(firstText), new Text(secondText)],
        );

    var title = uploadItem == null
        ? (item == null
            ? new Text("tapped to upload image")
            : row(
                item.ppmTaskUploadTimestamp,
                item.ppmTaskUploadLatitude +
                    ", " +
                    item.ppmTaskUploadLongitude))
        : row(uploadItem.date,
            "Latitude: " + uploadItem.latitude + ", " + uploadItem.longitude);

    return ListTile(
        contentPadding: EdgeInsets.only(top: 6.0),
        leading: leading,
        trailing: trailing,
        title: title,
        onTap: () async => uploadItem == null
            ? item == null
                ? (widget.disable ? null : uploadImage())
                : openBottomSheet()
            : openBottomSheet());
  }

  Column getSection(int number, {FormHItem item}) {
    var uploadItem = uploadItems.length == 0
        ? null
        : uploadItems.firstWhere((test) => test.index == number,
            orElse: () => null);

    void note(String text) {
      if (item == null)
        mapNotes["$number"] = text;
      else
        mapNotes[item.ppmTaskUploadId] = text;
    }

    return Column(children: <Widget>[
      getTile(number, item: item, uploadItem: uploadItem),
      field(
          "Image ${number == 0 ? (number + 1) : (number == 4 ? 1 : number)} - Description",
          (text) => note,
          horizontal: 0,
          value: uploadItem == null
              ? (item == null ? "" : item.ppmTaskUploadDesc)
              : uploadItem.name,
          enable: !widget.disable),
    ]);
  }

  Future getItems() {
    return provider.fetch().then((value) {
      setState(() => responseValue = value);
      return Future.value();
    }).catchError((err) {
      setState(() => responseValue = null);
      return Future.error(err);
    });
  }

  void get openLocationSetting async {
    final AndroidIntent intent = new AndroidIntent(
      action: 'android.settings.LOCATION_SOURCE_SETTINGS',
    );
    await intent.launch();
  }

  void delete(String id) async {
    await provider
        .delete(
            url:
                "/api/m_ppm.php?action=delete_ppm_maintenance_image&ppmTaskUploadId=$id")
        .then((value) {
      widget.refreshStatus();
      return getItems();
    }).catchError((err) {
      print(err);
    });
  }

  void post() async {
    setState(() {
      loading = true;
    });
    uploadItems.forEach((f) async {
      var keys = mapNotes.keys.toList();
      for (var i = 0; i < keys.length; i++) {
        var key = keys[i];
        if (f.index == int.parse(keys[i])) f.name = mapNotes[key];
      }

      await provider.post(url: "/api/m_ppm.php", body: f.body).then((value) {
        setState(() {
          loading = false;
          uploadItems = List<UploadItem>();
        });
        widget.refreshStatus();

        alert(value);
        return getItems();
      }).catchError((err) {
        setState(() {
          loading = false;
        });
        alert(err);
      });
    });

    if (uploadItems.length == 0) {
      var uploadDesc =
          UploadDesc("save_image_desc", widget.id, notes: mapNotes);

      provider.post(url: "/api/m_ppm.php", body: uploadDesc.body).then((value) {
        setState(() {
          loading = false;
        });

        return getItems();
      }).catchError((err) {
        print(err);
      });
    }
  }

  void _settingModalBottomSheet(context, {UploadItem item1, FormHItem item2}) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.image),
                    title: new Text('View Image'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ImageViewer(
                                  url: item2.documentSrc,
                                )),
                      );
                    }),
                new ListTile(
                  leading: new Icon(Icons.map),
                  title: new Text('Open Map'),
                  onTap: () {
                    var _latitude = item1 == null
                        ? item2.ppmTaskUploadLatitude
                        : item1.latitude;
                    var _longitude = item1 == null
                        ? item2.ppmTaskUploadLongitude
                        : item1.longitude;
                    openMap(_latitude, _longitude);
                  },
                ),
              ],
            ),
          );
        });
  }

  void openMap(latitudeHere, longitudeHere) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitudeHere,$longitudeHere';
    String appleUrl =
        'https://maps.apple.com/?sll=$latitudeHere,$longitudeHere';
    if (await canLaunch(googleUrl)) {
      print('launching com googleUrl');
      await launch(googleUrl);
    } else if (await canLaunch(appleUrl)) {
      print('launching apple url');
      await launch(appleUrl);
    } else {
      throw 'Could not launch url';
    }
  }

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
  final int index;

  UploadItem(action, ppmTaskId,
      {this.date,
      this.uploadType,
      this.longitude,
      this.latitude,
      this.name,
      this.filename,
      this.size,
      this.data,
      this.index})
      : super(action: action, ppmTaskId: ppmTaskId);

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

  UploadDesc(action, ppmTaskId, {this.notes})
      : super(action: action, ppmTaskId: ppmTaskId);

  @override
  Map<String, String> get body {
    Map<String, String> b = {"action": action, "ppmTaskId": ppmTaskId};

    var i = 0;

    for (var key in notes.keys) {
      b["ppmTaskUpload[$i][ppmTaskUploadId]"] = key;
      b["ppmTaskUpload[$i][ppmTaskUploadDesc]"] = notes[key];
      i++;
    }

    return b;
  }
}

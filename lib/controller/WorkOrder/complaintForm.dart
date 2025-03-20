import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
// Removed flutter_image_compress; using flutter_native_image instead:
import 'package:flutter_native_image_v2/flutter_native_image_v2.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:gfm_gems/controller/PPM/Form/openImage.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:gfm_gems/view/dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class FormComplaint extends StatefulWidget {
  @override
  _FormComplaintState createState() => _FormComplaintState();
}

class _FormComplaintState extends State<FormComplaint> {
  String location = "abcdef";
  String desc = "";
  bool loading = false;
  List<UploadItem> listItem = List<UploadItem>();
  String dropdownLocation;
  String dropdownArea;

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    var body = ListView(
      children: <Widget>[
        SizedBox(height: 12),
        _locationCode,
        // _locationDropdown,
        // _areaDropdown,
        _descComplaint,
        _addPhoto,
        listItem.length >= 1 ? _section(listItem[0]) : Container(),
        listItem.length >= 2 ? _section(listItem[1]) : Container(),
        listItem.length >= 3 ? _section(listItem[2]) : Container(),
      ],
    );
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Add Complaint",
            style: TextStyle(color: colorTheme3),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: loading
            ? Stack(
                children: <Widget>[
                  body,
                  Container(
                    child: Center(child: CircularProgressIndicator()),
                    height: double.infinity,
                    width: double.infinity,
                    color: Colors.black.withOpacity(0.4),
                  )
                ],
              )
            : body,
        floatingActionButton: FloatingActionButton.extended(
            label: Text("Submit"),
            backgroundColor: colorTheme2,
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => CustomDialog(
                        cancel: true,
                        description: "Do you confirm want to submit?",
                        buttonText: "Yes",
                        image: Image.asset(
                          "assets/icon_trans.png",
                          height: 40,
                        ),
                        okayTapped: () {
                          Navigator.pop(context);
                          _upload();
                        },
                      ));
            }),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget get _locationCode {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        decoration: InputDecoration(labelText: "* Location"),
        onChanged: ((text) => location = text),
      ),
    );
  }

  Widget get _locationDropdown {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: DropdownButton<String>(
        value: dropdownLocation,
        iconSize: 24,
        elevation: 16,
        hint: Text("Location"),
        underline: Container(
          height: 1,
          color: Colors.grey,
        ),
        isExpanded: true,
        onChanged: (String newValue) {
          setState(() {
            dropdownLocation = newValue;
          });
        },
        items: <String>['One', 'Two', 'Free', 'Four']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  Widget get _areaDropdown {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: DropdownButton<String>(
        value: dropdownArea,
        iconSize: 24,
        elevation: 16,
        hint: Text("Location Code"),
        underline: Container(
          height: 1,
          color: Colors.grey,
        ),
        isExpanded: true,
        onChanged: (String newValue) {
          setState(() {
            dropdownArea = newValue;
          });
        },
        items: <String>['One', 'Two', 'Free', 'Four']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  Widget get _descComplaint {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        decoration:
            InputDecoration(labelText: "* Description of Complaint"),
        keyboardType: TextInputType.multiline,
        maxLength: 1000,
        maxLines: null,
        onChanged: (value) => desc = value,
      ),
    );
  }

  Widget get _addPhoto {
    var title = Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Text(
          "Photo",
          style: TextStyle(fontWeight: FontWeight.bold),
        ));
    var subtitle = Text(
        "(Maximum of 3 images, Individual file should not larger than 5mb)");
    var plustext = Text(
      "+",
      style: TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
    );
    var plus = MaterialButton(
      shape: CircleBorder(),
      height: 25,
      child: plustext,
      color: listItem.length == 3
          ? colorTheme2.withOpacity(0.5)
          : colorTheme2,
      onPressed: listItem.length == 3 ? null : () => _createUploadItem(),
    );

    return ListTile(
      title: title,
      subtitle: subtitle,
      trailing: plus,
    );
  }

  Widget _section(UploadItem item) {
    var iconButton = IconButton(
      icon: Icon(Icons.delete),
      color: Colors.red,
      onPressed: () =>
          setState(() => listItem.removeWhere((value) => value == item)),
    );

    var _latitude = item.latitude;
    var _longitude = item.longitude;
    var date = item.date;
    var src = item.file;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(children: <Widget>[
        ListTile(
            contentPadding: EdgeInsets.only(top: 6.0),
            leading: Image.file(src),
            trailing: iconButton,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(date),
                Text(_latitude + ", " + _longitude)
              ],
            ),
            onTap: () async => _bottomSheet(
                latitude: _latitude, longitude: _longitude, src: src)),
        TextField(
          decoration: InputDecoration(hintText: "Remark"),
          onChanged: (text) {
            item.desc = text;
          },
        )
      ]),
    );
  }

  void _bottomSheet({latitude, longitude, src}) {
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
        MaterialPageRoute(builder: (context) => ImageViewer(file: src)));

    showModalBottomSheet(
        context: context,
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

  void _createUploadItem() async {
    var latitude;
    var longitude;

    Future<File> getImage() async {
      var value = await ImagePicker().pickImage(source: ImageSource.camera);

      if (value != null) {
        final file = File(value.path);
        return file;
      }
      return null;
    }

    // Updated compressFile function using flutter_native_image.
    Future<List<int>> compressFile(File file) async {
      File compressedFile = await FlutterNativeImage.compressImage(
        file.absolute.path,
        quality: Platform.isIOS ? 20 : 60,
        targetWidth: 480,
        targetHeight: 640,
      );
      final result = await compressedFile.readAsBytes();
      print("Original file size: ${file.lengthSync()}");
      print("Compressed file size: ${result.length}");
      return result;
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
      String name = "${date()}.jpg";

      if (int.parse(size) > 5000000) {
        Toast.show("File size more than 5mb, please try again.");
        return;
      }

      UploadItem uploadItem = UploadItem(
          file: file,
          date: date(),
          desc: "",
          longitude: longitude,
          latitude: latitude,
          name: name,
          filename: name,
          size: size,
          data: base64Image,
          i: listItem.length);

      setState(() => listItem.add(uploadItem));
    }

    if (await openLocationSetting()) {
      getImage()
          .then((value) => createObject(value))
          .catchError((err) => print(err));
    } else
      Toast.show("Please allow permission location for camera");
  }

  void _upload() async {
    var latitude;
    var longitude;

    if (location.length == 0) {
      Toast.show("Location at least 8 characters");
      return;
    }
    if (desc.length <= 8) {
      Toast.show("Description at least 8 characters");
      return;
    }

    Future<bool> openLocationSetting() async {
      var prefs = await SharedPreferences.getInstance();
      latitude = prefs.getString(prefsLATITUDE) ?? "0.0";
      longitude = prefs.getString(prefsLONGITUDE) ?? "0.0";

      if (latitude == "0.0" || longitude == "0.0") return false;
      return true;
    }

    if (await openLocationSetting()) {
      var body = {
        "action": "submit_complain",
        "woTaskLocation": location,
        "woTaskComplaint": desc,
        "woTaskLongitude": longitude,
        "woTaskLatitude": latitude,
      };

      listItem.forEach((f) => body.addAll(f.body));

      setState(() => loading = true);

      Provider provider = Provider();
      provider.context = context;

      provider.post(url: "/api/m_wo.php", body: body).then((value) {
        setState(() => loading = false);
        alert(txt: value);
      }).catchError((err) {
        print(err);
        alert(err: err.toString());
      }).whenComplete(() => setState(() => loading = false));
    } else
      Toast.show("Please allow permission location for camera");
  }

  void alert({String txt, String err}) {
    showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
            rootPage: err != null ? null : "/workorder",
            description: err != null ? err : txt,
            buttonText: "Okay",
            image: Image.asset(
              "assets/icon_trans.png",
              height: 40,
            )));
  }
}

class UploadItem {
  final File file;
  final String longitude;
  final String latitude;
  String name;
  final String filename;
  final String size;
  final String type = "data:image/jpeg:base64";
  final String data;
  final String date;
  String desc;
  int i;

  UploadItem(
      {this.file,
      this.date,
      this.longitude,
      this.latitude,
      this.name,
      this.filename,
      this.desc,
      this.size,
      this.data,
      this.i});

  Map<String, String> get body => {
        "complaintImages[$i][longitude]": longitude,
        "complaintImages[$i][latitude]": latitude,
        "complaintImages[$i][description]": desc,
        "complaintImages[$i][name]": name,
        "complaintImages[$i][filename]": filename,
        "complaintImages[$i][size]": size,
        "complaintImages[$i][type]": type,
        "complaintImages[$i][data]": data,
      };
}

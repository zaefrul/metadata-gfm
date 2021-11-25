import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gfm_gems/model/responseValue.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/view/dialog.dart';
import 'package:toast/toast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../utils/reference.dart';
import '../../view/button.dart';
import '../../view/field.dart';
import '../../model/user.dart';
import '../PPM/Form/openImage.dart';

class Edit extends StatefulWidget {
  final User user;

  Edit(this.user);

  @override
  _EditState createState() => _EditState();
}

class _EditState extends State<Edit> {
  String name = "";
  String contact = "";
  String imageSrc;
  bool loading = false;
  var path;
  var bytes;
  String size;
  String base64Image;
  String desc;

  @override
  void initState() {
    super.initState();

    name = widget.user.firstName;
    contact = widget.user.contactNo;
    imageSrc = widget.user.imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    Widget image = new Image.asset(
      "assets/profile.png",
      height: 100,
    );

    if (imageSrc.length > 0)
      image = Container(
        height: 120.0,
        width: 120.0,
        decoration: new BoxDecoration(
          image: DecorationImage(
            image: new NetworkImage("http:" + imageSrc),
            fit: BoxFit.fitWidth,
          ),
          shape: BoxShape.circle,
        ),
      );

    if (path != null)
      image = Container(
        height: 120.0,
        width: 120.0,
        decoration: new BoxDecoration(
          image: DecorationImage(
            image: new FileImage(File(path)),
            fit: BoxFit.fitWidth,
          ),
          shape: BoxShape.circle,
        ),
      );

    var body = new Column(
      children: <Widget>[
        SizedBox(height: 40),
        GestureDetector(
            child: image,
            onTap: () {
              _bottomSheet();
            }),
        SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            _bottomSheet();
          },
          child: new Text(
            "Change Profile Picture",
            style: TextStyle(color: colorTheme1),
          ),
        ),
        SizedBox(height: 30),
        field("Name", (text) {
          name = text;
        }, secure: false, value: name),
        field("Contact No", (text) {
          contact = text;
        }, secure: false, value: contact, phoneType: true),
        SizedBox(height: 80),
        new Container(
            width: 200,
            height: 50,
            child: Button(
              text: "Done",
              onPressed: () {
                action;
              },
              color: colorTheme2,
            ))
      ],
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          title: title("Edit Profile"),
          backgroundColor: Colors.white,
          centerTitle: true,
          iconTheme: IconThemeData(color: colorTheme3)),
      body: loading
          ? new Stack(
              children: <Widget>[
                body,
                new Container(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                  color: Colors.black.withOpacity(0.5),
                )
              ],
            )
          : body,
    );
  }

  Widget title(text, {double size = 30.0}) => new Text(text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: colorTheme3,
        fontFamily: 'Avenir',
        fontSize: size,
        fontWeight: FontWeight.bold,
      ));

  get action async {
    setState(() => loading = true);

    var bodyProvider = {
      "action": "edit_profile",
    };

    if (name != widget.user.firstName) bodyProvider["name"] = name;
    if (contact != widget.user.contactNo) bodyProvider["phoneNo"] = contact;
    if (path != null) {
      bodyProvider["fileUpload[name]"] = name;
      bodyProvider["fileUpload[filename]"] = desc;
      bodyProvider["fileUpload[size]"] = size;
      bodyProvider["fileUpload[type]"] = "data:image/jpeg;base64";
      bodyProvider["fileUpload[data]"] = base64Image;
    }

    if (bodyProvider.length == 1) {
      Toast.show("Nothing to update", context);
      setState(() => loading = false);
      return;
    }

    Provider provider = Provider();

    provider
        .post(url: "/api/m_ppm.php", body: bodyProvider)
        .then((value) => setState(() async {
              ResponseValue response = value as ResponseValue;
              String src = response.result;
              widget.user.updateProfile(
                  name,
                  contact,
                  src == null
                      ? imageSrc
                      : src.length == 0
                          ? imageSrc
                          : src);
              alert(response.errmsg);
            }))
        .catchError((err) => alert(err, success: false))
        .whenComplete(() => setState(() => loading = false));
  }

  void alert(String txt, {bool success = true}) => showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
          rootPage: success ? "/profile" : null,
          description: txt,
          buttonText: "Okay",
          image: Image.asset(
            "assets/icon_trans.png",
            height: 40,
          )));

  Widget _bottomSheet() {
    Future<File> getImageCamera() async {
      if (Platform.isIOS) {
        var value = await ImagePicker.pickImage(source: ImageSource.camera);
        var result = await FlutterImageCompress.compressWithFile(
          value.path,
          minWidth: 480,
          minHeight: 640,
        );
        return await File(value.path).writeAsBytes(result);
      }

      var value = await ImagePicker.pickImage(
          source: ImageSource.camera, maxWidth: 480, maxHeight: 640);

      return value;
    }

    Future<File> getImageGallery() async {
      if (Platform.isIOS) {
        var value = await ImagePicker.pickImage(source: ImageSource.camera);
        var result = await FlutterImageCompress.compressWithFile(
          value.path,
          minWidth: 480,
          minHeight: 640,
        );
        return await File(value.path).writeAsBytes(result);
      }
      var value = await ImagePicker.pickImage(
          source: ImageSource.gallery, maxWidth: 480, maxHeight: 640);

      return value;
    }

    void viewImage() {
      ImageViewer viewer;
      if (path != null)
        viewer = ImageViewer(
          path: path,
        );
      else if (imageSrc != null) viewer = ImageViewer(url: "http:" + imageSrc);
      Navigator.push(context, MaterialPageRoute(builder: (context) => viewer));
    }

    void setImage(File file) async {
      Navigator.of(context).pop();
      setState(() => path = file.path);
      bytes = await compressFile(file);
      size = bytes.length.toString();
      base64Image = base64Encode(bytes);
      desc = "${file.path}.jpg";
    }

    var children = <Widget>[
      new ListTile(
          leading: new Icon(Icons.camera),
          title: new Text('Open Camera'),
          onTap: () => getImageCamera().then((value) => setImage(value))),
      new ListTile(
          leading: new Icon(Icons.image),
          title: new Text('Open Gallery'),
          onTap: () => getImageGallery().then((value) => setImage(value))),
    ];

    if (imageSrc.length > 0 || path != null) {
      children.add(new ListTile(
          leading: new Icon(Icons.visibility),
          title: new Text('View Image'),
          onTap: () => viewImage()));
    }

    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) => Container(
              child: new Wrap(children: children),
            ));
  }

  Future<List<int>> compressFile(File file) async {
    var result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: 60,
    );
    print(file.lengthSync());
    print(result.length);
    return result;
  }
}

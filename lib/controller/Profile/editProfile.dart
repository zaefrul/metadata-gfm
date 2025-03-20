import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gfm_gems/model/responseValue.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/view/dialog.dart';
import 'package:toast/toast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_native_image_v2/flutter_native_image_v2.dart';

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
  String path; // storing path as String for simplicity
  List<int> bytes;
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
    ToastContext().init(context);

    Widget image = Image.asset(
      "assets/profile.png",
      height: 100,
    );

    if (imageSrc.length > 0)
      image = Container(
        height: 120.0,
        width: 120.0,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage("http:" + imageSrc),
            fit: BoxFit.fitWidth,
          ),
          shape: BoxShape.circle,
        ),
      );

    if (path != null)
      image = Container(
        height: 120.0,
        width: 120.0,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: FileImage(File(path)),
            fit: BoxFit.fitWidth,
          ),
          shape: BoxShape.circle,
        ),
      );

    var bodyContent = Column(
      children: <Widget>[
        SizedBox(height: 40),
        GestureDetector(
          child: image,
          onTap: () {
            _bottomSheet();
          },
        ),
        SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            _bottomSheet();
          },
          child: Text(
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
        Container(
          width: 200,
          height: 50,
          child: Button(
            text: "Done",
            onPressed: () {
              action;
            },
            color: colorTheme2,
          ),
        )
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
          ? Stack(
              children: <Widget>[
                bodyContent,
                Container(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                  color: Colors.black.withOpacity(0.5),
                )
              ],
            )
          : bodyContent,
    );
  }

  Widget title(text, {double size = 30.0}) => Text(text,
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
      Toast.show("Nothing to update");
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

  /// A helper method to pick an image (from camera or gallery), compress it,
  /// and return the compressed File.
  Future<File> getCompressedImage(ImageSource source) async {
    var picked = await ImagePicker().pickImage(
        source: source, maxWidth: 480, maxHeight: 640);
    if (picked == null) return null;
    File originalFile = File(picked.path);
    File compressedFile = await FlutterNativeImage.compressImage(
      originalFile.path,
      quality: 60,
      targetWidth: 480,
      targetHeight: 640,
    );
    return compressedFile;
  }

  // Now getImageCamera and getImageGallery simply call the helper:
  Future<File> getImageCamera() async {
    return getCompressedImage(ImageSource.camera);
  }

  Future<File> getImageGallery() async {
    return getCompressedImage(ImageSource.gallery);
  }

  void viewImage() {
    ImageViewer viewer;
    if (path != null)
      viewer = ImageViewer(
        path: path,
      );
    else
      viewer = ImageViewer(url: "http:" + imageSrc);
    Navigator.push(context, MaterialPageRoute(builder: (context) => viewer));
  }

  void setImage(File file) async {
    Navigator.of(context).pop();
    if (file == null) return;
    setState(() => path = file.path);
    // Compress again if needed (or simply read the compressed file's bytes):
    bytes = await compressFile(File(file.path));
    size = bytes.length.toString();
    base64Image = base64Encode(bytes);
    desc = "${file.path}.jpg";
  }

  /// Updated compressFile to use flutter_native_image.
  Future<List<int>> compressFile(File file) async {
    File compressedFile = await FlutterNativeImage.compressImage(
      file.absolute.path,
      quality: 60,
      targetWidth: 480,
      targetHeight: 640,
    );
    final compressedBytes = await compressedFile.readAsBytes();
    print("Original file size: ${file.lengthSync()}");
    print("Compressed file size: ${compressedBytes.length}");
    return compressedBytes;
  }

  Widget _bottomSheet() {
    var children = <Widget>[
      ListTile(
          leading: Icon(Icons.camera),
          title: Text('Open Camera'),
          onTap: () => getImageCamera().then((value) => setImage(value))),
      ListTile(
          leading: Icon(Icons.image),
          title: Text('Open Gallery'),
          onTap: () => getImageGallery().then((value) => setImage(value))),
    ];

    if (imageSrc.length > 0 || path != null) {
      children.add(ListTile(
          leading: Icon(Icons.visibility),
          title: Text('View Image'),
          onTap: () => viewImage()));
    }

    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) => Container(
              child: Wrap(children: children),
            ));
    return Container();
  }
}

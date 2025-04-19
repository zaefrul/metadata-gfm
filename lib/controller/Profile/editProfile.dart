import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gfm_gems/model/responseValue.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/view/dialog.dart';
import 'package:toast/toast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gfm_gems/utils/image_compressor.dart';

import '../../utils/reference.dart';
import '../../view/button.dart';
import '../../view/field.dart';
import '../../model/user.dart';
import '../PPM/Form/openImage.dart';

class Edit extends StatefulWidget {
  final User user;

  const Edit(this.user, {Key? key}) : super(key: key);

  @override
  _EditState createState() => _EditState();
}

class _EditState extends State<Edit> {
  String name = "";
  String contact = "";
  String imageSrc = "";
  bool loading = false;
  String? path; // storing path as String for simplicity
  List<int>? bytes;
  String? size;
  String? base64Image;
  String? desc;

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

    if (imageSrc.isNotEmpty) {
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
    }

    if (path != null) {
      image = Container(
        height: 120.0,
        width: 120.0,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: FileImage(File(path!)),
            fit: BoxFit.fitWidth,
          ),
          shape: BoxShape.circle,
        ),
      );
    }

    final bodyContent = Column(
      children: <Widget>[
        const SizedBox(height: 40),
        GestureDetector(
          child: image,
          onTap: _bottomSheet,
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _bottomSheet,
          child: Text(
            "Change Profile Picture",
            style: TextStyle(color: colorTheme1),
          ),
        ),
        const SizedBox(height: 30),
        field("Name", (text) {
          name = text;
        }, secure: false, value: name),
        field("Contact No", (text) {
          contact = text;
        }, secure: false, value: contact, phoneType: true),
        const SizedBox(height: 80),
        Container(
          width: 200,
          height: 50,
          child: Button(
            text: "Done",
            onPressed: _action,
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
        iconTheme: IconThemeData(color: colorTheme3),
      ),
      body: loading
          ? Stack(
              children: <Widget>[
                bodyContent,
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              ],
            )
          : bodyContent,
    );
  }

  Widget title(String text, {double size = 30.0}) => Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: colorTheme3,
          fontFamily: 'Avenir',
          fontSize: size,
          fontWeight: FontWeight.bold,
        ),
      );

  Future<void> _action() async {
    setState(() => loading = true);

    var bodyProvider = {
      "action": "edit_profile",
    };

    if (name != widget.user.firstName) bodyProvider["name"] = name;
    if (contact != widget.user.contactNo) bodyProvider["phoneNo"] = contact;
    if (path != null) {
      bodyProvider["fileUpload[name]"] = name;
      bodyProvider["fileUpload[filename]"] = desc ?? "";
      bodyProvider["fileUpload[size]"] = size ?? "";
      bodyProvider["fileUpload[type]"] = "data:image/jpeg;base64";
      bodyProvider["fileUpload[data]"] = base64Image ?? "";
    }

    if (bodyProvider.length == 1) {
      Toast.show("Nothing to update");
      setState(() => loading = false);
      return;
    }

    Provider provider = Provider(fetchURL: "/api/m_ppm.php");

    provider
        .post(url: "/api/m_ppm.php", body: bodyProvider)
        .then((value) async {
      ResponseValue response = value as ResponseValue;
      String src = response.result ?? "";
      widget.user.updateProfile(
          name,
          contact,
          (src == null || src.isEmpty) ? imageSrc : src);
      alert(response.errmsg);
    }).catchError((err) {
      alert(err.toString(), success: false);
    }).whenComplete(() => setState(() => loading = false));
  }

  void alert(String txt, {bool success = true}) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        rootPage: success ? "/profile" : "",
        description: txt,
        buttonText: "Okay",
        image: Image.asset(
          "assets/icon_trans.png",
          height: 40,
        ),
      ),
    );
  }

  Future<File?> getImageCamera() async {
    return getCompressedImage(ImageSource.camera);
  }

  Future<File?> getImageGallery() async {
    return getCompressedImage(ImageSource.gallery);
  }

  void viewImage() {
    ImageViewer viewer;
    if (path != null) {
      viewer = ImageViewer(path: path);
    } else {
      viewer = ImageViewer(url: "http:" + imageSrc);
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => viewer));
  }

  void _bottomSheet() {
    List<Widget> children = [
      ListTile(
          leading: const Icon(Icons.camera),
          title: const Text('Open Camera'),
          onTap: () => getImageCamera().then((value) {
                if (value != null) setImage(value);
              })),
      ListTile(
          leading: const Icon(Icons.image),
          title: const Text('Open Gallery'),
          onTap: () => getImageGallery().then((value) {
                if (value != null) setImage(value);
              })),
    ];

    if (imageSrc.isNotEmpty || path != null) {
      children.add(ListTile(
          leading: const Icon(Icons.visibility),
          title: const Text('View Image'),
          onTap: viewImage));
    }

    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) => Container(
              child: Wrap(children: children),
            ));
  }

  void setImage(File file) async {
    Navigator.of(context).pop();
    setState(() {
      path = file.path;
    });
    bytes = await compressFile(File(file.path), settings: {
      'quality': Platform.isIOS ? 60 : 100,
      'minWidth': 480,
      'minHeight': 640
    });
    size = bytes!.length.toString();
    base64Image = base64Encode(bytes!);
    desc = "${file.path}.jpg";
  }
}

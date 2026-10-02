import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:GEMS/view/gems_chrome.dart';
import 'package:GEMS/model/responseValue.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/view/dialog.dart';
import 'package:toast/toast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:GEMS/utils/image_compressor.dart';

import '../../view/field.dart';
import '../../model/user.dart';
import '../PPM/Form/openImage.dart';
import '../../main.dart';

class Edit extends StatefulWidget {
  final User user;

  const Edit(this.user, {super.key});

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
            image: NetworkImage("http:$imageSrc"),
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

    final bodyContent = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _bottomSheet,
            child: image,
          ),
          TextButton(
            onPressed: _bottomSheet,
            child: Text(
              'Change profile picture',
              style: GemsChrome.body(weight: FontWeight.w600, color: GemsChrome.primary),
            ),
          ),
          const SizedBox(height: 8),
          GemsFormSection(
            title: 'Profile',
            icon: Icons.person_outline,
            child: Column(
              children: [
                field(
                  'Name',
                  (text) => name = text,
                  value: name,
                  outlined: true,
                  horizontal: 0,
                ),
                const SizedBox(height: 12),
                field(
                  'Contact No',
                  (text) => contact = text,
                  value: contact,
                  phoneType: true,
                  outlined: true,
                  horizontal: 0,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            style: gemsPrimaryButton(),
            onPressed: loading ? null : _action,
            child: Text(
              'Save',
              style: GemsChrome.body(weight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: GemsChrome.page,
      appBar: gemsAppBar(
        title: const Text('Edit Profile'),
      ),
      body: loading
          ? Stack(
              children: <Widget>[
                bodyContent,
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(color: GemsChrome.primary),
                  ),
                )
              ],
            )
          : bodyContent,
    );
  }

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
          (src.isEmpty) ? imageSrc : src);
      alert(response.errmsg);
    }).catchError((err) {
      alert(err.toString(), success: false);
    }).whenComplete(() => setState(() => loading = false));
  }

  void alert(String txt, {bool success = true}) {
    showDialog(
      context: navigatorKey.currentContext!,
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
      viewer = ImageViewer(url: "http:$imageSrc");
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => viewer));
  }

  void _bottomSheet() {
    List<Widget> children = [
      ListTile(
          leading: const Icon(Icons.photo_camera_outlined, color: GemsChrome.primary),
          title: Text('Open Camera', style: GemsChrome.body()),
          onTap: () => getImageCamera().then((value) {
                if (value != null) setImage(value);
              })),
      ListTile(
          leading: const Icon(Icons.image_outlined, color: GemsChrome.primary),
          title: Text('Open Gallery', style: GemsChrome.body()),
          onTap: () => getImageGallery().then((value) {
                if (value != null) setImage(value);
              })),
    ];

    if (imageSrc.isNotEmpty || path != null) {
      children.add(ListTile(
          leading: const Icon(Icons.visibility_outlined, color: GemsChrome.primary),
          title: Text('View Image', style: GemsChrome.body()),
          onTap: viewImage));
    }

    showModalBottomSheet(
        context: navigatorKey.currentContext!,
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

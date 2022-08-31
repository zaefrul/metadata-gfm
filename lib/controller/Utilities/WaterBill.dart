import 'dart:convert';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/PPM/Form/openImage.dart';
import 'package:gfm_gems/model/meter.dart';
import 'package:gfm_gems/model/serializers.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

import 'package:toast/toast.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:url_launcher/url_launcher.dart';

class WaterBillScreen extends StatefulWidget {
  final bool isMontly;
  final bool isDaily;

  WaterBillScreen({this.isDaily = false, this.isMontly = false});

  @override
  _WaterBillScreenState createState() =>
      _WaterBillScreenState(isMontly: isMontly, isDaily: isDaily);
}

class _WaterBillScreenState extends State<WaterBillScreen> {
  final List<TextEditingController> _controllers = [];
  final f = new DateFormat('yyyy-MM-dd');
  final BehaviorSubject<Meter> dropdownValue = BehaviorSubject<Meter>();
  List<File> listItem = [];
  List<Meter> list = [];

  _WaterBillScreenState({bool isDaily = false, bool isMontly = false}) {
    _controllers.addAll(List.generate(2, (index) => TextEditingController()));

    dropdownValue.listen((event) {
      if (isDaily) _controllers.first.text = event.meterName;
    });
  }

  @override
  void dispose() {
    dropdownValue.close();
    _controllers.forEach((element) => element.dispose());
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    final Provider _providerMeter = Provider(fetchURL: "/utility_meter/Water");
    _providerMeter.context = context;

    _providerMeter.getJson().then((value) {
      final values = deserializeListOf<Meter>(value).toList();
      setState(() {
        list = values;
      });
      if (dropdownValue.value == null) dropdownValue.sink.add(list.first);
    }).catchError((err) => Toast.show(err));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Water Bill : ${widget.isDaily ? 'Daily' : 'Monthly'}"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: list.length == 0
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Container(
              child: ListView(
                padding: EdgeInsets.all(12),
                children: [
                  if (widget.isDaily) _Daily(_controllers, _filter(list)),
                  if (widget.isMontly) _Monthly(_controllers, _filter(list)),
                  _addPhoto,
                  if (listItem.length == 1) _section(listItem[0]),
                  if (listItem.length == 2) _section(listItem[1]),
                  if (listItem.length == 3) _section(listItem[2]),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: confirmation, label: Text("Submit")),
    );
  }

  void confirmation() {
    FocusScope.of(context).unfocus();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Confirmation"),
        content: Text("Are you confirm to submit the bill?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              submit();
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> submit() async {
    bool checkEmpty = false;
    List<TextEditingController> tempCtrl = [];

    checkEmpty = _controllers.firstWhere((element) => element.text.isEmpty,
            orElse: () => null) !=
        null;
    if (checkEmpty) {
      Toast.show("Please check all fields");
      return "Please check all fields";
    }

    if (widget.isDaily) {
      tempCtrl.add(_controllers.last);
    } else {
      tempCtrl.add(_controllers.first);
      tempCtrl.add(_controllers[1]);
    }

    for (var i = 0; i < tempCtrl.length; i++) {
      final ctrl = tempCtrl[i];
      try {
        final _ = double.parse(ctrl.text);
      } catch (err) {
        Toast.show("Please check all fields must be numerical");
        return "Please check all fields must be numerical";
      }
    }

    checkEmpty = listItem.length == 0;

    if (checkEmpty) {
      Toast.show(
        "Please insert image",
      );
      return "Please insert image";
    }

    showDialog(
      context: context,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );

    final Provider _provider = Provider();
    _provider.context = context;

    File file = listItem.first;
    String url = "/utility/Water/";
    String reading;
    String max = "";
    String amount = '';

    final bytes = await compressFile(File(file.path));
    String size = bytes.length.toString();
    String base64Image = base64Encode(bytes);
    String name =
        DateFormat('kk:mm:ss EEE d MMM').format(DateTime.now()) + ".jpg";
    final Image image = Image.file(File(file.path));
    image.image
        .resolve(new ImageConfiguration())
        .completer
        .addListener(ImageStreamListener((info, _) async {
      String height = info.image.height.toString();
      String width = info.image.width.toString();

      if (widget.isDaily) {
        url += "Daily";
        reading = _controllers.last.text;
      } else {
        url += "Monthly";
        reading = _controllers.first.text;
        amount = _controllers[1].text;
      }
      final param = {
        "meterId": dropdownValue.value.meterId,
        "utilityDate": f.format(DateTime.now()),
        "utilityReading": reading,
        "utilityMaxDemand": max,
        'utilityTotalRm': amount,
        'readingImage[name]': "Utility Image",
        'readingImage[filename]': name,
        'readingImage[type]': 'data:image/jpg:base64',
        'readingImage[size]': size,
        'readingImage[data]': base64Image,
        'readingImage[height]': height,
        'readingImage[width]': width,
      };
      _provider.postUtilities(url: url, body: param).then((value) {
        Toast.show("Submitted");

        Navigator.pop(context);
      }).catchError((err) {
        Toast.show(err);
      }).whenComplete(() {
        Navigator.pop(context);
      });
    }));
  }

  Future<List<int>> compressFile(File file) async {
    var result = await FlutterImageCompress.compressWithFile(file.absolute.path,
        quality: Platform.isIOS ? 20 : 60, minWidth: 480, minHeight: 640);
    print(file.lengthSync());
    print(result.length);
    return result;
  }

  Widget _filter(List<Meter> values) => StreamBuilder<Meter>(
      stream: dropdownValue.stream,
      builder: (context, snapshot) {
        return DropdownButton<Meter>(
          underline: new Container(),
          value: snapshot.data,
          hint: Text("Select Location"),
          onChanged: (Meter newValue) => dropdownValue.sink.add(newValue),
          items: values.map<DropdownMenuItem<Meter>>((Meter value) {
            return DropdownMenuItem<Meter>(
              value: value,
              child: Text(value.meterLocation),
            );
          }).toList(),
        );
      });

  Widget get _addPhoto {
    var title = new Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Text(
          "Photo",
          style: TextStyle(fontWeight: FontWeight.bold),
        ));
    var subtitle = new Text(
        "(Maximum of 1 Image only, Individual file should not larger than 5mb)");
    var plustext = new Text(
      "+",
      style: TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
    );
    var plus = MaterialButton(
      shape: CircleBorder(),
      height: 25,
      child: plustext,
      color: colorTheme2.withOpacity(0.5),
      onPressed: () => _createUploadItem(),
    );

    return ListTile(
      title: title,
      subtitle: subtitle,
      trailing: plus,
    );
  }

  void _createUploadItem() async {
    if (listItem.length == 1) {
      Toast.show("Only one picture is required");
      return;
    }
    final value = await ImagePicker().pickImage(source: ImageSource.camera);

    if (value != null) {
      final file = File(value.path);
      setState(() => listItem.add(file));
    }
  }

  Widget _section(File item) {
    var iconButton = new IconButton(
      icon: new Icon(Icons.delete),
      color: Colors.red,
      onPressed: () =>
          setState(() => listItem.removeWhere((value) => value == item)),
    );

    var _latitude =
        "0.0"; //prefs.getString(prefsLATITUDE) ?? "0.0"; //= item.latitude;
    var _longitude =
        "0.0"; //prefs.getString(prefsLONGITUDE) ?? "0.0"; //= item.longitude;

    // var prefs = await SharedPreferences.getInstance();

    var date = DateTime.now().toString(); //= item.date;
    // var src = item.file;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(children: <Widget>[
        ListTile(
            contentPadding: EdgeInsets.only(top: 6.0),
            leading: new Image.file(item),
            trailing: iconButton,
            title: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(date),
                new Text(_latitude + ", " + _longitude)
              ],
            ),
            onTap: () async => _bottomSheet(
                latitude: _latitude, longitude: _longitude, src: item)),
        // TextField(
        //   decoration: InputDecoration(hintText: "Remark"),
        //   onChanged: (text) {
        //     item.desc = text;
        //   },
        // )
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
        child: new Wrap(
          children: <Widget>[
            new ListTile(
              leading: new Icon(Icons.image),
              title: new Text('View Image'),
              onTap: () => _openViewer(),
            ),
            new ListTile(
              leading: new Icon(Icons.map),
              title: new Text('Open Map'),
              onTap: () => _openMap(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Monthly extends StatelessWidget {
  final Widget location;
  final List<TextEditingController> _controllers;
  _Monthly(List<TextEditingController> values, this.location)
      : _controllers = values;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Location"),
        location,
        _Field("Total Usage (35m³)", _controllers.first),
        _Field("Total (RM)", _controllers.last),
      ],
    );
  }
}

class _Daily extends StatelessWidget {
  final Widget location;
  final List<TextEditingController> _controllers;

  _Daily(List<TextEditingController> values, this.location)
      : _controllers = values;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Location"),
        location,
        _Field("Meter No", _controllers.first, enabled: false),
        _Field("Today Reading", _controllers.last),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final bool enabled;
  final TextEditingController controller;

  _Field(this.label, this.controller, {this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      enabled: enabled,
    );
  }
}

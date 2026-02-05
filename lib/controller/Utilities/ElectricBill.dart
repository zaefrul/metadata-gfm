import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:GEMS/controller/PPM/Form/openImage.dart';
import 'package:GEMS/model/meter.dart';
import 'package:GEMS/model/serializers.dart';
import 'package:GEMS/utils/image_compressor.dart';
import 'package:GEMS/utils/biometric_lock_manager.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:GEMS/utils/biometric_lock_manager.dart';
import '../../main.dart';

class ElectricBillScreen extends StatefulWidget {
  final bool isMontly;
  final bool isDaily;

  const ElectricBillScreen({super.key, this.isDaily = false, this.isMontly = false});

  @override
  _ElectricBillScreenState createState() =>
      _ElectricBillScreenState(isMontly: isMontly, isDaily: isDaily);
}

class _ElectricBillScreenState extends State<ElectricBillScreen> {
  final List<TextEditingController> _controllers = [];
  final DateFormat f = DateFormat('yyyy-MM-dd');
  final BehaviorSubject<Meter> dropdownValue = BehaviorSubject<Meter>();
  List<File> listItem = [];
  List<Meter> list = [];

  _ElectricBillScreenState({bool isDaily = false, bool isMontly = false}) {
    if (isDaily) {
      _controllers.addAll(List.generate(3, (index) => TextEditingController()));
    } else if (isMontly) {
      _controllers.addAll(List.generate(4, (index) => TextEditingController()));
    }

    dropdownValue.listen((event) {
      if (isDaily) _controllers.first.text = event.meterName;
      if (isMontly) _controllers.last.text = event.meterName;
    });
  }

  @override
  void dispose() {
    for (var ctrl in _controllers) {
      ctrl.dispose();
    }
    dropdownValue.close();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    final Provider providerMeter =
        Provider(fetchURL: "/utility_meter/Electricity");
    providerMeter.context = context;

    providerMeter.getJson(url: "/utility_meter/Electricity").then((value) {
      final values = deserializeListOf<Meter>(value).toList();
      setState(() {
        list = values;
      });
    }).catchError((err) => Toast.show(err.toString()));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Electric Bill : ${widget.isDaily ? 'Daily' : 'Monthly'}"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: list.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(12),
              children: [
                if (widget.isDaily) _Daily(_controllers, _filter(list)),
                if (widget.isMontly) _Monthly(_controllers, _filter(list)),
                _addPhoto,
                if (listItem.length == 1) _section(listItem[0]),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: confirmation, label: Text("Submit")),
    );
  }

  void confirmation() {
    FocusScope.of(context).unfocus();
    showDialog(
      context: navigatorKey.currentContext!,
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
    FocusScope.of(context).unfocus();
    // Check if any controller text is empty.
    if (_controllers.any((element) => element.text.isEmpty)) {
      Toast.show("Please check all fields");
      return;
    }

    // Depending on type, select controllers.
    List<TextEditingController> tempCtrl = [];
    if (widget.isDaily) {
      tempCtrl.add(_controllers[1]);
      tempCtrl.add(_controllers.last);
    } else {
      tempCtrl.add(_controllers.first);
      tempCtrl.add(_controllers[1]);
      tempCtrl.add(_controllers[2]);
    }

    // Validate each controller's text is numerical.
    for (var ctrl in tempCtrl) {
      try {
        double.parse(ctrl.text);
      } catch (err) {
        Toast.show("Please check all fields must be numerical");
        return;
      }
    }

    if (listItem.isEmpty) {
      Toast.show("Please insert image");
      return;
    }

    showDialog(
        context: navigatorKey.currentContext!,
        builder: (_) => Center(child: CircularProgressIndicator()));

    final Provider provider = Provider(fetchURL: "/utility/Electricity/");
    provider.context = context;

    File file = listItem.first;
    String url = "/utility/Electricity/";
    String reading;
    String max = "";
    String amount = '';

    // Compress the file and get bytes.
    final bytes = await compressFile(File(file.path), settings: {
      'quality': Platform.isIOS ? 20 : 60,
      'minWidth': 480,
      'minHeight': 640,
    }) ?? Uint8List(0);
    String size = bytes.length.toString();
    String base64Image = base64Encode(bytes);
    String name =
        "${DateFormat('kk:mm:ss EEE d MMM').format(DateTime.now())}.jpg";
    final Image image = Image.file(File(file.path));

    // Listen on image resolution.
    image.image
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener((info, _) async {
      String height = info.image.height.toString();
      String width = info.image.width.toString();

      if (widget.isDaily) {
        url += "Daily";
        max = _controllers[1].text;
        reading = _controllers.last.text;
      } else {
        url += "Monthly";
        reading = _controllers.first.text;
        max = _controllers[1].text;
        amount = _controllers[2].text;
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
      provider.postUtilities(url: url, body: param).then((value) {
        Toast.show("Submitted");
        Navigator.pop(context);
      }).catchError((err) {
        Toast.show(err.toString());
      }).whenComplete(() {
        Navigator.pop(context);
      });
    }));
  }

  Widget _filter(List<Meter> values) => StreamBuilder<Meter>(
      stream: dropdownValue.stream,
      builder: (context, snapshot) {
        return DropdownButton<Meter>(
          underline: Container(),
          value: snapshot.data,
          hint: Text("Select Location"),
          onChanged: (Meter? newValue) {
            if (newValue != null) dropdownValue.sink.add(newValue);
          },
          items: values.map<DropdownMenuItem<Meter>>((Meter value) {
            return DropdownMenuItem<Meter>(
              value: value,
              child: Text(value.meterLocation),
            );
          }).toList(),
        );
      });

  Widget get _addPhoto {
    var title = Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Text(
          "Photo",
          style: TextStyle(fontWeight: FontWeight.bold),
        ));
    var subtitle = Text(
        "(Maximum of 1 Image only, Individual file should not larger than 5mb)");
    var plustext = Text(
      "+",
      style: TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
    );
    var plus = MaterialButton(
      shape: CircleBorder(),
      height: 25,
      color: colorTheme2.withOpacity(0.5),
      onPressed: _createUploadItem,
      child: plustext,
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
    final value = await BiometricLockManager.pickImage(
      source: ImageSource.camera,
    );
    if (value != null) {
      final file = File(value.path);
      setState(() => listItem.add(file));
    }
  }

  Widget _section(File item) {
    var iconButton = IconButton(
      icon: Icon(Icons.delete),
      color: Colors.red,
      onPressed: () => setState(() => listItem.remove(item)),
    );

    var latitude = "0.0";
    var longitude = "0.0";
    var date = DateTime.now().toString();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(children: <Widget>[
        ListTile(
            contentPadding: EdgeInsets.only(top: 6.0),
            leading: Image.file(item),
            trailing: iconButton,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(date),
                Text("$latitude, $longitude")
              ],
            ),
            onTap: () async => _bottomSheet(
                latitude: latitude, longitude: longitude, src: item)),
      ]),
    );
  }

  void _bottomSheet({required String latitude, required String longitude, required File src}) {
    Future<void> openMap() async {
      final String googleUrl =
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
      final String appleUrl = 'https://maps.apple.com/?sll=$latitude,$longitude';

      // Use BiometricLockManager to prevent biometric prompt when returning from maps
      if (await canLaunch(googleUrl)) {
        await BiometricLockManager.launchExternalUrlString(googleUrl);
      } else if (await canLaunch(appleUrl)) {
        await BiometricLockManager.launchExternalUrlString(appleUrl);
      } else {
        throw 'Could not launch url';
      }
    }

    void openViewer() => Navigator.push(context,
        MaterialPageRoute(builder: (context) => ImageViewer(file: src)));

    showModalBottomSheet(
      context: navigatorKey.currentContext!,
      builder: (BuildContext bc) => Container(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.image),
              title: Text('View Image'),
              onTap: openViewer,
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text('Open Map'),
              onTap: openMap,
            ),
          ],
        ),
      ),
    );
  }
}

class _Monthly extends StatelessWidget {
  final List<TextEditingController> _controllers;
  final Widget location;
  const _Monthly(List<TextEditingController> values, this.location)
      : _controllers = values;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Select Location"),
        location,
        _Field("Meter No", _controllers.last, enabled: false),
        _Field("Total kWh Consumption", _controllers.first),
        _Field("Maximum Demand", _controllers[1]),
        _Field("Total (RM)", _controllers[2]),
      ],
    );
  }
}

class _Daily extends StatelessWidget {
  final List<TextEditingController> _controllers;
  final Widget location;

  const _Daily(List<TextEditingController> values, this.location)
      : _controllers = values;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Select Location"),
        location,
        _Field("Meter No", _controllers.first, enabled: false),
        _Field("Maximum Demand", _controllers[1], enabled: true),
        _Field("Today Reading", _controllers.last),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final bool enabled;
  final TextEditingController controller;

  const _Field(this.label, this.controller, {this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      enabled: enabled,
    );
  }
}

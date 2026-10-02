import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:GEMS/view/gems_chrome.dart';
import 'package:GEMS/controller/PPM/Form/openImage.dart';
import 'package:GEMS/model/meter.dart';
import 'package:GEMS/model/serializers.dart';
import 'package:GEMS/utils/image_compressor.dart';
import 'package:GEMS/utils/biometric_lock_manager.dart';
import 'package:GEMS/utils/network.dart';
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
  bool _submitting = false;

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
      backgroundColor: GemsChrome.page,
      appBar: gemsAppBar(
        title: Text("Electric Bill : ${widget.isDaily ? 'Daily' : 'Monthly'}"),
      ),
      body: list.isEmpty
          ? const Center(child: CircularProgressIndicator(color: GemsChrome.primary))
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
          backgroundColor: GemsChrome.primary,
          foregroundColor: Colors.white,
          onPressed: _submitting ? null : confirmation,
          label: Text(_submitting ? "Submitting..." : "Submit")),
    );
  }

  void confirmation() {
    if (_submitting) return;
    FocusScope.of(context).unfocus();
    var started = false;
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (_) => AlertDialog(
        title: Text('Confirmation', style: GemsChrome.heading(size: 18)),
        content: Text(
          'Are you confirm to submit the bill?',
          style: GemsChrome.body(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel', style: GemsChrome.body(color: GemsChrome.textSoft)),
          ),
          TextButton(
            onPressed: () {
              if (started) return;
              started = true;
              Navigator.pop(context);
              submit();
            },
            child: Text(
              'OK',
              style: GemsChrome.body(weight: FontWeight.w600, color: GemsChrome.primary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    FocusScope.of(context).unfocus();
    // Check if any controller text is empty.
    if (_controllers.any((element) => element.text.isEmpty)) {
      Toast.show("Please check all fields");
      if (mounted) setState(() => _submitting = false);
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
        if (mounted) setState(() => _submitting = false);
        return;
      }
    }

    if (listItem.isEmpty) {
      Toast.show("Please insert image");
      if (mounted) setState(() => _submitting = false);
      return;
    }

    showDialog(
        context: navigatorKey.currentContext!,
        builder: (_) => const Center(child: CircularProgressIndicator(color: GemsChrome.primary)));

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
        if (mounted) setState(() => _submitting = false);
        Navigator.pop(context);
      });
    }));
  }

  Widget _filter(List<Meter> values) => StreamBuilder<Meter>(
      stream: dropdownValue.stream,
      builder: (context, snapshot) {
        return DropdownButtonFormField<Meter>(
          decoration: gemsFieldDecoration(label: 'Location'),
          isExpanded: true,
          value: snapshot.data,
          hint: Text('Select location', style: GemsChrome.body(color: GemsChrome.muted)),
          style: GemsChrome.body(size: 14),
          onChanged: (Meter? newValue) {
            if (newValue != null) dropdownValue.sink.add(newValue);
          },
          items: values.map<DropdownMenuItem<Meter>>((Meter value) {
            return DropdownMenuItem<Meter>(
              value: value,
              child: Text(value.meterLocation, style: GemsChrome.body(size: 14)),
            );
          }).toList(),
        );
      });

  Widget get _addPhoto {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: GemsFormSection(
        title: 'Photo',
        icon: Icons.photo_camera_outlined,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'One image, up to 5 MB.',
              style: GemsChrome.body(size: 13, color: GemsChrome.textSoft),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _createUploadItem,
              icon: const Icon(Icons.add_a_photo_outlined),
              label: Text(
                'Add photo',
                style: GemsChrome.body(weight: FontWeight.w600, color: GemsChrome.primary),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: GemsChrome.primary,
                side: const BorderSide(color: GemsChrome.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GemsChrome.radius),
                ),
              ),
            ),
          ],
        ),
      ),
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
      icon: const Icon(Icons.delete_outline),
      color: GemsChrome.danger,
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
              leading: const Icon(Icons.image_outlined, color: GemsChrome.primary),
              title: Text('View Image', style: GemsChrome.body()),
              onTap: openViewer,
            ),
            ListTile(
              leading: const Icon(Icons.map_outlined, color: GemsChrome.primary),
              title: Text('Open Map', style: GemsChrome.body()),
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
    return GemsFormSection(
      title: 'Monthly reading',
      icon: Icons.bolt_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          location,
          _Field('Meter No', _controllers.last, enabled: false),
          _Field('Total kWh consumption', _controllers.first),
          _Field('Maximum demand', _controllers[1]),
          _Field('Total (RM)', _controllers[2]),
        ],
      ),
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
    return GemsFormSection(
      title: 'Daily reading',
      icon: Icons.bolt_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          location,
          _Field('Meter No', _controllers.first, enabled: false),
          _Field('Maximum demand', _controllers[1], enabled: true),
          _Field('Today reading', _controllers.last),
        ],
      ),
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
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: TextField(
        controller: controller,
        enabled: enabled,
        style: GemsChrome.body(size: 14),
        decoration: gemsFieldDecoration(label: label, enabled: enabled),
      ),
    );
  }
}

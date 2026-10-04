import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:GEMS/view/gems_chrome.dart';
import 'package:GEMS/controller/PPM/Form/openImage.dart';
import 'package:GEMS/data/repository/utility_repository.dart';
import 'package:GEMS/model/meter.dart';
import 'package:GEMS/utils/image_compressor.dart';
import 'package:GEMS/utils/biometric_lock_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:toast/toast.dart';
// Removed flutter_image_compress import
import 'package:url_launcher/url_launcher.dart';
import '../../main.dart';

class WaterBillScreen extends StatefulWidget {
  final bool isMontly;
  final bool isDaily;

  const WaterBillScreen({super.key, this.isDaily = false, this.isMontly = false});

  @override
  _WaterBillScreenState createState() =>
      _WaterBillScreenState(isMontly: isMontly, isDaily: isDaily);
}

class _WaterBillScreenState extends State<WaterBillScreen> {
  final List<TextEditingController> _controllers = [];
  final f = DateFormat('yyyy-MM-dd');
  final BehaviorSubject<Meter> dropdownValue = BehaviorSubject<Meter>();
  List<File> listItem = [];
  List<Meter> list = [];
  bool _submitting = false;
  bool _loadingMeters = true;
  String? _loadError;

  _WaterBillScreenState({bool isDaily = false, bool isMontly = false}) {
    _controllers.addAll(List.generate(2, (index) => TextEditingController()));

    dropdownValue.listen((event) {
      if (isDaily) _controllers.first.text = event.meterName;
    });
  }

  @override
  void dispose() {
    dropdownValue.close();
    for (var element in _controllers) {
      element.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadMeters();
  }

  Future<void> _loadMeters() async {
    try {
      final values = await UtilityRepository.instance.loadWaterMeters();
      if (!mounted) return;
      setState(() {
        list = values;
        _loadingMeters = false;
      });
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _loadError = err.toString();
        _loadingMeters = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      backgroundColor: GemsChrome.page,
      appBar: gemsAppBar(
        title: Text("Water Bill : ${widget.isDaily ? 'Daily' : 'Monthly'}"),
      ),
      body: _loadingMeters
          ? const Center(child: CircularProgressIndicator(color: GemsChrome.primary))
          : _loadError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_loadError!, textAlign: TextAlign.center),
                  ),
                )
              : ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  if (widget.isDaily)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'The shift is taken from the time you tap Submit. Morning is 06:00–18:00, Evening is 18:00–22:00, and anything else is Night. Before 06:00 counts as the previous day. If there is no network, the reading stays on this phone and is sent automatically later.',
                        style: GemsChrome.body(size: 13, color: GemsChrome.textSoft),
                      ),
                    ),
                  if (widget.isDaily) _Daily(_controllers, _filter(list)),
                  if (widget.isMontly) _Monthly(_controllers, _filter(list)),
                  _addPhoto,
                  if (listItem.length == 1) _section(listItem[0]),
                  if (listItem.length == 2) _section(listItem[1]),
                  if (listItem.length == 3) _section(listItem[2]),
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
    bool checkEmpty = false;
    List<TextEditingController> tempCtrl = [];

    try {
      _controllers.firstWhere((element) => element.text.isEmpty);
      checkEmpty = true;
    } catch (e) {
      checkEmpty = false;
    }
    if (checkEmpty) {
      Toast.show("Please check all fields");
      if (mounted) setState(() => _submitting = false);
      return;
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
        if (mounted) setState(() => _submitting = false);
        return;
      }
    }

    checkEmpty = listItem.isEmpty;

    if (checkEmpty) {
      Toast.show("Please insert image");
      if (mounted) setState(() => _submitting = false);
      return;
    }

    if (!dropdownValue.hasValue) {
      Toast.show('Select a location');
      if (mounted) setState(() => _submitting = false);
      return;
    }

    final capturedAt = DateTime.now();
    final file = listItem.first;
    var url = "/utility/Water/";
    String reading;
    var amount = '';

    final bytes = await compressFile(File(file.path), settings: {
      'quality': Platform.isIOS ? 20 : 60,
      'minWidth': 480,
      'minHeight': 640,
    }) ?? Uint8List(0);
    if (bytes.isEmpty) {
      Toast.show('Could not read the photo');
      if (mounted) setState(() => _submitting = false);
      return;
    }
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final height = frame.image.height.toString();
    final width = frame.image.width.toString();
    frame.image.dispose();

    if (widget.isDaily) {
      url += "Daily";
      reading = _controllers.last.text;
    } else {
      url += "Monthly";
      reading = _controllers.first.text;
      amount = _controllers[1].text;
    }
    final meter = dropdownValue.value;
    final param = <String, String>{
      "meterId": meter.meterId,
      "utilityDate": f.format(capturedAt),
      "utilityReading": reading,
      "utilityMaxDemand": "",
      'utilityTotalRm': amount,
      if (widget.isDaily)
        'utilityCapturedAt': DateFormat('yyyy-MM-dd HH:mm:ss').format(capturedAt),
      'readingImage[name]': "Utility Image",
      'readingImage[filename]':
          "${DateFormat('kk:mm:ss EEE d MMM').format(capturedAt)}.jpg",
      'readingImage[type]': 'data:image/jpeg;base64',
      'readingImage[size]': bytes.length.toString(),
      'readingImage[data]': base64Encode(bytes),
      'readingImage[height]': height,
      'readingImage[width]': width,
    };
    try {
      final result = await UtilityRepository.instance.saveWaterReading(
        url: url,
        fields: param,
        summary: '${meter.meterLocation}: $reading m³',
        meterId: meter.meterId,
        capturedAt: capturedAt,
      );
      if (!mounted) return;
      Toast.show(result.message, duration: 4);
      if (!result.rejected) {
        Navigator.pop(context);
      }
    } catch (err) {
      Toast.show(err.toString(), duration: 4);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
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
            if (newValue != null) {
              dropdownValue.sink.add(newValue);
            }
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
      onPressed: () =>
          setState(() => listItem.removeWhere((value) => value == item)),
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
                Text(latitude + ", " + longitude)
              ],
            ),
            onTap: () async => _bottomSheet(
                latitude: latitude, longitude: longitude, src: item)),
      ]),
    );
  }

  void _bottomSheet({latitude, longitude, src}) {
    openMap() async {
      String googleUrl =
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
      String appleUrl = 'https://maps.apple.com/?sll=$latitude,$longitude';

      // Use BiometricLockManager to prevent biometric prompt when returning from maps
      if (await canLaunch(googleUrl)) {
        await BiometricLockManager.launchExternalUrlString(googleUrl);
      } else if (await canLaunch(appleUrl))
        await BiometricLockManager.launchExternalUrlString(appleUrl);
      else
        throw 'Could not launch url';
    }

    openViewer() => Navigator.push(context,
        MaterialPageRoute(builder: (context) => ImageViewer(file: src)));

    showModalBottomSheet(
      context: navigatorKey.currentContext!,
      builder: (BuildContext bc) => Container(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.image_outlined, color: GemsChrome.primary),
              title: Text('View Image', style: GemsChrome.body()),
              onTap: () => openViewer(),
            ),
            ListTile(
              leading: const Icon(Icons.map_outlined, color: GemsChrome.primary),
              title: Text('Open Map', style: GemsChrome.body()),
              onTap: () => openMap(),
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
  const _Monthly(List<TextEditingController> values, this.location)
      : _controllers = values;

  @override
  Widget build(BuildContext context) {
    return GemsFormSection(
      title: 'Monthly reading',
      icon: Icons.water_drop_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          location,
          _Field('Total usage (m³)', _controllers.first),
          _Field('Total (RM)', _controllers.last),
        ],
      ),
    );
  }
}

class _Daily extends StatelessWidget {
  final Widget location;
  final List<TextEditingController> _controllers;

  const _Daily(List<TextEditingController> values, this.location)
      : _controllers = values;

  @override
  Widget build(BuildContext context) {
    return GemsFormSection(
      title: 'Daily reading',
      icon: Icons.water_drop_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          location,
          _Field('Meter No', _controllers.first, enabled: false),
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

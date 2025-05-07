import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gfm_gems/main.dart';
import 'package:gfm_gems/utils/image_compressor.dart';
import 'package:intl/intl.dart';
import 'package:gfm_gems/controller/PPM/Form/openImage.dart';
import 'package:gfm_gems/model/workorder.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gfm_gems/view/dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class ComplaintSectionC extends StatefulWidget {
  final String id;
  final bool disable;

  const ComplaintSectionC(this.id, this.disable, {Key? key}) : super(key: key);

  @override
  _ComplaintSectionCState createState() => _ComplaintSectionCState();
}

class _ComplaintSectionCState extends State<ComplaintSectionC> {
  final List<String> _sectionNames = [
    "Image Before",
    "Image During",
    "Image After"
  ];

  late Provider _provider;
  bool _loading = false;
  List<TechnicianImageRepair> _before = [];
  List<TechnicianImageRepair> _during = [];
  List<TechnicianImageRepair> _after  = [];
  Map<String, String> _notes = {};

  @override
  void initState() {
    super.initState();
    _provider = Provider(
      taskID: widget.id,
      fetchURL: "/api/m_wo.php?type=wo_repair_images&woTaskId="
    );
    _fetchImages();
  }

  Future<void> _fetchImages() async {
    setState(() => _loading = true);
    _provider.context = context;
    try {
      final resp = await _provider.fetch();
      final all = resp.technicianImages?.toList() ?? [];
      _notes.clear();
      _before = all.where((i) => i.woTaskUploadType == "Before").toList();
      _during = all.where((i) => i.woTaskUploadType == "During").toList();
      _after  = all.where((i) => i.woTaskUploadType == "After").toList();
      for (var img in all) {
        _notes[img.woTaskUploadId] = img.woTaskUploadDesc;
      }
    } catch (e) {
      // ignore
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: colorTheme3),
        title: Text("D. Image", style: TextStyle(color: colorTheme3, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            children: [
              Text(
                "Requires at least one photo for each of the following sections:",
                style: TextStyle(color: colorTheme3),
              ),
              const SizedBox(height: 16),
              _imageBlock(0, _before),
              _imageBlock(1, _during),
              _imageBlock(2, _after),
              const SizedBox(height: 80),
            ],
          ),
          if (_loading)
            Container(
              color: Colors.black38,
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      floatingActionButton: widget.disable
          ? null
          : FloatingActionButton.extended(
              backgroundColor: colorTheme2,
              label: Text("Save Descriptions", style: TextStyle(color: Colors.white)),
              onPressed: _notes.isEmpty ? null : _postNotes,
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _imageBlock(int idx, List<TechnicianImageRepair> list) {
    // old: always 3 slots for index==1, otherwise just 1 slot
    final maxSlots = (idx == 1 ? 3 : 1);
    List<Widget> cards = [];

    for (var slot = 0; slot < maxSlots; slot++) {
      if (slot < list.length) {
        cards.add(_sectionCard(list[slot]));
      } else {
        cards.add(_emptyCard(idx));
      }
      cards.add(const SizedBox(height: 12));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _sectionNames[idx],
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...cards,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _emptyCard(int idx) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: Icon(Icons.camera_alt, color: colorTheme2),
        title: Text("Tap to upload", style: TextStyle(color: colorTheme3)),
        onTap: widget.disable ? null : () => _createUpload(idx),
      ),
    );
  }

  Widget _sectionCard(TechnicianImageRepair item) {
  final src = "https:${item.documentSrc}";
  return Card(
    margin: EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              // <-- make the thumbnail tappable:
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ImageViewer(url: src),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    src,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.woTaskUploadTimestamp,
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(
                      "${item.woTaskUploadLatitude}, ${item.woTaskUploadLongitude}",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),

              if (!widget.disable)
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _delete(item.woTaskUploadId),
                ),
            ],
          ),

          const SizedBox(height: 8),
          TextField(
            enabled: !widget.disable,
            controller:
                TextEditingController(text: _notes[item.woTaskUploadId]),
            decoration: InputDecoration(
              hintText: "Description (optional)",
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colorTheme2.withOpacity(0.5)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colorTheme2),
              ),
            ),
            onChanged: (v) => _notes[item.woTaskUploadId] = v,
          ),
        ],
      ),
    ),
  );
}

  Future<void> _createUpload(int idx) async {
    setState(() => _loading = true);
    // get location
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getString(prefsLATITUDE)  ?? "0.0";
    final lng = prefs.getString(prefsLONGITUDE) ?? "0.0";
    if (lat == "0.0" && lng == "0.0") {
      Toast.show("Please relogin to get location");
      return setState(() => _loading = false);
    }

    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked == null) return setState(() => _loading = false);

    final file = File(picked.path);
    final bytes = await compressFile(file, settings: {
      'quality': Platform.isIOS ? 20 : 60,
      'minWidth': 480,
      'minHeight': 640,
    }) ?? Uint8List(0);
    final base64Img = base64Encode(bytes);
    final dateStr = DateFormat('yyyy/MM/dd HH:mm:ss').format(DateTime.now());

    final upload = UploadItem(
      "upload_repair_image",
      widget.id,
      date: dateStr,
      uploadType: (idx + 2).toString(),
      longitude: lng,
      latitude: lat,
      name: "Repair Image",
      filename: "${file.path}.jpg",
      size: bytes.length.toString(),
      data: base64Img,
    );

    try {
      _provider.context = navigatorKey.currentContext!;
      await _provider.post(url: "/api/m_wo.php", body: upload.body);
      Toast.show("Uploaded");
      await _fetchImages();
    } catch (e) {
      Toast.show("Upload failed");
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _postNotes() async {
    setState(() => _loading = true);
    final desc = UploadDesc("save_wo_repair_image_desc", widget.id, notes: _notes);
    try {
      _provider.context = navigatorKey.currentContext!;
      await _provider.post(url: "/api/m_wo.php", body: desc.body);
      Toast.show("Descriptions saved");
    } catch (e) {
      Toast.show("Save failed");
    } finally {
      await _fetchImages();
      setState(() => _loading = false);
    }
  }

  Future<void> _delete(String id) async {
    setState(() => _loading = true);
    try {
      _provider.context = context;
      await _provider.delete(
        url:
            "/api/m_wo.php?action=delete_wo_repair_image&woTaskId=${widget.id}&woTaskUploadId=$id",
      );
      await _fetchImages();
    } catch (e) {
      Toast.show("Delete failed");
      setState(() => _loading = false);
    }
  }

  void _bottomSheet({required String latitude, required String longitude, required String src}) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Wrap(children: [
        ListTile(
          leading: Icon(Icons.image),
          title: Text("View Image"),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ImageViewer(url: src)),
          ),
        ),
        ListTile(
          leading: Icon(Icons.map),
          title: Text("Open Map"),
          onTap: () async {
            final googleUrl = "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";
            if (await canLaunch(googleUrl)) await launch(googleUrl);
          },
        ),
      ]),
    );
  }
}

class UploadItem extends Upload {
  final String uploadType, longitude, latitude, name, filename, size, data, date;
  UploadItem(
    action,
    ppmTaskId, {
    required this.date,
    required this.uploadType,
    required this.longitude,
    required this.latitude,
    required this.name,
    required this.filename,
    required this.size,
    required this.data,
  }) : super(action: action, ppmTaskId: ppmTaskId);

  @override
  Map<String, dynamic> get body => {
        "action": action,
        "woTaskId": ppmTaskId,
        "uploadType": uploadType,
        "longitude": longitude,
        "latitude": latitude,
        "fileUpload[name]": name,
        "fileUpload[filename]": filename,
        "fileUpload[size]": size,
        "fileUpload[type]": "data:image/jpeg;base64",
        "fileUpload[data]": data,
      };
}

class UploadDesc extends Upload {
  final Map<String, String> notes;
  UploadDesc(action, ppmTaskId, {required this.notes})
      : super(action: action, ppmTaskId: ppmTaskId);

  @override
  Map<String, String> get body {
    final b = {"action": action, "woTaskId": ppmTaskId};
    var i = 0;
    notes.forEach((k, v) {
      b["woTaskUpload[$i][woTaskUploadId]"] = k;
      b["woTaskUpload[$i][woTaskUploadDesc]"] = v;
      i++;
    });
    return b;
  }
}

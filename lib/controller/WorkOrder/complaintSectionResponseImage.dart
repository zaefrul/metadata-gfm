// lib/controller/WorkOrder/complaintSectionResponseImage.dart

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/PPM/Form/openImage.dart';
import 'package:gfm_gems/main.dart';
import 'package:gfm_gems/utils/image_compressor.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:gfm_gems/view/dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' show basename;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class ComplaintSectionResponseImage extends StatefulWidget {
  final String woTaskId;
  final bool disable;

  const ComplaintSectionResponseImage({
    Key? key,
    required this.woTaskId,
    this.disable = false,
  }) : super(key: key);

  @override
  _ComplaintSectionResponseImageState createState() =>
      _ComplaintSectionResponseImageState();
}

class _ComplaintSectionResponseImageState
    extends State<ComplaintSectionResponseImage> {
  bool _loading = false;

  /// already-saved images from server
  List<ResponseImage> _existing = [];

  /// newly picked images waiting to upload
  final List<_LocalImage> _toUpload = [];

  @override
  void initState() {
    super.initState();
    ToastContext().init(context);
    _loadExisting();
  }

  /// Fetch the already-uploaded images
  Future<void> _loadExisting() async {
    setState(() => _loading = true);

    final url =
      "/api/m_wo.php?type=wo_response_images&woTaskId=${widget.woTaskId}";
    final provider = Provider(fetchURL: url)..context = context;

    try {
      final raw = await provider.getJson(url: url);

      // 1) Figure out where our List of items actually lives
      List<dynamic> listData;
      if (raw is List) {
        // provider jumped straight to the array
        listData = raw;
      } else if (raw is String) {
        // we got a JSON string → decode to Map
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        listData = decoded['result'] as List<dynamic>? ?? [];
      } else if (raw is Map) {
        // we already have a Map
        listData = raw['result'] as List<dynamic>? ?? [];
      } else {
        throw Exception("Unexpected response type: ${raw.runtimeType}");
      }

      // 2) Map into your model
      _existing = listData
        .map((e) => ResponseImage.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    } catch (e, st) {
      debugPrint("❌ _loadExisting failed: $e\n$st");
      Toast.show("Failed to load response images");
      _existing = [];
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Response Images",
            style: TextStyle(color: AppColors.primaryDark)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: AppColors.primaryDark),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _buildBody(),
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
              label: Text("Submit", style: TextStyle(color: Colors.white)),
              onPressed:
                  _toUpload.isEmpty || _loading ? null : _confirmAndSubmit,
            ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBody() {
    final totalImages = _existing.length + _toUpload.length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 1) Existing Images
          if (_existing.isNotEmpty) ...[
            Text("Already uploaded",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: _existing.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, i) => _buildExistingCard(_existing[i]),
              ),
            ),
            Divider(),
          ],

          // 2) To‐upload Section (only show if less than 3 images total)
          if (totalImages < 3) ...[
            ListTile(
              title: Text("Add up to 3 new images",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("(Each ≤ 5 MB)"),
              trailing: MaterialButton(
                shape: CircleBorder(),
                color: _toUpload.length == 3
                    ? colorTheme2.withOpacity(0.5)
                    : colorTheme2,
                child: Text("+",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                onPressed: widget.disable || _toUpload.length == 3
                    ? null
                    : _pickLocalImage,
              ),
            ),
          ],
          const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: _toUpload.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, i) => _buildLocalCard(_toUpload[i], i),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExistingCard(ResponseImage img) {
    final src = img.documentSrc.startsWith("//")
        ? "https:${img.documentSrc}"
        : img.documentSrc;
    return Card(
      child: ListTile(
        leading: GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ImageViewer(url: src)),
          ),
          child: Image.network(src, width: 64, height: 64, fit: BoxFit.cover),
        ),
        title: Text(img.documentFilename),
        subtitle: Text(img.documentDesc),
      ),
    );
  }

  Widget _buildLocalCard(_LocalImage img, int idx) {
    return Card(
      child: ListTile(
        leading: GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ImageViewer(file: img.file)),
          ),
          child: Image.file(img.file, width: 64, height: 64, fit: BoxFit.cover),
        ),
        title: TextField(
          decoration: InputDecoration(hintText: "Description (optional)"),
          onChanged: (v) => img.description = v,
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () => setState(() => _toUpload.removeAt(idx)),
        ),
      ),
    );
  }

  Future<void> _pickLocalImage() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked == null) return;

    setState(() => _loading = true);

    final file = File(picked.path);
    final bytes = await compressFile(file, settings: {
          'quality': Platform.isIOS ? 20 : 60,
          'minWidth': 480,
          'minHeight': 640,
        }) ??
        Uint8List(0);

    if (bytes.length > 5 * 1024 * 1024) {
      Toast.show("File is larger than 5 MB");
      setState(() => _loading = false);
      return;
    }

    setState(() {
      _toUpload.add(_LocalImage(
        file: file,
        data: base64Encode(bytes),
        name: basename(picked.path),
        size: bytes.length.toString(),
      ));
      _loading = false;
    });
  }

  void _confirmAndSubmit() {
    showDialog(
      context: context,
      builder: (_) => CustomDialog(
        cancel: true,
        description: "Submit ${_toUpload.length} image(s)?",
        buttonText: "Yes",
        image: Image.asset("assets/icon_trans.png", height: 40),
        okayTapped: () {
          Navigator.pop(context);
          _submitAll();
        },
      ),
    );
  }

  /// POST each picked image, then reload `_existing`
  Future<void> _submitAll() async {
    setState(() => _loading = true);

    final provider = Provider(fetchURL: "/api/m_wo.php")..context = context;

    // get location
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getString(prefsLATITUDE)  ?? "0.0";
    final lng = prefs.getString(prefsLONGITUDE) ?? "0.0";
    if (lat == "0.0" && lng == "0.0") {
      Toast.show("Please relogin to get location");
      return setState(() => _loading = false);
    }

    for (var i = 0; i < _toUpload.length; i++) {
      final img = _toUpload[i];
      final body = {
        "action": "upload_response_image",
        "woTaskId": widget.woTaskId,
        // you may adjust uploadType logic if needed:
        "uploadType": "${i+2}",
        "longitude": lng,
        "latitude": lat,
        "fileUpload[name]": img.name,
        "fileUpload[filename]": img.name,
        "fileUpload[size]": img.size,
        "fileUpload[type]": "data:image/jpeg;base64",
        "fileUpload[data]": img.data,
        "fileUpload[description]": img.description,
      };

      try {
        await provider.post(url: provider.fetchURL, body: body);
      } catch (e) {
        Toast.show("Failed to upload image #${i+1}");
      }
    }

    Toast.show("Done!");
    _toUpload.clear();
    await _loadExisting();
  }
}

/// model for existing images
class ResponseImage {
  final String woTaskUploadId;
  final String documentFilename;
  final String documentDesc;
  final String documentSrc;

  ResponseImage({
    required this.woTaskUploadId,
    required this.documentFilename,
    required this.documentDesc,
    required this.documentSrc,
  });

  factory ResponseImage.fromJson(Map<String, dynamic> json) {
    return ResponseImage(
      woTaskUploadId: json['woTaskUploadId'],
      documentFilename: json['documentFilename'],
      documentDesc: json['documentDesc'],
      documentSrc: json['documentSrc'],
    );
  }
}

/// model for new, local picks
class _LocalImage {
  final File file;
  final String name;
  final String data;
  final String size;
  String description = "";
  String latitude = "";
  String longitude = "";

  _LocalImage({
    required this.file,
    required this.name,
    required this.data,
    required this.size,
  });
}

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
  final List<_ResponseImageItem> _items = [];

  @override
  void initState() {
    super.initState();
    ToastContext().init(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Response Images", style: TextStyle(color: AppColors.primaryDark)),
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
              onPressed: _items.isEmpty || _loading ? null : _confirmAndSubmit,
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ListTile(
            title: Text("Add up to 3 images with descriptions",
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("(Each file ≤ 5 MB)"),
            trailing: MaterialButton(
              shape: CircleBorder(),
              color: _items.length == 3
                  ? colorTheme2.withOpacity(0.5)
                  : colorTheme2,
              child: Text("+",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              onPressed:
                  widget.disable || _items.length == 3 ? null : _pickImage,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: _items.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_, i) => _buildCard(_items[i], i),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(_ResponseImageItem item, int index) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ImageViewer(file: item.file)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(item.file, width: 64, height: 64, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                enabled: !widget.disable,
                decoration: InputDecoration(
                  hintText: "Description (optional)",
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                ),
                onChanged: (v) => item.description = v,
              ),
            ),
            if (!widget.disable)
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => setState(() => _items.removeAt(index)),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
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
      return setState(() => _loading = false);
    }

    setState(() {
      _items.add(_ResponseImageItem(
        file: file,
        name: basename(picked.path),
        data: base64Encode(bytes),
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
        description: "Submit these ${_items.length} image(s)?",
        buttonText: "Yes",
        image: Image.asset("assets/icon_trans.png", height: 40),
        okayTapped: () {
          Navigator.pop(context);
          _submitAll();
        },
      ),
    );
  }

  Future<void> _submitAll() async {
    setState(() => _loading = true);

    final provider = Provider(fetchURL: "/api/m_wo.php")..context = context;
    for (var i = 0; i < _items.length; i++) {
      final item = _items[i];
      final body = <String,String>{
        "action": "upload_response_image",
        "woTaskId": widget.woTaskId,
        "uploadType": "${i+2}",               // e.g. 2=before, 3=during, 4=after
        "longitude": item.longitude,          // you’ll need to capture this if required
        "latitude":  item.latitude,           // same here
        "fileUpload[name]":     item.name,
        "fileUpload[filename]": item.name,
        "fileUpload[size]":     item.size,
        "fileUpload[type]":     "data:image/jpeg;base64",
        "fileUpload[data]":     item.data,
        // if your API expects a description field:
        "fileUpload[description]": item.description,
      };

      try {
        final resp = await provider.post(url: provider.fetchURL, body: body);
        // you could check resp or show a per‐item Toast here
      } catch (e) {
        Toast.show("Upload failed for image #${i+1}");
      }
    }

    // on success:
    Toast.show("All images uploaded!");
    setState(() {
      _items.clear();
      _loading = false;
    });
  }
}

/// small model to hold each image’s data
class _ResponseImageItem {
  final File file;
  final String name, data, size;
  String description = "";
  String latitude = "", longitude = "";

  _ResponseImageItem({
    required this.file,
    required this.name,
    required this.data,
    required this.size,
  });
}

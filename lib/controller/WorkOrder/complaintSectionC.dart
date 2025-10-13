import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:GEMS/utils/image_compressor.dart';
import 'package:GEMS/controller/PPM/Form/openImage.dart';
import 'package:GEMS/data/repository/work_order_detail_repository.dart';
import 'package:GEMS/model/workorder.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' show basename;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:GEMS/controller/WorkOrder/pending_sync.dart';
import 'package:GEMS/controller/WorkOrder/widgets/pending_sync_banner.dart';

class ComplaintSectionC extends StatefulWidget {
  final String id;
  final bool disable;
  final PendingSyncController? pendingSync;

  const ComplaintSectionC(this.id, this.disable, {super.key, this.pendingSync});

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
  final Map<String, String> _notes = {};
  late final WorkOrderDetailRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = WorkOrderDetailRepository();
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
      body: Column(
        children: [
          if (widget.pendingSync != null)
            PendingSyncIndicator(controller: widget.pendingSync!),
          Expanded(
            child: Stack(
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
    try {
      final result = await _repository.uploadRepairImage(
        workOrderId: widget.id,
        uploadType: (idx + 2).toString(),
        latitude: lat,
        longitude: lng,
        displayName: "Repair Image",
        filename: basename(file.path),
        sizeBytes: bytes.length,
        base64Data: base64Img,
      );
      if (!mounted) return;
      if (result == WorkOrderActionResult.success) {
        Toast.show("Uploaded");
        await _fetchImages();
      } else {
        Toast.show(
          "You're offline right now. We'll sync this photo once you're back online.",
        );
        if (widget.pendingSync != null) {
          try {
            await widget.pendingSync!.retry();
          } catch (err, st) {
            debugPrint('Pending sync retry failed: $err\n$st');
          }
        }
      }
    } catch (e) {
      Toast.show("Upload failed");
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _postNotes() async {
    setState(() => _loading = true);
    try {
      final result = await _repository.saveRepairImageDescriptions(
        workOrderId: widget.id,
        descriptions: _notes,
      );
      if (!mounted) return;
      if (result == WorkOrderActionResult.success) {
        Toast.show("Descriptions saved");
        await _fetchImages();
      } else {
        Toast.show(
          "You're offline right now. We'll sync these descriptions once you're back online.",
        );
        if (widget.pendingSync != null) {
          try {
            await widget.pendingSync!.retry();
          } catch (err, st) {
            debugPrint('Pending sync retry failed: $err\n$st');
          }
        }
      }
    } catch (e) {
      Toast.show("Save failed");
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
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

}

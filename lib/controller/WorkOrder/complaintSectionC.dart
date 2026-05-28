import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:GEMS/utils/image_compressor.dart';
import 'package:GEMS/controller/PPM/Form/openImage.dart';
import 'package:GEMS/data/repository/work_order_detail_repository.dart';
import 'package:GEMS/model/workorder.dart';
import 'package:GEMS/utils/biometric_lock_manager.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:GEMS/utils/location_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' show basename;
import 'package:toast/toast.dart';
import 'package:GEMS/controller/WorkOrder/pending_sync.dart';
import 'package:GEMS/controller/WorkOrder/widgets/pending_sync_banner.dart';
import 'package:intl/intl.dart';

class ComplaintSectionC extends StatefulWidget {
  final String id;
  final bool disable;
  final PendingSyncController? pendingSync;
  final Stream<WorkOrderSnapshotData?>? snapshotStream;
  final WorkOrderSnapshotData? initialSnapshot;

  const ComplaintSectionC(
    this.id,
    this.disable, {
    super.key,
  this.pendingSync,
  this.snapshotStream,
    this.initialSnapshot,
  });

  @override
  State<ComplaintSectionC> createState() => _ComplaintSectionCState();
}

class _ComplaintSectionCState extends State<ComplaintSectionC> {
  final List<String> _sectionNames = const [
    'Image Before',
    'Image During',
    'Image After',
  ];

  bool _loading = false;
  List<TechnicianImageRepair> _before = [];
  List<TechnicianImageRepair> _during = [];
  List<TechnicianImageRepair> _after = [];
  final Map<String, String> _notes = {};
  late final WorkOrderDetailRepository _repository;
  List<PendingRepairImage> _pending = [];
  StreamSubscription<int>? _pendingSubscription;
  int? _lastPendingCount;
  StreamSubscription<WorkOrderSnapshotData?>? _snapshotSubscription;

  @override
  void initState() {
    super.initState();
    _repository = WorkOrderDetailRepository();
    _applySnapshot(widget.initialSnapshot);
    _loadImages();
    _loadPendingImages();
    _watchPendingSync();
    _listenToSnapshots();
  }

  @override
  void dispose() {
    _pendingSubscription?.cancel();
    _snapshotSubscription?.cancel();
    super.dispose();
  }

  void _listenToSnapshots() {
  if (widget.snapshotStream == null) return;
  _snapshotSubscription = widget.snapshotStream!.listen((snapshot) {
      if (!mounted) return;
      _applySnapshot(snapshot);
    });
  }

  void _applySnapshot(WorkOrderSnapshotData? snapshot) {
    if (snapshot == null) return;
    final repairs = snapshot.repairImages;
    final notes = <String, String>{};
    for (final img in repairs) {
      notes[img.woTaskUploadId] = img.woTaskUploadDesc;
    }
    setState(() {
      _before =
          repairs.where((img) => img.woTaskUploadType == 'Before').toList();
      _during =
          repairs.where((img) => img.woTaskUploadType == 'During').toList();
      _after = repairs.where((img) => img.woTaskUploadType == 'After').toList();
      _notes
        ..clear()
        ..addAll(notes);
      _loading = false;
    });
  }

  Future<void> _loadImages({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final images = await _repository.getRepairImages(
        workOrderId: widget.id,
        forceRefresh: forceRefresh,
        onRemoteUpdate: (latest) {
          if (!mounted) return;
          _updateImageLists(latest);
        },
      );
      if (!mounted) return;
      _updateImageLists(images);
    } catch (err, st) {
      debugPrint('Failed to load repair images: $err\n$st');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadPendingImages() async {
    try {
      final pending = await _repository.getPendingRepairImages(widget.id);
      if (!mounted) return;
      setState(() {
        _pending = pending;
      });
    } catch (err, st) {
      debugPrint('Failed to load pending repair images: $err\n$st');
    }
  }

  void _updateImageLists(List<TechnicianImageRepair> all) {
    final before =
        all.where((img) => img.woTaskUploadType == 'Before').toList();
    final during =
        all.where((img) => img.woTaskUploadType == 'During').toList();
    final after = all.where((img) => img.woTaskUploadType == 'After').toList();
    final notes = <String, String>{};
    for (final img in all) {
      notes[img.woTaskUploadId] = img.woTaskUploadDesc;
    }

    setState(() {
      _before = before;
      _during = during;
      _after = after;
      _notes
        ..clear()
        ..addAll(notes);
    });
  }

  void _watchPendingSync() {
    final controller = widget.pendingSync;
    if (controller == null) return;
    _pendingSubscription = controller.pendingCount$.listen((count) {
      if (!mounted) return;
      final previous = _lastPendingCount;
      _lastPendingCount = count;
      _loadPendingImages();
      if ((previous ?? 0) > 0 && count == 0) {
        _loadImages(forceRefresh: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: colorTheme3),
        title: Text(
          'D. Image',
          style: TextStyle(
            color: colorTheme3,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          if (widget.pendingSync != null)
            PendingSyncIndicator(controller: widget.pendingSync!),
          Expanded(
            child: Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  children: [
                    Text(
                      'Requires at least one photo for each of the following sections:',
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
                    child: const Center(child: CircularProgressIndicator()),
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
              label: const Text(
                'Save Descriptions',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: _notes.isEmpty ? null : _postNotes,
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _imageBlock(int idx, List<TechnicianImageRepair> remote) {
    final maxSlots = idx == 1 ? 3 : 1;
    final pending = _pending
        .where((item) => _sectionIndexForUploadType(item.uploadType) == idx)
        .toList();

    final tiles = <Widget>[];
    for (final item in pending) {
      tiles.add(_pendingCard(item));
      tiles.add(const SizedBox(height: 12));
    }
    for (final item in remote) {
      tiles.add(_sectionCard(item));
      tiles.add(const SizedBox(height: 12));
    }

    final filled = pending.length + remote.length;
    final empties = (maxSlots - filled).clamp(0, maxSlots);
    for (var i = 0; i < empties; i++) {
      tiles.add(_emptyCard(idx));
      tiles.add(const SizedBox(height: 12));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _sectionNames[idx],
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...tiles,
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
        title: Text('Tap to upload', style: TextStyle(color: colorTheme3)),
        onTap: widget.disable ? null : () => _createUpload(idx),
      ),
    );
  }

  Widget _sectionCard(TechnicianImageRepair item) {
    final src = 'https:${item.documentSrc}';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
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
                      Text(
                        item.woTaskUploadTimestamp,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.woTaskUploadLatitude}, ${item.woTaskUploadLongitude}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                if (!widget.disable)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _delete(item.woTaskUploadId),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              enabled: !widget.disable,
              controller: TextEditingController(
                text: _notes[item.woTaskUploadId] ?? '',
              ),
              decoration: InputDecoration(
                hintText: 'Description (optional)',
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: colorTheme2.withOpacity(0.5)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: colorTheme2),
                ),
              ),
              onChanged: (value) => _notes[item.woTaskUploadId] = value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _pendingCard(PendingRepairImage item) {
    final timestamp =
        DateFormat('dd MMM yyyy, HH:mm').format(item.createdAt.toLocal());
    final coordinates = <String>[
      if ((item.latitude ?? '').isNotEmpty) item.latitude!,
      if ((item.longitude ?? '').isNotEmpty) item.longitude!,
    ].join(', ');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    item.bytes,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timestamp,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        coordinates.isEmpty
                            ? 'Location unavailable'
                            : coordinates,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: colorTheme2.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Text(
                    'Pending sync',
                    style: TextStyle(
                      color: colorTheme2,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.displayName ?? 'Repair Image',
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createUpload(int idx) async {
    setState(() => _loading = true);
    final location = await resolveDeviceLocation();
    final lat = location.latitude;
    final lng = location.longitude;
    if (!location.hasValidCoordinates) {
      final message = describeLocationFailure(location.status);
      if (message.isNotEmpty) {
        Toast.show(message);
      }
      if (mounted) {
        setState(() => _loading = false);
      }
      return;
    }

    final picked =
        await BiometricLockManager.pickImage(source: ImageSource.camera);
    if (picked == null) {
      if (mounted) {
        setState(() => _loading = false);
      }
      return;
    }

    final file = File(picked.path);
    final compressed = await compressFile(file, settings: {
      'quality': Platform.isIOS ? 20 : 60,
      'minWidth': 480,
      'minHeight': 640,
    });
    final bytes = compressed ?? await file.readAsBytes();
    if (bytes.isEmpty) {
      Toast.show('Unable to process image');
      if (mounted) {
        setState(() => _loading = false);
      }
      return;
    }

    final base64Img = base64Encode(bytes);
    try {
      final result = await _repository.uploadRepairImage(
        workOrderId: widget.id,
        uploadType: (idx + 2).toString(),
        latitude: lat,
        longitude: lng,
        displayName: 'Repair Image',
        filename: basename(file.path),
        sizeBytes: bytes.length,
        base64Data: base64Img,
      );
      if (!mounted) return;
      if (result == WorkOrderActionResult.success) {
        Toast.show('Uploaded');
        await _loadPendingImages();
        await _loadImages(forceRefresh: true);
      } else {
        Toast.show(
          'You\'re offline right now. We\'ll sync this photo once you\'re back online.',
        );
        await _loadPendingImages();
        if (widget.pendingSync != null) {
          try {
            await widget.pendingSync!.retry();
          } catch (err, st) {
            debugPrint('Pending sync retry failed: $err\n$st');
          }
        }
      }
    } catch (err, st) {
      debugPrint('Upload failed: $err\n$st');
      Toast.show('Upload failed');
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
        Toast.show('Descriptions saved');
        await _loadImages(forceRefresh: true);
      } else {
        Toast.show(
          'You\'re offline right now. We\'ll sync these descriptions once you\'re back online.',
        );
        if (widget.pendingSync != null) {
          try {
            await widget.pendingSync!.retry();
          } catch (err, st) {
            debugPrint('Pending sync retry failed: $err\n$st');
          }
        }
      }
    } catch (err, st) {
      debugPrint('Save descriptions failed: $err\n$st');
      Toast.show('Save failed');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _delete(String id) async {
    setState(() => _loading = true);
    try {
      final provider = Provider(
        taskID: widget.id,
        fetchURL: '/api/m_wo.php?type=wo_repair_images&woTaskId=',
      );
      provider.context = context;
      await provider.delete(
        url:
            '/api/m_wo.php?action=delete_wo_repair_image&woTaskId=${widget.id}&woTaskUploadId=$id',
      );
      await _loadImages(forceRefresh: true);
    } catch (err, st) {
      debugPrint('Delete repair image failed: $err\n$st');
      Toast.show('Delete failed');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  int _sectionIndexForUploadType(String uploadType) {
    switch (uploadType) {
      case '2':
        return 0;
      case '3':
        return 1;
      case '4':
        return 2;
      default:
        return -1;
    }
  }
}

// lib/controller/WorkOrder/complaintSectionResponseImage.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:GEMS/controller/PPM/Form/openImage.dart';
import 'package:GEMS/data/repository/work_order_detail_repository.dart';
import 'package:GEMS/model/response_image.dart';
import 'package:GEMS/utils/image_compressor.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:GEMS/utils/location_helper.dart';
import 'package:GEMS/view/dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' show basename;
import 'package:toast/toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:GEMS/controller/WorkOrder/pending_sync.dart';
import 'package:GEMS/controller/WorkOrder/widgets/pending_sync_banner.dart';

class ComplaintSectionResponseImage extends StatefulWidget {
  final String woTaskId;
  final bool disable;
  final PendingSyncController? pendingSync;
  final Stream<WorkOrderSnapshotData?>? snapshotStream;
  final WorkOrderSnapshotData? initialSnapshot;

  const ComplaintSectionResponseImage({
    super.key,
    required this.woTaskId,
    this.disable = false,
    this.pendingSync,
    this.snapshotStream,
    this.initialSnapshot,
  });

  @override
  _ComplaintSectionResponseImageState createState() =>
      _ComplaintSectionResponseImageState();
}

class _ComplaintSectionResponseImageState
    extends State<ComplaintSectionResponseImage> {
  bool _loading = false;

  /// already-saved images from server
  List<ResponseImage> _existing = [];

  /// queued uploads waiting for sync
  List<PendingResponseImage> _pending = [];

  /// newly picked images waiting to upload
  final List<_LocalImage> _toUpload = [];
  late final WorkOrderDetailRepository _repository;
  StreamSubscription<int>? _pendingSyncSub;
  int? _lastPendingCount;
  StreamSubscription<WorkOrderSnapshotData?>? _snapshotSub;

  @override
  void initState() {
    super.initState();
    ToastContext().init(context);
    _repository = WorkOrderDetailRepository();
    _applySnapshot(widget.initialSnapshot);
    _loadExisting();
    _loadPending();
    _watchPendingSync();
    _listenToSnapshots();
  }

  Future<void> _loadPending() async {
    try {
      final pending =
          await _repository.getPendingResponseImages(widget.woTaskId);
      if (!mounted) return;
      setState(() {
        _pending = pending;
      });
    } catch (err, st) {
      debugPrint('Failed to load pending response images: $err\n$st');
    }
  }

  @override
  void didUpdateWidget(covariant ComplaintSectionResponseImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pendingSync != widget.pendingSync) {
      _pendingSyncSub?.cancel();
      _watchPendingSync();
    }
  }

  void _watchPendingSync() {
    final controller = widget.pendingSync;
    if (controller == null) return;
    _pendingSyncSub = controller.pendingCount$.listen((count) {
      final previous = _lastPendingCount;
      _lastPendingCount = count;
      if (!mounted) return;
      _loadPending();
      final pendingCleared = previous != null && previous > 0 && count == 0;
      if (pendingCleared) {
        _loadExisting(force: true);
      }
    });
  }

  /// Fetch the already-uploaded images
  Future<void> _loadExisting({bool force = false}) async {
    if (!mounted) return;
    if (_loading && !force) return;
    setState(() => _loading = true);
    try {
      final images = await _repository.getResponseImages(
        workOrderId: widget.woTaskId,
        forceRefresh: force,
        onRemoteUpdate: (latest) {
          if (!mounted) return;
          setState(() {
            _existing = latest;
          });
        },
      );
      if (!mounted) return;
      setState(() {
        _existing = images;
      });
    } catch (err, st) {
      debugPrint('Failed to load response images: $err\n$st');
      if (mounted) {
        Toast.show('Failed to load response images');
        setState(() {
          _existing = [];
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _pendingSyncSub?.cancel();
    _snapshotSub?.cancel();
    super.dispose();
  }

  void _listenToSnapshots() {
  final stream = widget.snapshotStream;
    if (stream == null) return;
    _snapshotSub = stream.listen((snapshot) {
      if (!mounted) return;
      _applySnapshot(snapshot);
    });
  }

  void _applySnapshot(WorkOrderSnapshotData? snapshot) {
    if (snapshot == null) return;
    setState(() {
      _existing = snapshot.responseImages;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDefault,
      appBar: AppBar(
        title: Text(
          'Response Images',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.bgAppBar,
        elevation: 1,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: Column(
        children: [
          if (widget.pendingSync != null)
            PendingSyncIndicator(controller: widget.pendingSync!),
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildBody(),
                ),
                if (_loading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        ],
      ),
      // floatingActionButton: widget.disable
      //     ? null
      //     : _buildSubmitButton(),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: FloatingActionButton.extended(
          onPressed: _toUpload.isEmpty || _loading ? null : _confirmAndSubmit,
          backgroundColor:
              _toUpload.isEmpty ? AppColors.secondary : AppColors.primary,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          label: Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Text(
              'SUBMIT IMAGES',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final totalImages = _existing.length + _toUpload.length + _pending.length;
    final canAddMore = totalImages < 3;

    return SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload Response Evidence',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Document your work with photos (max 3)',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24),

            if (_pending.isNotEmpty) ...[
              _buildSectionCard(
                title: 'Waiting to Sync',
                child: Column(
                  children: [
                    ..._pending.map(_buildPendingCard),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],

            // Existing Images
            if (_existing.isNotEmpty) ...[
              _buildSectionCard(
                title: 'Uploaded Images',
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _existing.length,
                  itemBuilder: (_, i) => _buildExistingCard(_existing[i]),
                ),
              ),
              SizedBox(height: 16),
            ],

            // Add New Photos
            if (canAddMore) ...[
              _buildSectionCard(
                title: 'Add Photos (${3 - totalImages} remaining)',
                child: Column(
                  children: [
                    if (_toUpload.isEmpty)
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.grey[200]!, width: 1.5),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.photo_library_outlined,
                                size: 40, color: Colors.grey[400]),
                            SizedBox(height: 8),
                            Text(
                              'No photos added yet',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Photos help us better understand the issue',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 12),
                    InkWell(
                      onTap: widget.disable ? null : _pickLocalImage,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: AppColors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Add Photo',
                              style: GoogleFonts.poppins(
                                color: AppColors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],

            // New Photos to Upload
            if (_toUpload.isNotEmpty) ...[
              _buildSectionCard(
                title: 'Photos to Upload',
                child: Column(
                  children: [
                    ..._toUpload.asMap().entries.map(
                          (e) => _buildLocalCard(e.value, e.key),
                        ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 80), // Space for FAB
            if (!widget.disable && _toUpload.isNotEmpty) _buildSubmitButton(),
          ],
        ));
  }

  Widget _buildPendingCard(PendingResponseImage item) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.memory(
              item.bytes,
              fit: BoxFit.cover,
              height: 160,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.15),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.sync, color: AppColors.warning, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Waiting to sync',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if ((item.description ?? '').isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            item.description!,
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                        ),
                      if ((item.displayName ?? '').isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            item.displayName!,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildExistingCard(ResponseImage img) {
    final src = img.documentSrc.startsWith('//')
        ? 'https:${img.documentSrc}'
        : img.documentSrc;

    return Stack(
      children: [
        Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ImageViewer(url: src)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(8)),
                    child: Image.network(
                      src,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation(AppColors.primary),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (img.documentDesc.isNotEmpty) ...[
                        SizedBox(height: 4),
                        Text(
                          img.documentDesc,
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.grey[600]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // delete button in the corner:
        if (!widget.disable)
          Positioned(
            top: 4,
            right: 4,
            child: Material(
              color: Colors.white.withOpacity(0.8),
              shape: CircleBorder(),
              child: IconButton(
                icon: Icon(Icons.delete, size: 20, color: Colors.red),
                onPressed: () => _confirmDelete(img.woTaskUploadId),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLocalCard(_LocalImage img, int idx) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ImageViewer(file: img.file)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              child: Image.file(
                img.file,
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Add description...",
                      border: InputBorder.none,
                    ),
                    style: GoogleFonts.poppins(fontSize: 14),
                    onChanged: (v) => img.description = v,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: AppColors.danger),
                  onPressed: () => setState(() => _toUpload.removeAt(idx)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickLocalImage() async {
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
      setState(() => _loading = false);
      return;
    }

    setState(() {
      _toUpload.add(_LocalImage(
        file: file,
        data: base64Encode(bytes),
        name: basename(picked.path),
        sizeBytes: bytes.length,
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

  void _confirmDelete(String uploadId) {
    showDialog(
      context: context,
      builder: (_) => CustomDialog(
        cancel: true,
        description: 'Delete this image?',
        buttonText: 'Yes',
        image: Image.asset('assets/icon_trans.png', height: 40),
        okayTapped: () {
          Navigator.pop(context);
          _deleteExistingImage(uploadId);
        },
      ),
    );
  }

  Future<void> _deleteExistingImage(String uploadId) async {
    if (!mounted) return;
    final previous = List<ResponseImage>.from(_existing);
    setState(() {
      _loading = true;
      _existing =
          _existing.where((item) => item.woTaskUploadId != uploadId).toList();
    });

    try {
      final result = await _repository.deleteResponseImage(
        workOrderId: widget.woTaskId,
        uploadId: uploadId,
      );
      if (result == WorkOrderActionResult.success) {
        Toast.show('Image deleted');
        await _loadExisting(force: true);
      } else {
        Toast.show("We'll delete this photo once you're back online.");
        if (widget.pendingSync != null) {
          try {
            await widget.pendingSync!.retry();
          } catch (err, st) {
            debugPrint(
                'Pending sync retry failed after delete queue: $err\n$st');
          }
        }
      }
    } catch (err, st) {
      debugPrint('Failed to delete response image: $err\n$st');
      Toast.show('Delete failed');
      if (mounted) {
        setState(() {
          _existing = previous;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  /// POST each picked image, then reload `_existing`
  Future<void> _submitAll() async {
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

    var anyQueued = false;
    var anySuccess = false;
    var hadError = false;

    for (var i = 0; i < _toUpload.length; i++) {
      final img = _toUpload[i];
      try {
        final result = await _repository.uploadResponseImage(
          workOrderId: widget.woTaskId,
          uploadType: '${i + 2}',
          latitude: lat,
          longitude: lng,
          displayName: img.name,
          filename: img.name,
          sizeBytes: img.sizeBytes,
          base64Data: img.data,
          description: img.description,
        );
        if (result == WorkOrderActionResult.success) {
          anySuccess = true;
        } else {
          anyQueued = true;
        }
      } catch (err, st) {
        debugPrint('Failed to upload response image: $err\n$st');
        hadError = true;
      }
    }

    if (!mounted) {
      return;
    }

    String? message;
    if (anySuccess && anyQueued) {
      message =
          "Some photos uploaded. Others will sync once you're back online.";
    } else if (anySuccess) {
      message = "Images uploaded";
    } else if (anyQueued) {
      message =
          "You're offline right now. We'll sync these photos once you're back online.";
    } else if (hadError) {
      message = "Failed to upload images";
    }

    if (message != null) {
      Toast.show(message);
    }

    if (anyQueued && widget.pendingSync != null) {
      try {
        await widget.pendingSync!.retry();
      } catch (err, st) {
        debugPrint('Pending sync retry failed: $err\n$st');
      }
    }

    if (anySuccess) {
      await _loadExisting(force: true);
      if (!mounted) {
        return;
      }
    }

    await _loadPending();

    setState(() {
      _toUpload.clear();
      _loading = false;
    });
  }
}

/// model for new, local picks
class _LocalImage {
  final File file;
  final String name;
  final String data;
  final int sizeBytes;
  String description = "";

  _LocalImage({
    required this.file,
    required this.name,
    required this.data,
    required this.sizeBytes,
  });
}

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data'; // Required for Uint8List

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:GEMS/controller/PPM/Form/openImage.dart';
import 'package:GEMS/model/form.dart'; // Assuming FormHItem is defined here
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:image_picker/image_picker.dart';
import 'package:GEMS/view/dialog.dart'; // Assuming CustomDialog is defined here
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:GEMS/utils/image_compressor.dart';
import 'package:geolocator/geolocator.dart'; // Import for Geolocator
import 'package:GEMS/data/repository/ppm_repository.dart';
import 'package:GEMS/data/local/entities/ppm_entities.dart';
import 'package:GEMS/controller/PPM/pending_sync.dart';
import 'package:GEMS/controller/PPM/widgets/pending_sync_banner.dart';
import 'package:GEMS/utils/biometric_lock_manager.dart';
import 'package:path/path.dart' show basename;

class FormH extends StatefulWidget {
  final String id;
  final bool verified;
  final bool disable;
  final Function(bool) refreshStatus; // Changed to specify parameter type

  const FormH(
    this.id,
    this.verified,
    this.refreshStatus,
    this.disable, {
    super.key,
  });

  @override
  _FormHState createState() => _FormHState();
}

class _FormHState extends State<FormH> {
  // FINAL VARIABLE
  final List<String> _sectionName = [
    "Image Before",
    "Image During",
    "Image After"
  ];

  // IMMUTABLE VARIABLES
  late Provider _provider;
  late PPMRepository _repository;
  PPMPendingSyncController? _pendingSync;
  bool _loading = false;
  late List<Widget> _children = [];
  Map<String, String> _notes = {};
  
  // Image lists - maintain state for uploaded and pending images
  List<PendingMaintenanceImage> _pending = [];
  List<FormHItem> _uploadedImages = [];

  @override
  void initState() {
    super.initState();
    _children = [
      _getTitle(
          "Requires at least one photo for each of the following image section below:")
    ];

    _provider = Provider(
      taskID: widget.id,
      fetchURL: "/api/m_ppm.php?type=ppm_section_h&ppmTaskId=",
    );
    
    _repository = PPMRepository();
    _pendingSync = PPMPendingSyncController();
    _pendingSync?.setPPMTaskId(widget.id);
    
    _loadImages();
    _loadPendingImages();
  }
  
  @override
  void dispose() {
    _pendingSync?.dispose();
    super.dispose();
  }

  // ============================================================================
  // DATA LOADING METHODS
  // ============================================================================

  Future<void> _loadImages({bool forceRefresh = false}) async {
    if (!mounted) return;
    debugPrint('FormH: _loadImages called, forceRefresh=$forceRefresh');
    setState(() => _loading = true);
    try {
      final images = await _repository.getMaintenanceImages(
        ppmTaskId: widget.id,
        forceRefresh: forceRefresh,
        onRemoteUpdate: (latest) {
          debugPrint('FormH: onRemoteUpdate callback triggered with ${latest.length} images');
          if (!mounted) return;
          _updateImageLists(latest);
        },
      );
      if (!mounted) return;
      debugPrint('FormH: getMaintenanceImages returned ${images.length} images');
      _updateImageLists(images);
    } catch (err, st) {
      debugPrint('Failed to load maintenance images: $err\n$st');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadPendingImages() async {
    try {
      debugPrint('FormH: _loadPendingImages called for ppmTaskId=${widget.id}');
      final pending = await _repository.getPendingMaintenanceImages(widget.id);
      if (!mounted) return;
      debugPrint('FormH: Loaded ${pending.length} pending maintenance images');
      for (var i = 0; i < pending.length; i++) {
        debugPrint('  - Pending[$i]: type=${pending[i].uploadType}, size=${pending[i].bytes.length} bytes, created=${pending[i].createdAt}');
      }
      setState(() {
        _pending = pending;
        // Regenerate children to show pending images along with uploaded images
        _regenerateUIFromCurrentState();
      });
      debugPrint('FormH: setState completed with ${_pending.length} pending images');
    } catch (err, st) {
      debugPrint('Failed to load pending maintenance images: $err\n$st');
    }
  }
  
  /// Regenerate UI from current uploaded images state
  void _regenerateUIFromCurrentState() {
    final before = _uploadedImages.where((img) => img.ppmTaskUploadType == 'Before').toList();
    final during = _uploadedImages.where((img) => img.ppmTaskUploadType == 'During').toList();
    final after = _uploadedImages.where((img) => img.ppmTaskUploadType == 'After').toList();
    
    _generateChildren([
      before.isNotEmpty ? before.first : null,
      during.length > 3 ? during.sublist(0, 3) : during,
      after.isNotEmpty ? after.first : null,
    ]);
  }

  void _updateImageLists(List<FormHItem> all) {
    debugPrint('FormH: _updateImageLists called with ${all.length} total images');
    
    final before = all.where((img) => img.ppmTaskUploadType == 'Before').toList();
    final during = all.where((img) => img.ppmTaskUploadType == 'During').toList();
    final after = all.where((img) => img.ppmTaskUploadType == 'After').toList();
    
    debugPrint('FormH: Categorized - Before: ${before.length}, During: ${during.length}, After: ${after.length}');
    
    final notes = <String, String>{};
    for (final img in all) {
      notes[img.ppmTaskUploadId] = img.ppmTaskUploadDesc;
    }

    setState(() {
      _uploadedImages = all; // Store all uploaded images
      _notes
        ..clear()
        ..addAll(notes);
      
      // Regenerate children for display
      _generateChildren([
        before.isNotEmpty ? before.first : null,
        during.length > 3 ? during.sublist(0, 3) : during,
        after.isNotEmpty ? after.first : null,
      ]);
    });
    
    debugPrint('FormH: setState completed, UI should update now');
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context); // Initialize ToastContext
    _provider.context = context;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: colorTheme3),
        title: _getTitle("H. Maintenance Image", bold: true),
      ),
      body: Column(
        children: [
          if (_pendingSync != null)
            PPMPendingSyncIndicator(controller: _pendingSync!),
          Expanded(
            child: _loading
                ? Stack(
                    children: <Widget>[
                      _builtBody,
                      Container(
                        color: Colors.black.withOpacity(0.5),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    ],
                  )
                : _builtBody,
          ),
        ],
      ),
      floatingActionButton: _floatingButton, // Use the getter
    );
  }

  // WIDGETS

  Widget _getTitle(String text, {bool bold = false}) => Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(vertical: 8.0), // Added padding for better spacing
        child: Text(
          text,
          style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: colorTheme3,
              fontSize: bold ? 16 : 14, // Adjusted font size
            ),
        ),
      );

  Widget? get _floatingButton {
    if (widget.disable) return null;

    return FloatingActionButton.extended(
      label: Text("Save"),
      backgroundColor: colorTheme2,
      icon: Icon(Icons.save), // Added icon
      onPressed: () {
        if (!widget.verified) {
          Toast.show("Please verify this task first.", duration: Toast.lengthLong, gravity: Toast.bottom);
          return;
        }
        if (_notes.isNotEmpty) {
          _postNotes();
        } else {
          // Optionally show a toast if there are no notes to save, or just do nothing.
          Toast.show("No changes to save in descriptions.", duration: Toast.lengthShort, gravity: Toast.bottom);
        }
      },
    );
  }

  Widget get _builtBody {
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: _children,
    );
  }

  Widget _emptySection(int index) {
    // Determine the correct section type for upload based on index
    // 0: Before, 1: During, 2: After
    // This 'index' parameter in _emptySection corresponds to the main section index (0, 1, 2)
    // not the sub-index within "During".
    // When calling _createUploadItem, we need to pass the correct section type.
    // For "Before" and "After", the index is directly 0 or 2.
    // For "During", the index passed to _createUploadItem should always be 1.
    int uploadItemTypeIndex = index;

    return Card( // Wrap in a card for better visual separation
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.camera_alt, color: colorTheme3),
              title: Text("Tap to upload image", style: TextStyle(color: widget.disable ? Colors.grey : colorTheme3)),
              onTap: widget.disable ? null : () => _createUploadItem(uploadItemTypeIndex),
            ),
            SizedBox(height: 8),
            TextField(
              enabled: false, // This field is always disabled as per original logic
              decoration: InputDecoration(
                labelText: "Image Description",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _section(FormHItem item) {
    var latitude = item.ppmTaskUploadLatitude ?? "N/A"; // Handle null
    var longitude = item.ppmTaskUploadLongitude ?? "N/A"; // Handle null
    var src = item.documentSrc.isNotEmpty
        ? (item.documentSrc.startsWith("http") ? item.documentSrc : "http:${item.documentSrc}")
        : null; // Handle null or empty src and ensure it has a scheme

    return Card( // Wrap in a card
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: src != null
                  ? GestureDetector(
                      onTap: () => _openImageViewer(src),
                      child: Image.network(
                        src,
                        width: 60, height: 60, fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 60, color: Colors.grey),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return SizedBox(
                            width: 60, height: 60,
                            child: Center(child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                            )),
                          );
                        },
                      ),
                    )
                  : Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
              trailing: widget.disable
                  ? null
                  : IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => _confirmDelete(item.ppmTaskUploadId),
                    ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(item.ppmTaskUploadTimestamp ?? "No timestamp", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  SizedBox(height: 2),
                  Text("Lat: $latitude, Lon: $longitude", style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                ],
              ),
              onTap: (latitude != "N/A" && longitude != "N/A" && src != null)
                  ? () => _showImageOptionsBottomSheet(latitude: latitude, longitude: longitude, src: src)
                  : (src != null ? () => _openImageViewer(src) : null), // Only allow tap if there's something to show/do
            ),
            SizedBox(height: 8),
            TextField(
              controller: TextEditingController(text: item.ppmTaskUploadDesc ?? ""), // Handle null
              enabled: !widget.disable,
              decoration: InputDecoration(
                labelText: "Image Description",
                border: OutlineInputBorder(),
                hintText: "Enter description...",
              ),
              onChanged: (text) {
                _notes[item.ppmTaskUploadId] = text;
              },
              maxLines: null, // Allow multiline
            )
          ],
        ),
      ),
    );
  }

  Widget _pendingCard(PendingMaintenanceImage item) {
    final timestamp = DateFormat('dd MMM yyyy, HH:mm').format(item.createdAt.toLocal());
    final coordinates = <String>[
      if ((item.latitude ?? '').isNotEmpty) item.latitude!,
      if ((item.longitude ?? '').isNotEmpty) item.longitude!,
    ].join(', ');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
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
                    width: 60,
                    height: 60,
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
                        coordinates.isEmpty ? 'Location unavailable' : 'Lat/Lon: $coordinates',
                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: colorTheme2.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
              item.displayName ?? 'Maintenance Image',
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  // FUNCTIONALITY - API

  void _fetch() {
    if (!mounted) return;
    setState(() => _loading = true);

    _provider.fetch().then((response) {
      if (!mounted) return;
      var value = response.sectionHList?.toList() ?? [];
      _notes = {}; // Reset notes based on fetched data

      FormHItem? before;
      List<FormHItem> during = [];
      FormHItem? after;

      if (value.isNotEmpty) {
        for (var f in value) {
 // Ensure 'f' itself is not null if sectionHList can contain nulls
          _notes[f.ppmTaskUploadId] = f.ppmTaskUploadDesc ?? ""; // Handle null description
          if (f.ppmTaskUploadType == "Before") {
            before = f;
          } else if (f.ppmTaskUploadType == "During") {
            during.add(f);
          } else if (f.ppmTaskUploadType == "After") {
            after = f;
          }
                }
      }
      // Ensure 'during' list doesn't exceed 3 items for UI consistency
      if (during.length > 3) {
        during = during.sublist(0, 3);
      }

      List<dynamic> sectionItem = [before, during, after];
      _generateChildren(sectionItem);
      setState(() => _loading = false);
    }).catchError((err) {
      if (!mounted) return;
      print("Fetch error: $err");
      
      // Check if the error is due to empty result list (which is normal for first-time visits)
      if (err.toString().contains("Empty result list")) {
        // This is normal - no images uploaded yet, so just show empty sections
        _generateChildren([null, [], null]); // Pass empty list for 'during' to show 3 empty slots
        setState(() => _loading = false);
      } else {
        // This is an actual error - network issue, authentication problem, etc.
        _generateChildren([null, [], null]); // Pass empty list for 'during' to show 3 empty slots
        setState(() => _loading = false);
        _showAlert("Error", "Failed to load image data: ${err.toString()}");
      }
    });
  }

  void _postNotes() async {
    if (!mounted) return;
    
    if (_notes.isEmpty) {
      Toast.show(
        "No descriptions to save",
        duration: Toast.lengthShort,
        gravity: Toast.bottom,
      );
      return;
    }

    print('[FormH] _postNotes called with ${_notes.length} descriptions');
    setState(() => _loading = true);

    try {
      final result = await _repository.saveMaintenanceImageDescriptions(
        ppmTaskId: widget.id,
        descriptions: _notes,
      );

      if (!mounted) return;

      if (result == PPMActionResult.success) {
        print('[FormH] Descriptions saved successfully');
        _notes = {}; // Clear notes after successful save
        Toast.show(
          "Descriptions saved successfully",
          duration: Toast.lengthShort,
          gravity: Toast.bottom,
        );
        // Refresh to confirm changes
        await _loadImages();
      } else {
        // PPMActionResult.queued
        print('[FormH] Descriptions queued for offline sync');
        Toast.show(
          "Descriptions saved. Will sync when online.",
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
        );
        // Refresh pending count immediately so banner shows
        await _pendingSync?.refreshPendingCount();
        // Don't clear notes yet - they'll be sent when online
      }
    } catch (e, stackTrace) {
      print('[FormH] Error saving descriptions: $e');
      print('[FormH] Stack trace: $stackTrace');
      if (mounted) {
        _showAlert("Error", "Failed to save descriptions: ${e.toString()}");
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context, // Use local context
      builder: (BuildContext ctx) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Are you sure you want to delete this image and its description?"),
        actions: <Widget>[
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: Text("Delete", style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteImage(id);
            },
          ),
        ],
      ),
    );
  }

  void _deleteImage(String id) {
    if (!mounted) return;
    setState(() => _loading = true);
    _provider
        .delete(
            url:
                "/api/m_ppm.php?action=delete_ppm_maintenance_image&ppmTaskUploadId=$id")
        .then((value) {
      if (!mounted) return;
      _showAlert("Success", value);
      _fetch(); // Refetch to update list
    }).catchError((err) {
      if (!mounted) return;
      print("Delete error: $err");
      setState(() => _loading = false);
      _showAlert("Error", "Failed to delete image: ${err.toString()}");
    }).whenComplete(() {
      if (!mounted) return;
      widget.refreshStatus(true); // Pass true to indicate completion
    });
  }

  // FUNCTIONALITY - CUSTOM

  void _generateChildren(List<dynamic> sectionItem) {
    _children = [
      _getTitle(
          "Requires at least one photo for each of the following image section below:")
    ];

    for (var i = 0; i < 3; i++) {
      _children.add(SizedBox(height: 10.0)); // Reduced spacing a bit
      _children.add(_getTitle(_sectionName[i], bold: true));
      var currentSectionData = sectionItem[i];

      // Get pending images for this section
      final pendingForSection = _pending.where((p) => p.uploadType == i.toString()).toList();

      // Add pending images first
      for (final pendingImage in pendingForSection) {
        _children.add(_pendingCard(pendingImage));
      }

      if (i == 1) { // Handling "During" section (index 1)
        List duringItems = (currentSectionData is List) ? currentSectionData : [];
        for (var j = 0; j < 3; j++) { // Always show 3 slots for "During"
          if (j < duringItems.length && duringItems[j] is FormHItem) {
            _children.add(_section(duringItems[j] as FormHItem));
          } else {
            // For "During" section, the uploadType should be "1"
            _children.add(_emptySection(1));
          }
        }
      } else { // Handling "Before" (index 0) and "After" (index 2)
        if (currentSectionData is FormHItem) {
          _children.add(_section(currentSectionData));
        } else {
          _children.add(_emptySection(i)); // i is 0 for "Before", 2 for "After"
        }
      }
    }
    if (mounted) { // Ensure widget is still in tree before calling setState
        setState(() {}); // Refresh UI with new children
    }
  }


  void _createUploadItem(int sectionIndex) async {
    // sectionIndex here corresponds to the actual uploadType:
    // 0 for "Before", 1 for "During", 2 for "After"
    if (!mounted) return;

    print('[FormH] _createUploadItem called for section $sectionIndex (${_sectionName[sectionIndex]})');

    try {
      // Step 1: Take photo using BiometricLockManager wrapper
      final XFile? pickedFile = await BiometricLockManager.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (pickedFile == null) {
        print('[FormH] User cancelled camera');
        return;
      }

      print('[FormH] Image captured: ${pickedFile.path}');

      final File imageFile = File(pickedFile.path);
      final fileName = basename(imageFile.path);

      // Show immediate feedback - image is being processed
      Toast.show(
        "Processing image...",
        duration: Toast.lengthShort,
        gravity: Toast.bottom,
      );

      // Step 2: Get location (don't block UI)
      String latitude = '0.0';
      String longitude = '0.0';
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission != LocationPermission.denied && permission != LocationPermission.deniedForever) {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 5), // Reduced from 10 to 5 seconds
          );
          latitude = position.latitude.toString();
          longitude = position.longitude.toString();
          print('[FormH] Location obtained: $latitude, $longitude');
        } else {
          print('[FormH] Location permission denied - using defaults');
        }
      } catch (e) {
        print('[FormH] Location error: $e - using defaults');
        // Continue with defaults, don't block the user
      }

      // Step 3: Compress image in background
      final Uint8List? bytes = await compressFile(imageFile, settings: {
        'quality': Platform.isIOS ? 60 : 80,
        'minWidth': 640,
        'minHeight': 480,
      });

      if (bytes == null) {
        print('[FormH] Image compression failed');
        if (mounted) {
          _showAlert("Error", "Unable to compress image.");
        }
        return;
      }

      print('[FormH] Image compressed: ${bytes.length} bytes');

      // Step 4: Upload via repository (handles online/offline)
      // This happens in the background - don't block UI
      _repository.uploadMaintenanceImage(
        ppmTaskId: widget.id,
        uploadType: sectionIndex.toString(),
        latitude: latitude,
        longitude: longitude,
        displayName: fileName,
        filename: fileName,
        sizeBytes: bytes.length,
        base64Data: base64Encode(bytes),
      ).then((result) async {
        if (!mounted) return;
        
        if (result == PPMActionResult.success) {
          print('[FormH] Upload successful');
          Toast.show(
            "Image uploaded successfully",
            duration: Toast.lengthShort,
            gravity: Toast.bottom,
          );
        } else {
          // PPMActionResult.queued
          print('[FormH] Upload queued for offline sync');
          Toast.show(
            "Image saved. Will sync when online.",
            duration: Toast.lengthShort,
            gravity: Toast.bottom,
          );
          // Refresh pending count immediately so banner shows
          await _pendingSync?.refreshPendingCount();
        }

        // Refresh display after successful upload/queue
        await _loadImages();
        await _loadPendingImages();
      }).catchError((e, stackTrace) {
        print('[FormH] Error uploading: $e');
        print('[FormH] Stack trace: $stackTrace');
        if (mounted) {
          Toast.show(
            "Failed to save image: $e",
            duration: Toast.lengthLong,
            gravity: Toast.bottom,
          );
        }
      });

      // Show pending image immediately (optimistic UI update)
      final now = DateTime.now();
      final tempPending = PendingMaintenanceImage(
        uploadType: sectionIndex.toString(),
        bytes: bytes,
        createdAt: now,
        latitude: latitude,
        longitude: longitude,
        displayName: fileName,
      );

      setState(() {
        _pending.add(tempPending);
        _regenerateUIFromCurrentState();
      });

      print('[FormH] Image added to UI - processing in background');

    } catch (e, stackTrace) {
      print('[FormH] Error in _createUploadItem: $e');
      print('[FormH] Stack trace: $stackTrace');
      if (mounted) {
        _showAlert("Error", "Failed to process image: $e");
      }
    }
  }

  void _openImageViewer(String imageUrl) {
     if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ImageViewer(url: imageUrl)),
    );
  }
  
  void _showImageOptionsBottomSheet({required String latitude, required String longitude, required String src}) {
    if (!mounted) return;

    openMap() async {
      String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
      String appleMapsUrl = 'https://maps.apple.com/?q=$latitude,$longitude';
      
      Uri mapsUri;
      if (Platform.isIOS) {
        mapsUri = Uri.parse(appleMapsUrl);
        if (!await canLaunchUrl(mapsUri)) { // Fallback to Google Maps if Apple Maps can't be launched
            mapsUri = Uri.parse(googleMapsUrl);
        }
      } else {
        mapsUri = Uri.parse(googleMapsUrl);
      }

      // Use BiometricLockManager to prevent biometric prompt when returning from maps
      if (await canLaunchUrl(mapsUri)) {
        await BiometricLockManager.launchExternalUrl(mapsUri);
      } else {
        if (mounted) _showAlert("Error", "Could not launch map application.");
      }
    }

    showModalBottomSheet(
      context: context, 
      builder: (BuildContext bc) => Container(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.image_search),
              title: Text('View Full Image'),
              onTap: () {
                Navigator.pop(bc); 
                _openImageViewer(src);
              },
            ),
            ListTile(
              leading: Icon(Icons.map_outlined),
              title: Text('Show on Map'),
              onTap: () {
                Navigator.pop(bc); 
                openMap();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAlert(String title, String description) {
    if (!mounted) return; 
    showDialog(
      context: context, 
      builder: (BuildContext ctx) => CustomDialog(
        title: title, 
        description: description,
        buttonText: "Okay",
        image: Image.asset("assets/icon_trans.png", height: 40, fit: BoxFit.contain),
        // Assuming CustomDialog has an 'okayTapped' parameter.
        // If not, the "Okay" button within CustomDialog should handle Navigator.of(ctx).pop().
        okayTapped: () => Navigator.of(ctx).pop(), 
      ),
    );
  }
}

abstract class Upload {
  final String action;
  final String ppmTaskId;

  Upload({required this.action, required this.ppmTaskId});

  Map<String, dynamic> get body;
}


class UploadItem extends Upload {
  final String uploadType; 
  final String longitude;
  final String latitude;
  final String name;
  final String filename;
  final String size;
  final String type = "data:image/jpeg;base64"; 
  final String data; 
  final String date; 

  UploadItem(
    String action,
    String ppmTaskId, {
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
        "ppmTaskId": ppmTaskId,
        "uploadType": uploadType,
        "longitude": longitude,
        "latitude": latitude,
        "fileUpload[name]": name,
        "fileUpload[filename]": filename, 
        "fileUpload[size]": size,
        "fileUpload[type]": type,
        "fileUpload[data]": data,
        "fileUpload[timestamp]": date, 
      };
}

class UploadDesc extends Upload {
  final Map<String, String> notes; 

  UploadDesc(
    String action,
    String ppmTaskId, {
    required this.notes,
  }) : super(action: action, ppmTaskId: ppmTaskId);

  @override
  Map<String, String> get body {
    Map<String, String> b = {"action": action, "ppmTaskId": ppmTaskId};
    var i = 0;
    notes.forEach((key, value) {
      b["ppmTaskUpload[$i][ppmTaskUploadId]"] = key;
      b["ppmTaskUpload[$i][ppmTaskUploadDesc]"] = value;
      i++;
    });
    return b;
  }
}

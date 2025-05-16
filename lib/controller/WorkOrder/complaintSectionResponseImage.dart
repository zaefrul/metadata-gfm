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
import 'package:google_fonts/google_fonts.dart';

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
      body: Stack(
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
          backgroundColor: _toUpload.isEmpty 
              ? AppColors.secondary
              : AppColors.primary,
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
    final totalImages = _existing.length + _toUpload.length;
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
                          border: Border.all(color: Colors.grey[200]!, width: 1.5),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.photo_library_outlined, size: 40, color: Colors.grey[400]),
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
          if (!widget.disable && _toUpload.isNotEmpty )
              _buildSubmitButton(),
        ],
      )
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
                fontSize: 16, 
                fontWeight: FontWeight.w600
              ),
            ),
            SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildExistingCard(ResponseImage img) {
    final src = img.documentSrc.startsWith("//")
        ? "https:${img.documentSrc}"
        : img.documentSrc;
    return Card(
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
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                child: Image.network(
                  src,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
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
                  Text(
                    img.documentFilename,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (img.documentDesc.isNotEmpty) ...[
                    SizedBox(height: 4),
                    Text(
                      img.documentDesc,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
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

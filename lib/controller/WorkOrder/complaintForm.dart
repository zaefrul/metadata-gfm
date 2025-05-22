import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gfm_gems/utils/image_compressor.dart';
import 'package:gfm_gems/controller/PPM/Form/openImage.dart';
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:gfm_gems/view/dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' show basename;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class FormComplaint extends StatefulWidget {
  @override
  _FormComplaintState createState() => _FormComplaintState();
}

class _FormComplaintState extends State<FormComplaint> {
  Map<String, List<LocationAPI>> _locationsByType = {};
  List<String> _zoneTypes = [];
  String? _selectedZoneType;
  List<LocationAPI> _filteredZones = [];

  LocationAPI? _selectedLocation;
  String desc = '';
  bool loading = false;
  List<UploadItem> listItem = [];

  @override
  void initState() {
    super.initState();
    ToastContext().init(context);
    _fetchZones();
  }

  Future<void> _fetchZones() async {
    try {
      final provider = Provider(fetchURL: '/zone/list')..context = context;
      final raw = await provider.getJson(url: '/zone/list');
      final result = raw as Map<String, dynamic>;

      _locationsByType = {
        for (var entry in result.entries)
          entry.key: (entry.value as List)
              .map((e) => LocationAPI.fromJson(e))
              .toList()
      };
      _zoneTypes = _locationsByType.keys.toList();
      if (_zoneTypes.isNotEmpty) {
        _selectedZoneType = _zoneTypes.first;
        _filteredZones = _locationsByType[_selectedZoneType!]!;
      }
      setState(() {});
    } catch (e) {
      debugPrint('Error fetching zones: \$e');
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'New Complaint',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, size: 22),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Report an Issue',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Please provide details about the problem you encountered',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 24),
                
                // Zone & Location Section
                _buildSection(
                  title: 'Location Details',
                  icon: Icons.location_on_outlined,
                  child: Column(
                    children: [
                      _buildDropdown<String>(
                        label: 'Zone Type',
                        items: _zoneTypes,
                        selected: _selectedZoneType,
                        onChanged: (t) {
                          setState(() {
                            _selectedZoneType = t;
                            _filteredZones = _locationsByType[t] ?? [];
                            _selectedLocation = null;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      _buildDropdown<LocationAPI>(
                        label: 'Specific Location',
                        items: _filteredZones,
                        itemAsString: (loc) => '${loc.zoneCode} — ${loc.zoneName}',
                        selected: _selectedLocation,
                        onChanged: (loc) => setState(() => _selectedLocation = loc),
                        showSearchBox: true,
                        hint: 'Search for a location...',
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Complaint Details
                _buildSection(
                  title: 'Problem Description',
                  icon: Icons.description_outlined,
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Describe the issue',
                          hintText: 'Provide detailed information about the problem',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        ),
                        maxLines: 5,
                        style: GoogleFonts.poppins(fontSize: 14),
                        onChanged: (v) => desc = v,
                      ),
                      SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Minimum 8 characters required',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Photos Section
                _buildSection(
                  title: 'Attach Photos',
                  icon: Icons.photo_camera_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add visual evidence (max 3)',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 12),
                      if (listItem.isEmpty)
                        _buildEmptyPhotoState(),
                      ...listItem.map((item) => _photoCard(item)),
                      SizedBox(height: 12),
                      if (listItem.length < 3)
                        _buildAddPhotoButton(),
                    ],
                  ),
                ),
                
                SizedBox(height: 40),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: FloatingActionButton.extended(
                      onPressed: _submitComplaint,
                      backgroundColor: AppColors.primary,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      label: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'SUBMIT COMPLAINT',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 40),

              ],
            ),
          ),
          
          if (loading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Submitting...',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required List<T> items,
    required T? selected,
    required void Function(T?) onChanged,
    String Function(T)? itemAsString,
    bool showSearchBox = false,
    String? hint,
  }) {
    return DropdownSearch<T>(
      items: (String filter, LoadProps? loadProps) => items,
      selectedItem: selected,
      popupProps: PopupProps.modalBottomSheet(
        showSearchBox: showSearchBox,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        modalBottomSheetProps: ModalBottomSheetProps(
          backgroundColor: Colors.grey[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
        ),
      ),
      itemAsString: itemAsString,
      compareFn: (T a, T b) => a == b,
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildEmptyPhotoState() {
    return Center(
      child: Container(
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
    );
  }

  Widget _buildAddPhotoButton() {
    return InkWell(
      onTap: listItem.length >= 3 ? null : _createUploadItem,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text(
              'Add Photo',
              style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _photoCard(UploadItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                item.file,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Add remark (optional)',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: GoogleFonts.poppins(fontSize: 14),
                onChanged: (t) => item.remark = t,
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red[400]),
              onPressed: () => setState(() => listItem.remove(item)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createUploadItem() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked == null) return;
    setState(() => loading = true);
    final file = File(picked.path);
    final bytes = await compressFile(file, settings: {
      'quality': Platform.isIOS ? 20 : 60,
      'minWidth': 480,
      'minHeight': 640,
    }) ?? Uint8List(0);
    if (bytes.length > 5 * 1024 * 1024) {
      Toast.show('File > 5 MB');
      setState(() => loading = false);
      return;
    }
    setState(() {
      listItem.add(UploadItem(
        file: file,
        date: DateFormat('yyyy/MM/dd HH:mm:ss').format(DateTime.now()),
        name: basename(picked.path),
        filename: basename(picked.path),
        size: bytes.length.toString(),
        data: base64Encode(bytes),
      ));
      loading = false;
    });
  }

  Future<void> _submitComplaint() async {
    if (_selectedLocation == null) {
      Toast.show('Please pick a Location');
      return;
    }
    if (desc.length < 8) {
      Toast.show('Description must be ≥ 8 chars');
      return;
    }
    setState(() => loading = true);
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getString(prefsLATITUDE);
    final lng = prefs.getString(prefsLONGITUDE);
    if (lat == null || lng == null) {
      Toast.show('Missing GPS coords');
      setState(() => loading = false);
      return;
    }
    final body = {
      'action': 'submit_complain',
      'woTaskLocation': '\$lat,\$lng',
      'woTaskComplaint': desc,
      'zoneId': _selectedLocation!.zoneId.toString(),
    };
    debugPrint('ListItem: $listItem.length');
    for (var i = 0; i < listItem.length; i++) {
      debugPrint('ListItem: ${listItem[i].toBody(i)}');
      body.addAll(listItem[i].toBody(i));
    }
    final prov = Provider(fetchURL: '/api/m_wo.php')..context = context;
    try {
      final resp = await prov.post(url: '/api/m_wo.php', body: body);
      _showResult(resp);
    } catch (e) {
      _showResult(e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  void _showResult(String msg) {
    showDialog(
      context: context,
      builder: (_) => CustomDialog(
        rootPage: '/workorder',
        description: msg,
        buttonText: 'Okay',
        image: Image.asset('assets/icon_trans.png', height: 40),
      ),
    );
  }
}

class UploadItem {
  final File file;
  final String date, name, filename, size, data;
  String remark = '';
  UploadItem({
    required this.file,
    required this.date,
    required this.name,
    required this.filename,
    required this.size,
    required this.data,
  });
  Map<String, String> toBody(int idx) => {
        'complaintImages[\$idx][name]': name,
        'complaintImages[\$idx][filename]': filename,
        'complaintImages[\$idx][size]': size,
        'complaintImages[\$idx][type]': 'data:image/jpeg;base64',
        'complaintImages[\$idx][data]': data,
        'complaintImages[\$idx][description]': remark,
      };
}

class LocationAPI {
  final int zoneId;
  final String siteId, zoneCode, zoneType, zoneName;
  final int zoneStatus;
  LocationAPI.fromJson(Map<String, dynamic> json)
      : zoneId = json['zoneId'] as int,
        siteId = json['siteId'].toString(),
        zoneCode = json['zoneCode'] as String,
        zoneType = json['zoneType'] as String,
        zoneName = json['zoneName'] as String,
        zoneStatus = json['zoneStatus'] as int;
  @override
  String toString() => '\$zoneCode — \$zoneName';
}

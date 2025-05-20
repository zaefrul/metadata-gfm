import 'dart:convert';
import 'dart:io';
import 'dart:typed_data'; // Required for Uint8List

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gfm_gems/controller/PPM/Form/openImage.dart';
import 'package:gfm_gems/model/form.dart'; // Assuming FormHItem is defined here
import 'package:gfm_gems/utils/network.dart';
import 'package:gfm_gems/utils/reference.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gfm_gems/view/dialog.dart'; // Assuming CustomDialog is defined here
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gfm_gems/utils/image_compressor.dart';
import 'package:geolocator/geolocator.dart'; // Import for Geolocator

import '../../../main.dart'; // For navigatorKey, colorTheme2, colorTheme3

class FormH extends StatefulWidget {
  final String id;
  final bool verified;
  final bool disable;
  final Function refreshStatus;

  const FormH(
    this.id,
    this.verified,
    this.refreshStatus,
    this.disable, {
    Key? key,
  }) : super(key: key);

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
  bool _loading = false;
  late List<Widget> _children = [];
  Map<String, String> _notes = {};

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
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context); // Initialize ToastContext
    _provider.context = context;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: colorTheme3),
        title: _getTitle("C. Maintenance Image", bold: true),
      ),
      body: _loading
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
    var src = item.documentSrc != null && item.documentSrc.isNotEmpty
        ? (item.documentSrc.startsWith("http") ? item.documentSrc : "http:" + item.documentSrc)
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
                          return Container(
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
          if (f != null) { // Ensure 'f' itself is not null if sectionHList can contain nulls
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
      // In case of error, display all sections as empty
      _generateChildren([null, [], null]); // Pass empty list for 'during' to show 3 empty slots
      setState(() => _loading = false);
      _showAlert("Error", "Failed to load image data: ${err.toString()}");
    });
  }

  void _postImage(UploadItem item) {
    if (!mounted) return;
    setState(() => _loading = true);

    _provider.post(url: "/api/m_ppm.php", body: item.body).then((value) {
      if (!mounted) return;
      widget.refreshStatus();
      _showAlert("Success", value ?? "Image uploaded successfully.");
      _fetch(); // Refetch to update the list
    }).catchError((err) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showAlert("Error", "Failed to upload image: ${err.toString()}");
    });
  }

  void _postNotes() {
    if (!mounted) return;
    setState(() => _loading = true);

    var uploadDesc = UploadDesc("save_image_desc", widget.id, notes: _notes);

    _provider.post(url: "/api/m_ppm.php", body: uploadDesc.body).then((value) {
      if (!mounted) return;
      _notes = {}; // Clear notes after successful save
      setState(() => _loading = false);
      _showAlert("Success", value ?? "Descriptions saved successfully.");
      _fetch(); // Refetch to confirm changes
    }).catchError((err) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showAlert("Error", "Failed to save descriptions: ${err.toString()}");
    });
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
      _showAlert("Success", value ?? "Image deleted successfully.");
      _fetch(); // Refetch to update list
    }).catchError((err) {
      if (!mounted) return;
      print("Delete error: $err");
      setState(() => _loading = false);
      _showAlert("Error", "Failed to delete image: ${err.toString()}");
    }).whenComplete(() {
      if (!mounted) return;
      widget.refreshStatus();
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

    Future<File?> getImage() async {
      try {
        final XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 70);
        if (pickedFile != null) return File(pickedFile.path);
      } catch (e) {
        print("ImagePicker error: $e");
        if (mounted) _showAlert("Error", "Could not pick image: $e");
      }
      return null;
    }

    Future<Map<String, String>?> getLocation() async {
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          if (mounted) _showAlert("Location Denied", "Location permission is required to tag images.");
          return null;
        }
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium, timeLimit: Duration(seconds:10));
        return {'latitude': position.latitude.toString(), 'longitude': position.longitude.toString()};
      } catch (e) {
        print("Location error: $e");
        if (mounted) _showAlert("Location Error", "Could not get location: $e. Using default 0.0.");
        return {'latitude': "0.0", 'longitude': "0.0"}; // Fallback or handle as error
      }
    }

    String formattedDate() =>
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    void processAndUpload(File imageFile, Map<String, String>? locationData) async {
      if (!mounted) return;
      setState(() => _loading = true);

      // Corrected call to compressFile
      final Uint8List? bytes = await compressFile(imageFile, settings: {
        'quality': Platform.isIOS ? 60 : 80, // Quality as integer
        'minWidth': 640, // minWidth as integer
        'minHeight': 480  // minHeight as integer
      });

      if (bytes == null) {
        if (mounted) {
          setState(() => _loading = false);
          _showAlert("Error", "Unable to compress image.");
        }
        return;
      }
      String base64Image = base64Encode(bytes);
      String fileName = imageFile.path.split('/').last;

      UploadItem uploadItem = UploadItem(
        "upload_maintenance_image",
        widget.id,
        date: formattedDate(),
        uploadType: sectionIndex.toString(), // Use the passed sectionIndex
        longitude: locationData?['longitude'] ?? "0.0",
        latitude: locationData?['latitude'] ?? "0.0",
        name: fileName,
        filename: fileName,
        size: bytes.length.toString(),
        data: base64Image,
      );
      _postImage(uploadItem);
    }

    File? imageFile = await getImage();
    if (imageFile != null) {
      Map<String, String>? location = await getLocation();
      processAndUpload(imageFile, location);
    } else {
      if (mounted) setState(() => _loading = false);
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

    _openMap() async {
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

      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(mapsUri);
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
                _openMap();
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

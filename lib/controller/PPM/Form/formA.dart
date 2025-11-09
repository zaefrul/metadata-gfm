import 'package:flutter/material.dart';
import 'package:GEMS/main.dart';
import 'package:GEMS/model/form.dart';
import 'package:GEMS/model/responseValue.dart';
import 'package:GEMS/model/serializers.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:GEMS/data/repository/ppm_repository.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/services.dart';
import 'package:GEMS/view/dialog.dart';
import 'package:toast/toast.dart';

class FormA extends StatefulWidget {
  final String id;
  final ValueChanged<bool>? verification;
  final bool viewer;
  final bool verified;

  const FormA(
    this.id, {
    this.verification,
    this.viewer = false,
    this.verified = false,
    super.key,
  });

  @override
  _FormAState createState() => _FormAState();
}

class _FormAState extends State<FormA> {
  String keyword = "";
  String startDate = "";
  String assetNo = "";
  String taskNo = "";
  String model = "";
  String capacity = "";
  String pmStart = "";
  String pmEnd = "";
  String assetGroup = "";

  late Provider provider;
  late PPMRepository _repository;
  late bool verified;
  Future<ResponseValue>? _sectionDataFuture; // Cache the future

  @override
  void initState() {
    super.initState();
    verified = widget.verified;
    _repository = PPMRepository();
    provider = Provider(
      taskID: widget.id,
      fetchURL: "/api/m_ppm.php?type=ppm_section_a&ppmTaskId=",
    );
    _sectionDataFuture = _fetchSectionData(); // Initialize the future
  }

  /// Fetch section data - checks offline mode first
  Future<ResponseValue> _fetchSectionData() async {
    // Check if offline mode is enabled
    final isOffline = await _repository.isOfflineModeEnabled(widget.id);
    
    if (isOffline) {
      debugPrint('FormA: Loading from offline cache');
      final sectionData = await _repository.loadSectionData(widget.id, 'A');
      
      if (sectionData != null) {
        debugPrint('FormA: Cached section data: $sectionData');
        
        // The cached data is already parsed as a Map
        // Wrap it in the expected API response format
        final cachedResponse = {
          'success': true,
          'result': sectionData, // sectionData is already a Map
          'error': '',
          'errmsg': '',
        };
        
        try {
          // Deserialize using the same serializer as Provider.fetch()
          final responseValue = serializers.deserializeWith(
            ResponseValue.serializer, 
            cachedResponse
          );
          
          if (responseValue != null) {
            debugPrint('FormA: Successfully loaded from cache, ppmTaskTimeStart: ${responseValue.sectionAList?.ppmTaskTimeStart}');
            return responseValue;
          }
        } catch (err) {
          debugPrint('FormA: Failed to deserialize cached data: $err');
        }
      } else {
        debugPrint('FormA: No cached data found, falling back to API');
      }
    }
    
    // Fetch from API (online mode or offline cache miss)
    return await provider.fetch();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    provider.context = context;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: colorTheme3,
        ),
        title: getTitle("A. Asset Details", bold: true),
        actions: widget.viewer || verified
            ? null
            : <Widget>[
                GestureDetector(
                  onTap: scan,
                  child: Icon(
                    Icons.camera,
                    color: colorTheme3,
                    size: 30,
                  ),
                ),
                SizedBox(width: 20),
              ],
      ),
      body: FutureBuilder<ResponseValue>(
        future: _sectionDataFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            assetNo = snapshot.data?.sectionAList?.assetNo ?? "";
            assetGroup = snapshot.data?.sectionAList?.assetGroupName ?? "";
            debugPrint('snapshot.data: ${snapshot.data}');
          }
          return !snapshot.hasData
              ? Center(child: CircularProgressIndicator())
              : body(snapshot.data!.sectionAList ?? FormAItem());
        },
      ),
    );
  }

  Future<void> scan() async {
    // Check if offline mode is enabled
    final isOffline = await _repository.isOfflineModeEnabled(widget.id);
    
    if (isOffline) {
      // Skip QR scan in offline mode - show confirmation dialog
      _showOfflineStartConfirmation();
      return;
    }
    
    // Normal QR scan flow for online mode
    try {
      var barcode = await BarcodeScanner.scan();
      if (barcode.rawContent == assetNo) {
        if(assetGroup != "") {
          groupExecutionDialog();
        }
        else {
          singleExecutionDialog();
        }
        return;
      } else {
        keyword = "Incorrect Asset No.";
      }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        keyword = 'The user did not grant the camera permission!';
      } else {
        keyword = 'Image scanning failed, please try again';
      }
    } on FormatException {
      keyword = 'Image scanning failed, please try again';
    } catch (e) {
      keyword = 'Image scanning failed, please try again';
    }

    Toast.show(keyword);
  }

  void _showOfflineStartConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.cloud_off, color: Colors.orange),
              SizedBox(width: 8),
              Text("Start Task"),
              SizedBox(width: 8),
              Icon(Icons.offline_bolt, size: 20, color: Colors.orange[700]),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("You are in offline mode. The task will start without QR verification."),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Asset No:", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(assetNo),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Text(
                "The start time will be synced when you're back online.",
                style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: <Widget>[
            dialogButton(
              "Cancel",
              () => Navigator.of(context).pop(),
              AppColors.secondary,
            ),
            dialogButton(
              "Start Task",
              () {
                Navigator.of(context).pop();
                _startTaskOffline();
              },
              AppColors.primaryDark,
            ),
          ],
        );
      },
    );
  }

  Future<void> _startTaskOffline() async {
    try {
      // Record the start time
      final startTime = DateTime.now();
      
      // Save start time action to pending queue (to be synced later)
      await _repository.savePPMStartTimeOffline(
        ppmTaskId: widget.id,
        groupExecution: assetGroup.isNotEmpty,
        startTime: startTime,
      );
      
      // Update the cached Section A data with the start time
      await _repository.updateSectionAStartTime(
        ppmTaskId: widget.id,
        startTime: startTime,
      );
      
      verified = true;
      widget.verification?.call(true);
      
      Toast.show("Task started in offline mode. Will sync when online.", duration: 3);
      
      // Refresh the future to reload the UI with updated start time
      setState(() {
        _sectionDataFuture = _fetchSectionData();
      });
    } catch (err) {
      Toast.show("Failed to start task: $err");
    }
  }

  Widget body(FormAItem object) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Asset Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              FutureBuilder<bool>(
                future: _repository.isOfflineModeEnabled(widget.id),
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.offline_bolt, size: 16, color: Colors.orange[800]),
                          SizedBox(width: 4),
                          Text(
                            "Offline Mode",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[800],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
            ],
          ),
          SizedBox(height: 8),
          FutureBuilder<bool>(
            future: _repository.isOfflineModeEnabled(widget.id),
            builder: (context, snapshot) {
              final isOffline = snapshot.data == true;
              return Text(
                isOffline 
                  ? "Offline mode enabled. You can start the task without QR scanning. Tap the camera icon to begin."
                  : "Check the asset details before proceeding. To execute the PPM, scan the asset QR code.",
                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
              );
            },
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
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
              children: [
                infoRow(Icons.business, "Asset Group", object.assetGroupName),
                infoRow(Icons.category, "Asset Category", object.assetCategoryName),
                infoRow(Icons.widgets, "Asset Type", object.assetTypeName),
                infoRow(Icons.confirmation_number, "Asset No.", object.assetNo),
                infoRow(Icons.task, "Task No", object.assetName),
                infoRow(Icons.devices, "Model", object.assetModelName),
                infoRow(Icons.bar_chart, "Capacity", object.assetCapacity),
                infoRow(Icons.access_time, "PM Start Date/Time", object.ppmTaskTimeStart),
                infoRow(Icons.access_time_filled, "PM End Date/Time", object.ppmTaskTimeServiced),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                SizedBox(height: 2),
                Text(value == "" ? "-" : value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getTitle(String text, {bool bold = false}) => Container(
        alignment: Alignment.centerLeft,
        padding: bold ? null : EdgeInsets.only(top: 12),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: colorTheme3,
          ),
        ),
      );

  void alert(String txt) {
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) => CustomDialog(
        description: txt,
        buttonText: "Okay",
        image: Image.asset(
          "assets/icon_trans.png",
          height: 40,
        ),
      ),
    );
  }

  ElevatedButton dialogButton(String text, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(text, style: TextStyle(color: Colors.white)),
    );
  }

  void groupExecutionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Execute PPM"),
          content: Text("Do you want to execute PPM for all assets under this group, type, and checklist?"),
          actions: <Widget>[
            dialogButton(
              "No, Only Execute this asset",
              () {
                Navigator.of(context).pop();
                sendPPMExecutionRequest();
              },
              AppColors.dangerDark,
            ),
            dialogButton(
              "Yes, Execute All Assets",
              () {
                Navigator.of(context).pop();
                sendPPMExecutionRequest(groupExecution: true);
              },
              AppColors.primaryDark,
            ),
            dialogButton(
              "Cancel", 
              () {
                Navigator.of(context).pop();
              }, 
                AppColors.secondaryDark
            ),
          ],
        );
      },
    );
  }

  void singleExecutionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Execute PPM"),
          content: Text("Do you want to execute PPM for this asset?"),
          actions: <Widget>[
            dialogButton(
              "No",
              () {
                Navigator.of(context).pop();
              },
              AppColors.dangerDark,
            ),
            dialogButton(
              "Yes",
              () {
                Navigator.of(context).pop();
                sendPPMExecutionRequest();
              },
              AppColors.primaryDark,
            ),
          ],
        );
      },
    );
  }

  void sendPPMExecutionRequest({bool groupExecution = false}) {
    provider.post(
      url: "/api/m_ppm.php",
      body: {
        "action": "save_scan_start_time",
        "ppmTaskId": widget.id,
        "ppmGroupExecution": groupExecution ? "1" : "0",
      },
    ).then((value) {
      verified = true;
      widget.verification?.call(true);
      alert(value);
    }).catchError((err) {
      verified = false;
      alert(err);
    });
  }
}

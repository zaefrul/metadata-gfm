import 'dart:io';

import 'package:flutter/material.dart';
import 'package:GEMS/model/responseValue.dart';
import 'package:GEMS/model/serializers.dart';
import 'package:GEMS/utils/network.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:GEMS/view/dialog.dart';
import 'package:toast/toast.dart';
import 'package:GEMS/data/repository/ppm_repository.dart';
import '../../../main.dart';

class FormG extends StatefulWidget {
  final String id;
  final bool verified;
  final ValueChanged<bool> refreshStatus;
  final bool disable;

  const FormG(
    this.id,
    this.verified,
    this.refreshStatus,
    this.disable, {
    super.key,
  });

  @override
  _FormGState createState() => _FormGState();
}

class _FormGState extends State<FormG> {
  bool loading = false;
  late Provider provider;
  late PPMRepository _repository;
  late UploadItem _uploadItem;  // <-- Initialize it here instead.
  Future<ResponseValue>? _sectionDataFuture; // Cache the future

  @override
  void initState() {
    super.initState();
    provider = Provider(
      taskID: widget.id,
      fetchURL: "/api/m_ppm.php?type=ppm_section_g&ppmTaskId=",
    );
    
    _repository = PPMRepository();
    _uploadItem = UploadItem("save_ppm_remark", widget.id); // initialization here
    _sectionDataFuture = _fetchSectionData(); // Initialize the future
  }

  /// Check if device has internet connectivity
  Future<bool> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Fetch section data - checks offline mode first
  Future<ResponseValue> _fetchSectionData() async {
    // Check if offline mode is enabled
    final isOffline = await _repository.isOfflineModeEnabled(widget.id);
    
    if (isOffline) {
      debugPrint('FormG: Loading from offline cache');
      final sectionData = await _repository.loadSectionData(widget.id, 'G');
      
      if (sectionData != null) {
        debugPrint('FormG: Cached section data found');
        
        // The cached data is already parsed as a Map
        // Wrap it in the expected API response format
        final cachedResponse = {
          'success': true,
          'result': sectionData,
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
            debugPrint('FormG: Successfully loaded remark from cache');
            return responseValue;
          }
        } catch (err) {
          debugPrint('FormG: Failed to deserialize cached data: $err');
        }
      } else {
        debugPrint('FormG: No cached data found');
      }
    }
    
    // Check connectivity before trying API
    final isOnline = await _checkConnectivity();
    if (!isOnline) {
      debugPrint('FormG: No internet connection and no cache available');
      // Return empty response to prevent hanging
      return ResponseValue((b) => b
        ..success = false
        ..error = 'NO_CONNECTION'
        ..errmsg = 'No internet connection. Please enable offline mode when connected.'
        ..result = ''
        ..sectionGList = null);
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
        iconTheme: IconThemeData(color: colorTheme3),
        title: getTitle("G. Remark", bold: true),
      ),
      body: FutureBuilder<ResponseValue>(
        future: _sectionDataFuture,
        builder: (context, AsyncSnapshot<ResponseValue> snapshot) {
          // Show error message if no connection and no cache
          if (snapshot.hasData && snapshot.data?.error == 'NO_CONNECTION') {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: Colors.orange[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cloud_off, size: 48, color: Colors.orange),
                        SizedBox(height: 8),
                        Text(
                          'No Internet Connection',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Please enable offline mode when connected to internet to access this section offline.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          
          if (snapshot.hasData) {
            _uploadItem.ppmTaskRemark =
                snapshot.data!.sectionGList?.ppmTaskRemark ?? "";
          }
          return !snapshot.hasData
              ? Center(child: CircularProgressIndicator())
              : (loading
                  ? Stack(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: TextField(
                            enabled: !widget.disable,
                            controller: TextEditingController(
                                text: snapshot.data!.sectionGList?.ppmTaskRemark ?? ""),
                            keyboardType: TextInputType.multiline,
                            maxLength: 500,
                            maxLines: null,
                            onChanged: (value) {
                              _uploadItem.ppmTaskRemark = value;
                            },
                          ),
                        ),
                        Container(
                          color: Colors.black.withOpacity(0.5),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      ],
                    )
                  : Padding(
                      padding: EdgeInsets.all(16),
                      child: TextField(
                        enabled: !widget.disable,
                        controller: TextEditingController(
                            text: snapshot.data!.sectionGList?.ppmTaskRemark ?? ""),
                        keyboardType: TextInputType.multiline,
                        maxLength: 500,
                        maxLines: null,
                        onChanged: (value) {
                          _uploadItem.ppmTaskRemark = value;
                        },
                      ),
                    ));
        },
      ),
      floatingActionButton: widget.disable
          ? null
          : FloatingActionButton.extended(
              label: Text("Save"),
              onPressed: () async {
                if (widget.verified) {
                  setState(() {
                    loading = true;
                  });
                  
                  try {
                    final result = await _repository.saveRemark(
                      ppmTaskId: widget.id,
                      remark: _uploadItem.ppmTaskRemark ?? '',
                    );
                    
                    if (result == PPMActionResult.success) {
                      alert("Remark saved successfully");
                      
                      // Reload the section data to reflect changes
                      setState(() {
                        _sectionDataFuture = _fetchSectionData();
                      });
                    } else {
                      alert("Remark saved. Will sync when online.");
                      
                      // In offline mode, reload to show the saved state
                      setState(() {
                        _sectionDataFuture = _fetchSectionData();
                      });
                    }
                    
                    widget.refreshStatus(true);
                  } catch (err) {
                    alert(err.toString());
                  } finally {
                    setState(() {
                      loading = false;
                    });
                  }
                } else {
                  Toast.show("Please verified this task.");
                }
              },
            ),
    );
  }

  Widget getTitle(String text, {bool bold = false}) => Container(
        alignment: Alignment.centerLeft,
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
        image: Image.asset("assets/icon_trans.png", height: 40),
      ),
    );
  }
}

class UploadItem extends Upload {
  String? ppmTaskRemark;

  UploadItem(String action, String ppmTaskId, {this.ppmTaskRemark = ""})
      : super(action: action, ppmTaskId: ppmTaskId);

  @override
  Map<String, dynamic> get body => {
        "action": action,
        "ppmTaskId": ppmTaskId,
        "ppmTaskRemark": ppmTaskRemark ?? ""
      };
}

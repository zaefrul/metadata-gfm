import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:GEMS/data/repository/work_order_detail_repository.dart';
import 'package:GEMS/utils/biometric_lock_manager.dart';

import 'package:GEMS/utils/network.dart';
import 'package:GEMS/view/dialog.dart';
import 'package:GEMS/utils/reference.dart';

import 'complaintSign.dart';

import '../../main.dart';

class ComplaintPDF extends StatefulWidget {
  final bool viewer;
  final String id;
  final String transactionNo;
  final Function? submitted;
  final int checkpoint;
  final String taskCategory;

  const ComplaintPDF({
    super.key,
    required this.viewer,
    required this.id,
    required this.transactionNo,
    this.submitted,
    required this.checkpoint,
    required this.taskCategory,
  });

  @override
  State<ComplaintPDF> createState() => _ComplaintPDFState();
}

class _ComplaintPDFState extends State<ComplaintPDF> {
  String assetPDFPath = "";
  PdfControllerPinch? _pdfController;
  late CustomDialog dialog; // Initialize with a default value
  String src = "";
  String? _loadError;
  bool _loadingPdf = true;
  int _loadGeneration = 0;
  final WorkOrderDetailRepository _repository = WorkOrderDetailRepository();

  @override
  void initState() {
    super.initState();

    // Initialize dialog with a default value to avoid LateInitializationError
    dialog = CustomDialog(
      rootPage: "/workorder",
      title: "",
      description: "",
      buttonText: "Okay",
      image: Image.asset(
        "assets/icon_trans.png",
        height: 40,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_loadPdf());
      }
    });
  }

  String _resolvePdfUrl(String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty) {
      return '';
    }
    if (value.startsWith('https://') || value.startsWith('http://')) {
      return value;
    }
    if (value.startsWith('//')) {
      return 'https:$value';
    }
    return value;
  }

  Future<void> _loadPdf() async {
    final generation = ++_loadGeneration;
    if (!mounted) return;
    setState(() {
      _loadingPdf = true;
      _loadError = null;
      _pdfController?.dispose();
      _pdfController = null;
    });

    try {
      final provider = Provider(
          fetchURL: "/api/m_wo.php?type=preview_pdf&woTaskId=${widget.id}");
      provider.context = context;

      final value = await provider.fetch().timeout(
        const Duration(seconds: 45),
        onTimeout: () => throw TimeoutException('PDF preview timed out'),
      );
      if (!mounted || generation != _loadGeneration) return;
      debugPrint(value.toString());

      src = _resolvePdfUrl(value.result?.toString());
      if (src.isEmpty) {
        throw Exception('PDF URL is empty');
      }

      final file = await createFileOfPdfUrl(src);
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        assetPDFPath = file.path;
        _pdfController?.dispose();
        _pdfController = PdfControllerPinch(
          document: PdfDocument.openFile(file.path),
        );
        _loadingPdf = false;
        _loadError = null;
      });
    } catch (err) {
      debugPrint(err.toString());
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        _loadingPdf = false;
        _loadError =
            'Unable to load the work order PDF. You can still continue, or tap Retry.';
      });
    }
  }

  Future<File> createFileOfPdfUrl(String url) async {
    final uri = Uri.parse(url);
    var filename = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'wo.pdf';
    filename = filename.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    if (!filename.toLowerCase().endsWith('.pdf')) {
      filename = '${widget.transactionNo}.pdf';
    }

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 20);
    try {
      final request = await client.getUrl(uri);
      final response = await request.close().timeout(const Duration(seconds: 45));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException('PDF download failed (${response.statusCode})', uri: uri);
      }
      final bytes = await consolidateHttpClientResponseBytes(response)
          .timeout(const Duration(seconds: 45));
      if (bytes.length < 5 ||
          String.fromCharCodes(bytes.take(5)) != '%PDF-') {
        throw const FormatException('Downloaded file is not a PDF');
      }
      final dir = (await getApplicationDocumentsDirectory()).path;
      final file = File('$dir/$filename');
      await file.writeAsBytes(bytes);
      return file;
    } finally {
      client.close(force: true);
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    // Dispose dialog's controller only if it has been initialized
    dialog.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Checkpoint are : ${widget.checkpoint}');
    String submitText = "Complete";
    if (widget.checkpoint == 1 || widget.checkpoint == 5) submitText = "Verify";
    if (widget.checkpoint == 2 || widget.checkpoint == 4 || widget.checkpoint == 6) submitText = "Check";
    if (widget.checkpoint == 3) submitText = "Complete";

    return Scaffold(
      appBar: AppBar(
        title: title(widget.transactionNo),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: colorTheme3,
        ),
        actions: widget.viewer
            ? null
            : <Widget>[
                widget.checkpoint == 1 && submitText != "Verify"
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            dialog = CustomDialog(
                              rootPage: "/workorder",
                              title: "Remark",
                              description: "Remark",
                              buttonText: "Okay",
                              cancel: true,
                              secondButton: false,
                              image: Image.asset(
                                "assets/icon_trans.png",
                                height: 40,
                              ),
                              remarkTapped: (String text) {
                                Navigator.pop(context);
                                post(text);
                              },
                            );
                            showDialog(
                                context: navigatorKey.currentContext!,
                                builder: (BuildContext context) => dialog);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(6.0)),
                              color: Colors.redAccent,
                            ),
                            width: 80,
                            child: Center(child: title("Re-Open", bold: false)),
                          ),
                        ),
                      )
                    : Container(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: _openSignatureFlow,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(6.0)),
                          color: colorTheme2),
                      width: 80,
                      child: Center(child: title(submitText, bold: false)),
                    ),
                  ),
                ),
              ],
      ),
      body: _pdfController != null
          ? PdfViewPinch(controller: _pdfController!)
          : Center(
              child: _loadingPdf
                  ? const CircularProgressIndicator()
                  : Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _loadError ??
                                'Unable to load the work order PDF.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colorTheme3),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadPdf,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
            ),
      floatingActionButton: src.isEmpty
          ? null
          : FloatingActionButton.extended(
              label: const Text("Open File"),
              onPressed: openPdfFile,
            ),
    );
  }

  Widget title(String text, {bool bold = true}) => Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: bold ? colorTheme3 : Colors.white,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      );

  Future<bool> _hasConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<void> _openSignatureFlow() async {
    final offlineMode = await _repository.isOfflineModeEnabled(widget.id);
    final online = await _hasConnectivity();

    if (offlineMode || !online) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogCtx) => CustomDialog(
          description: offlineMode
              ? 'Offline mode is on. Your signature will be saved locally and submitted automatically when you sync.'
              : 'No internet connection. Your signature will be queued and submitted when you are back online.',
          buttonText: 'Continue',
          cancel: true,
          image: Image.asset('assets/icon_trans.png', height: 40),
          okayTapped: () {
            Navigator.of(dialogCtx).pop();
            _navigateToSignature();
          },
        ),
      );
      return;
    }

    _navigateToSignature();
  }

  void _navigateToSignature() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComplaintSignature(
          id: widget.id,
          result: "Check",
          checkpoint: widget.checkpoint,
          taskCategory: widget.taskCategory,
        ),
      ),
    );
  }

  void post(String text) {
    var body = UploadItem(action: "return_verify", id: widget.id, remark: text);

    Provider provider = Provider(fetchURL: "/api/m_wo.php");
    provider.context = context;
    provider
        .post(url: "/api/m_wo.php", body: body.body)
        .then((value) => alert(value))
        .catchError((err) => alert(err.toString()));
  }

  Future<void> openPdfFile() async {
    if (src.isEmpty) {
      return;
    }
    // Open the remote PDF in the device's external viewer/browser.
    // A file:// uri can't be handed to other apps on Android, so use the URL.
    await BiometricLockManager.launchExternalUrlString(src);
  }

  void alert(String txt) {
    showDialog(
        context: navigatorKey.currentContext!,
        builder: (BuildContext context) => CustomDialog(
              rootPage: "/workorder",
              description: txt,
              buttonText: "Okay",
              image: Image.asset(
                "assets/icon_trans.png",
                height: 40,
              ),
            ));
  }
}

class UploadItem extends Upload {
  final String remark;

  UploadItem({required String id, required super.action, required this.remark})
      : super(ppmTaskId: id);

  @override
  Map<String, dynamic> get body => {
        "action": action,
        "woTaskId": ppmTaskId,
        "remark": remark,
      };
}

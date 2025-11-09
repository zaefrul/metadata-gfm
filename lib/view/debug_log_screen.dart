import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

import '../utils/debug_log_service.dart';

class DebugLogScreen extends StatefulWidget {
  static const routeName = '/debug-logs';

  const DebugLogScreen({super.key});

  @override
  State<DebugLogScreen> createState() => _DebugLogScreenState();
}

class _DebugLogScreenState extends State<DebugLogScreen> {
  final DebugLogService _service = DebugLogService.instance;
  bool _isExporting = false;

  Future<void> _exportLogs() async {
    if (_isExporting) return;

    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Log export is not supported on web builds.')),
      );
      return;
    }

    setState(() => _isExporting = true);

    try {
      final entries = _service.entries;
      if (entries.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No logs to export yet.')),
        );
        return;
      }

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final logsAsBytes = Uint8List.fromList(utf8.encode(entries.join('\n')));

      String? savedPath;
      try {
        savedPath = await FilePicker.platform.saveFile(
          dialogTitle: 'Save debug log',
          fileName: 'gems_debug_$timestamp.txt',
          type: FileType.custom,
          allowedExtensions: const ['txt'],
          bytes: logsAsBytes,
        );
      } on Exception catch (pickerErr) {
        debugPrint('DebugLogScreen saveFile failed: $pickerErr');
        savedPath = null;
      }

      if (!mounted) return;

      if (savedPath == null || savedPath.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export cancelled.')),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logs exported to $savedPath'),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (err, stack) {
      debugPrint('DebugLogScreen export failed: $err\n$stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to export logs.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Logs'),
        actions: [
          if (_isExporting)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save_alt),
              tooltip: 'Export logs',
              onPressed: _exportLogs,
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _service.clear,
            tooltip: 'Clear logs',
          ),
        ],
      ),
      body: StreamBuilder<List<String>>(
        stream: _service.entries$,
        initialData: _service.entries,
        builder: (context, snapshot) {
          final logs = snapshot.data ?? const <String>[];
          if (logs.isEmpty) {
            return const Center(
              child: Text('No debug logs yet.'),
            );
          }
          return Scrollbar(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final entry = logs[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    entry,
                    style: const TextStyle(fontSize: 12, height: 1.4),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

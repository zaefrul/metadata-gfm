import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:GEMS/utils/biometric_lock_manager.dart';

import '../utils/debug_log_service.dart';

class DebugLogScreen extends StatefulWidget {
  static const routeName = '/debug-logs';

  const DebugLogScreen({super.key});

  @override
  State<DebugLogScreen> createState() => _DebugLogScreenState();
}

class _DebugLogScreenState extends State<DebugLogScreen> {
  final DebugLogService _service = DebugLogService.instance;
  final TextEditingController _searchController = TextEditingController();
  bool _isExporting = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
        // Suppress biometric lock when opening file save dialog
        BiometricLockManager.suppressNextLock();
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
            onPressed: () {
              _service.clear();
              setState(() => _searchQuery = '');
              _searchController.clear();
            },
            tooltip: 'Clear logs',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search logs... (e.g., "ComplaintSectionC", "error", "upload")',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),
          // Log list
          Expanded(
            child: StreamBuilder<List<String>>(
              stream: _service.entries$,
              initialData: _service.entries,
              builder: (context, snapshot) {
                final logs = snapshot.data ?? const <String>[];
                if (logs.isEmpty) {
                  return const Center(
                    child: Text('No debug logs yet.'),
                  );
                }
                
                // Reverse the list to show latest logs at the top
                final reversedLogs = logs.reversed.toList();
                
                // Filter logs based on search query
                final filteredLogs = _searchQuery.isEmpty
                    ? reversedLogs
                    : reversedLogs.where((log) => log.toLowerCase().contains(_searchQuery)).toList();
                
                if (filteredLogs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No logs match "$_searchQuery"',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                
                return Scrollbar(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: filteredLogs.length,
                    itemBuilder: (context, index) {
                      final entry = filteredLogs[index];
                      final logParts = _parseLogEntry(entry);
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: logParts.isError 
                                ? Colors.red.withOpacity(0.1) 
                                : Colors.grey.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: logParts.isError 
                                  ? Colors.red.withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (logParts.source != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _getSourceColor(logParts.source!),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          logParts.source!,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      if (logParts.timestamp != null) ...[
                                        const SizedBox(width: 8),
                                        Text(
                                          logParts.timestamp!,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              Text(
                                logParts.message,
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.4,
                                  color: logParts.isError ? Colors.red[900] : Colors.black87,
                                  fontWeight: logParts.isError ? FontWeight.w500 : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Parse log entry to extract source, timestamp, and message
  LogEntry _parseLogEntry(String entry) {
    // Pattern: [timestamp] SourceName: message
    // Or: SourceName: message
    // Or: plain message
    
    String? timestamp;
    String? source;
    String message = entry;
    bool isError = entry.toLowerCase().contains('error') || 
                   entry.toLowerCase().contains('failed') ||
                   entry.toLowerCase().contains('exception');
    
    // Try to extract timestamp [yyyy-MM-dd HH:mm:ss.SSS]
    final timestampMatch = RegExp(r'^\[([^\]]+)\]\s*').firstMatch(entry);
    if (timestampMatch != null) {
      timestamp = timestampMatch.group(1);
      message = entry.substring(timestampMatch.end);
    }
    
    // Try to extract source (e.g., "ComplaintSectionC:", "WorkOrderRepository:", etc.)
    final sourceMatch = RegExp(r'^([A-Z][a-zA-Z0-9_]*)\s*:\s*').firstMatch(message);
    if (sourceMatch != null) {
      source = sourceMatch.group(1);
      message = message.substring(sourceMatch.end);
    }
    
    return LogEntry(
      timestamp: timestamp,
      source: source,
      message: message,
      isError: isError,
    );
  }

  /// Get color based on source name for better visual distinction
  Color _getSourceColor(String source) {
    // Hash the source name to get a consistent color
    final hash = source.hashCode;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.cyan,
    ];
    return colors[hash.abs() % colors.length];
  }
}

/// Helper class to hold parsed log entry components
class LogEntry {
  final String? timestamp;
  final String? source;
  final String message;
  final bool isError;

  LogEntry({
    this.timestamp,
    this.source,
    required this.message,
    this.isError = false,
  });
}

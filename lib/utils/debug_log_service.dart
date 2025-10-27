import 'dart:async';

class DebugLogService {
  DebugLogService._();

  static final DebugLogService instance = DebugLogService._();

  static const _maxEntries = 250;

  final List<String> _entries = <String>[];
  final StreamController<List<String>> _controller =
      StreamController<List<String>>.broadcast();

  Stream<List<String>> get entries$ => _controller.stream;

  List<String> get entries => List<String>.unmodifiable(_entries);

  void add(String message) {
    final timestamp = DateTime.now().toIso8601String();
    _entries.add('[$timestamp] $message');
    if (_entries.length > _maxEntries) {
      _entries.removeAt(0);
    }
    _controller.add(List<String>.unmodifiable(_entries));
  }

  void clear() {
    _entries.clear();
    _controller.add(const <String>[]);
  }

  void dispose() {
    _controller.close();
  }
}

import 'dart:async';

class PendingSyncController {
  const PendingSyncController({
    required this.pendingCount$,
    required this.retry,
  });

  final Stream<int> pendingCount$;
  final Future<void> Function() retry;
}

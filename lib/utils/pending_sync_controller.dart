import 'dart:async';

/// Controller for managing pending sync state and retry functionality.
/// Used for both Work Order and PPM offline modes.
class PendingSyncController {
  const PendingSyncController({
    required this.pendingCount$,
    required this.retry,
  });

  final Stream<int> pendingCount$;
  final Future<void> Function() retry;
}

import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

import 'package:GEMS/utils/reference.dart';
import 'package:GEMS/utils/pending_sync_controller.dart';

class PendingSyncIndicator extends StatelessWidget {
  const PendingSyncIndicator({
    super.key,
    required this.controller,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  final PendingSyncController controller;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: controller.pendingCount$,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        if (count == 0) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: padding,
          child: PendingSyncBanner(
            count: count,
            onRetry: controller.retry,
          ),
        );
      },
    );
  }
}

class PendingSyncBanner extends StatelessWidget {
  const PendingSyncBanner({
    super.key,
    required this.count,
    required this.onRetry,
  });

  final int count;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final attemptsLabel = count == 1 ? 'action' : 'actions';
    return Container(
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.cloud_off, color: AppColors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Waiting to sync $count $attemptsLabel. We\'ll retry automatically when you\'re back online.',
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: AppColors.dark,
              ),
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: () async {
              Toast.show(
                'Syncing now…',
                duration: Toast.lengthShort,
                gravity: Toast.bottom,
              );
              try {
                await onRetry();
              } catch (err) {
                Toast.show(
                  'Still offline. We\'ll keep trying.',
                  duration: Toast.lengthShort,
                  gravity: Toast.bottom,
                  backgroundColor: AppColors.danger,
                );
                debugPrint('Retry pending sync failed: $err');
              }
            },
            child: const Text('Retry now'),
          ),
        ],
      ),
    );
  }
}

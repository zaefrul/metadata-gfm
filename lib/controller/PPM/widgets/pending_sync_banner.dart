import 'package:flutter/material.dart';
import 'package:GEMS/controller/PPM/pending_sync.dart';
import 'package:GEMS/utils/reference.dart';

class PPMPendingSyncIndicator extends StatelessWidget {
  final PPMPendingSyncController controller;

  const PPMPendingSyncIndicator({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: controller.pendingCount$,
      initialData: controller.currentPendingCount,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        if (count == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: colorTheme2.withOpacity(0.1),
          child: Row(
            children: [
              Icon(Icons.cloud_upload, color: colorTheme2, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  count == 1
                      ? '1 action pending sync'
                      : '$count actions pending sync',
                  style: TextStyle(
                    color: colorTheme3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await controller.retry();
                },
                child: Text(
                  'RETRY',
                  style: TextStyle(
                    color: colorTheme2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

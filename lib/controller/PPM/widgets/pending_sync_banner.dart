import 'package:flutter/material.dart';
import 'package:GEMS/controller/PPM/pending_sync.dart';
import 'package:GEMS/data/repository/ppm_repository.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:toast/toast.dart';

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

        return StreamBuilder<PPMSyncProgress?>(
          stream: controller.syncProgress$,
          builder: (context, progressSnapshot) {
            final progress = progressSnapshot.data;
            final isSyncing = progress != null && !progress.isComplete;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: colorTheme2.withOpacity(0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isSyncing ? Icons.sync : Icons.cloud_upload,
                        color: colorTheme2,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isSyncing
                              ? progress.statusText
                              : count == 1
                                  ? '1 action pending sync'
                                  : '$count actions pending sync',
                          style: TextStyle(
                            color: colorTheme3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (!isSyncing)
                        TextButton(
                          onPressed: () async {
                            ToastContext().init(context);
                            final beforeCount = controller.currentPendingCount;

                            Toast.show(
                              'Syncing $beforeCount ${beforeCount == 1 ? 'action' : 'actions'}...',
                              duration: Toast.lengthShort,
                              gravity: Toast.bottom,
                            );

                            await controller.retry();

                            // Check final count to show success/failure feedback
                            final afterCount = controller.currentPendingCount;
                            if (afterCount == 0) {
                              Toast.show(
                                'All actions synced successfully!',
                                duration: Toast.lengthLong,
                                gravity: Toast.bottom,
                              );
                            } else if (afterCount < beforeCount) {
                              Toast.show(
                                'Synced ${beforeCount - afterCount} actions. $afterCount still pending (server error).',
                                duration: Toast.lengthLong,
                                gravity: Toast.bottom,
                              );
                            } else {
                              Toast.show(
                                'Sync failed. Check your connection and try again.',
                                duration: Toast.lengthLong,
                                gravity: Toast.bottom,
                              );
                            }
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
                  if (isSyncing) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress.percentage,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(colorTheme2),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(progress.percentage * 100).toStringAsFixed(0)}% complete',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}


import 'package:flutter/material.dart';
import 'package:GEMS/controller/PPM/pending_sync.dart';
import 'package:GEMS/data/repository/ppm_repository.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:GEMS/view/gems_chrome.dart';
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
              color: GemsChrome.primarySoft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isSyncing ? Icons.sync : Icons.cloud_upload,
                        color: GemsChrome.primary,
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
                          style: GemsChrome.body(weight: FontWeight.w500),
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
                            style: GemsChrome.body(
                              weight: FontWeight.w600,
                              color: GemsChrome.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (isSyncing) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress.percentage,
                      backgroundColor: GemsChrome.border,
                      color: GemsChrome.primary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(progress.percentage * 100).toStringAsFixed(0)}% complete',
                      style: GemsChrome.body(size: 12, color: GemsChrome.textSoft),
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


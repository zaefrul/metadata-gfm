import 'package:GEMS/controller/PPM/search.dart';
import 'package:GEMS/controller/WorkOrder/complaintSearch.dart';
import 'package:GEMS/model/user.dart';
import 'package:GEMS/service/pending_notification_store.dart';
import 'package:GEMS/utils/network.dart';
import 'package:flutter/material.dart';

class NotificationRouter {
  /// Entry point for push/inbox taps. Checks backend identity before deep-link.
  static Future<void> navigateFromPayload(
    GlobalKey<NavigatorState> navigatorKey,
    Map<String, String> data, {
    bool skipBackendCheck = false,
  }) async {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    await NetworkEnvironment.load();
    final current = NetworkEnvironment.currentSource;
    final rawSource = data['network_source'] ?? data['networkSource'] ?? '';
    final target = rawSource.isEmpty
        ? current
        : NetworkEnvironment.sourceFromValue(rawSource);

    if (!skipBackendCheck && target != current) {
      final confirmed = await _promptSwitchBackend(
        navigatorKey.currentContext,
        target,
      );
      if (confirmed != true) {
        return;
      }
      await _switchBackendAndLogin(navigatorKey, data, target);
      return;
    }

    _openDestination(navigator, data);
  }

  /// After successful login (or homepage ready), open any pending deep-link.
  static Future<void> consumePendingAndNavigate(
    GlobalKey<NavigatorState> navigatorKey,
  ) async {
    final pending = await PendingNotificationStore.consume();
    if (pending == null || pending.isEmpty) {
      return;
    }

    await NetworkEnvironment.load();
    final current = NetworkEnvironment.currentSource;
    final rawSource =
        pending['network_source'] ?? pending['networkSource'] ?? '';
    if (rawSource.isNotEmpty) {
      final target = NetworkEnvironment.sourceFromValue(rawSource);
      if (target != current) {
        // User logged into a different backend than the pending notification.
        await PendingNotificationStore.clear();
        return;
      }
    }

    // Session now matches; skip mismatch prompt.
    await navigateFromPayload(
      navigatorKey,
      pending,
      skipBackendCheck: true,
    );
  }

  static Future<bool?> _promptSwitchBackend(
    BuildContext? context,
    NetworkSource target,
  ) async {
    if (context == null || !context.mounted) {
      return false;
    }
    final label = NetworkEnvironment.labelFor(target);
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Switch to $label?'),
        content: Text(
          'This notification belongs to $label. '
          'Switch backends and sign in to open it?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Switch & Open'),
          ),
        ],
      ),
    );
  }

  static Future<void> _switchBackendAndLogin(
    GlobalKey<NavigatorState> navigatorKey,
    Map<String, String> data,
    NetworkSource target,
  ) async {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    await PendingNotificationStore.save(data);
    await NetworkEnvironment.save(target);

    try {
      final raw = await User.getPrefUser;
      final user = User.fromMap(raw);
      await user.removeUser();
    } catch (_) {
      // Already logged out.
    }

    navigator.pushNamedAndRemoveUntil(
      '/',
      (route) => false,
      arguments: LoginArguments(preselectedSource: target),
    );
  }

  static void _openDestination(
    NavigatorState navigator,
    Map<String, String> data,
  ) {
    final module = data['module'] ?? '';
    final taskNo = data['task_no'] ?? data['taskNo'] ?? '';

    switch (module) {
      case 'ppm':
        if (taskNo.isNotEmpty) {
          navigator.pushNamed(
            Search.routeName,
            arguments: SearchArguments(index: 1, initialTaskNo: taskNo),
          );
        } else {
          navigator.pushNamed('/ppm');
        }
        break;
      case 'wo':
        if (taskNo.isNotEmpty) {
          navigator.pushNamed(
            SearchComplaint.routeName,
            arguments: SearchComplaintArguments(initialTaskNo: taskNo),
          );
        } else {
          navigator.pushNamed('/workorder');
        }
        break;
      case 'mr':
        navigator.pushNamed('/workorder');
        break;
      case 'fca':
      default:
        navigator.pushNamed('/homepage');
        break;
    }
  }
}

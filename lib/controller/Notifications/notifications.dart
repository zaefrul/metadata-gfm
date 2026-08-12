import 'package:flutter/material.dart';
import 'package:GEMS/data/repository/notification_repository.dart';
import 'package:GEMS/model/notification_item.dart';
import 'package:GEMS/service/notification_router.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:GEMS/main.dart' show navigatorKey;

class NotificationsScreen extends StatefulWidget {
  static const routeName = '/notifications';

  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationRepository _repository = NotificationRepository();
  List<NotificationItem> _items = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final items = await _repository.fetchNotifications(context);
      if (!mounted) return;
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _markAllRead() async {
    try {
      await _repository.markAllRead(context);
      await _loadNotifications();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark all as read: $e')),
      );
    }
  }

  Future<void> _openNotification(NotificationItem item) async {
    try {
      if (!item.isRead) {
        await _repository.markRead(context, item.id);
      }
    } catch (_) {}

    final data = item.routingData;
    if (data.isNotEmpty) {
      await NotificationRouter.navigateFromPayload(navigatorKey, data);
    }

    if (mounted) {
      await _loadNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_items.any((item) => !item.isRead))
            TextButton(
              onPressed: _markAllRead,
              child: Text('Mark all read', style: TextStyle(color: colorTheme3)),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadNotifications,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ],
      );
    }
    if (_items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(child: Text('No notifications yet')),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = _items[index];
        return ListTile(
          leading: Icon(
            item.isRead ? Icons.notifications_none : Icons.notifications,
            color: item.isRead ? Colors.grey : colorTheme3,
          ),
          title: Text(
            item.title,
            style: TextStyle(
              fontWeight: item.isRead ? FontWeight.normal : FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(item.body),
              if (item.sentAt != null) ...[
                const SizedBox(height: 6),
                Text(
                  item.sentAt!,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ],
          ),
          isThreeLine: true,
          onTap: () => _openNotification(item),
        );
      },
    );
  }
}

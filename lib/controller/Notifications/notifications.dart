import 'package:flutter/material.dart';
import 'package:GEMS/data/repository/notification_repository.dart';
import 'package:GEMS/model/notification_item.dart';
import 'package:GEMS/service/notification_router.dart';
import 'package:GEMS/view/gems_chrome.dart';
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
      backgroundColor: GemsChrome.page,
      appBar: gemsAppBar(
        title: const Text('Notifications'),
        actions: [
          if (_items.any((item) => !item.isRead))
            TextButton(
              onPressed: _markAllRead,
              child: Text(
                'Mark all read',
                style: GemsChrome.body(weight: FontWeight.w600, color: GemsChrome.primary),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: GemsChrome.primary,
        onRefresh: _loadNotifications,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: GemsChrome.primary));
    }
    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: GemsChrome.body(color: GemsChrome.textSoft),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  style: gemsPrimaryButton(),
                  onPressed: _loadNotifications,
                  child: Text(
                    'Retry',
                    style: GemsChrome.body(weight: FontWeight.w600, color: Colors.white),
                  ),
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
        children: [
          const SizedBox(height: 120),
          const Center(
            child: Icon(Icons.notifications_none, size: 64, color: GemsChrome.muted),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'No notifications yet',
              style: GemsChrome.body(color: GemsChrome.textSoft),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = _items[index];
        final accent = item.isRead ? GemsChrome.border : GemsChrome.primary;
        return GemsAccentCard(
          accent: accent,
          onTap: () => _openNotification(item),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  item.isRead ? Icons.notifications_none : Icons.notifications,
                  color: item.isRead ? GemsChrome.muted : GemsChrome.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.displayTitle,
                        style: GemsChrome.body(
                          size: 15,
                          weight: item.isRead ? FontWeight.w500 : FontWeight.w600,
                          color: item.isRead ? GemsChrome.textSoft : GemsChrome.text,
                        ),
                      ),
                      if (item.displayBody.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.displayBody,
                          style: GemsChrome.body(size: 13, color: GemsChrome.textSoft),
                        ),
                      ],
                      if (item.sentAt != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          item.sentAt!,
                          style: GemsChrome.body(size: 12, color: GemsChrome.muted),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

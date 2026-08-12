import 'package:GEMS/model/notification_item.dart';
import 'package:GEMS/utils/network.dart';
import 'package:flutter/material.dart';

class NotificationRepository {
  Future<List<NotificationItem>> fetchNotifications(BuildContext context) async {
    final provider = Provider(fetchURL: '/noti_mobile/by_userId')
      ..context = context;
    final result = await provider.getJson(url: '/noti_mobile/by_userId');
    final rows = (result is Map && result['data'] is List)
        ? result['data'] as List
        : <dynamic>[];
    return rows
        .whereType<Map>()
        .map((row) => NotificationItem.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<int> fetchUnreadCount(BuildContext context) async {
    final provider = Provider(fetchURL: '/noti_mobile/unread_count')
      ..context = context;
    final result = await provider.getJson(url: '/noti_mobile/unread_count');
    if (result is Map && result['count'] != null) {
      return int.tryParse(result['count'].toString()) ?? 0;
    }
    return 0;
  }

  Future<void> markRead(BuildContext context, int notiLogId) async {
    final provider = Provider(fetchURL: '/noti_mobile/$notiLogId/read')
      ..context = context;
    await provider.put(body: {});
  }

  Future<void> markAllRead(BuildContext context) async {
    final provider = Provider(fetchURL: '/noti_mobile/read_all')..context = context;
    await provider.put(body: {});
  }
}

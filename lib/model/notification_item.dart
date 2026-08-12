import 'dart:convert';

class NotificationItem {
  final int id;
  final int? notiTextId;
  final String title;
  final String body;
  final String? notiData;
  final String? sentAt;
  final bool isRead;

  NotificationItem({
    required this.id,
    this.notiTextId,
    required this.title,
    required this.body,
    this.notiData,
    this.sentAt,
    required this.isRead,
  });

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    final readAt = map['notiLogReadAt'] ?? map['noti_log_read_at'];
    return NotificationItem(
      id: _asInt(map['notiLogId'] ?? map['noti_log_id']),
      notiTextId: _asIntOrNull(map['notiTextId'] ?? map['noti_text_id']),
      title: (map['notiTitle'] ?? map['noti_title'] ?? '').toString(),
      body: (map['notiHtml'] ?? map['noti_html'] ?? '').toString(),
      notiData: (map['notiData'] ?? map['noti_data'])?.toString(),
      sentAt:
          (map['notiLogTimeSent'] ?? map['noti_log_time_sent'])?.toString(),
      isRead: readAt != null && readAt.toString().isNotEmpty,
    );
  }

  Map<String, String> get routingData {
    if (notiData == null || notiData!.isEmpty) {
      return {};
    }
    try {
      final decoded = jsonDecode(notiData!) as Map<String, dynamic>;
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    } catch (_) {
      return {};
    }
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _asIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}

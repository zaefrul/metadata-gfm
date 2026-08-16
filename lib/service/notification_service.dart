import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:GEMS/service/notification_router.dart';
import 'package:GEMS/utils/network.dart';

const AndroidNotificationChannel kHighImportanceChannel =
    AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

bool _localNotificationsInitialized = false;
int _notificationId = 0;
GlobalKey<NavigatorState>? _navigatorKey;
VoidCallback? _onUnreadCountChanged;

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Notification+data messages are already displayed by the OS/FCM tray.
  // Only show a local notification for data-only payloads.
  if (message.notification != null) return;

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.ensureLocalNotificationsInitialized();
  await NotificationService.showLocalNotification(message);
}

class NotificationService {
  static Future<void> initialize({
    required GlobalKey<NavigatorState> navigatorKey,
    VoidCallback? onUnreadCountChanged,
  }) async {
    _navigatorKey = navigatorKey;
    _onUnreadCountChanged = onUnreadCountChanged;

    await ensureLocalNotificationsInitialized();

    final messaging = FirebaseMessaging.instance;

    if (Platform.isIOS) {
      await messaging.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true,
      );
      for (var attempt = 0; attempt < 10; attempt++) {
        final apnsToken = await messaging.getAPNSToken();
        if (apnsToken != null) break;
        await Future.delayed(const Duration(milliseconds: 300));
      }
    } else if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    // iOS foreground banners are shown via local notifications below.
    // Keeping alert:true here would duplicate the banner.
    await messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: true,
      sound: false,
    );

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((message) async {
      await showLocalNotification(message);
      _onUnreadCountChanged?.call();
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedMessage);

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleOpenedMessage(initialMessage);
    }

    messaging.onTokenRefresh.listen((token) async {
      final context = _navigatorKey?.currentContext;
      if (context != null && context.mounted) {
        await registerToken(context: context, token: token);
      }
    });
  }

  static Future<void> ensureLocalNotificationsInitialized() async {
    if (_localNotificationsInitialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty || _navigatorKey == null) {
          return;
        }
        try {
          final data = Map<String, String>.from(
            jsonDecode(payload).map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            ),
          );
          NotificationRouter.navigateFromPayload(_navigatorKey!, data);
        } catch (e) {
          debugPrint('Notification tap payload parse failed: $e');
        }
      },
    );

    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(kHighImportanceChannel);
    }

    _localNotificationsInitialized = true;
  }

  static Future<void> showLocalNotification(RemoteMessage message) async {
    await ensureLocalNotificationsInitialized();

    final notification = message.notification;
    final title = notification?.title ?? message.data['title'] ?? 'GEMS';
    final body = notification?.body ?? message.data['body'] ?? '';
    if (body.isEmpty && title == 'GEMS') return;

    final payload = message.data.isNotEmpty ? jsonEncode(message.data) : null;
    _notificationId++;

    await flutterLocalNotificationsPlugin.show(
      _notificationId,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          kHighImportanceChannel.id,
          kHighImportanceChannel.name,
          channelDescription: kHighImportanceChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  static void _handleOpenedMessage(RemoteMessage message) {
    if (_navigatorKey == null) return;
    final data = message.data.map(
      (key, value) => MapEntry(key, value.toString()),
    );
    if (data.isEmpty) return;
    NotificationRouter.navigateFromPayload(_navigatorKey!, data);
  }

  static Future<String?> getToken() async {
    if (Platform.isIOS) {
      for (var attempt = 0; attempt < 10; attempt++) {
        final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken != null) break;
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
    return FirebaseMessaging.instance.getToken();
  }

  static Future<void> registerToken({
    required BuildContext context,
    String? token,
  }) async {
    final fcmToken = token ?? await getToken();
    if (fcmToken == null || !context.mounted) return;

    final provider = Provider(fetchURL: '/api/m_ppm.php')..context = context;
    await provider.post(
      url: '/api/m_ppm.php',
      body: {
        'action': 'save_token',
        'token': fcmToken,
      },
    );
    debugPrint('FCM token registered');
  }
}

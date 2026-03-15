import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Background message handler must be a top-level function.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Khi nhận thông báo nền, có thể xử lý hoặc log.
  // Đây là nơi thích hợp để xử lý dữ liệu mà không cần UI.
}

class PushNotificationService {
  static final _messaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();

  /// Khởi tạo Firebase Messaging và local notification.
  static Future<void> init() async {
    // Yêu cầu quyền thông báo (iOS/macOS)
    if (Platform.isIOS || Platform.isMacOS) {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
    }

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _localNotifications.initialize(settings);

    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        _showLocalNotification(message);
      }
    });

    // Lắng nghe khi mở qua thông báo
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // Có thể navigate đến màn hình tương ứng
    });
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const android = AndroidNotificationDetails(
      'default_channel',
      'Default',
      channelDescription: 'Default channel',
      importance: Importance.max,
      priority: Priority.high,
    );
    const ios = DarwinNotificationDetails();

    final details = NotificationDetails(android: android, iOS: ios);

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
    );
  }

  static Future<void> subscribeToNewChapterTopic() async {
    await _messaging.subscribeToTopic('new_chapter');
  }

  static Future<void> unsubscribeFromNewChapterTopic() async {
    await _messaging.unsubscribeFromTopic('new_chapter');
  }

  static Future<String?> getToken() async => await _messaging.getToken();
}

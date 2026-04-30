import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/routes/app_routes.dart';

@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(NotificationResponse response) {
  // Background isolate: avoid navigation here.
  AppLoggerHelper.info(
    'Notification action received in background: ${response.actionId}',
  );
}

class NotificationService {
  NotificationService._();

  static const String _channelId = 'outdoorda_notifications';
  static const String _channelName = 'Outdoorda Notifications';
  static const String _channelDescription = 'General push notifications';

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) {
      return;
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        handleNotificationTap(response.payload);
      },
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotificationResponse,
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.max,
      ),
    );

    _isInitialized = true;
  }

  static Future<void> showFromRemoteMessage(RemoteMessage message) async {
    await init();

    final title =
        message.notification?.title ?? message.data['title']?.toString() ?? '';
    final body =
        message.notification?.body ?? message.data['body']?.toString() ?? '';

    if (title.isEmpty && body.isEmpty) {
      return;
    }

    final details = NotificationDetails(
      android: const AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: details,
      payload: jsonEncode(message.data),
    );
  }

  static void handleMessageNavigation(RemoteMessage message) {
    _navigateFromData(message.data);
  }

  static void handleNotificationTap(String? payload) {
    if (payload == null || payload.isEmpty) {
      return;
    }

    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        _navigateFromData(decoded);
        return;
      }
    } catch (_) {
      _navigateFromData(<String, dynamic>{'screen': payload});
      return;
    }
  }

  static void _navigateFromData(Map<String, dynamic> data) {
    final route = data['screen']?.toString() ?? data['route']?.toString();
    if (route == null || route.isEmpty) {
      return;
    }

    final routeExists = AppRoute.routes.any(
      (GetPage page) => page.name == route,
    );
    if (!routeExists) {
      AppLoggerHelper.warning('Notification route not found: $route');
      return;
    }

    if (Get.currentRoute == route) {
      return;
    }

    if (Get.key.currentState == null) {
      Future<void>.delayed(
        const Duration(milliseconds: 400),
        () => _navigateFromData(data),
      );
      return;
    }

    Get.toNamed(route, arguments: data);
  }
}

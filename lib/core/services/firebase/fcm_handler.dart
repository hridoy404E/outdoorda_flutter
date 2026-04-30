import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:outdoorda_flutter/core/services/firebase/firebase_service.dart';
import 'package:outdoorda_flutter/core/services/firebase/notification_service.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await FirebaseService.init();
  await NotificationService.showFromRemoteMessage(message);
}

class FCMHandler {
  FCMHandler._();

  static bool _isConfigured = false;

  static void registerBackgroundHandler() {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  static Future<void> configure() async {
    if (_isConfigured) {
      return;
    }

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: false,
          badge: true,
          sound: true,
        );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      AppLoggerHelper.info('Foreground push received: ${message.messageId}');
      await NotificationService.showFromRemoteMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      NotificationService.handleMessageNavigation(message);
    });

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      NotificationService.handleMessageNavigation(initialMessage);
    }

    _isConfigured = true;
  }
}

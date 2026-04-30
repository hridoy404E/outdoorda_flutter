import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/firebase_options.dart';

class FirebaseService {
  FirebaseService._();

  static Future<void> init() async {
    if (Firebase.apps.isNotEmpty) {
      return;
    }

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  static Future<NotificationSettings> requestPermission() {
    return FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  static Future<String?> getFcmToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    AppLoggerHelper.info('FCM token fetched: $token');
    return token;
  }
}

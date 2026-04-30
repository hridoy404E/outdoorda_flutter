import 'package:outdoorda_flutter/core/services/firebase/firebase_service.dart';
import 'package:outdoorda_flutter/core/services/firebase/notification_service.dart';

class AppNotificationInitializer {
  AppNotificationInitializer._();

  static Future<void> init() async {
    await FirebaseService.init();
    await NotificationService.init();
  }
}

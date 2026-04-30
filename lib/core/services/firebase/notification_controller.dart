import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/services/firebase/app_notification_initializer.dart';
import 'package:outdoorda_flutter/core/services/firebase/fcm_handler.dart';
import 'package:outdoorda_flutter/core/services/firebase/firebase_service.dart';
import 'package:outdoorda_flutter/core/services/firebase/notification_token_api_service.dart';
import 'package:outdoorda_flutter/core/services/storage_service.dart';
import 'package:outdoorda_flutter/core/services/user_profile_api_service.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationController extends GetxController with WidgetsBindingObserver {
  final NotificationTokenApiService _notificationTokenApiService =
      NotificationTokenApiService();
  final UserProfileApiService _userProfileApiService = UserProfileApiService();

  final RxnString fcmToken = RxnString();
  final RxBool isInitialized = false.obs;
  final RxBool permissionGranted = false.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _initializeNotifications();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshPermissionStatus();
    }
  }

  Future<void> _initializeNotifications() async {
    try {
      await AppNotificationInitializer.init();

      NotificationSettings settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
        settings = await FirebaseService.requestPermission();
      }

      _applyPermissionSettings(settings);

      await FCMHandler.configure();
      fcmToken.value = await FirebaseService.getFcmToken();
      isInitialized.value = true;

      FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
        fcmToken.value = token;
        AppLoggerHelper.info('FCM token refreshed: $token');
      });
    } catch (e) {
      AppLoggerHelper.error('Notification initialization failed', e);
    }
  }

  Future<void> refreshPermissionStatus() async {
    try {
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      _applyPermissionSettings(settings);
    } catch (error) {
      AppLoggerHelper.error('Notification permission refresh failed', error);
    }
  }

  Future<void> enableNotifications() async {
    try {
      final currentSettings =
          await FirebaseMessaging.instance.getNotificationSettings();
      if (_isPermissionGranted(currentSettings)) {
        _applyPermissionSettings(currentSettings);
        return;
      }

      if (currentSettings.authorizationStatus ==
          AuthorizationStatus.notDetermined) {
        final requestedSettings = await FirebaseService.requestPermission();
        _applyPermissionSettings(requestedSettings);

        if (_isPermissionGranted(requestedSettings)) {
          await syncFcmTokenWithBackend(force: true);
          EasyLoading.showSuccess('Notifications enabled');
          return;
        }
      }

      await openSystemNotificationSettings(
        message:
            'Turn on notifications for this app in your device settings, then return here.',
      );
    } catch (error) {
      AppLoggerHelper.error('Enable notifications failed', error);
      EasyLoading.showError('Unable to update notification setting');
    }
  }

  Future<void> disableNotifications() async {
    await openSystemNotificationSettings(
      message:
          'Turn off notifications for this app in your device settings, then return here.',
    );
  }

  Future<void> openSystemNotificationSettings({String? message}) async {
    final opened = await openAppSettings();
    if (!opened) {
      EasyLoading.showError('Unable to open app settings');
      return;
    }

    if (message != null && message.isNotEmpty) {
      EasyLoading.showInfo(message);
    }
  }

  void _applyPermissionSettings(NotificationSettings settings) {
    final isGranted = _isPermissionGranted(settings);
    permissionGranted.value = isGranted;
    AppLoggerHelper.info(
      'Notification permission status: ${settings.authorizationStatus.name}',
    );
  }

  bool _isPermissionGranted(NotificationSettings settings) {
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<void> syncFcmTokenWithBackend({bool force = false}) async {
    final token =
        fcmToken.value?.trim() ?? (await FirebaseService.getFcmToken())?.trim();
    if (token == null || token.isEmpty) return;
    fcmToken.value = token;

    final authorization = _buildAuthorizationHeader();
    if (authorization == null) return;

    final userId = await _resolveUserId(authorization);
    if (userId == null) return;

    final sameAsLastSync =
        StorageService.lastSyncedFcmToken == token &&
        StorageService.lastSyncedFcmUserId == userId;
    if (!force && sameAsLastSync) {
      return;
    }

    final saved = await _notificationTokenApiService.saveToken(
      authorization: authorization,
      userId: userId,
      token: token,
      platform: _resolvePlatform(),
    );

    if (saved) {
      await StorageService.saveFcmSyncMeta(token: token, userId: userId);
    }
  }

  String? _buildAuthorizationHeader() {
    final accessToken = StorageService.accessToken?.trim();
    if (accessToken == null || accessToken.isEmpty) {
      return null;
    }

    final tokenType = StorageService.tokenType?.trim();
    final prefix = (tokenType != null && tokenType.isNotEmpty)
        ? tokenType
        : 'Bearer';
    return '$prefix $accessToken';
  }

  Future<String?> _resolveUserId(String authorization) async {
    final cachedUserId = StorageService.userId?.trim();
    if (cachedUserId != null && cachedUserId.isNotEmpty) {
      return cachedUserId;
    }

    try {
      final profile = await _userProfileApiService.fetchCurrentUser(
        authorization: authorization,
      );
      final profileId = profile.id.trim();
      if (profileId.isEmpty) return null;
      await StorageService.saveUserId(profileId);
      return profileId;
    } catch (error) {
      AppLoggerHelper.warning('Unable to resolve user id for FCM sync: $error');
      return null;
    }
  }

  String _resolvePlatform() {
    if (kIsWeb) return 'web';

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.fuchsia:
        return 'fuchsia';
    }
  }
}

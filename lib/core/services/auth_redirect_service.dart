import 'package:outdoorda_flutter/core/services/storage_service.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/routes/app_routes.dart';

class AuthRedirectService {
  AuthRedirectService._();

  static Future<String> resolveInitialRoute() async {
    final accessToken = StorageService.accessToken;
    final cachedRole = StorageService.role;

    if (accessToken == null || cachedRole == null || cachedRole.isEmpty) {
      return AppRoute.getLoginScreen();
    }

    final normalizedRole = _normalizeRole(cachedRole);
    AppLoggerHelper.info(
      'AuthRedirectService: starting app as $normalizedRole',
    );

    return AppRoute.getBottomNavbarScreen();
  }

  static String _normalizeRole(String role) {
    final cleaned = role.trim().toLowerCase();
    switch (cleaned) {
      case 'admin':
        return 'Admin';
      case 'installer':
        return 'Installer';
      case 'customer':
      default:
        return 'Customer';
    }
  }
}

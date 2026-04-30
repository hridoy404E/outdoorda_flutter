import 'package:outdoorda_flutter/core/services/network_caller.dart';
import 'package:outdoorda_flutter/core/utils/constants/api_endpoints.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';

class NotificationTokenApiService {
  NotificationTokenApiService();

  final NetworkCaller _networkCaller = NetworkCaller();

  Future<bool> saveToken({
    required String authorization,
    required String userId,
    required String token,
    required String platform,
  }) async {
    final response = await _networkCaller.postRequest(
      ApiEndpoints.saveFcmToken,
      token: authorization,
      headers: {'accept': 'application/json'},
      body: {'user_id': userId, 'token': token, 'platform': platform},
    );

    if (response.isSuccess) {
      AppLoggerHelper.info(
        'Notification token saved: user_id=$userId platform=$platform',
      );
      return true;
    }

    AppLoggerHelper.warning(
      'Notification token save failed: status=${response.statusCode} '
      'error=${response.errorMessage}',
    );
    return false;
  }
}

import 'package:outdoorda_flutter/core/services/network_caller.dart';
import 'package:outdoorda_flutter/core/services/storage_service.dart';
import 'package:outdoorda_flutter/core/utils/constants/api_endpoints.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';

class TwoFactorApiService {
  final NetworkCaller _networkCaller = NetworkCaller();

  Future<bool> toggleTwoFactor({required String authorization}) async {
    final response = await _networkCaller.patchRequest(
      ApiEndpoints.toggleTwoFactor,
      token: authorization,
      headers: {'accept': 'application/json'},
      body: const <String, dynamic>{},
    );

    AppLoggerHelper.debug(
      'TwoFactorApiService.toggleTwoFactor: '
      'status=${response.statusCode} success=${response.isSuccess} '
      'body=${response.responseData}',
    );

    if (!response.isSuccess) {
      throw Exception(
        _extractErrorMessage(
          response.responseData,
          fallback: response.errorMessage,
        ),
      );
    }

    final enabled = _extractTwoFactorEnabled(response.responseData);
    await StorageService.saveTwoFactorEnabled(enabled);
    return enabled;
  }

  bool getSavedStatus() {
    return StorageService.getTwoFactorEnabled();
  }

  bool _extractTwoFactorEnabled(dynamic data) {
    if (data is Map<String, dynamic>) {
      final directValue = _asBool(data['two_factor_enabled']);
      if (directValue != null) return directValue;

      final nestedData = data['data'];
      if (nestedData is Map<String, dynamic>) {
        final nestedValue = _asBool(nestedData['two_factor_enabled']);
        if (nestedValue != null) return nestedValue;
      }
    }

    throw Exception('Two-factor authentication state missing from response');
  }

  bool? _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
    return null;
  }

  String _extractErrorMessage(dynamic data, {required String fallback}) {
    if (data is Map<String, dynamic>) {
      final detail = data['detail']?.toString();
      final message = data['message']?.toString();
      final source = detail ?? message;
      if (source != null && source.trim().isNotEmpty) {
        return source;
      }
    }

    if (fallback.trim().isNotEmpty) return fallback;
    return 'Failed to update two-factor authentication';
  }
}

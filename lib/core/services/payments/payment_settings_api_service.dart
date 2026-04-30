import 'package:outdoorda_flutter/core/models/payment_settings_status_model.dart';
import 'package:outdoorda_flutter/core/services/network_caller.dart';
import 'package:outdoorda_flutter/core/utils/constants/api_endpoints.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';

class PaymentSettingsApiService {
  PaymentSettingsApiService();

  final NetworkCaller _networkCaller = NetworkCaller();

  Future<PaymentSettingsStatusModel> fetchPaymentSettings({
    required String authorization,
  }) async {
    final response = await _networkCaller.getRequest(
      ApiEndpoints.adminPaymentSettings,
      token: authorization,
      headers: {'accept': 'application/json'},
    );

    AppLoggerHelper.debug(
      'PaymentSettingsApiService.fetchPaymentSettings: '
      'status=${response.statusCode} success=${response.isSuccess} '
      'body=${response.responseData}',
    );

    if (_isSuccessfulResponse(response) &&
        response.responseData is Map<String, dynamic>) {
      return PaymentSettingsStatusModel.fromJson(
        response.responseData as Map<String, dynamic>,
      );
    }

    throw Exception(
      _extractErrorMessage(
        response.responseData,
        fallback: response.errorMessage,
      ),
    );
  }

  Future<PaymentSettingsStatusModel> updateStripePaymentStatus({
    required String authorization,
    required bool newStatus,
  }) async {
    final response = await _networkCaller.postRequest(
      ApiEndpoints.adminPaymentSettings,
      token: authorization,
      headers: {'accept': 'application/json'},
      formUrlEncoded: true,
      body: {'new_status': newStatus.toString()},
    );

    AppLoggerHelper.debug(
      'PaymentSettingsApiService.updateStripePaymentStatus: '
      'status=${response.statusCode} success=${response.isSuccess} '
      'newStatus=$newStatus body=${response.responseData}',
    );

    if (_isSuccessfulResponse(response) &&
        response.responseData is Map<String, dynamic>) {
      return PaymentSettingsStatusModel.fromJson(
        response.responseData as Map<String, dynamic>,
      );
    }

    throw Exception(
      _extractErrorMessage(
        response.responseData,
        fallback: response.errorMessage,
      ),
    );
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
    return 'Failed to fetch payment settings';
  }

  bool _isSuccessfulResponse(dynamic response) {
    return response.isSuccess ||
        (response.statusCode >= 200 && response.statusCode < 300);
  }
}

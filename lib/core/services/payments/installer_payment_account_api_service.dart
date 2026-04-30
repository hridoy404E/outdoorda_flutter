import 'package:outdoorda_flutter/core/services/network_caller.dart';
import 'package:outdoorda_flutter/core/utils/constants/api_endpoints.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';

class InstallerPaymentAccountApiService {
  InstallerPaymentAccountApiService();

  final NetworkCaller _networkCaller = NetworkCaller();

  Future<bool> isAccountReady({required String authorization}) async {
    final response = await _networkCaller.getRequest(
      ApiEndpoints.paymentAccountIsReady,
      token: authorization,
      headers: {'accept': 'application/json'},
    );

    final detail = _extractDetail(response.responseData).toLowerCase();
    if (detail.contains('installer not ready for payments')) {
      return false;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    }

    throw Exception(
      response.errorMessage.isNotEmpty
          ? response.errorMessage
          : (detail.isNotEmpty
                ? detail
                : 'Failed to check payment account status'),
    );
  }

  Future<void> createInstallerStripeAccount({
    required String authorization,
  }) async {
    final response = await _networkCaller.postRequest(
      ApiEndpoints.installerStripeCreateAccount,
      token: authorization,
      headers: {'accept': 'application/json'},
      formUrlEncoded: true,
      body: const {},
    );

    AppLoggerHelper.debug(
      'createInstallerStripeAccount: status=${response.statusCode} '
      'success=${response.isSuccess} body=${response.responseData}',
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw Exception(
      response.errorMessage.isNotEmpty
          ? response.errorMessage
          : _extractDetail(
              response.responseData,
            ).ifEmpty('Failed to create Stripe account'),
    );
  }

  Future<String> createInstallerOnboardingLink({
    required String authorization,
  }) async {
    final response = await _networkCaller.postRequest(
      ApiEndpoints.installerStripeOnboardingLink,
      token: authorization,
      headers: {'accept': 'application/json'},
      formUrlEncoded: true,
      body: const {},
    );

    AppLoggerHelper.debug(
      'createInstallerOnboardingLink: status=${response.statusCode} '
      'success=${response.isSuccess} body=${response.responseData}',
    );

    if (response.responseData is Map) {
      final data = Map<String, dynamic>.from(response.responseData as Map);
      final url = data['url']?.toString().trim() ?? '';
      if (url.isNotEmpty &&
          response.statusCode >= 200 &&
          response.statusCode < 300) {
        return url;
      }
    }

    throw Exception(
      response.errorMessage.isNotEmpty
          ? response.errorMessage
          : (_extractDetail(
              response.responseData,
            ).ifEmpty('Failed to create onboarding link')),
    );
  }

  String _extractDetail(dynamic data) {
    if (data is Map) {
      final detail = data['detail']?.toString().trim() ?? '';
      if (detail.isNotEmpty) return detail;
      final message = data['message']?.toString().trim() ?? '';
      if (message.isNotEmpty) return message;
    }
    return '';
  }
}

extension on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
}

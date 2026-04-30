import 'package:outdoorda_flutter/core/services/network_caller.dart';
import 'package:outdoorda_flutter/core/utils/constants/api_endpoints.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/features/admin_section/user_management/payment/models/admin_installer_payment.dart';

class AdminInstallerPaymentApiService {
  AdminInstallerPaymentApiService();

  final NetworkCaller _networkCaller = NetworkCaller();

  Future<List<AdminInstallerPayment>> fetchInstallerPayments({
    required String authorization,
    required String userId,
    int skip = 0,
    int limit = 10,
  }) async {
    final response = await _networkCaller.getRequest(
      ApiEndpoints.installerPayments,
      token: authorization,
      headers: {'accept': 'application/json'},
      queryParams: {'user_id': userId, 'skip': skip, 'limit': limit},
    );

    AppLoggerHelper.debug(
      'AdminInstallerPaymentApiService.fetchInstallerPayments: '
      'status=${response.statusCode} success=${response.isSuccess} '
      'userId=$userId skip=$skip limit=$limit body=${response.responseData}',
    );

    if (_isSuccessfulResponse(response)) {
      final items = _extractPaymentList(response.responseData);
      return items
          .whereType<Map>()
          .map(
            (item) =>
                AdminInstallerPayment.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }

    throw Exception(
      _extractErrorMessage(
        response.responseData,
        fallback: response.errorMessage,
      ),
    );
  }

  Future<AdminInstallerPayment?> markPaymentPaid({
    required String authorization,
    required String paymentId,
    required String action,
  }) async {
    final endpoint = Uri.parse(
      '${ApiEndpoints.installerPayments}${Uri.encodeComponent(paymentId)}/mark-paid',
    ).replace(queryParameters: {'action': action}).toString();

    final response = await _networkCaller.putRequest(
      endpoint,
      token: authorization,
      headers: {'accept': 'application/json'},
    );

    AppLoggerHelper.debug(
      'AdminInstallerPaymentApiService.markPaymentPaid: '
      'status=${response.statusCode} success=${response.isSuccess} '
      'paymentId=$paymentId action=$action body=${response.responseData}',
    );

    if (!_isSuccessfulResponse(response)) {
      throw Exception(
        _extractErrorMessage(
          response.responseData,
          fallback: response.errorMessage,
        ),
      );
    }

    final paymentData = _extractPaymentMap(response.responseData);
    if (paymentData == null) return null;
    return AdminInstallerPayment.fromJson(
      Map<String, dynamic>.from(paymentData),
    );
  }

  List<dynamic> _extractPaymentList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      final candidates = [data['results'], data['data'], data['items']];
      for (final candidate in candidates) {
        if (candidate is List) return candidate;
      }
    }
    return const [];
  }

  Map? _extractPaymentMap(dynamic data) {
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final candidates = [
        map['payment'],
        map['data'],
        map['result'],
        map.containsKey('amount') && map.containsKey('payment_type')
            ? map
            : null,
      ];
      for (final candidate in candidates) {
        if (candidate is Map) return candidate;
      }
    }
    return null;
  }

  String _extractErrorMessage(dynamic data, {required String fallback}) {
    if (data is Map) {
      final detail = data['detail'];
      if (detail is String && detail.trim().isNotEmpty) return detail;
      if (detail is List && detail.isNotEmpty) return detail.first.toString();

      final message = data['message']?.toString();
      if (message != null && message.trim().isNotEmpty) return message;
    }
    if (fallback.trim().isNotEmpty) return fallback;
    return 'Unable to load installer payments';
  }

  bool _isSuccessfulResponse(dynamic response) {
    return response.isSuccess ||
        (response.statusCode >= 200 && response.statusCode < 300);
  }
}

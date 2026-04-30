import 'package:outdoorda_flutter/core/services/network_caller.dart';
import 'package:outdoorda_flutter/core/utils/constants/api_endpoints.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/features/installer_section/payment/models/installer_payment.dart';

class InstallerPaymentApiService {
  InstallerPaymentApiService();

  final NetworkCaller _networkCaller = NetworkCaller();

  Future<List<InstallerPayment>> fetchInstallerPayments({
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
      'InstallerPaymentApiService.fetchInstallerPayments: '
      'status=${response.statusCode} success=${response.isSuccess} '
      'userId=$userId skip=$skip limit=$limit body=${response.responseData}',
    );

    if (_isSuccessfulResponse(response)) {
      final items = _extractPaymentList(response.responseData);
      return items
          .whereType<Map>()
          .map(
            (item) =>
                InstallerPayment.fromJson(Map<String, dynamic>.from(item)),
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

  Future<InstallerCommissionPaymentResult> createCommissionPayment({
    required String authorization,
    required double amount,
    required String paymentType,
  }) async {
    final response = await _networkCaller.postRequest(
      ApiEndpoints.createPaymentIntent,
      token: authorization,
      headers: {'accept': 'application/json'},
      formUrlEncoded: true,
      body: {'amount': amount.toStringAsFixed(2), 'payment_type': paymentType},
    );

    AppLoggerHelper.debug(
      'InstallerPaymentApiService.createCommissionPayment: '
      'status=${response.statusCode} success=${response.isSuccess} '
      'body=${response.responseData}',
    );

    if (!_isSuccessfulResponse(response)) {
      throw Exception(
        _extractErrorMessage(
          response.responseData,
          fallback: response.errorMessage,
        ),
      );
    }

    return InstallerCommissionPaymentResult.fromResponse(response.responseData);
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

  String _extractErrorMessage(dynamic data, {required String fallback}) {
    if (data is Map) {
      final detail = data['detail']?.toString();
      final message = data['message']?.toString();
      final source = detail ?? message;
      if (source != null && source.trim().isNotEmpty) return source;
    }
    if (fallback.trim().isNotEmpty) return fallback;
    return 'Unable to load installer payments';
  }

  bool _isSuccessfulResponse(dynamic response) {
    return response.isSuccess ||
        (response.statusCode >= 200 && response.statusCode < 300);
  }
}

class InstallerCommissionPaymentResult {
  const InstallerCommissionPaymentResult({
    this.payment,
    this.clientSecret,
    this.message,
  });

  final InstallerPayment? payment;
  final String? clientSecret;
  final String? message;

  factory InstallerCommissionPaymentResult.fromResponse(dynamic data) {
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final paymentData = _firstMap([
        map['payment'],
        map['data'],
        map['result'],
        map.containsKey('amount') && map.containsKey('payment_type')
            ? map
            : null,
      ]);

      return InstallerCommissionPaymentResult(
        payment: paymentData == null
            ? null
            : InstallerPayment.fromJson(Map<String, dynamic>.from(paymentData)),
        clientSecret: _firstNotEmpty([
          map['client_secret'],
          map['clientSecret'],
          map['payment_intent_client_secret'],
          map['paymentIntentClientSecret'],
        ]),
        message: _firstNotEmpty([map['message'], map['detail']]),
      );
    }

    return InstallerCommissionPaymentResult(message: data?.toString());
  }

  static Map? _firstMap(List<dynamic> values) {
    for (final value in values) {
      if (value is Map) return value;
    }
    return null;
  }

  static String? _firstNotEmpty(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) return text;
    }
    return null;
  }
}

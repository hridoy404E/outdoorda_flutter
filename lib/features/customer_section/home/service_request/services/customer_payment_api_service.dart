import 'package:outdoorda_flutter/core/services/network_caller.dart';
import 'package:outdoorda_flutter/core/utils/constants/api_endpoints.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';

class CustomerPaymentApiService {
  CustomerPaymentApiService();

  final NetworkCaller _networkCaller = NetworkCaller();

  Future<String> createPaymentIntent({
    required String postId,
    required String authorization,
  }) async {
    final cleanedPostId = postId.trim();
    if (cleanedPostId.isEmpty) {
      throw Exception('Invalid post id');
    }

    final endpoint =
        '${ApiEndpoints.createPaymentIntent}?post_id=${Uri.encodeQueryComponent(cleanedPostId)}';
    AppLoggerHelper.info(
      'CustomerPaymentApiService: creating payment intent for post $cleanedPostId',
    );

    final response = await _networkCaller.postRequest(
      endpoint,
      token: authorization,
      headers: {'accept': 'application/json'},
      formUrlEncoded: true,
      body: const {},
    );

    AppLoggerHelper.debug(
      'CustomerPaymentApiService.createPaymentIntent: '
      'status=${response.statusCode} success=${response.isSuccess} '
      'body=${response.responseData}',
    );

    if (response.responseData is Map) {
      final data = Map<String, dynamic>.from(response.responseData as Map);
      final clientSecret = data['client_secret']?.toString().trim() ?? '';
      if (clientSecret.isNotEmpty &&
          (response.isSuccess ||
              (response.statusCode >= 200 && response.statusCode < 300))) {
        return clientSecret;
      }
    }

    throw Exception(
      response.errorMessage.isNotEmpty
          ? response.errorMessage
          : 'Unable to create payment intent',
    );
  }

  Future<void> createCashPayment({
    required String postId,
    required String authorization,
  }) async {
    final cleanedPostId = postId.trim();
    if (cleanedPostId.isEmpty) {
      throw Exception('Invalid post id');
    }

    AppLoggerHelper.info(
      'CustomerPaymentApiService: creating cash payment for post $cleanedPostId',
    );

    final response = await _networkCaller.postRequest(
      ApiEndpoints.cashPayment,
      token: authorization,
      headers: {'accept': 'application/json'},
      formUrlEncoded: true,
      body: {'post_id': cleanedPostId},
    );

    AppLoggerHelper.debug(
      'CustomerPaymentApiService.createCashPayment: '
      'status=${response.statusCode} success=${response.isSuccess} '
      'body=${response.responseData}',
    );

    if (response.isSuccess ||
        (response.statusCode >= 200 && response.statusCode < 300)) {
      return;
    }

    throw Exception(
      response.errorMessage.isNotEmpty
          ? response.errorMessage
          : 'Unable to create cash payment',
    );
  }
}

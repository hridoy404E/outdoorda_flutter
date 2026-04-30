import 'package:outdoorda_flutter/core/services/network_caller.dart';
import 'package:outdoorda_flutter/core/utils/constants/api_endpoints.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/models/review_model.dart';

class CustomerReviewApiService {
  CustomerReviewApiService();

  final NetworkCaller _networkCaller = NetworkCaller();

  Future<void> submitReview({
    required String authorization,
    required String installerId,
    required int rating,
    required String review,
  }) async {
    AppLoggerHelper.info(
      'CustomerReviewApiService: submitting review for $installerId',
    );

    final response = await _networkCaller.postRequest(
      ApiEndpoints.customerReview,
      token: authorization,
      headers: {'accept': 'application/json'},
      formUrlEncoded: true,
      body: {
        'installer_id': installerId.trim(),
        'rating': rating,
        'review': review.trim(),
      },
    );

    AppLoggerHelper.debug(
      'CustomerReviewApiService.submitReview: status=${response.statusCode} '
      'success=${response.isSuccess} body=${response.responseData}',
    );

    if (response.isSuccess ||
        (response.statusCode >= 200 && response.statusCode < 300)) {
      return;
    }

    throw Exception(
      response.errorMessage.isNotEmpty
          ? response.errorMessage
          : 'Failed to submit review',
    );
  }

  Future<List<Review>> fetchInstallerRatings({
    required String authorization,
    int limit = 20,
    int skip = 0,
  }) async {
    AppLoggerHelper.info(
      'CustomerReviewApiService: fetching installer ratings',
    );

    final response = await _networkCaller.getRequest(
      ApiEndpoints.installerRatings,
      token: authorization,
      headers: {'accept': 'application/json'},
      queryParams: {'limit': limit, 'skip': skip},
    );

    AppLoggerHelper.debug(
      'CustomerReviewApiService.fetchInstallerRatings: '
      'status=${response.statusCode} success=${response.isSuccess} '
      'body=${response.responseData}',
    );

    if (!response.isSuccess && response.statusCode != 200) {
      throw Exception(
        response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Unable to load installer ratings',
      );
    }

    final data = response.responseData;
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(Review.fromInstallerRatingJson)
          .toList();
    }

    if (data is Map<String, dynamic>) {
      final dynamic ratings = data['ratings'] ?? data['items'] ?? data['data'];
      if (ratings is List) {
        return ratings
            .whereType<Map<String, dynamic>>()
            .map(Review.fromInstallerRatingJson)
            .toList();
      }
    }

    return const <Review>[];
  }
}

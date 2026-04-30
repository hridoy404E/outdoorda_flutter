import 'package:outdoorda_flutter/core/services/network_caller.dart';
import 'package:outdoorda_flutter/core/utils/constants/api_endpoints.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import '../models/customer_post_model.dart';

class CustomerPostsApiService {
  CustomerPostsApiService();

  final NetworkCaller _networkCaller = NetworkCaller();

  Future<List<CustomerPostModel>> fetchCustomerPosts({
    String? authorization,
  }) async {
    AppLoggerHelper.info('CustomerPostsApiService: fetching customer posts');

    final response = await _networkCaller.getRequest(
      ApiEndpoints.customerPosts,
      token: authorization,
      headers: {'accept': 'application/json'},
    );

    AppLoggerHelper.debug(
      'CustomerPostsApiService.fetchCustomerPosts: status=${response.statusCode} '
      'success=${response.isSuccess} body=${response.responseData}',
    );

    if (response.isSuccess &&
        response.responseData is Map<String, dynamic> &&
        response.responseData['posts'] is List) {
      final posts = (response.responseData['posts'] as List)
          .whereType<Map<String, dynamic>>()
          .map(CustomerPostModel.fromJson)
          .toList();
      return posts;
    }

    throw Exception(
      response.errorMessage.isNotEmpty
          ? response.errorMessage
          : 'Unable to load service history',
    );
  }
}

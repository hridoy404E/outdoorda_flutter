import 'package:outdoorda_flutter/core/services/network_caller.dart';
import 'package:outdoorda_flutter/core/utils/constants/api_endpoints.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import '../models/customer_post_bid_model.dart';

class CustomerPostBidsApiService {
  CustomerPostBidsApiService();

  final NetworkCaller _networkCaller = NetworkCaller();

  Future<List<CustomerPostBidModel>> fetchBids({
    required String postId,
    String? authorization,
  }) async {
    AppLoggerHelper.info(
      'CustomerPostBidsApiService: fetching bids for $postId',
    );

    final uri = '${ApiEndpoints.customerPostBids}?post_id=$postId';
    final response = await _networkCaller.getRequest(
      uri,
      token: authorization,
      headers: {'accept': 'application/json'},
    );

    AppLoggerHelper.debug(
      'CustomerPostBidsApiService.fetchBids: status=${response.statusCode} '
      'success=${response.isSuccess} body=${response.responseData}',
    );

    if (response.isSuccess &&
        response.responseData is Map<String, dynamic> &&
        response.responseData['bids'] is List) {
      return (response.responseData['bids'] as List)
          .whereType<Map<String, dynamic>>()
          .map(CustomerPostBidModel.fromJson)
          .toList();
    }

    throw Exception(
      response.errorMessage.isNotEmpty
          ? response.errorMessage
          : 'Unable to load bids',
    );
  }

  Future<void> acceptBid({
    required String bidId,
    required String authorization,
  }) async {
    AppLoggerHelper.info('CustomerPostBidsApiService: accepting bid $bidId');

    final response = await _networkCaller.postRequest(
      _buildAcceptBidEndpoint(bidId),
      token: authorization,
      headers: {'accept': 'application/json'},
      formUrlEncoded: true,
      body: const {},
    );

    AppLoggerHelper.debug(
      'CustomerPostBidsApiService.acceptBid: status=${response.statusCode} '
      'success=${response.isSuccess} body=${response.responseData}',
    );

    if (response.isSuccess ||
        (response.statusCode >= 200 && response.statusCode < 300)) {
      return;
    }

    throw Exception(
      response.errorMessage.isNotEmpty
          ? response.errorMessage
          : 'Unable to accept bid',
    );
  }

  String _buildAcceptBidEndpoint(String bidId) {
    final cleanedId = bidId.trim();
    if (cleanedId.isEmpty) {
      throw Exception('Invalid bid id');
    }
    return '${ApiEndpoints.customerBid}$cleanedId/accept/';
  }
}

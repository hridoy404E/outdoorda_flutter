import 'package:outdoorda_flutter/core/services/network_caller.dart';
import 'package:outdoorda_flutter/core/utils/constants/api_endpoints.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/features/admin_section/home/models/activity_model.dart';

class AdminRecentActivityApiService {
  AdminRecentActivityApiService();

  final NetworkCaller _networkCaller = NetworkCaller();

  Future<List<Activity>> fetchRecentActivities({
    required String authorization,
    required int offset,
    required int limit,
  }) async {
    final response = await _networkCaller.getRequest(
      ApiEndpoints.adminRecentBids,
      token: authorization,
      headers: {'accept': 'application/json'},
      queryParams: {'offset': offset, 'limit': limit},
    );

    AppLoggerHelper.debug(
      'AdminRecentActivityApiService.fetchRecentActivities: '
      'status=${response.statusCode} success=${response.isSuccess} '
      'offset=$offset limit=$limit body=${response.responseData}',
    );

    if (response.isSuccess) {
      final items = _extractItems(response.responseData);
      return items.map(_toActivity).toList();
    }

    if (response.statusCode == 404) {
      final detail = response.responseData is Map<String, dynamic>
          ? (response.responseData as Map<String, dynamic>)['detail']
                ?.toString()
                .toLowerCase()
          : '';
      if ((detail ?? '').contains('bid')) {
        return [];
      }
    }

    throw Exception(_extractErrorMessage(response.responseData));
  }

  List<Map<String, dynamic>> _extractItems(dynamic data) {
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }
    if (data is Map<String, dynamic>) {
      if (data['bids'] is List) {
        return (data['bids'] as List)
            .whereType<Map<String, dynamic>>()
            .toList();
      }
      if (data['results'] is List) {
        return (data['results'] as List)
            .whereType<Map<String, dynamic>>()
            .toList();
      }
    }
    return const [];
  }

  Activity _toActivity(Map<String, dynamic> bid) {
    final bidId = bid['id']?.toString() ?? '';
    final installerId = bid['installer_id']?.toString() ?? 'Installer';
    final postRequestId = bid['post_request_id']?.toString() ?? '';
    final note = bid['note']?.toString().trim() ?? '';
    final createdAt = DateTime.tryParse(bid['created_at']?.toString() ?? '');
    final price = (bid['price'] as num?)?.toDouble() ?? 0.0;

    final description =
        '$installerId submitted a bid of '
        '\$${_formatPrice(price)} for Job #${_shortId(postRequestId)}'
        '${_noteSuffix(note)}';

    return Activity(
      id: bidId,
      description: description,
      timestamp: createdAt ?? DateTime.now(),
    );
  }

  String _formatPrice(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }

  String _shortId(String id) {
    final compact = id.replaceAll('-', '').toUpperCase();
    if (compact.isEmpty) return 'N/A';
    return compact.length <= 8 ? compact : compact.substring(0, 8);
  }

  String _noteSuffix(String note) {
    if (note.isEmpty || note.toLowerCase() == 'string') return '';
    return '. Note: $note';
  }

  String _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final detail = data['detail']?.toString();
      final message = data['message']?.toString();
      final source = detail ?? message;
      if (source != null && source.trim().isNotEmpty) {
        return source;
      }
    }
    return 'Failed to load recent activities';
  }
}

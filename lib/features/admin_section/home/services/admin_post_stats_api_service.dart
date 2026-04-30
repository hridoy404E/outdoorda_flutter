import 'package:outdoorda_flutter/core/services/network_caller.dart';
import 'package:outdoorda_flutter/core/utils/constants/api_endpoints.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/features/admin_section/home/models/admin_post_stats_model.dart';

class AdminPostStatsApiService {
  AdminPostStatsApiService();

  final NetworkCaller _networkCaller = NetworkCaller();

  Future<AdminPostStatsModel> fetchPostStats({
    required String authorization,
  }) async {
    final response = await _networkCaller.getRequest(
      ApiEndpoints.adminPostStats,
      token: authorization,
      headers: {'accept': 'application/json'},
    );

    AppLoggerHelper.debug(
      'AdminPostStatsApiService.fetchPostStats: '
      'status=${response.statusCode} success=${response.isSuccess} '
      'body=${response.responseData}',
    );

    if (response.isSuccess) {
      final payload = _extractPayload(response.responseData);
      return AdminPostStatsModel.fromJson(payload);
    }

    throw Exception(_extractErrorMessage(response.responseData));
  }

  Map<String, dynamic> _extractPayload(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['data'] is Map<String, dynamic>) {
        return data['data'] as Map<String, dynamic>;
      }
      return data;
    }
    return const <String, dynamic>{};
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
    return 'Failed to load admin post stats';
  }
}

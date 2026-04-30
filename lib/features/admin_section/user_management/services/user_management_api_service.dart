import 'package:outdoorda_flutter/core/services/network_caller.dart';
import 'package:outdoorda_flutter/core/utils/constants/api_endpoints.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/features/admin_section/user_management/models/user_list_response.dart';

class UserManagementApiService {
  UserManagementApiService();

  final NetworkCaller _networkCaller = NetworkCaller();

  Future<UserListResponse> fetchUsers({
    required String authorization,
    required int offset,
    required int limit,
  }) async {
    final response = await _networkCaller.getRequest(
      ApiEndpoints.users,
      token: authorization,
      headers: {'accept': 'application/json'},
      queryParams: {'offset': offset, 'limit': limit},
    );

    AppLoggerHelper.debug(
      'UserManagementApiService.fetchUsers: '
      'status=${response.statusCode} '
      'success=${response.isSuccess} '
      'offset=$offset limit=$limit '
      'body=${response.responseData}',
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return UserListResponse.fromJson(
        response.responseData as Map<String, dynamic>,
      );
    }

    throw Exception(
      _extractErrorMessage(
        response.responseData,
        response.errorMessage,
        fallback: 'Failed to fetch users',
      ),
    );
  }

  Future<void> suspendUser({
    required String authorization,
    required String userId,
  }) async {
    final url = Uri.parse(
      ApiEndpoints.userSuspend,
    ).replace(queryParameters: {'user_id': userId}).toString();

    final response = await _networkCaller.patchRequest(
      url,
      token: authorization,
      headers: {'accept': 'application/json'},
    );

    AppLoggerHelper.debug(
      'UserManagementApiService.suspendUser: '
      'status=${response.statusCode} success=${response.isSuccess} '
      'userId=$userId body=${response.responseData}',
    );

    if (response.isSuccess) return;

    throw Exception(
      _extractErrorMessage(
        response.responseData,
        response.errorMessage,
        fallback: 'Failed to suspend user',
      ),
    );
  }

  Future<void> deleteUser({
    required String authorization,
    required String userId,
  }) async {
    final url = '${ApiEndpoints.users}${Uri.encodeComponent(userId)}';

    final response = await _networkCaller.deleteRequest(
      url,
      token: authorization,
      headers: {'accept': 'application/json'},
    );

    AppLoggerHelper.debug(
      'UserManagementApiService.deleteUser: '
      'status=${response.statusCode} success=${response.isSuccess} '
      'userId=$userId body=${response.responseData}',
    );

    if (response.isSuccess ||
        (response.statusCode >= 200 && response.statusCode < 300)) {
      return;
    }

    throw Exception(
      _extractErrorMessage(
        response.responseData,
        response.errorMessage,
        fallback: 'Failed to delete user',
      ),
    );
  }

  String _extractErrorMessage(
    dynamic data,
    String fallbackMessage, {
    required String fallback,
  }) {
    if (data is Map<String, dynamic>) {
      final detail = data['detail']?.toString();
      final message = data['message']?.toString();
      final source = detail ?? message;
      if (source != null && source.trim().isNotEmpty) {
        return source;
      }
    }
    if (fallbackMessage.trim().isNotEmpty) {
      return fallbackMessage;
    }
    return fallback;
  }
}

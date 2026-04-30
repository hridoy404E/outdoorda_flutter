import 'package:outdoorda_flutter/core/services/network_caller.dart';
import 'package:outdoorda_flutter/core/utils/constants/api_endpoints.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/features/admin_section/settings/models/job_management_settings_model.dart';

class AdminJobManagementSettingsApiService {
  AdminJobManagementSettingsApiService();

  final NetworkCaller _networkCaller = NetworkCaller();

  Future<JobManagementSettingsModel> fetchSettings({
    required String authorization,
  }) async {
    final response = await _networkCaller.getRequest(
      ApiEndpoints.adminJobManagementSettings,
      token: authorization,
      headers: {'accept': 'application/json'},
    );

    AppLoggerHelper.debug(
      'AdminJobManagementSettingsApiService.fetchSettings: '
      'status=${response.statusCode} success=${response.isSuccess} '
      'body=${response.responseData}',
    );

    if (response.isSuccess) {
      final payload = _extractPayload(response.responseData);
      return JobManagementSettingsModel.fromJson(payload);
    }

    throw Exception(
      _extractErrorMessage(
        response.responseData,
        fallback: response.errorMessage,
      ),
    );
  }

  Future<JobManagementSettingsModel> saveSettings({
    required String authorization,
    required bool autoAssignJob,
    required int jobTimeoutHours,
  }) async {
    final response = await _networkCaller.postRequest(
      ApiEndpoints.adminJobManagementSettings,
      token: authorization,
      headers: {'accept': 'application/json'},
      formUrlEncoded: true,
      body: {
        'auto_assign_job': autoAssignJob.toString(),
        'job_timeout_hours': jobTimeoutHours.toString(),
      },
    );

    AppLoggerHelper.debug(
      'AdminJobManagementSettingsApiService.saveSettings: '
      'status=${response.statusCode} success=${response.isSuccess} '
      'autoAssignJob=$autoAssignJob jobTimeoutHours=$jobTimeoutHours '
      'body=${response.responseData}',
    );

    if (response.isSuccess) {
      final payload = _extractPayload(response.responseData);
      return JobManagementSettingsModel.fromJson(payload);
    }

    throw Exception(
      _extractErrorMessage(
        response.responseData,
        fallback: response.errorMessage,
      ),
    );
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

  String _extractErrorMessage(dynamic data, {required String fallback}) {
    if (data is Map<String, dynamic>) {
      final detail = data['detail']?.toString();
      final message = data['message']?.toString();
      final source = detail ?? message;
      if (source != null && source.trim().isNotEmpty) {
        return source;
      }
    }
    if (fallback.trim().isNotEmpty) return fallback;
    return 'Failed to update job management settings';
  }
}

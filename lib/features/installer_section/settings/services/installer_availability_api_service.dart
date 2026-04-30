import 'package:outdoorda_flutter/core/services/network_caller.dart';
import 'package:outdoorda_flutter/core/utils/constants/api_endpoints.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/features/installer_section/settings/models/installer_availability.dart';

class InstallerAvailabilityApiService {
  InstallerAvailabilityApiService();

  final NetworkCaller _networkCaller = NetworkCaller();

  Future<InstallerAvailability> fetchInstallerAvailability({
    required String authorization,
  }) async {
    final response = await _networkCaller.getRequest(
      ApiEndpoints.installerAvailabilityGet,
      token: authorization,
      headers: {'accept': 'application/json'},
    );

    AppLoggerHelper.debug(
      'InstallerAvailabilityApiService.fetchInstallerAvailability: '
      'status=${response.statusCode} success=${response.isSuccess} '
      'body=${response.responseData}',
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return InstallerAvailability.fromJson(
        response.responseData as Map<String, dynamic>,
      );
    }

    throw Exception(
      response.errorMessage.isNotEmpty
          ? response.errorMessage
          : 'Failed to load installer availability',
    );
  }

  Future<void> updateInstallerAvailability({
    required String authorization,
    required bool isAvailable,
    required int weekHours,
  }) async {
    final response = await _networkCaller.postRequest(
      ApiEndpoints.installerAvailability,
      token: authorization,
      headers: {'accept': 'application/json'},
      formUrlEncoded: true,
      body: {'is_available': isAvailable, 'week_hours': weekHours},
    );

    AppLoggerHelper.debug(
      'InstallerAvailabilityApiService.updateInstallerAvailability: '
      'status=${response.statusCode} success=${response.isSuccess} '
      'body=${response.responseData}',
    );

    if (response.isSuccess) return;

    throw Exception(
      response.errorMessage.isNotEmpty
          ? response.errorMessage
          : 'Failed to update installer availability',
    );
  }
}

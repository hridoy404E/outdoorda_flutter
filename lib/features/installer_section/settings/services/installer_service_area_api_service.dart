import 'package:outdoorda_flutter/core/services/network_caller.dart';
import 'package:outdoorda_flutter/core/utils/constants/api_endpoints.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/features/installer_section/settings/models/installer_service_area_option.dart';

class InstallerServiceAreaApiService {
  InstallerServiceAreaApiService();

  final NetworkCaller _networkCaller = NetworkCaller();

  Future<List<InstallerServiceAreaOption>> fetchAvailableServiceAreas({
    required String authorization,
  }) async {
    final response = await _networkCaller.getRequest(
      ApiEndpoints.serviceAreas,
      token: authorization,
      headers: {'accept': 'application/json'},
    );

    AppLoggerHelper.debug(
      'InstallerServiceAreaApiService.fetchAvailableServiceAreas: '
      'status=${response.statusCode} success=${response.isSuccess} '
      'body=${response.responseData}',
    );

    if (response.isSuccess && response.responseData is List) {
      return (response.responseData as List)
          .whereType<Map<String, dynamic>>()
          .map(InstallerServiceAreaOption.fromAvailableJson)
          .where((e) => e.id > 0)
          .toList();
    }

    throw Exception(
      response.errorMessage.isNotEmpty
          ? response.errorMessage
          : 'Failed to load available service areas',
    );
  }

  Future<List<InstallerServiceAreaOption>> fetchInstallerServiceAreas({
    required String authorization,
  }) async {
    final response = await _networkCaller.getRequest(
      ApiEndpoints.installerServiceAreas,
      token: authorization,
      headers: {'accept': 'application/json'},
    );

    AppLoggerHelper.debug(
      'InstallerServiceAreaApiService.fetchInstallerServiceAreas: '
      'status=${response.statusCode} success=${response.isSuccess} '
      'body=${response.responseData}',
    );

    if (response.isSuccess && response.responseData is List) {
      return (response.responseData as List)
          .whereType<Map<String, dynamic>>()
          .map(InstallerServiceAreaOption.fromAssignedJson)
          .where((e) => e.id > 0)
          .toList();
    }

    throw Exception(
      response.errorMessage.isNotEmpty
          ? response.errorMessage
          : 'Failed to load installer service areas',
    );
  }

  Future<void> updateInstallerServiceAreas({
    required String authorization,
    required List<int> areaIds,
  }) async {
    final response = await _networkCaller.postRequest(
      ApiEndpoints.installerServiceAreas,
      token: authorization,
      headers: {'accept': 'application/json'},
      body: {'area_ids': areaIds},
    );

    AppLoggerHelper.debug(
      'InstallerServiceAreaApiService.updateInstallerServiceAreas: '
      'status=${response.statusCode} success=${response.isSuccess} '
      'body=${response.responseData}',
    );

    if (response.isSuccess) return;

    throw Exception(
      response.errorMessage.isNotEmpty
          ? response.errorMessage
          : 'Failed to update installer service areas',
    );
  }
}

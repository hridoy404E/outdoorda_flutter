import 'package:outdoorda_flutter/core/models/response_data.dart';
import 'package:outdoorda_flutter/core/services/network_caller.dart';
import 'package:outdoorda_flutter/core/utils/constants/api_endpoints.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/models/service_area_model.dart';

class AdminServiceAreaApiService {
  AdminServiceAreaApiService();

  final NetworkCaller _networkCaller = NetworkCaller();

  Future<List<ServiceAreaModel>> fetchServiceAreas({
    String? authorization,
  }) async {
    final response = await _networkCaller.getRequest(
      ApiEndpoints.serviceAreas,
      token: authorization,
      headers: {'accept': 'application/json'},
    );

    AppLoggerHelper.debug(
      'AdminServiceAreaApiService.fetchServiceAreas: '
      'status=${response.statusCode} success=${response.isSuccess} '
      'body=${response.responseData}',
    );

    if (response.isSuccess && response.responseData is List) {
      return (response.responseData as List)
          .whereType<Map<String, dynamic>>()
          .map(ServiceAreaModel.fromJson)
          .where((e) => e.id > 0 && e.name.trim().isNotEmpty)
          .toList();
    }

    throw Exception(
      response.errorMessage.isNotEmpty
          ? response.errorMessage
          : 'Failed to load service areas',
    );
  }

  Future<List<Map<String, dynamic>>> fetchInstallersByServiceArea({
    required String authorization,
    dynamic serviceAreaId,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (serviceAreaId != null) {
      queryParams['service_area_id'] = serviceAreaId;
    }

    final response = await _networkCaller.getRequest(
      ApiEndpoints.adminInstallers,
      token: authorization,
      headers: {'accept': 'application/json'},
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );

    AppLoggerHelper.debug(
      'AdminServiceAreaApiService.fetchInstallersByServiceArea: '
      'status=${response.statusCode} success=${response.isSuccess} '
      'serviceAreaId=$serviceAreaId body=${response.responseData}',
    );

    if (response.isSuccess && response.responseData != null) {
      final data = response.responseData;
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList();
      } else if (data is Map<String, dynamic>) {
        if (data['results'] is List) {
          return (data['results'] as List).whereType<Map<String, dynamic>>().toList();
        } else if (data['data'] is List) {
          return (data['data'] as List).whereType<Map<String, dynamic>>().toList();
        } else if (data['installers'] is List) {
          return (data['installers'] as List).whereType<Map<String, dynamic>>().toList();
        }
      }
    }

    return [];
  }

  Future<ResponseData> createServiceArea({
    required String authorization,
    required String name,
  }) async {
    final response = await _networkCaller.postRequest(
      ApiEndpoints.adminServiceAreas,
      token: authorization,
      headers: {'accept': 'application/json'},
      formUrlEncoded: true,
      body: {'name': name},
    );

    AppLoggerHelper.debug(
      'AdminServiceAreaApiService.createServiceArea: '
      'status=${response.statusCode} success=${response.isSuccess} '
      'body=${response.responseData}',
    );

    return response;
  }

  Future<ResponseData> updateServiceArea({
    required String authorization,
    required dynamic id,
    required String name,
  }) async {
    final response = await _networkCaller.patchRequest(
      '${ApiEndpoints.adminServiceAreas}/$id',
      token: authorization,
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: {'name': name},
    );

    AppLoggerHelper.debug(
      'AdminServiceAreaApiService.updateServiceArea: '
      'status=${response.statusCode} success=${response.isSuccess} '
      'body=${response.responseData}',
    );

    return response;
  }

  Future<ResponseData> deleteServiceArea({
    required String authorization,
    required dynamic id,
  }) async {
    final response = await _networkCaller.deleteRequest(
      '${ApiEndpoints.adminServiceAreas}/$id',
      token: authorization,
      headers: {'accept': 'application/json'},
    );

    AppLoggerHelper.debug(
      'AdminServiceAreaApiService.deleteServiceArea: '
      'status=${response.statusCode} success=${response.isSuccess} '
      'body=${response.responseData}',
    );

    return response;
  }
}

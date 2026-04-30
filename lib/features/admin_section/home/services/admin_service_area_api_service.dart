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
}

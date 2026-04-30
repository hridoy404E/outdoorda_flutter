import 'package:outdoorda_flutter/core/services/network_caller.dart';
import 'package:outdoorda_flutter/core/utils/constants/api_endpoints.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import '../models/service_area_model.dart';

class ServiceAreaApiService {
  ServiceAreaApiService();

  final NetworkCaller _networkCaller = NetworkCaller();

  Future<List<ServiceAreaModel>> fetchServiceAreas({
    String? authorization,
  }) async {
    AppLoggerHelper.info('Fetching service areas');
    final response = await _networkCaller.getRequest(
      ApiEndpoints.serviceAreas,
      token: authorization,
      headers: {'accept': 'application/json'},
    );
    AppLoggerHelper.debug(
      'ServiceAreaApiService.fetchServiceAreas: '
      'status=${response.statusCode} success=${response.isSuccess} '
      'body=${response.responseData}',
    );

    if (response.isSuccess && response.responseData is List) {
      return (response.responseData as List)
          .whereType<Map<String, dynamic>>()
          .map(ServiceAreaModel.fromJson)
          .toList();
    }

    throw Exception(
      response.errorMessage.isNotEmpty
          ? response.errorMessage
          : 'Failed to load service areas',
    );
  }
}

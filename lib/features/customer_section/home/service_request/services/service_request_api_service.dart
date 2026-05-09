// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:outdoorda_flutter/core/models/response_data.dart';
import 'package:outdoorda_flutter/core/services/network_caller.dart';
import 'package:outdoorda_flutter/core/utils/constants/api_endpoints.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';

class ServiceRequestApiService {
  ServiceRequestApiService();

  final NetworkCaller _networkCaller = NetworkCaller();

  Future<ResponseData> createServiceRequest({
    required String custName,
    required String custEmail,
    required String custPhone,
    required String petName,
    required String petType,
    required String price,
    required String size,
    required String installationSurface,
    required int serviceAreaId,
    required String addressLine1,
    required String addressLine2,
    required String city,
    required String state,
    required String zipCode,
    required String country,
    required File attachment,
    String? authorization,
  }) async {
    AppLoggerHelper.info('ServiceRequestApiService: creating service request');

    final multipartFile = await http.MultipartFile.fromPath(
      'photos',
      attachment.path,
      filename: attachment.path.split(Platform.pathSeparator).last,
    );

    final response = await _networkCaller.multipartRequest(
      ApiEndpoints.createServiceRequest,
      token: authorization,
      headers: {'accept': 'application/json'},
      fields: {
        'cust_name': custName,
        'cust_email': custEmail,
        'cust_phone': custPhone,
        'pet_name': petName,
        'pet_type': petType,
        'price': price,
        'size': size,
        'installation_surface': installationSurface,
        'service_area_id': serviceAreaId.toString(),
        'address_line_1': addressLine1,
        if (addressLine2.trim().isNotEmpty) 'address_line_2': addressLine2,
        'city': city,
        'state': state,
        'zip_code': zipCode,
        'country': country,
      },
      files: [multipartFile],
    );

    AppLoggerHelper.debug(
      'ServiceRequestApiService.createServiceRequest: '
      'status=${response.statusCode} success=${response.isSuccess} '
      'body=${response.responseData}',
    );

    return response;
  }
}

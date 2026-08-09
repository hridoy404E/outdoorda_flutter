// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:outdoorda_flutter/core/models/response_data.dart';
import 'package:outdoorda_flutter/core/services/network_caller.dart';
import 'package:outdoorda_flutter/core/utils/constants/api_endpoints.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';

class AdminCreatePostApiService {
  AdminCreatePostApiService();

  final NetworkCaller _networkCaller = NetworkCaller();

  Future<ResponseData> createPost({
    required String authorization,
    required String size,
    required List<File> photos,
    required List<File> attachments,
    required String custPhone,
    required String installationSurface,
    required String price,
    required int serviceAreaId,
    required String petName,
    required String custIds,
    required String custEmail,
    required String addressLine1,
    required String addressLine2,
    required String city,
    required String state,
    required String zipCode,
    required String country,
    required String custName,
    required String petType,
  }) async {
    final files = <http.MultipartFile>[];
    for (final photo in photos) {
      if (!photo.existsSync()) continue;
      files.add(
        await http.MultipartFile.fromPath(
          'photos',
          photo.path,
          filename: photo.path.split(Platform.pathSeparator).last,
        ),
      );
    }
    for (final attachment in attachments) {
      if (!attachment.existsSync()) continue;
      files.add(
        await http.MultipartFile.fromPath(
          'photos',
          attachment.path,
          filename: attachment.path.split(Platform.pathSeparator).last,
        ),
      );
    }
    final response = await _networkCaller.multipartRequest(
      ApiEndpoints.adminPostsAdmin,
      token: authorization,
      headers: {'accept': 'application/json'},
      fields: {
        'size': size,
        'cust_phone': custPhone,
        'installation_surface': installationSurface,
        'service_area_id': serviceAreaId.toString(),
        'price': price,
        'pet_name': petName,
        'inst_ids': custIds,
        'cust_email': custEmail,
        'address_line_1': addressLine1,
        if (addressLine2.trim().isNotEmpty) 'address_line_2': addressLine2,
        'city': city,
        'state': state,
        'zip_code': zipCode,
        'country': country,
        'cust_name': custName,
        'pet_type': petType,
      },
      files: files,
      method: 'POST',
    );

    AppLoggerHelper.debug(
      'AdminCreatePostApiService.createPost: '
      'status=${response.statusCode} success=${response.isSuccess} '
      'body=${response.responseData}',
    );

    return response;
  }

  Future<ResponseData> deletePost({
    required String authorization,
    required String postId,
  }) async {
    final baseUrl = ApiEndpoints.adminPostsAdmin.endsWith('/')
        ? ApiEndpoints.adminPostsAdmin
        : '${ApiEndpoints.adminPostsAdmin}/';
    final url = '$baseUrl$postId/';

    final response = await _networkCaller.deleteRequest(
      url,
      token: authorization,
      headers: {'accept': 'application/json'},
    );

    AppLoggerHelper.debug(
      'AdminCreatePostApiService.deletePost: '
      'status=${response.statusCode} success=${response.isSuccess} '
      'postId=$postId body=${response.responseData}',
    );

    return response;
  }
}

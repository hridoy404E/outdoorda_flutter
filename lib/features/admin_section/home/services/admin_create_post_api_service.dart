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
    required String jobNotes,
    required String petName,
    required String custIds,
    required String custEmail,
    required String address,
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

    final trimmedJobNotes = jobNotes.trim();

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
        'address': address,
        'cust_name': custName,
        'pet_type': petType,
        if (trimmedJobNotes.isNotEmpty) 'note': trimmedJobNotes,
        if (trimmedJobNotes.isNotEmpty) 'job_notes': trimmedJobNotes,
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
}

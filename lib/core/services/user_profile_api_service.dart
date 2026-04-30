// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:outdoorda_flutter/core/models/user_profile.dart';
import 'package:outdoorda_flutter/core/services/network_caller.dart';
import 'package:outdoorda_flutter/core/services/storage_service.dart';
import 'package:outdoorda_flutter/core/utils/constants/api_endpoints.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';

class UserProfileApiService {
  UserProfileApiService();

  final NetworkCaller _networkCaller = NetworkCaller();

  Future<UserProfile> fetchCurrentUser({required String authorization}) async {
    AppLoggerHelper.info('UserProfileApiService: fetching current user');

    final response = await _networkCaller.getRequest(
      ApiEndpoints.currentUser,
      token: authorization,
      headers: {'accept': 'application/json'},
    );

    AppLoggerHelper.debug(
      'UserProfileApiService.fetchCurrentUser: '
      'status=${response.statusCode} '
      'success=${response.isSuccess} '
      'body=${response.responseData}',
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      final profile = UserProfile.fromJson(
        response.responseData as Map<String, dynamic>,
      );
      await StorageService.saveUserId(profile.id);
      return profile;
    }

    throw Exception(
      response.errorMessage.isNotEmpty
          ? response.errorMessage
          : 'Unable to load user profile',
    );
  }

  Future<UserProfile> updateCurrentUserProfile({
    required String authorization,
    required String name,
    String? phone,
    String? photoPath,
  }) async {
    AppLoggerHelper.info(
      'UserProfileApiService: updating current user profile',
    );

    final fields = <String, String>{'name': name.trim()};
    final cleanedPhone = phone?.trim();
    if (cleanedPhone != null) {
      fields['phone'] = cleanedPhone;
    }

    final files = <http.MultipartFile>[];
    if (photoPath != null &&
        photoPath.trim().isNotEmpty &&
        File(photoPath).existsSync()) {
      files.add(
        await http.MultipartFile.fromPath(
          'photo',
          photoPath,
          filename: photoPath.split(Platform.pathSeparator).last,
        ),
      );
    }

    final response = await _networkCaller.multipartRequest(
      ApiEndpoints.updateCurrentUserProfile,
      token: authorization,
      headers: {'accept': 'application/json'},
      fields: fields,
      files: files.isEmpty ? null : files,
      method: 'PATCH',
    );

    AppLoggerHelper.debug(
      'UserProfileApiService.updateCurrentUserProfile: '
      'status=${response.statusCode} '
      'success=${response.isSuccess} '
      'body=${response.responseData}',
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      final profile = UserProfile.fromJson(
        response.responseData as Map<String, dynamic>,
      );
      await StorageService.saveUserId(profile.id);
      return profile;
    }

    throw Exception(
      response.errorMessage.isNotEmpty
          ? response.errorMessage
          : 'Unable to update user profile',
    );
  }
}

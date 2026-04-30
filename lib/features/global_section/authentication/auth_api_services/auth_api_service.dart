import 'package:outdoorda_flutter/core/models/response_data.dart';
import 'package:outdoorda_flutter/core/services/network_caller.dart';
import 'package:outdoorda_flutter/core/utils/constants/api_endpoints.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';

class AuthApiService {
  final NetworkCaller _networkCaller = NetworkCaller();

  Future<ResponseData> sendOtp({
    required String email,
    required String purpose,
  }) async {
    AppLoggerHelper.debug('AuthApiService: sendOtp($email, $purpose)');
    final response = await _networkCaller.postRequest(
      ApiEndpoints.sendOtp,
      body: {'email': email, 'purpose': purpose},
      headers: {'accept': 'application/json'},
      formUrlEncoded: true,
    );
    AppLoggerHelper.debug(
      'sendOtp status=${response.statusCode} '
      'success=${response.isSuccess} body=${response.responseData}',
    );
    return response;
  }

  Future<ResponseData> verifyOtp({
    required String email,
    required String otpValue,
    required String purpose,
  }) async {
    AppLoggerHelper.debug('AuthApiService: verifyOtp($email, $purpose)');
    final response = await _networkCaller.postRequest(
      ApiEndpoints.verifyOtp,
      body: {'email': email, 'otp_value': otpValue, 'purpose': purpose},
      headers: {'accept': 'application/json'},
      formUrlEncoded: true,
    );
    AppLoggerHelper.debug(
      'verifyOtp status=${response.statusCode} '
      'success=${response.isSuccess} body=${response.responseData}',
    );
    return response;
  }

  Future<ResponseData> forgotPassword({
    required String email,
    required String password,
    required String sessionKey,
  }) async {
    AppLoggerHelper.debug('AuthApiService: forgotPassword($email)');
    final response = await _networkCaller.postRequest(
      ApiEndpoints.forgotPassword,
      body: {'email': email, 'password': password, 'session_key': sessionKey},
      headers: {'accept': 'application/json'},
      formUrlEncoded: true,
    );
    AppLoggerHelper.debug(
      'forgotPassword status=${response.statusCode} '
      'success=${response.isSuccess} body=${response.responseData}',
    );
    return response;
  }

  Future<ResponseData> signup({
    required String name,
    required String email,
    required String password,
    required String otpValue,
    required String purpose,
  }) async {
    AppLoggerHelper.debug('AuthApiService: signup($email, $purpose)');
    final response = await _networkCaller.postRequest(
      ApiEndpoints.signup,
      body: {
        'name': name,
        'email': email,
        'password': password,
        'otp_value': otpValue,
        'purpose': purpose,
      },
      headers: {'accept': 'application/json'},
      formUrlEncoded: true,
    );
    AppLoggerHelper.debug(
      'signup status=${response.statusCode} '
      'success=${response.isSuccess} body=${response.responseData}',
    );
    return response;
  }

  Future<ResponseData> resetPassword({
    required String authorization,
    required String oldPassword,
    required String newPassword,
  }) async {
    AppLoggerHelper.debug('AuthApiService: resetPassword');
    final response = await _networkCaller.postRequest(
      ApiEndpoints.resetPassword,
      body: {'old_password': oldPassword, 'password': newPassword},
      token: authorization,
      headers: {'accept': 'application/json'},
      formUrlEncoded: true,
    );
    AppLoggerHelper.debug(
      'resetPassword status=${response.statusCode} '
      'success=${response.isSuccess} body=${response.responseData}',
    );
    return response;
  }

  Future<ResponseData> deleteCurrentUserAccount({
    required String authorization,
  }) async {
    AppLoggerHelper.debug('AuthApiService: deleteCurrentUserAccount');
    final response = await _networkCaller.deleteRequest(
      ApiEndpoints.deleteCurrentUser,
      token: authorization,
      headers: {'accept': 'application/json'},
    );
    AppLoggerHelper.debug(
      'deleteCurrentUserAccount status=${response.statusCode} '
      'success=${response.isSuccess} body=${response.responseData}',
    );
    return response;
  }
}

// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart' hide Response;
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:outdoorda_flutter/core/services/storage_service.dart';
import 'package:outdoorda_flutter/core/utils/constants/api_endpoints.dart';
import 'package:outdoorda_flutter/core/utils/helpers/auth_token_helper.dart';
import 'package:outdoorda_flutter/routes/app_routes.dart';

import '../models/response_data.dart';
import '../utils/logging/logger.dart';

class NetworkCaller {
  final int timeoutDuration = 120;

  static const String _jsonContentType = 'application/json';
  static const String _formContentType = 'application/x-www-form-urlencoded';
  static Future<bool>? _tokenRefreshFuture;
  static bool _isLoggingOut = false;

  Map<String, String> _buildHeaders({
    String contentType = _jsonContentType,
    String? token,
    Map<String, String>? headers,
  }) {
    return {
      'Content-Type': contentType,
      if (token != null) 'Authorization': token,
      if (headers != null) ...headers,
    };
  }

  String _encodeFormBody(Map<String, dynamic>? body) {
    if (body == null || body.isEmpty) return '';
    return body.entries
        .map(
          (entry) =>
              '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value?.toString() ?? '')}',
        )
        .join('&');
  }

  Future<ResponseData> getRequest(
    String url, {
    String? token,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) async {
    Uri uri = Uri.parse(url);
    if (queryParams != null) {
      uri = uri.replace(
        queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())),
      );
    }

    return _sendRequest(
      token: token,
      request: (authorization) => get(
        uri,
        headers: _buildHeaders(token: authorization, headers: headers),
      ),
    );
  }

  Future<ResponseData> postRequest(
    String url, {
    Map<String, dynamic>? body,
    String? token,
    Map<String, String>? headers,
    bool formUrlEncoded = false,
  }) async {
    final encodedBody = formUrlEncoded
        ? _encodeFormBody(body)
        : jsonEncode(body ?? {});

    return _sendRequest(
      token: token,
      request: (authorization) => post(
        Uri.parse(url),
        headers: _buildHeaders(
          token: authorization,
          headers: headers,
          contentType: formUrlEncoded ? _formContentType : _jsonContentType,
        ),
        body: encodedBody,
      ),
    );
  }

  Future<ResponseData> putRequest(
    String url, {
    Map<String, dynamic>? body,
    String? token,
    Map<String, String>? headers,
    bool formUrlEncoded = false,
  }) async {
    final encodedBody = formUrlEncoded
        ? _encodeFormBody(body)
        : jsonEncode(body ?? {});

    return _sendRequest(
      token: token,
      request: (authorization) => put(
        Uri.parse(url),
        headers: _buildHeaders(
          token: authorization,
          headers: headers,
          contentType: formUrlEncoded ? _formContentType : _jsonContentType,
        ),
        body: encodedBody,
      ),
    );
  }

  Future<ResponseData> patchRequest(
    String url, {
    Map<String, dynamic>? body,
    String? token,
    Map<String, String>? headers,
    bool formUrlEncoded = false,
  }) async {
    final encodedBody = formUrlEncoded
        ? _encodeFormBody(body)
        : jsonEncode(body ?? {});

    return _sendRequest(
      token: token,
      request: (authorization) => patch(
        Uri.parse(url),
        headers: _buildHeaders(
          token: authorization,
          headers: headers,
          contentType: formUrlEncoded ? _formContentType : _jsonContentType,
        ),
        body: encodedBody,
      ),
    );
  }

  Future<ResponseData> deleteRequest(
    String url, {
    String? token,
    Map<String, String>? headers,
  }) async {
    return _sendRequest(
      token: token,
      request: (authorization) => delete(
        Uri.parse(url),
        headers: _buildHeaders(token: authorization, headers: headers),
      ),
    );
  }

  Future<ResponseData> multipartRequest(
    String url, {
    Map<String, String>? fields,
    Map<String, String>? headers,
    List<http.MultipartFile>? files,
    String? token,
    String method = 'POST',
  }) async {
    Uri uri = Uri.parse(url);
    return _sendRequest(
      token: token,
      canRefresh: files == null || files.isEmpty,
      request: (authorization) async {
        final requestHeaders = _buildHeaders(
          token: authorization,
          headers: headers,
        );
        requestHeaders.remove('Content-Type');

        final request = http.MultipartRequest(method.toUpperCase(), uri);
        request.headers.addAll(requestHeaders);
        if (fields != null) request.fields.addAll(fields);
        if (files != null) request.files.addAll(files);

        final streamedResponse = await request.send().timeout(
          Duration(seconds: timeoutDuration),
        );
        return Response.fromStream(streamedResponse);
      },
    );
  }

  Future<ResponseData> _sendRequest({
    required Future<Response> Function(String? authorization) request,
    String? token,
    bool canRefresh = true,
  }) async {
    try {
      final response = await request(
        token,
      ).timeout(Duration(seconds: timeoutDuration));
      final responseData = _handleResponse(response);
      final requestUrl = response.request?.url.toString();

      final isUnauthorized =
          responseData.statusCode == 401 || responseData.statusCode == 403;

      if (isUnauthorized && _isAuthEndpoint(requestUrl)) {
        return responseData;
      }

      if (isUnauthorized && canRefresh) {
        final refreshed = await _refreshAccessToken();
        if (refreshed) {
          final refreshedAuthorization = _buildStoredAuthorizationHeader();
          if (refreshedAuthorization != null) {
            AppLoggerHelper.info(
              'Retrying request with refreshed access token: ${response.request?.url}',
            );
            final retriedResponse = await request(
              refreshedAuthorization,
            ).timeout(Duration(seconds: timeoutDuration));
            final retriedData = _handleResponse(retriedResponse);

            if (retriedData.statusCode == 401 ||
                retriedData.statusCode == 403) {
              await _logoutUserDueToExpiredSession();
            }
            return retriedData;
          }
        }
      }

      if (isUnauthorized) {
        await _logoutUserDueToExpiredSession();
      }

      return responseData;
    } catch (e) {
      return _handleError(e);
    }
  }

  bool _isAuthEndpoint(String? url) {
    if (url == null || url.trim().isEmpty) return false;
    final path = url.toLowerCase();
    return path.contains('/auth/login') ||
        path.contains('/auth/signup') ||
        path.contains('/auth/send_otp') ||
        path.contains('/auth/verify_otp') ||
        path.contains('/auth/forgot_password') ||
        path.contains('/auth/reset_password');
  }

  Future<bool> _refreshAccessToken() async {
    final pendingRefresh = _tokenRefreshFuture;
    if (pendingRefresh != null) {
      return pendingRefresh;
    }

    final completer = Completer<bool>();
    _tokenRefreshFuture = completer.future;

    try {
      final refreshToken = StorageService.refreshToken?.trim();
      final authorization = _buildStoredAuthorizationHeader();
      if (refreshToken == null || refreshToken.isEmpty) {
        AppLoggerHelper.warning('Refresh token missing. Logging out user.');
        await _logoutUserDueToExpiredSession();
        completer.complete(false);
        return false;
      }

      AppLoggerHelper.info('Refreshing access token');
      AppLoggerHelper.debug('Stored refresh token: $refreshToken');
      AppLoggerHelper.debug(
        'Stored authorization header for refresh: ${authorization ?? 'null'}',
      );
      final response = await get(
        Uri.parse(ApiEndpoints.verifyToken),
        headers: {
          'Content-Type': _jsonContentType,
          'accept': 'application/json',
          'refresh-token': refreshToken,
          if (authorization != null) 'Authorization': authorization,
        },
      ).timeout(Duration(seconds: timeoutDuration));

      final responseData = _handleResponse(response);
      final decoded = responseData.responseData;
      if (responseData.isSuccess && decoded is Map) {
        final refreshedTokens = _extractRefreshedTokens(decoded);
        final accessToken = refreshedTokens.accessToken;
        if (accessToken != null && accessToken.isNotEmpty) {
          await StorageService.saveAuthData(
            accessToken: accessToken,
            refreshToken: refreshedTokens.refreshToken,
            tokenType: refreshedTokens.tokenType,
            role: refreshedTokens.role,
          );
          final userId =
              refreshedTokens.userId ??
              AuthTokenHelper.getSubjectFromJwt(accessToken);
          if (userId != null && userId.isNotEmpty) {
            await StorageService.saveUserId(userId);
          }
          AppLoggerHelper.info('Access token refreshed successfully');
          completer.complete(true);
          return true;
        }
      }

      if (_shouldLogoutAfterRefreshFailure(responseData)) {
        await _logoutUserDueToExpiredSession();
      }

      completer.complete(false);
      return false;
    } catch (e) {
      AppLoggerHelper.error('Token refresh failed', e);
      completer.complete(false);
      return false;
    } finally {
      _tokenRefreshFuture = null;
    }
  }

  bool _shouldLogoutAfterRefreshFailure(ResponseData responseData) {
    if (responseData.statusCode == 401 || responseData.statusCode == 403) {
      return true;
    }

    final errorText = _extractErrorMessage(
      responseData.responseData,
      fallback: responseData.errorMessage,
    ).toLowerCase();

    return errorText.contains('refresh token expired') ||
        errorText.contains('refresh token invalid') ||
        errorText.contains('refresh token required');
  }

  String? _buildStoredAuthorizationHeader() {
    final accessToken =
        (StorageService.accessToken ?? StorageService.token)?.trim();
    if (accessToken == null || accessToken.isEmpty) {
      return null;
    }

    final tokenType = StorageService.tokenType?.trim();
    final prefix = tokenType != null && tokenType.isNotEmpty
        ? tokenType
        : 'Bearer';
    return '$prefix $accessToken';
  }

  _RefreshedTokens _extractRefreshedTokens(Map decoded) {
    final nestedTokens = decoded['new_tokens'] ?? decoded['data'] ?? decoded['tokens'];
    final tokenSource = nestedTokens is Map ? nestedTokens : decoded;

    String? readTokenValue(Map source, String key) {
      final value = source[key]?.toString().trim();
      return value != null && value.isNotEmpty ? value : null;
    }

    String? findToken(List<String> keys) {
      for (final key in keys) {
        final val = readTokenValue(tokenSource, key) ?? readTokenValue(decoded, key);
        if (val != null) return val;
      }
      return null;
    }

    return _RefreshedTokens(
      accessToken: findToken(['access_token', 'accessToken', 'token', 'access']),
      refreshToken: findToken(['refresh_token', 'refreshToken', 'refresh']),
      tokenType:
          readTokenValue(tokenSource, 'token_type') ??
          readTokenValue(decoded, 'token_type'),
      role: readTokenValue(decoded, 'role'),
      userId: readTokenValue(decoded, 'id'),
    );
  }

  Future<void> _logoutUserDueToExpiredSession() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    try {
      await StorageService.logoutUser();
      EasyLoading.dismiss();
      EasyLoading.showError('Session expired. Please log in again.');
      if (Get.currentRoute != AppRoute.getLoginScreen()) {
        Get.offAllNamed(AppRoute.getLoginScreen());
      }
    } catch (e) {
      AppLoggerHelper.error('Failed to logout expired session', e);
    } finally {
      _isLoggingOut = false;
    }
  }

  ResponseData _handleResponse(Response response) {
    final method = response.request?.method ?? 'UNKNOWN';
    final endpoint = response.request?.url.toString() ?? 'UNKNOWN';
    AppLoggerHelper.debug('Endpoint: [$method] $endpoint');
    AppLoggerHelper.debug('Status: ${response.statusCode}');
    AppLoggerHelper.debug('Body: ${response.body}');
    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      decoded = response.body;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      bool success = true;
      if (decoded is Map) {
        if (decoded.containsKey('success')) {
          success = decoded['success'] == true;
        } else if (decoded.containsKey('status')) {
          final statusValue = decoded['status']?.toString().toLowerCase();
          success = statusValue == 'success';
        } else if (decoded.containsKey('access_token')) {
          success = true;
        }
      }
      return ResponseData(
        isSuccess: success,
        statusCode: response.statusCode,
        responseData: decoded,
        errorMessage: success
            ? ''
            : _extractErrorMessage(decoded, fallback: 'Unknown error occurred'),
      );
    } else if (response.statusCode == 400) {
      return ResponseData(
        isSuccess: false,
        statusCode: response.statusCode,
        responseData: decoded,
        errorMessage: decoded is Map
            ? _extractErrorMessages(decoded['errorSources'])
            : _extractErrorMessage(decoded, fallback: 'Validation error'),
      );
    } else if (response.statusCode == 401) {
      return ResponseData(
        isSuccess: false,
        statusCode: 401,
        responseData: decoded,
        errorMessage: 'Unauthorized request',
      );
    } else if (response.statusCode == 403) {
      return ResponseData(
        isSuccess: false,
        statusCode: 403,
        responseData: decoded,
        errorMessage: 'Forbidden request',
      );
    } else if (response.statusCode == 500) {
      return ResponseData(
        isSuccess: false,
        statusCode: 500,
        responseData: decoded,
        errorMessage: _extractErrorMessage(
          decoded,
          fallback: 'Server error occurred',
        ),
      );
    } else {
      return ResponseData(
        isSuccess: false,
        statusCode: response.statusCode,
        responseData: decoded,
        errorMessage: _extractErrorMessage(
          decoded,
          fallback: 'Unknown error occurred',
        ),
      );
    }
  }

  String _extractErrorMessages(dynamic errorSources) {
    if (errorSources is List) {
      return errorSources
          .map(
            (e) => e is Map
                ? e['message']?.toString() ?? 'Unknown error'
                : e.toString(),
          )
          .join(', ');
    }
    return 'Validation error';
  }

  String _extractErrorMessage(dynamic decoded, {required String fallback}) {
    if (decoded == null) return fallback;
    if (decoded is String) {
      final text = decoded.trim();
      return text.isEmpty ? fallback : text;
    }

    if (decoded is List) {
      if (decoded.isEmpty) return fallback;
      final first = decoded.first;
      if (first is Map && first['msg'] != null) {
        return first['msg'].toString();
      }
      return decoded.join(', ');
    }

    if (decoded is Map) {
      final message = decoded['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }

      final detail = decoded['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return detail.trim();
      }
      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map && first['msg'] != null) {
          return first['msg'].toString();
        }
        return detail.join(', ');
      }
    }

    return fallback;
  }

  ResponseData _handleError(dynamic error) {
    AppLoggerHelper.error('Request error', error);
    if (error is TimeoutException) {
      return ResponseData(
        isSuccess: false,
        statusCode: 408,
        responseData: '',
        errorMessage: 'Request timeout',
      );
    }
    return ResponseData(
      isSuccess: false,
      statusCode: 500,
      responseData: '',
      errorMessage: error.toString(),
    );
  }
}

class _RefreshedTokens {
  const _RefreshedTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.role,
    required this.userId,
  });

  final String? accessToken;
  final String? refreshToken;
  final String? tokenType;
  final String? role;
  final String? userId;
}

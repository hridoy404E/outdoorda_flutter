import 'package:outdoorda_flutter/core/services/network_caller.dart';
import 'package:outdoorda_flutter/core/utils/constants/api_endpoints.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';

class ChatSessionApiService {
  ChatSessionApiService();

  final NetworkCaller _networkCaller = NetworkCaller();

  Future<bool> startChat({
    required String authorization,
    required String fromType,
    required String fromId,
    required String toType,
    required String toId,
  }) async {
    final normalizedFromType = normalizeToSingularType(fromType);
    final normalizedToType = normalizeToSingularType(toType);
    final url =
        '${ApiEndpoints.baseUrl}/communications/chat/start/'
        '$normalizedFromType/$fromId/$normalizedToType/$toId';

    final response = await _networkCaller.postRequest(
      url,
      token: authorization,
      headers: {'accept': 'application/json'},
      body: const <String, dynamic>{},
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    }

    AppLoggerHelper.warning(
      'Failed to start chat: status=${response.statusCode} '
      'error=${response.errorMessage} url=$url',
    );
    return false;
  }

  Future<bool> endChat({
    required String authorization,
    required String fromType,
    required String fromId,
    required String toType,
    required String toId,
  }) async {
    final normalizedFromType = normalizeToSingularType(fromType);
    final normalizedToType = normalizeToSingularType(toType);
    final url =
        '${ApiEndpoints.baseUrl}/communications/chat/end/'
        '$normalizedFromType/$fromId/$normalizedToType/$toId';

    final response = await _networkCaller.postRequest(
      url,
      token: authorization,
      headers: {'accept': 'application/json'},
      body: const <String, dynamic>{},
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    }

    AppLoggerHelper.warning(
      'Failed to end chat: status=${response.statusCode} '
      'error=${response.errorMessage} url=$url',
    );
    return false;
  }

  String buildWebSocketUrl({
    required String userTypePlural,
    required String userId,
  }) {
    final baseUri = Uri.parse(ApiEndpoints.baseUrl);
    final socketScheme = baseUri.scheme == 'https' ? 'wss' : 'ws';
    final hostWithPort = baseUri.hasPort
        ? '${baseUri.host}:${baseUri.port}'
        : baseUri.host;
    return '$socketScheme://$hostWithPort/communications/ws/chat/$userTypePlural/$userId';
  }

  static String normalizeToSingularType(String value) {
    final cleaned = value.trim().toLowerCase();
    switch (cleaned) {
      case 'customers':
      case 'customer':
        return 'customer';
      case 'installers':
      case 'installer':
      case 'instraller':
        return 'installer';
      case 'admins':
      case 'admin':
        return 'admin';
      default:
        return cleaned;
    }
  }

  static String normalizeToPluralWsType(String value) {
    final cleaned = value.trim().toLowerCase();
    switch (cleaned) {
      case 'customer':
      case 'customers':
        return 'customers';
      case 'installer':
      case 'installers':
      case 'instraller':
        return 'installers';
      case 'admin':
      case 'admins':
        return 'admins';
      default:
        return cleaned;
    }
  }
}

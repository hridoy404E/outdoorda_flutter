import 'dart:convert';

class AuthTokenHelper {
  AuthTokenHelper._();

  static String? getSubjectFromJwt(String? jwtToken) {
    if (jwtToken == null || jwtToken.trim().isEmpty) {
      return null;
    }

    final parts = jwtToken.split('.');
    if (parts.length < 2) {
      return null;
    }

    try {
      final payload = _decodeBase64Url(parts[1]);
      final payloadMap = jsonDecode(payload);
      if (payloadMap is Map<String, dynamic>) {
        final sub = payloadMap['sub']?.toString().trim();
        if (sub != null && sub.isNotEmpty) {
          return sub;
        }
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  static String _decodeBase64Url(String input) {
    var normalized = input.replaceAll('-', '+').replaceAll('_', '/');
    switch (normalized.length % 4) {
      case 2:
        normalized += '==';
      case 3:
        normalized += '=';
      case 0:
        break;
      default:
        throw const FormatException('Invalid base64url input');
    }

    return utf8.decode(base64Decode(normalized));
  }
}

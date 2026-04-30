import 'package:outdoorda_flutter/core/services/communications/chat_session_api_service.dart';
import 'package:outdoorda_flutter/core/services/network_caller.dart';
import 'package:outdoorda_flutter/core/utils/constants/api_endpoints.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';

class ChatPartner {
  const ChatPartner({
    required this.type,
    required this.id,
    required this.userName,
    required this.lastMessageAt,
  });

  final String type;
  final String id;
  final String userName;
  final DateTime? lastMessageAt;
}

class ChatPartnerApiService {
  ChatPartnerApiService();

  final NetworkCaller _networkCaller = NetworkCaller();

  Future<List<ChatPartner>> fetchPartners({
    required String authorization,
    required String userType,
    required String userId,
  }) async {
    final candidates = _pathTypeCandidates(userType);

    for (final typePath in candidates) {
      final url =
          '${ApiEndpoints.baseUrl}/communications/chat/partners/$typePath/$userId';

      final response = await _networkCaller.getRequest(
        url,
        token: authorization,
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final parsed = _parsePartners(response.responseData);
        AppLoggerHelper.info(
          'Chat partners loaded: type=$typePath count=${parsed.length}',
        );
        return parsed;
      }
    }

    AppLoggerHelper.warning(
      'Failed to fetch chat partners for userType=$userType userId=$userId',
    );
    return const <ChatPartner>[];
  }

  List<ChatPartner> _parsePartners(dynamic data) {
    if (data is! Map<String, dynamic>) return const <ChatPartner>[];
    final rawPartners = data['partners'];
    if (rawPartners is! List) return const <ChatPartner>[];

    final partners = <ChatPartner>[];
    for (final item in rawPartners) {
      if (item is! Map<String, dynamic>) continue;
      final type = item['type']?.toString().trim() ?? '';
      final id = item['id']?.toString().trim() ?? '';
      if (type.isEmpty || id.isEmpty) continue;
      final userName = item['user_name']?.toString().trim().isNotEmpty == true
          ? item['user_name'].toString().trim()
          : id;

      final parsedLastMessageAt = DateTime.tryParse(
        item['last_message_at']?.toString() ?? '',
      );
      final lastMessageAt = parsedLastMessageAt != null
          ? _asLocalTime(parsedLastMessageAt)
          : null;

      partners.add(
        ChatPartner(
          type: type,
          id: id,
          userName: userName,
          lastMessageAt: lastMessageAt,
        ),
      );
    }
    return partners;
  }

  DateTime _asLocalTime(DateTime value) {
    return value.toLocal();
  }

  List<String> _pathTypeCandidates(String userType) {
    final singular = ChatSessionApiService.normalizeToSingularType(userType);
    final plural = ChatSessionApiService.normalizeToPluralWsType(userType);
    final candidates = <String>[];

    void addUnique(String value) {
      if (!candidates.contains(value)) {
        candidates.add(value);
      }
    }

    if (singular == 'installer') {
      addUnique('installers');
      addUnique('installer');
      addUnique('instrallers');
      addUnique('instraller');
      return candidates;
    }

    if (singular == 'customer') {
      addUnique('customers');
      addUnique('customer');
      return candidates;
    }

    addUnique(singular);
    addUnique(plural);
    return candidates;
  }
}

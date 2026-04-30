import 'package:outdoorda_flutter/core/services/communications/chat_session_api_service.dart';
import 'package:outdoorda_flutter/core/services/network_caller.dart';
import 'package:outdoorda_flutter/core/utils/constants/api_endpoints.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';

class ChatHistoryMessage {
  const ChatHistoryMessage({
    required this.fromType,
    required this.fromId,
    required this.fromName,
    required this.text,
    required this.timestamp,
    required this.isRead,
    this.messageId,
    this.editedAt,
    this.isDeleted = false,
    this.reactions = const <String, dynamic>{},
    this.mediaType,
    this.mediaUrl,
    this.isOfflineMessage = false,
  });

  final String fromType;
  final String fromId;
  final String fromName;
  final String text;
  final DateTime timestamp;
  final bool isRead;
  final String? messageId;
  final DateTime? editedAt;
  final bool isDeleted;
  final Map<String, dynamic> reactions;
  final String? mediaType;
  final String? mediaUrl;
  final bool isOfflineMessage;
}

class ChatHistoryApiService {
  ChatHistoryApiService();

  final NetworkCaller _networkCaller = NetworkCaller();

  Future<List<ChatHistoryMessage>> fetchHistory({
    required String authorization,
    required String fromType,
    required String fromId,
    required String toType,
    required String toId,
    int limit = 50,
  }) async {
    final normalizedFromType = ChatSessionApiService.normalizeToPluralWsType(
      fromType,
    );
    final normalizedToType = ChatSessionApiService.normalizeToPluralWsType(
      toType,
    );

    final url =
        '${ApiEndpoints.baseUrl}/communications/chat/history/'
        '$normalizedFromType/$fromId/$normalizedToType/$toId';

    final response = await _networkCaller.getRequest(
      url,
      token: authorization,
      headers: {'accept': 'application/json'},
      queryParams: {'limit': limit},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      AppLoggerHelper.warning(
        'Failed to load chat history: status=${response.statusCode} '
        'error=${response.errorMessage} url=$url',
      );
      return const <ChatHistoryMessage>[];
    }

    final parsed = _parseMessages(response.responseData);
    AppLoggerHelper.info('Chat history loaded: count=${parsed.length}');
    return parsed;
  }

  List<ChatHistoryMessage> _parseMessages(dynamic data) {
    if (data is! Map<String, dynamic>) return const <ChatHistoryMessage>[];
    final rawMessages = data['messages'];
    if (rawMessages is! List) return const <ChatHistoryMessage>[];

    final messages = <ChatHistoryMessage>[];
    for (final item in rawMessages) {
      if (item is! Map<String, dynamic>) continue;

      final fromId = item['from_id']?.toString().trim() ?? '';
      final text = item['text']?.toString() ?? '';
      final mediaUrl = item['media_url']?.toString();
      final isDeleted = item['is_deleted'] == true;
      if (fromId.isEmpty) continue;
      if (text.trim().isEmpty &&
          (mediaUrl == null || mediaUrl.trim().isEmpty) &&
          !isDeleted) {
        continue;
      }

      final parsedTime = DateTime.tryParse(item['timestamp']?.toString() ?? '');
      final parsedEditedAt = DateTime.tryParse(
        item['edited_at']?.toString() ?? '',
      );
      final reactionsRaw = item['reactions'];

      messages.add(
        ChatHistoryMessage(
          fromType: ChatSessionApiService.normalizeToPluralWsType(
            item['from_type']?.toString() ?? '',
          ),
          fromId: fromId,
          fromName: item['from_name']?.toString() ?? '',
          text: text,
          timestamp: parsedTime != null
              ? _asLocalTime(parsedTime)
              : DateTime.now(),
          isRead: item['is_read'] == true,
          messageId: item['message_id']?.toString(),
          editedAt: parsedEditedAt != null
              ? _asLocalTime(parsedEditedAt)
              : null,
          isDeleted: isDeleted,
          reactions: reactionsRaw is Map
              ? Map<String, dynamic>.from(reactionsRaw)
              : const <String, dynamic>{},
          mediaType: item['media_type']?.toString(),
          mediaUrl: mediaUrl,
          isOfflineMessage: item['is_offline_message'] == true,
        ),
      );
    }

    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return messages;
  }

  DateTime _asLocalTime(DateTime value) {
    return value.toLocal();
  }
}

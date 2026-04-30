import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:outdoorda_flutter/core/services/communications/chat_attachment_codec.dart';
import 'package:outdoorda_flutter/core/services/communications/chat_history_api_service.dart';
import 'package:outdoorda_flutter/core/services/communications/chat_session_api_service.dart';
import 'package:outdoorda_flutter/core/services/storage_service.dart';
import 'package:outdoorda_flutter/core/services/user_profile_api_service.dart';
import 'package:outdoorda_flutter/core/utils/helpers/auth_token_helper.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/features/customer_section/home/messaging/models/message.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Controller for managing messaging/chat screen
/// Handles message list, websocket actions, and scroll behavior
class MessagingController extends GetxController {
  final ChatHistoryApiService _chatHistoryApiService = ChatHistoryApiService();
  final ChatSessionApiService _chatSessionApiService = ChatSessionApiService();
  final UserProfileApiService _userProfileApiService = UserProfileApiService();

  final RxList<Message> messages = <Message>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxBool isSocketConnected = false.obs;

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  late final Conversation conversation;
  bool _hasConversation = false;
  WebSocketChannel? _socket;
  StreamSubscription<dynamic>? _socketSubscription;
  final Set<String> _knownMessageIds = <String>{};
  final Map<String, int> _pendingReactionAcks = <String, int>{};
  bool _isStatusSyncInProgress = false;
  DateTime? _lastStatusSyncAt;
  String? _currentUserId;
  String? _currentUserName;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is Conversation) {
      conversation = Get.arguments as Conversation;
      _hasConversation = true;
      _initializeChat();
    }
  }

  @override
  void onClose() {
    _closeSocket();
    if (_hasConversation) {
      _endChatSession();
    }
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> _initializeChat() async {
    isLoading.value = true;
    try {
      final authorization = _buildAuthorizationHeader();
      if (authorization == null) return;

      final resolvedUserId = await _resolveCurrentUserId(authorization);
      if (resolvedUserId == null || resolvedUserId.isEmpty) {
        AppLoggerHelper.warning('Customer chat init failed: missing user id');
        return;
      }
      _currentUserId = resolvedUserId;
      await _resolveCurrentUserName(authorization);

      messages.clear();
      _knownMessageIds.clear();

      await _chatSessionApiService.startChat(
        authorization: authorization,
        fromType: _selfTypeSingular,
        fromId: resolvedUserId,
        toType: _peerTypeSingular,
        toId: conversation.userId,
      );
      await _loadHistory(
        authorization: authorization,
        currentUserId: resolvedUserId,
      );

      await _connectSocket(userId: resolvedUserId);
    } catch (error) {
      AppLoggerHelper.error('Customer chat init failed', error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage() async {
    final messageText = messageController.text.trim();
    await sendSocketMessage(text: messageText, clearComposer: true);
  }

  Future<bool> sendSocketMessage({
    required String text,
    String? mediaType,
    String? mediaUrl,
    bool clearComposer = false,
  }) async {
    final normalizedText = text.trim();
    final normalizedMediaType = _normalizeString(mediaType);
    final normalizedMediaUrl = _normalizeString(mediaUrl);
    if (normalizedText.isEmpty && normalizedMediaUrl == null) return false;

    if (!isSocketConnected.value || _socket == null) {
      AppLoggerHelper.warning(
        'Customer chat send skipped: socket disconnected',
      );
      Get.snackbar(
        'Connection error',
        'Message not sent. Please reconnect and try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    try {
      isSending.value = true;

      _appendLocalOutgoingMessage(
        text: normalizedText,
        mediaType: normalizedMediaType,
        mediaUrl: normalizedMediaUrl,
      );

      if (clearComposer) {
        messageController.clear();
      }

      final payload = <String, dynamic>{
        'action': 'send',
        'to_type': _peerTypePlural,
        'to_id': conversation.userId,
        'text': normalizedText,
        'from_name': _currentUserName ?? 'Me',
      };
      if (normalizedMediaType != null) {
        payload['media_type'] = normalizedMediaType;
      }
      if (normalizedMediaUrl != null) {
        payload['media_url'] = normalizedMediaUrl;
      }

      _sendSocketPayload(payload, actionName: 'send');
      return true;
    } catch (error) {
      AppLoggerHelper.error('Customer message send failed', error);
      Get.snackbar(
        'Send failed',
        'Could not send message. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSending.value = false;
    }
  }

  Future<void> editMessage({
    required String messageId,
    required String newText,
  }) async {
    final id = messageId.trim();
    final text = newText.trim();
    if (id.isEmpty || text.isEmpty) return;
    if (!_isSocketReadyForAction('Customer message edit')) return;

    final index = _findMessageIndexById(id);
    if (index >= 0) {
      messages[index] = messages[index].copyWith(
        message: text,
        editedAt: DateTime.now(),
      );
    }

    _sendSocketPayload({
      'action': 'edit',
      'message_id': id,
      'new_text': text,
    }, actionName: 'edit');
  }

  Future<void> deleteMessage({required String messageId}) async {
    final id = messageId.trim();
    if (id.isEmpty) return;
    if (!_isSocketReadyForAction('Customer message delete')) return;

    final index = _findMessageIndexById(id);
    if (index >= 0) {
      messages[index] = messages[index].copyWith(
        isDeleted: true,
        editedAt: DateTime.now(),
      );
    }

    _sendSocketPayload({
      'action': 'delete',
      'message_id': id,
    }, actionName: 'delete');
  }

  Future<void> reactToMessage({
    required String messageId,
    required String reaction,
  }) async {
    final id = messageId.trim();
    final emoji = reaction.trim();
    if (id.isEmpty || emoji.isEmpty) return;
    if (!_isSocketReadyForAction('Customer message react')) return;

    _applyLocalReactionChange(messageId: id, reaction: emoji, remove: false);
    _trackPendingReactionAck(messageId: id, reaction: emoji, remove: false);
    _sendSocketPayload({
      'action': 'react',
      'message_id': id,
      'reaction': emoji,
    }, actionName: 'react');
  }

  Future<void> removeReaction({
    required String messageId,
    required String reaction,
  }) async {
    final id = messageId.trim();
    final emoji = reaction.trim();
    if (id.isEmpty || emoji.isEmpty) return;
    if (!_isSocketReadyForAction('Customer message remove react')) return;

    _applyLocalReactionChange(messageId: id, reaction: emoji, remove: true);
    _trackPendingReactionAck(messageId: id, reaction: emoji, remove: true);
    _sendSocketPayload({
      'action': 'remove_react',
      'message_id': id,
      'reaction': emoji,
    }, actionName: 'remove_react');
  }

  bool _isSocketReadyForAction(String actionName) {
    if (isSocketConnected.value && _socket != null) return true;
    AppLoggerHelper.warning('$actionName skipped: socket disconnected');
    return false;
  }

  Future<void> _connectSocket({required String userId}) async {
    await _closeSocket();

    final wsUrl = _chatSessionApiService.buildWebSocketUrl(
      userTypePlural: _selfTypePlural,
      userId: userId,
    );

    _socket = WebSocketChannel.connect(Uri.parse(wsUrl));
    _socketSubscription = _socket!.stream.listen(
      _handleSocketEvent,
      onError: (Object error) {
        isSocketConnected.value = false;
        AppLoggerHelper.error('Customer websocket error', error);
      },
      onDone: () {
        isSocketConnected.value = false;
        AppLoggerHelper.warning('Customer websocket closed');
      },
      cancelOnError: true,
    );
    isSocketConnected.value = true;
    AppLoggerHelper.info('Customer websocket connected: $wsUrl');
  }

  void _handleSocketEvent(dynamic rawEvent) {
    final payloadText = rawEvent?.toString();
    if (payloadText == null || payloadText.isEmpty) return;
    AppLoggerHelper.debug(
      'Customer WS IN (raw, ${payloadText.length} chars): '
      '${_truncateForLog(payloadText)}',
    );

    try {
      final payload = jsonDecode(payloadText);
      if (payload is! Map<String, dynamic>) return;
      AppLoggerHelper.debug(
        'Customer WS IN (decoded): ${_summarizePayloadForLog(payload)}',
      );
      if (_handleNonMessagingSocketPayload(payload)) return;
      if (payload['type']?.toString() != 'messaging') return;

      final messageId = payload['message_id']?.toString().trim() ?? '';
      final existingIndex = _findMessageIndexById(messageId);
      final existingMessage = existingIndex >= 0
          ? messages[existingIndex]
          : null;

      final incomingMessage = _mapSocketPayloadToMessage(
        payload,
        existing: existingMessage,
      );
      if (incomingMessage == null) return;

      if (existingIndex >= 0) {
        messages[existingIndex] = incomingMessage;
        if (incomingMessage.id.isNotEmpty) {
          _knownMessageIds.add(incomingMessage.id);
        }
        return;
      }

      if (!_isMessageForCurrentConversation(incomingMessage, payload)) return;

      if (incomingMessage.id.isNotEmpty &&
          _knownMessageIds.contains(incomingMessage.id)) {
        return;
      }

      if (incomingMessage.isSentByMe) {
        final localEchoIndex = _findRecentLocalOutgoingIndex(
          text: incomingMessage.message,
          mediaUrl: incomingMessage.mediaUrl,
          incomingTime: incomingMessage.timestamp,
        );
        if (localEchoIndex >= 0) {
          messages[localEchoIndex] = incomingMessage;
          if (incomingMessage.id.isNotEmpty) {
            _knownMessageIds.add(incomingMessage.id);
          }
          return;
        }
      }

      messages.add(incomingMessage);
      if (incomingMessage.id.isNotEmpty) {
        _knownMessageIds.add(incomingMessage.id);
      }
      scrollToBottom(force: incomingMessage.isSentByMe);
    } catch (error) {
      AppLoggerHelper.error('Customer socket payload parse failed', error);
    }
  }

  Message? _mapSocketPayloadToMessage(
    Map<String, dynamic> payload, {
    Message? existing,
  }) {
    final fromId = _normalizeString(payload['from_id']) ?? existing?.senderId;
    if (fromId == null || fromId.isEmpty) return null;

    final messageId =
        _normalizeString(payload['message_id']) ??
        _normalizeString(payload['id']) ??
        existing?.id ??
        DateTime.now().microsecondsSinceEpoch.toString();

    final action = _normalizeString(payload['action']);
    final text =
        _normalizeString(payload['text']) ??
        _normalizeString(payload['new_text']) ??
        existing?.message ??
        '';
    final mediaType =
        _normalizeString(payload['media_type']) ?? existing?.mediaType;
    final mediaUrl =
        _normalizeString(payload['media_url']) ?? existing?.mediaUrl;
    final parsedTime = DateTime.tryParse(
      payload['timestamp']?.toString() ?? '',
    );
    final timestamp = parsedTime != null
        ? _asLocalTime(parsedTime)
        : (existing?.timestamp ?? DateTime.now());
    final parsedEditedAt = DateTime.tryParse(
      payload['edited_at']?.toString() ?? '',
    );
    final editedAt = parsedEditedAt != null
        ? _asLocalTime(parsedEditedAt)
        : ((action == 'edit') ? DateTime.now() : existing?.editedAt);
    final isDeleted =
        payload['is_deleted'] == true ||
        action == 'delete' ||
        existing?.isDeleted == true;

    final reactionsRaw = payload['reactions'];
    Map<String, dynamic> reactions =
        existing?.reactions ?? const <String, dynamic>{};
    if (reactionsRaw is Map) {
      reactions = Map<String, dynamic>.from(reactionsRaw);
    } else if (action == 'react' || action == 'remove_react') {
      final reaction = _normalizeString(payload['reaction']);
      if (reaction != null) {
        final remove = action == 'remove_react';
        final isSelfReactionEvent =
            _currentUserId != null && fromId == _currentUserId;
        final shouldSkipDelta =
            isSelfReactionEvent &&
            _consumePendingReactionAck(
              messageId: messageId,
              reaction: reaction,
              remove: remove,
            );
        if (!shouldSkipDelta) {
          reactions = _applyReactionDelta(
            current: reactions,
            reaction: reaction,
            remove: remove,
          );
        }
      }
    }

    if (!isDeleted &&
        text.trim().isEmpty &&
        (mediaUrl == null || mediaUrl.isEmpty)) {
      return null;
    }

    final selfMatches = _currentUserId != null && fromId == _currentUserId;
    return Message(
      id: messageId,
      senderId: fromId,
      senderName:
          _normalizeString(payload['from_name']) ??
          existing?.senderName ??
          (selfMatches ? (_currentUserName ?? 'Me') : ''),
      senderAvatar: existing?.senderAvatar ?? '',
      message: text,
      timestamp: timestamp,
      isRead: true,
      isSentByMe: selfMatches || (existing?.isSentByMe ?? false),
      editedAt: editedAt,
      isDeleted: isDeleted,
      reactions: reactions,
      mediaType: mediaType,
      mediaUrl: mediaUrl,
      isOfflineMessage:
          payload['is_offline_message'] == true ||
          existing?.isOfflineMessage == true,
    );
  }

  bool _isMessageForCurrentConversation(
    Message message,
    Map<String, dynamic> payload,
  ) {
    final peerMatches = message.senderId == conversation.userId;
    final selfMatches =
        _currentUserId != null && message.senderId == _currentUserId;
    if (!peerMatches && !selfMatches) return false;

    final fromType = _normalizeString(payload['from_type']);
    if (fromType != null && fromType.isNotEmpty) {
      final normalizedFromType = ChatSessionApiService.normalizeToPluralWsType(
        fromType,
      );
      if (normalizedFromType != _peerTypePlural &&
          normalizedFromType != _selfTypePlural) {
        AppLoggerHelper.debug(
          'Customer chat accepted message with unexpected from_type=$fromType',
        );
      }
    }

    return true;
  }

  Map<String, dynamic> _applyReactionDelta({
    required Map<String, dynamic> current,
    required String reaction,
    required bool remove,
  }) {
    final next = Map<String, dynamic>.from(current);
    final raw = next[reaction];
    final count = raw is int
        ? raw
        : raw is num
        ? raw.toInt()
        : raw is List
        ? raw.length
        : 0;

    final updated = remove ? (count - 1) : (count + 1);
    if (updated <= 0) {
      next.remove(reaction);
    } else {
      next[reaction] = updated;
    }
    return next;
  }

  void _applyLocalReactionChange({
    required String messageId,
    required String reaction,
    required bool remove,
  }) {
    final index = _findMessageIndexById(messageId);
    if (index < 0) return;
    final updatedReactions = _applyReactionDelta(
      current: messages[index].reactions,
      reaction: reaction,
      remove: remove,
    );
    messages[index] = messages[index].copyWith(reactions: updatedReactions);
  }

  void _trackPendingReactionAck({
    required String messageId,
    required String reaction,
    required bool remove,
  }) {
    final key = _reactionAckKey(
      messageId: messageId,
      reaction: reaction,
      remove: remove,
    );
    _pendingReactionAcks[key] = (_pendingReactionAcks[key] ?? 0) + 1;
  }

  bool _consumePendingReactionAck({
    required String messageId,
    required String reaction,
    required bool remove,
  }) {
    final key = _reactionAckKey(
      messageId: messageId,
      reaction: reaction,
      remove: remove,
    );
    final count = _pendingReactionAcks[key] ?? 0;
    if (count <= 0) return false;
    if (count == 1) {
      _pendingReactionAcks.remove(key);
    } else {
      _pendingReactionAcks[key] = count - 1;
    }
    return true;
  }

  String _reactionAckKey({
    required String messageId,
    required String reaction,
    required bool remove,
  }) {
    final action = remove ? 'remove' : 'add';
    return '$messageId|$reaction|$action';
  }

  int _findMessageIndexById(String messageId) {
    if (messageId.trim().isEmpty) return -1;
    return messages.indexWhere((Message message) => message.id == messageId);
  }

  int _findRecentLocalOutgoingIndex({
    required String text,
    required String? mediaUrl,
    required DateTime incomingTime,
  }) {
    for (int i = messages.length - 1; i >= 0; i--) {
      final message = messages[i];
      if (!message.isSentByMe || !message.id.startsWith('local_')) continue;
      if (message.message.trim() != text.trim()) continue;
      if ((message.mediaUrl ?? '').trim() != (mediaUrl ?? '').trim()) continue;

      final deltaMs =
          (incomingTime.millisecondsSinceEpoch -
                  message.timestamp.millisecondsSinceEpoch)
              .abs();
      if (deltaMs <= 5000) {
        return i;
      }
    }
    return -1;
  }

  void _appendLocalOutgoingMessage({
    required String text,
    String? mediaType,
    String? mediaUrl,
  }) {
    final currentUserId = _currentUserId ?? StorageService.userId ?? 'me';
    final localMessage = Message(
      id: 'local_${DateTime.now().microsecondsSinceEpoch}',
      senderId: currentUserId,
      senderName: _currentUserName ?? 'Me',
      senderAvatar: '',
      message: text,
      timestamp: DateTime.now(),
      isRead: true,
      isSentByMe: true,
      mediaType: mediaType,
      mediaUrl: mediaUrl,
    );
    messages.add(localMessage);
    scrollToBottom(force: true);
  }

  Future<void> _loadHistory({
    required String authorization,
    required String currentUserId,
    bool autoScroll = true,
  }) async {
    final history = await _chatHistoryApiService.fetchHistory(
      authorization: authorization,
      fromType: _selfTypeSingular,
      fromId: currentUserId,
      toType: _peerTypeSingular,
      toId: conversation.userId,
      limit: 50,
    );

    if (history.isEmpty) return;

    final mapped = history.map((ChatHistoryMessage historyMessage) {
      final id = historyMessage.messageId?.trim().isNotEmpty == true
          ? historyMessage.messageId!.trim()
          : '${historyMessage.fromType}_${historyMessage.fromId}_${historyMessage.timestamp.millisecondsSinceEpoch}_${historyMessage.text.hashCode}_${historyMessage.mediaUrl.hashCode}';
      return Message(
        id: id,
        senderId: historyMessage.fromId,
        senderName: historyMessage.fromName,
        senderAvatar: '',
        message: historyMessage.text,
        timestamp: _asLocalTime(historyMessage.timestamp),
        isRead: historyMessage.isRead,
        isSentByMe: historyMessage.fromId == currentUserId,
        editedAt: historyMessage.editedAt,
        isDeleted: historyMessage.isDeleted,
        reactions: historyMessage.reactions,
        mediaType: historyMessage.mediaType,
        mediaUrl: historyMessage.mediaUrl,
        isOfflineMessage: historyMessage.isOfflineMessage,
      );
    }).toList();

    for (final Message message in mapped) {
      if (message.id.isNotEmpty) {
        _knownMessageIds.add(message.id);
      }
    }

    messages.assignAll(mapped);
    if (autoScroll) {
      scrollToBottom(force: true, animated: false);
    }
  }

  Future<void> _closeSocket() async {
    AppLoggerHelper.info('Customer websocket closing');
    await _socketSubscription?.cancel();
    _socketSubscription = null;
    await _socket?.sink.close();
    _socket = null;
    isSocketConnected.value = false;
  }

  void _endChatSession() {
    final authorization = _buildAuthorizationHeader();
    final currentUserId = _currentUserId;
    if (authorization == null || currentUserId == null) return;

    // _chatSessionApiService.endChat(
    //   authorization: authorization,
    //   fromType: 'customer',
    //   fromId: currentUserId,
    //   toType: _peerTypeSingular,
    //   toId: conversation.userId,
    // );
  }

  String? _buildAuthorizationHeader() {
    final token = StorageService.accessToken?.trim();
    if (token == null || token.isEmpty) return null;

    final type = StorageService.tokenType?.trim();
    final prefix = (type != null && type.isNotEmpty) ? type : 'Bearer';
    return '$prefix $token';
  }

  Future<String?> _resolveCurrentUserId(String authorization) async {
    final tokenSub = AuthTokenHelper.getSubjectFromJwt(
      StorageService.accessToken,
    );
    if (tokenSub != null && tokenSub.isNotEmpty) {
      await StorageService.saveUserId(tokenSub);
      return tokenSub;
    }

    final cachedId = StorageService.userId?.trim();
    if (cachedId != null && cachedId.isNotEmpty) {
      return cachedId;
    }

    final profile = await _userProfileApiService.fetchCurrentUser(
      authorization: authorization,
    );
    if (profile.id.trim().isEmpty) return null;
    _currentUserName = _normalizeString(profile.name);
    return profile.id.trim();
  }

  Future<void> _resolveCurrentUserName(String authorization) async {
    try {
      final profile = await _userProfileApiService.fetchCurrentUser(
        authorization: authorization,
      );
      final resolvedName = _normalizeString(profile.name);
      if (resolvedName != null) {
        _currentUserName = resolvedName;
      }
      if (_currentUserId == null && profile.id.trim().isNotEmpty) {
        _currentUserId = profile.id.trim();
      }
    } catch (error) {
      AppLoggerHelper.warning('Customer chat name resolve skipped: $error');
    }
  }

  String get _selfTypeSingular {
    final role = StorageService.role?.trim();
    if (role == null || role.isEmpty) return 'customer';
    return ChatSessionApiService.normalizeToSingularType(role);
  }

  String get _selfTypePlural =>
      ChatSessionApiService.normalizeToPluralWsType(_selfTypeSingular);

  String get _peerTypePlural {
    final raw = conversation.userType;
    if (raw.trim().isEmpty) return 'installers';
    return ChatSessionApiService.normalizeToPluralWsType(raw);
  }

  String get _peerTypeSingular =>
      ChatSessionApiService.normalizeToSingularType(_peerTypePlural);

  bool _isNearBottom({double threshold = 140}) {
    if (!scrollController.hasClients) return true;
    final position = scrollController.position;
    final distanceToBottom = position.maxScrollExtent - position.pixels;
    return distanceToBottom <= threshold;
  }

  void scrollToBottom({bool force = false, bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isClosed || !scrollController.hasClients) return;
      if (!force && !_isNearBottom()) return;

      final maxExtent = scrollController.position.maxScrollExtent;
      if (!animated) {
        scrollController.jumpTo(maxExtent);
        return;
      }

      final current = scrollController.position.pixels;
      if ((maxExtent - current).abs() < 2) return;
      scrollController.animateTo(
        maxExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  /// Format timestamp for display in chat bubble
  String formatMessageTime(DateTime time) {
    final localTime = _asLocalTime(time);
    final hour = localTime.hour.toString().padLeft(2, '0');
    final minute = localTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  DateTime _asLocalTime(DateTime value) {
    return value.toLocal();
  }

  String? _normalizeString(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  void _sendSocketPayload(
    Map<String, dynamic> payload, {
    required String actionName,
  }) {
    final encoded = jsonEncode(payload);
    AppLoggerHelper.debug(
      'Customer WS OUT [$actionName]: ${_summarizePayloadForLog(payload)}',
    );
    _socket!.sink.add(encoded);
  }

  String _summarizePayloadForLog(Map<String, dynamic> payload) {
    final copy = Map<String, dynamic>.from(payload);
    final mediaUrl = copy['media_url']?.toString();
    if (mediaUrl != null && mediaUrl.length > 140) {
      copy['media_url'] =
          '${mediaUrl.substring(0, 120)}...(${mediaUrl.length} chars)';
    }
    return copy.toString();
  }

  String _truncateForLog(String value) {
    if (value.length <= 300) return value;
    return '${value.substring(0, 300)}...(${value.length} chars)';
  }

  bool _handleNonMessagingSocketPayload(Map<String, dynamic> payload) {
    final errorText =
        _normalizeString(payload['error']) ??
        _normalizeString(payload['detail']);
    if (errorText != null) {
      AppLoggerHelper.warning(
        'Customer WS ERROR RESPONSE: $errorText '
        'payload=${_summarizePayloadForLog(payload)}',
      );
      Get.snackbar(
        'Message error',
        errorText,
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    }

    final payloadType = _normalizeString(payload['type'])?.toLowerCase();
    if (payloadType == 'messaging') return false;
    if (payloadType == 'control') {
      _handleControlPayload(payload);
      return true;
    }

    final status = _normalizeString(payload['status'])?.toLowerCase();
    if (status != null) {
      _handleStatusAckPayload(status: status, payload: payload);
      return true;
    }

    AppLoggerHelper.info(
      'Customer WS non-messaging payload: ${_summarizePayloadForLog(payload)}',
    );
    return true;
  }

  void _handleControlPayload(Map<String, dynamic> payload) {
    final action = _normalizeString(payload['action'])?.toLowerCase();
    if (action == null) {
      AppLoggerHelper.info(
        'Customer WS control payload missing action: '
        '${_summarizePayloadForLog(payload)}',
      );
      return;
    }

    switch (action) {
      case 'react':
      case 'remove_react':
        final messageId = _normalizeString(payload['message_id']);
        final reaction = _normalizeString(payload['reaction']);
        if (messageId == null || reaction == null) {
          unawaited(_syncHistoryAfterStatusAck('control_$action'));
          return;
        }

        final remove = action == 'remove_react';
        final actorId = _extractControlActorId(payload['user']);
        final isSelfReactionEvent =
            _currentUserId != null && actorId == _currentUserId;
        if (isSelfReactionEvent &&
            _consumePendingReactionAck(
              messageId: messageId,
              reaction: reaction,
              remove: remove,
            )) {
          return;
        }

        final index = _findMessageIndexById(messageId);
        if (index < 0) {
          unawaited(_syncHistoryAfterStatusAck('control_$action'));
          return;
        }
        _applyLocalReactionChange(
          messageId: messageId,
          reaction: reaction,
          remove: remove,
        );
        return;

      case 'edit':
        final messageId = _normalizeString(payload['message_id']);
        final newText =
            _normalizeString(payload['new_text']) ??
            _normalizeString(payload['text']);
        if (messageId == null || newText == null) {
          unawaited(_syncHistoryAfterStatusAck('control_edit'));
          return;
        }
        final editIndex = _findMessageIndexById(messageId);
        if (editIndex < 0) {
          unawaited(_syncHistoryAfterStatusAck('control_edit'));
          return;
        }
        messages[editIndex] = messages[editIndex].copyWith(
          message: newText,
          editedAt: DateTime.now(),
        );
        return;

      case 'delete':
        final messageId = _normalizeString(payload['message_id']);
        if (messageId == null) {
          unawaited(_syncHistoryAfterStatusAck('control_delete'));
          return;
        }
        final deleteIndex = _findMessageIndexById(messageId);
        if (deleteIndex < 0) {
          unawaited(_syncHistoryAfterStatusAck('control_delete'));
          return;
        }
        messages[deleteIndex] = messages[deleteIndex].copyWith(
          isDeleted: true,
          editedAt: DateTime.now(),
        );
        return;
    }

    AppLoggerHelper.info(
      'Customer WS unsupported control action=$action '
      'payload=${_summarizePayloadForLog(payload)}',
    );
  }

  String? _extractControlActorId(dynamic rawUser) {
    final value = _normalizeString(rawUser);
    if (value == null) return null;
    final parts = value.split(':');
    if (parts.isEmpty) return value;
    final last = parts.last.trim();
    return last.isEmpty ? value : last;
  }

  void _handleStatusAckPayload({
    required String status,
    required Map<String, dynamic> payload,
  }) {
    const errorStatuses = <String>{'error', 'failed', 'failure'};
    const editStatuses = <String>{'edited', 'edit', 'message_edited'};
    const deleteStatuses = <String>{'deleted', 'delete', 'message_deleted'};
    const statusesNeedingSync = <String>{
      'reacted',
      'reaction_removed',
      'removed_react',
      'unreacted',
      ...editStatuses,
      ...deleteStatuses,
      'sent',
      'message_sent',
    };

    if (errorStatuses.contains(status)) {
      final errorText =
          _normalizeString(payload['error']) ??
          _normalizeString(payload['detail']) ??
          _normalizeString(payload['message']) ??
          'Server returned status: $status';
      AppLoggerHelper.warning(
        'Customer WS status error: $errorText '
        'payload=${_summarizePayloadForLog(payload)}',
      );
      Get.snackbar(
        'Message error',
        errorText,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (editStatuses.contains(status)) {
      AppLoggerHelper.info(
        'Customer WS edit status: ${_summarizePayloadForLog(payload)}',
      );
    } else if (deleteStatuses.contains(status)) {
      AppLoggerHelper.info(
        'Customer WS delete status: ${_summarizePayloadForLog(payload)}',
      );
    } else {
      AppLoggerHelper.info(
        'Customer WS status payload: ${_summarizePayloadForLog(payload)}',
      );
    }

    if (!statusesNeedingSync.contains(status)) return;
    unawaited(_syncHistoryAfterStatusAck(status));
  }

  Future<void> _syncHistoryAfterStatusAck(String status) async {
    if (_isStatusSyncInProgress) return;

    final now = DateTime.now();
    final last = _lastStatusSyncAt;
    if (last != null && now.difference(last).inMilliseconds < 700) return;

    final authorization = _buildAuthorizationHeader();
    final currentUserId = _currentUserId ?? StorageService.userId?.trim();
    if (authorization == null ||
        currentUserId == null ||
        currentUserId.isEmpty) {
      return;
    }

    _isStatusSyncInProgress = true;
    _lastStatusSyncAt = now;
    try {
      await _loadHistory(
        authorization: authorization,
        currentUserId: currentUserId,
        autoScroll: false,
      );
    } catch (error) {
      AppLoggerHelper.warning(
        'Customer history sync skipped after status=$status: $error',
      );
    } finally {
      _isStatusSyncInProgress = false;
    }
  }

  Future<void> onCameraPressed() async {
    final selection = await _pickAttachmentSource();
    if (selection == null) return;

    final payload = await _buildAttachmentPayload(selection);
    if (payload == null) return;

    final messageText = messageController.text.trim();
    final sent = await sendSocketMessage(
      text: messageText,
      mediaType: payload.mediaType,
      mediaUrl: payload.mediaUrl,
      clearComposer: true,
    );
    if (!sent) return;
  }

  Future<_AttachmentSource?> _pickAttachmentSource() async {
    final selected = await Get.bottomSheet<String>(
      SafeArea(
        child: Material(
          color: Colors.white,
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Camera'),
                onTap: () => Get.back(result: 'camera'),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Gallery'),
                onTap: () => Get.back(result: 'gallery'),
              ),
              ListTile(
                leading: const Icon(Icons.attach_file_outlined),
                title: const Text('File'),
                onTap: () => Get.back(result: 'file'),
              ),
            ],
          ),
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );

    switch (selected) {
      case 'camera':
        return _AttachmentSource.camera;
      case 'gallery':
        return _AttachmentSource.gallery;
      case 'file':
        return _AttachmentSource.file;
      default:
        return null;
    }
  }

  Future<ChatAttachmentPayload?> _buildAttachmentPayload(
    _AttachmentSource source,
  ) async {
    switch (source) {
      case _AttachmentSource.camera:
        final picked = await _imagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: 45,
          maxWidth: 900,
          maxHeight: 900,
        );
        if (picked == null) return null;
        return _validateAttachment(
          await ChatAttachmentCodec.fromPath(path: picked.path),
        );
      case _AttachmentSource.gallery:
        final picked = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 45,
          maxWidth: 900,
          maxHeight: 900,
        );
        if (picked == null) return null;
        return _validateAttachment(
          await ChatAttachmentCodec.fromPath(path: picked.path),
        );
      case _AttachmentSource.file:
        final result = await FilePicker.platform.pickFiles(
          allowMultiple: false,
          withData: false,
          type: FileType.any,
        );
        if (result == null || result.files.isEmpty) return null;
        final file = result.files.first;
        final fileName = file.name.trim();
        if (fileName.isEmpty) return null;
        if (file.path != null) {
          return _validateAttachment(
            await ChatAttachmentCodec.fromPath(
              path: file.path!,
              fileName: fileName,
            ),
          );
        }
        Get.snackbar(
          'Attachment failed',
          'Selected file path is unavailable on this device.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return null;
    }
  }

  ChatAttachmentPayload? _validateAttachment(ChatAttachmentPayload? payload) {
    if (payload != null) return payload;
    Get.snackbar(
      'Attachment failed',
      'Select a valid file up to ${ChatAttachmentCodec.maxSizeLabel()}',
      snackPosition: SnackPosition.BOTTOM,
    );
    return null;
  }

  Future<void> refreshMessages() async {
    // Websocket is realtime; keep existing messages.
  }
}

enum _AttachmentSource { camera, gallery, file }

import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/services/communications/chat_partner_api_service.dart';
import 'package:outdoorda_flutter/core/services/communications/chat_session_api_service.dart';
import 'package:outdoorda_flutter/core/services/storage_service.dart';
import 'package:outdoorda_flutter/core/services/user_profile_api_service.dart';
import 'package:outdoorda_flutter/core/utils/helpers/auth_token_helper.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/features/installer_section/message_section/models/message.dart';
import 'package:outdoorda_flutter/routes/app_routes.dart';

/// Controller for managing message list screen
/// Handles conversation list, loading states, and navigation
class InstallerMessageListController extends GetxController {
  final ChatPartnerApiService _chatPartnerApiService = ChatPartnerApiService();
  final UserProfileApiService _userProfileApiService = UserProfileApiService();

  final RxList<Conversation> conversations = <Conversation>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadConversations();
  }

  Future<void> loadConversations() async {
    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      AppLoggerHelper.warning('Installer chat list: missing authorization');
      conversations.clear();
      return;
    }

    final currentUserId = await _resolveCurrentUserId(authorization);
    if (currentUserId == null || currentUserId.isEmpty) {
      AppLoggerHelper.warning('Installer chat list: missing current user id');
      conversations.clear();
      return;
    }

    try {
      isLoading.value = true;

      final partners = await _chatPartnerApiService.fetchPartners(
        authorization: authorization,
        userType: 'installer',
        userId: currentUserId,
      );

      final mapped =
          partners
              .where((ChatPartner partner) {
                final partnerType =
                    ChatSessionApiService.normalizeToSingularType(partner.type);
                return !(partnerType == 'installer' &&
                    partner.id == currentUserId);
              })
              .map((ChatPartner partner) {
                final normalizedType =
                    ChatSessionApiService.normalizeToSingularType(partner.type);
                final timestamp = partner.lastMessageAt ?? DateTime.now();
                return Conversation(
                  id: '${normalizedType}_${partner.id}',
                  userId: partner.id,
                  userName: partner.userName,
                  userAvatar: '',
                  userType: normalizedType,
                  lastMessage: 'Tap to chat',
                  lastMessageTime: timestamp,
                  unreadCount: 0,
                );
              })
              .toList()
            ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

      conversations.assignAll(mapped);
    } catch (error) {
      AppLoggerHelper.error('Installer chat list load failed', error);
      conversations.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigate to messaging screen for specific conversation
  void openConversation(Conversation conversation) {
    Get.toNamed(
      AppRoute.getInstallerConversationScreen(),
      arguments: conversation,
    );
  }

  /// Mark conversation as read (clear unread count)
  void markAsRead(String conversationId) {
    final index = conversations.indexWhere((conv) => conv.id == conversationId);
    if (index != -1) {
      conversations[index] = conversations[index].copyWith(unreadCount: 0);
    }
  }

  /// Format time for display in conversation list
  String formatTime(DateTime time) {
    final localTime = time.toLocal();
    final now = DateTime.now();
    final difference = now.difference(localTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${localTime.day}/${localTime.month}/${localTime.year}';
    }
  }

  /// Refresh conversations list
  Future<void> refreshConversations() async {
    await loadConversations();
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

    try {
      final profile = await _userProfileApiService.fetchCurrentUser(
        authorization: authorization,
      );
      return profile.id.trim().isEmpty ? null : profile.id.trim();
    } catch (error) {
      AppLoggerHelper.warning(
        'Installer chat list user id resolve failed: $error',
      );
      return null;
    }
  }
}

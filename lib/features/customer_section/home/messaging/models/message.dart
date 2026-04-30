/// Model class for chat messages in the messaging system
/// Represents a single message in a conversation
class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final bool isSentByMe;
  final DateTime? editedAt;
  final bool isDeleted;
  final Map<String, dynamic> reactions;
  final String? mediaType;
  final String? mediaUrl;
  final bool isOfflineMessage;

  const Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.isSentByMe = false,
    this.editedAt,
    this.isDeleted = false,
    this.reactions = const <String, dynamic>{},
    this.mediaType,
    this.mediaUrl,
    this.isOfflineMessage = false,
  });

  /// Creates Message from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    final reactionsRaw = json['reactions'];
    return Message(
      id: json['message_id']?.toString() ?? json['id']?.toString() ?? '',
      senderId:
          json['from_id']?.toString() ?? json['senderId']?.toString() ?? '',
      senderName:
          json['from_name']?.toString() ?? json['senderName']?.toString() ?? '',
      senderAvatar: json['senderAvatar']?.toString() ?? '',
      message: json['text']?.toString() ?? json['message']?.toString() ?? '',
      timestamp: json['timestamp'] != null
          ? _asLocalTime(DateTime.parse(json['timestamp']))
          : DateTime.now(),
      isRead: json['is_read'] == true || json['isRead'] == true,
      isSentByMe: json['isSentByMe'] == true,
      editedAt: json['edited_at'] != null
          ? _asLocalTime(DateTime.parse(json['edited_at'].toString()))
          : null,
      isDeleted: json['is_deleted'] == true || json['isDeleted'] == true,
      reactions: reactionsRaw is Map
          ? Map<String, dynamic>.from(reactionsRaw)
          : const <String, dynamic>{},
      mediaType:
          json['media_type']?.toString() ?? json['mediaType']?.toString(),
      mediaUrl: json['media_url']?.toString() ?? json['mediaUrl']?.toString(),
      isOfflineMessage:
          json['is_offline_message'] == true ||
          json['isOfflineMessage'] == true,
    );
  }

  /// Converts Message to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'isSentByMe': isSentByMe,
      'edited_at': editedAt?.toIso8601String(),
      'is_deleted': isDeleted,
      'reactions': reactions,
      'media_type': mediaType,
      'media_url': mediaUrl,
      'is_offline_message': isOfflineMessage,
    };
  }

  /// Creates a copy of Message with updated fields
  Message copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    bool? isSentByMe,
    DateTime? editedAt,
    bool? isDeleted,
    Map<String, dynamic>? reactions,
    String? mediaType,
    String? mediaUrl,
    bool? isOfflineMessage,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isSentByMe: isSentByMe ?? this.isSentByMe,
      editedAt: editedAt ?? this.editedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      reactions: reactions ?? this.reactions,
      mediaType: mediaType ?? this.mediaType,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      isOfflineMessage: isOfflineMessage ?? this.isOfflineMessage,
    );
  }
}

/// Model class for conversation in the message list
/// Represents a chat conversation with another user
class Conversation {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String userType;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  const Conversation({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    this.userType = '',
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });

  /// Creates Conversation from JSON
  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      userAvatar: json['userAvatar']?.toString() ?? '',
      userType: json['userType']?.toString() ?? '',
      lastMessage: json['lastMessage']?.toString() ?? '',
      lastMessageTime: json['lastMessageTime'] != null
          ? _asLocalTime(DateTime.parse(json['lastMessageTime']))
          : DateTime.now(),
      unreadCount: json['unreadCount'] ?? 0,
    );
  }

  /// Converts Conversation to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'userType': userType,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'unreadCount': unreadCount,
    };
  }

  /// Creates a copy of Conversation with updated fields
  Conversation copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? userType,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
  }) {
    return Conversation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      userType: userType ?? this.userType,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

DateTime _asLocalTime(DateTime value) {
  return value.toLocal();
}

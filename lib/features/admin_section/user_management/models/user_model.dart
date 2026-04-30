import 'package:intl/intl.dart';

/// Model class for user management in admin section
/// Represents both installer and customer users
class UserModel {
  final String id;
  final String name;
  final String address;
  final String joinedDate;
  final String profileImageUrl;
  final bool isSuspended;
  final String userType; // 'installer' or 'customer'

  const UserModel({
    required this.id,
    required this.name,
    required this.address,
    required this.joinedDate,
    required this.profileImageUrl,
    this.isSuspended = false,
    required this.userType,
  });

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final roleRaw = (json['role'] ?? json['user_type'] ?? '').toString();
    final roleLower = roleRaw.toLowerCase();
    final normalizedRole = roleLower == 'installer'
        ? 'installer'
        : (roleLower == 'customer' ? 'customer' : 'other');

    final email = json['email']?.toString() ?? '';
    final phone = json['phone']?.toString();
    final phoneText = (phone != null && phone.isNotEmpty) ? ' • $phone' : '';
    final fallbackAddress = '$email$phoneText';

    final joinedDateRaw =
        json['created_at']?.toString() ?? json['joined_date']?.toString() ?? '';

    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? fallbackAddress,
      joinedDate: _formatJoinedDate(joinedDateRaw),
      profileImageUrl:
          json['photo']?.toString() ??
          json['profile_image_url']?.toString() ??
          '',
      isSuspended: json.containsKey('is_active')
          ? json['is_active'] != true
          : (json['is_suspended'] as bool? ?? false),
      userType: normalizedRole,
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'joined_date': joinedDate,
      'profile_image_url': profileImageUrl,
      'is_suspended': isSuspended,
      'user_type': userType,
    };
  }

  static String _formatJoinedDate(String dateTimeText) {
    if (dateTimeText.trim().isEmpty) return '-';
    final parsed = DateTime.tryParse(dateTimeText);
    if (parsed == null) return dateTimeText;
    return DateFormat('dd/MM/yyyy').format(parsed);
  }

  /// Create a copy with modified fields
  UserModel copyWith({
    String? id,
    String? name,
    String? address,
    String? joinedDate,
    String? profileImageUrl,
    bool? isSuspended,
    String? userType,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      joinedDate: joinedDate ?? this.joinedDate,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isSuspended: isSuspended ?? this.isSuspended,
      userType: userType ?? this.userType,
    );
  }
}

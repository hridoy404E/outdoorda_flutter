class UserProfile {
  final String id;
  final String email;
  final String phone;
  final String name;
  final String photo;
  final String role;
  final bool isActive;
  final bool isStaff;
  final bool twoFactorEnabled;
  final bool isSuspended;
  final double totalEarnings;
  final double payableCommissionAmount;
  final String createdAt;
  final String updatedAt;

  const UserProfile({
    required this.id,
    required this.email,
    required this.phone,
    required this.name,
    required this.photo,
    required this.role,
    required this.isActive,
    required this.isStaff,
    required this.twoFactorEnabled,
    required this.isSuspended,
    required this.totalEarnings,
    required this.payableCommissionAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      photo: json['photo']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      isActive: json['is_active'] == true,
      isStaff: json['is_staff'] == true,
      twoFactorEnabled: json['two_factor_enabled'] == true,
      isSuspended: json['is_suspended'] == true,
      totalEarnings: _toDouble(json['total_earnings']),
      payableCommissionAmount: _toDouble(json['payable_commission_amount']),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

import 'package:outdoorda_flutter/features/admin_section/user_management/models/user_model.dart';

class UserListResponse {
  final int total;
  final int offset;
  final int limit;
  final int count;
  final List<UserModel> results;

  const UserListResponse({
    required this.total,
    required this.offset,
    required this.limit,
    required this.count,
    required this.results,
  });

  factory UserListResponse.fromJson(Map<String, dynamic> json) {
    final items = (json['results'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(UserModel.fromJson)
        .toList();

    return UserListResponse(
      total: _parseInt(json['total']),
      offset: _parseInt(json['offset']),
      limit: _parseInt(json['limit']),
      count: _parseInt(json['count'], fallback: items.length),
      results: items,
    );
  }

  static int _parseInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}

class InstallerAvailability {
  final String id;
  final String installerId;
  final bool isAvailable;
  final int activeHoursPerWeek;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const InstallerAvailability({
    required this.id,
    required this.installerId,
    required this.isAvailable,
    required this.activeHoursPerWeek,
    this.createdAt,
    this.updatedAt,
  });

  factory InstallerAvailability.fromJson(Map<String, dynamic> json) {
    return InstallerAvailability(
      id: json['id']?.toString() ?? '',
      installerId: json['installer_id']?.toString() ?? '',
      isAvailable: _parseBool(json['is_available']) ?? true,
      activeHoursPerWeek:
          _parseInt(
            json['active_hourse_par_week'] ??
                json['active_hours_per_week'] ??
                json['week_hours'],
          ) ??
          0,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  static bool? _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value == null) return null;
    final cleaned = value.toString().trim().toLowerCase();
    if (cleaned == 'true') return true;
    if (cleaned == 'false') return false;
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  static DateTime? _parseDate(dynamic value) {
    final text = value?.toString();
    if (text == null || text.trim().isEmpty) return null;
    return DateTime.tryParse(text);
  }
}

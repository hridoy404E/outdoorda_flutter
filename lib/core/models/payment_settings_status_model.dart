class PaymentSettingsStatusModel {
  const PaymentSettingsStatusModel({
    required this.id,
    required this.updatedAt,
    required this.status,
  });

  final int? id;
  final String updatedAt;
  final bool status;

  factory PaymentSettingsStatusModel.fromJson(Map<String, dynamic> json) {
    return PaymentSettingsStatusModel(
      id: _parseInt(json['id']),
      updatedAt: json['updated_at']?.toString().trim() ?? '',
      status: _parseBool(json['status']),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;

    final normalized = value?.toString().trim().toLowerCase();
    return normalized == 'true';
  }
}

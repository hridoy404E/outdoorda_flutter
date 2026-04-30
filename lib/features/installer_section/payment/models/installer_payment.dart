class InstallerPayment {
  final double amount;
  final String status;
  final String id;
  final String paymentType;
  final DateTime? createdAt;
  final String installerId;
  final String stripePaymentIntentId;

  const InstallerPayment({
    required this.amount,
    required this.status,
    required this.id,
    required this.paymentType,
    required this.createdAt,
    required this.installerId,
    required this.stripePaymentIntentId,
  });

  factory InstallerPayment.fromJson(Map<String, dynamic> json) {
    return InstallerPayment(
      amount: _toDouble(json['amount']),
      status: json['status']?.toString() ?? '',
      id: json['id']?.toString() ?? '',
      paymentType: json['payment_type']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      installerId: json['installer_id']?.toString() ?? '',
      stripePaymentIntentId: json['stripe_payment_intent_id']?.toString() ?? '',
    );
  }

  String get statusLabel => _titleCase(status);
  String get paymentTypeLabel => _titleCase(paymentType);

  bool get isSucceeded => status.trim().toLowerCase() == 'succeeded';
  bool get isPending => status.trim().toLowerCase() == 'pending';

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _titleCase(String value) {
    final cleaned = value.trim().replaceAll('_', ' ');
    if (cleaned.isEmpty) return 'N/A';

    return cleaned
        .split(RegExp(r'\s+'))
        .map((part) {
          if (part.isEmpty) return part;
          return '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}';
        })
        .join(' ');
  }
}

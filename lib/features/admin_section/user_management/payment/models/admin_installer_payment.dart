class AdminInstallerPayment {
  final double amount;
  final String status;
  final String id;
  final String paymentType;
  final DateTime? createdAt;
  final String installerId;
  final String stripePaymentIntentId;

  const AdminInstallerPayment({
    required this.amount,
    required this.status,
    required this.id,
    required this.paymentType,
    required this.createdAt,
    required this.installerId,
    required this.stripePaymentIntentId,
  });

  factory AdminInstallerPayment.fromJson(Map<String, dynamic> json) {
    return AdminInstallerPayment(
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

  bool get isPending => status.trim().toLowerCase() == 'pending';
  bool get isSucceeded {
    final normalized = status.trim().toLowerCase();
    return normalized == 'succeeded' ||
        normalized == 'success' ||
        normalized == 'paid' ||
        normalized == 'received';
  }

  bool get isRejected {
    final normalized = status.trim().toLowerCase().replaceAll('_', ' ');
    return normalized == 'rejected' ||
        normalized == 'reject' ||
        normalized == 'not received';
  }

  bool get isFailed {
    final normalized = status.trim().toLowerCase();
    return normalized == 'failed' || normalized == 'faild';
  }

  AdminInstallerPayment copyWith({String? status}) {
    return AdminInstallerPayment(
      amount: amount,
      status: status ?? this.status,
      id: id,
      paymentType: paymentType,
      createdAt: createdAt,
      installerId: installerId,
      stripePaymentIntentId: stripePaymentIntentId,
    );
  }

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

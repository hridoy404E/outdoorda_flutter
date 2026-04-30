class InstallerEarningsSummary {
  final String installerId;
  final int inProgressCount;
  final int completedCount;
  final double earnings;
  final double commission;

  const InstallerEarningsSummary({
    required this.installerId,
    required this.inProgressCount,
    required this.completedCount,
    required this.earnings,
    required this.commission,
  });

  factory InstallerEarningsSummary.fromJson(Map<String, dynamic> json) {
    return InstallerEarningsSummary(
      installerId: json['installer_id']?.toString() ?? '',
      inProgressCount: (json['in_progress_count'] as num?)?.toInt() ?? 0,
      completedCount: (json['completed_count'] as num?)?.toInt() ?? 0,
      earnings: (json['earnings'] as num?)?.toDouble() ?? 0.0,
      commission:
          (json['commision'] as num?)?.toDouble() ??
          (json['commission'] as num?)?.toDouble() ??
          0.0,
    );
  }
}

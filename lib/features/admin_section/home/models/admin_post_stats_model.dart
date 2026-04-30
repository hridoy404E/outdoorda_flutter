class AdminPostStatsModel {
  final int newJobCount;
  final int pendingBidCount;
  final int installerAssignedCount;
  final int deuCount;

  const AdminPostStatsModel({
    required this.newJobCount,
    required this.pendingBidCount,
    required this.installerAssignedCount,
    required this.deuCount,
  });

  factory AdminPostStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminPostStatsModel(
      newJobCount: _toInt(json['new_job_count']),
      pendingBidCount: _toInt(json['pending_bid_count']),
      installerAssignedCount: _toInt(json['installer_assigned_count']),
      deuCount: _toInt(json['deu_count']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

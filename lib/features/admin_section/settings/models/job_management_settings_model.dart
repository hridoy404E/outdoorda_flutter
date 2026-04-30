class JobManagementSettingsModel {
  final int id;
  final int jobTimeoutHours;
  final bool autoAssignJob;

  const JobManagementSettingsModel({
    required this.id,
    required this.jobTimeoutHours,
    required this.autoAssignJob,
  });

  factory JobManagementSettingsModel.fromJson(Map<String, dynamic> json) {
    return JobManagementSettingsModel(
      id: _toInt(json['id']),
      jobTimeoutHours: _toInt(json['job_timeout_hours']),
      autoAssignJob: _toBool(json['auto_assign_job']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    final text = value?.toString().trim().toLowerCase() ?? '';
    return text == 'true' || text == '1' || text == 'yes';
  }
}

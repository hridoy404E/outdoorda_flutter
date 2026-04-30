import 'package:outdoorda_flutter/features/installer_section/management/models/management_job.dart';

/// Grouped installer posts response from API.
class InstallerManagementPosts {
  const InstallerManagementPosts({
    required this.newPosts,
    required this.assignedPosts,
  });

  final List<ManagementJob> newPosts;
  final List<ManagementJob> assignedPosts;
}

import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/services/storage_service.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/features/admin_section/home/models/activity_model.dart';
import 'package:outdoorda_flutter/features/admin_section/home/services/admin_post_stats_api_service.dart';
import 'package:outdoorda_flutter/features/admin_section/home/services/admin_recent_activity_api_service.dart';
import 'package:outdoorda_flutter/features/admin_section/home/views/screens/create_new_job.dart';
import 'package:outdoorda_flutter/features/admin_section/home/views/screens/create_service_area_screen.dart';
import 'package:outdoorda_flutter/features/admin_section/job_management/controllers/job_management_controller.dart';
import 'package:outdoorda_flutter/features/admin_section/job_management/services/admin_job_api_service.dart';
import 'package:outdoorda_flutter/features/global_section/bottom_navbar/controllers/bottom_navbar_controller.dart';
import 'package:outdoorda_flutter/features/installer_section/management/models/management_job.dart';
import 'package:outdoorda_flutter/routes/app_routes.dart';

/// Controller for Admin Home Screen
/// Manages KPI metrics, recent jobs, and activity feed
class AdminHomeController extends GetxController {
  final AdminJobApiService _adminJobApiService = AdminJobApiService();
  final AdminPostStatsApiService _adminPostStatsApiService =
      AdminPostStatsApiService();
  final AdminRecentActivityApiService _adminRecentActivityApiService =
      AdminRecentActivityApiService();

  // KPI Metrics
  final RxInt newJobOffers = 0.obs;
  final RxInt bidsPending = 0.obs;
  final RxInt jobsAssigned = 0.obs;
  final RxInt followUpsDue = 0.obs;

  // Recent Jobs (initially show 3)
  final RxList<ManagementJob> recentJobs = <ManagementJob>[].obs;
  final RxList<ManagementJob> allJobs = <ManagementJob>[].obs;

  // Recent Activity
  final RxList<Activity> recentActivities = <Activity>[].obs;

  // Loading state
  final RxBool isLoading = false.obs;

  // Welcome card visibility state
  final RxBool isWelcomeCardVisible = true.obs;

  @override
  void onInit() {
    super.onInit();
    refreshDashboardData(showLoader: true);
  }

  /// Load/refresh all dashboard data
  Future<void> refreshDashboardData({bool showLoader = false}) async {
    try {
      if (showLoader) {
        isLoading.value = true;
      }
      AppLoggerHelper.info('Refreshing admin dashboard data');

      await _loadPostStats();
      await _loadRecentJobs();
      await _loadRecentActivities();

      AppLoggerHelper.info('Admin dashboard data refreshed successfully');
    } catch (error) {
      AppLoggerHelper.error('Error refreshing admin dashboard data', error);
    } finally {
      if (showLoader) {
        isLoading.value = false;
      }
    }
  }

  /// Navigate to job details
  void onJobTap(ManagementJob job) {
    AppLoggerHelper.info('Navigating to job details: ${job.jobNumber}');
    Get.toNamed(AppRoute.getAdminManagementDetailsScreen(), arguments: job);
  }

  /// Navigate to create new job screen
  Future<void> onCreateNewJobTap() async {
    AppLoggerHelper.info('Create new job tapped');
    final shouldRefresh = await Get.bottomSheet<bool>(
      const CreateNewJobBottomSheet(),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
    );
    if (shouldRefresh == true) {
      await refreshDashboardData();
    }
  }

  /// Navigate to create service area screen
  void onCreateServiceAreaTap() {
    AppLoggerHelper.info('Create service area tapped');
    Get.to(() => const CreateServiceAreaScreen());
  }

  /// Navigate to Job Management screen (bottomNavBar index 2)
  void onViewAllTap() {
    try {
      final jobManagementController = Get.find<JobManagementController>();
      jobManagementController.loadInitialJobs();

      AppLoggerHelper.info('View All tapped - navigating to Job Management');
      final bottomNavController = Get.find<BottomNavbarController>();
      bottomNavController.changeTab(2);
    } catch (error) {
      AppLoggerHelper.error('Failed to navigate to Job Management', error);
    }
  }

  Future<void> _loadRecentJobs() async {
    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      AppLoggerHelper.warning('Admin recent jobs request missing token');
      recentJobs.clear();
      allJobs.clear();
      return;
    }

    try {
      final jobs = await _adminJobApiService.fetchRecentJobs(
        authorization: authorization,
        offset: 0,
        limit: 3,
      );

      recentJobs.assignAll(jobs);
      allJobs.assignAll(jobs);
    } catch (error) {
      AppLoggerHelper.error('Failed to load admin recent jobs', error);
      recentJobs.clear();
      allJobs.clear();
    }
  }

  Future<void> _loadPostStats() async {
    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      AppLoggerHelper.warning('Admin post stats request missing token');
      newJobOffers.value = 0;
      bidsPending.value = 0;
      jobsAssigned.value = 0;
      followUpsDue.value = 0;
      return;
    }

    try {
      final stats = await _adminPostStatsApiService.fetchPostStats(
        authorization: authorization,
      );
      newJobOffers.value = stats.newJobCount;
      bidsPending.value = stats.pendingBidCount;
      jobsAssigned.value = stats.installerAssignedCount;
      followUpsDue.value = stats.deuCount;
    } catch (error) {
      AppLoggerHelper.error('Failed to load admin post stats', error);
      newJobOffers.value = 0;
      bidsPending.value = 0;
      jobsAssigned.value = 0;
      followUpsDue.value = 0;
    }
  }

  Future<void> _loadRecentActivities() async {
    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      AppLoggerHelper.warning('Admin recent activity request missing token');
      recentActivities.clear();
      return;
    }

    try {
      final activities = await _adminRecentActivityApiService
          .fetchRecentActivities(
            authorization: authorization,
            offset: 0,
            limit: 10,
          );
      recentActivities.assignAll(activities);
    } catch (error) {
      AppLoggerHelper.error('Failed to load admin recent activities', error);
      recentActivities.clear();
    }
  }

  String? _buildAuthorizationHeader() {
    final token = StorageService.accessToken;
    if (token == null || token.isEmpty) return null;

    final type = StorageService.tokenType?.trim();
    final prefix = (type != null && type.isNotEmpty) ? type : 'Bearer';
    return '$prefix $token';
  }
}

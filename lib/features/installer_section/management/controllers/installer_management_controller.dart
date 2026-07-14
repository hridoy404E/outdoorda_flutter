import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/services/storage_service.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/features/installer_section/management/models/management_job.dart';
import 'package:outdoorda_flutter/features/installer_section/management/services/installer_management_api_service.dart';
import 'package:outdoorda_flutter/routes/app_routes.dart';

enum InstallerPostTab { newPosts, assignedPosts }

/// Controller for installer management screen
/// Manages job list and monthly statistics
class InstallerManagementController extends GetxController {
  final InstallerManagementApiService _installerManagementApiService =
      InstallerManagementApiService();

  final RxList<ManagementJob> newPosts = <ManagementJob>[].obs;
  final RxList<ManagementJob> assignedPosts = <ManagementJob>[].obs;
  final Rx<InstallerPostTab> selectedTab = InstallerPostTab.newPosts.obs;

  // Loading state
  final RxBool isLoading = false.obs;
  final RxBool isEarningsLoading = true.obs;
  final RxString loadJobsError = ''.obs;

  // Balance visibility toggle (shared across the screen)
  final RxBool isBalanceVisible = true.obs;

  // Monthly statistics
  final RxInt completedCount = 0.obs;
  final RxInt inProgressCount = 0.obs;
  final RxDouble totalEarned = 0.0.obs;
  final RxDouble totalCommission = 0.0.obs;

  static const double commissionRate = 0.20;

  double get calculatedCommission => totalEarned.value * commissionRate;

  double get myBalance {
    return (totalEarned.value - calculatedCommission)
        .clamp(0.0, double.infinity)
        .toDouble();
  }

  List<ManagementJob> get visibleJobs =>
      selectedTab.value == InstallerPostTab.newPosts ? newPosts : assignedPosts;

  @override
  void onInit() {
    super.onInit();
    _loadInstallerPosts();
    _loadMonthlyEarningsSummary();
  }

  Future<void> _loadMonthlyEarningsSummary() async {
    isEarningsLoading.value = true;

    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      AppLoggerHelper.warning(
        'Installer earnings request missing authorization token',
      );
      _resetMonthlyStats();
      isEarningsLoading.value = false;
      return;
    }

    try {
      final earningsSummary = await _installerManagementApiService
          .fetchMonthlyEarningsSummary(authorization: authorization);

      completedCount.value = earningsSummary.completedCount;
      inProgressCount.value = earningsSummary.inProgressCount;
      totalEarned.value = earningsSummary.earnings;
      totalCommission.value = earningsSummary.commission;
    } catch (error) {
      AppLoggerHelper.error('Failed to load monthly earnings summary', error);
      _resetMonthlyStats();
    } finally {
      isEarningsLoading.value = false;
    }
  }

  Future<void> _loadInstallerPosts() async {
    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      AppLoggerHelper.warning('Installer posts request missing token');
      loadJobsError.value = 'Authorization missing. Please log in again.';
      newPosts.clear();
      assignedPosts.clear();
      return;
    }

    isLoading.value = true;
    try {
      final groupedPosts = await _installerManagementApiService
          .fetchInstallerPosts(authorization: authorization);

      newPosts.assignAll(_sortByLatest(groupedPosts.newPosts));
      assignedPosts.assignAll(_sortByLatest(groupedPosts.assignedPosts));
      loadJobsError.value = '';

      AppLoggerHelper.info(
        'Loaded installer posts: new=${newPosts.length}, assigned=${assignedPosts.length}',
      );
    } catch (error) {
      AppLoggerHelper.error('Failed to load installer posts', error);
      loadJobsError.value = 'Failed to load jobs';
      newPosts.clear();
      assignedPosts.clear();
    } finally {
      isLoading.value = false;
    }
  }

  List<ManagementJob> _sortByLatest(List<ManagementJob> jobs) {
    final sorted = [...jobs];
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  void selectTab(InstallerPostTab tab) {
    if (selectedTab.value == tab) return;
    selectedTab.value = tab;
  }

  /// Navigate to management details screen
  Future<void> navigateToDetails(ManagementJob job) async {
    try {
      AppLoggerHelper.info('Navigating to details for job: ${job.jobNumber}');
      final result = await Get.toNamed(
        AppRoute.getManagementDetailsScreen(),
        arguments: job,
      );

      if (result != null) {
        if (result == true) {
          selectTab(InstallerPostTab.assignedPosts);
        }
        await refreshJobs();
      }
    } catch (error) {
      AppLoggerHelper.error('Navigation to details failed', error);
    }
  }

  String? _buildAuthorizationHeader() {
    final token = StorageService.accessToken;
    if (token == null || token.isEmpty) return null;

    final type = StorageService.tokenType?.trim();
    final prefix = (type != null && type.isNotEmpty) ? type : 'Bearer';
    return '$prefix $token';
  }

  void _resetMonthlyStats() {
    completedCount.value = 0;
    inProgressCount.value = 0;
    totalEarned.value = 0.0;
    totalCommission.value = 0.0;
  }

  /// Refresh job list
  Future<void> refreshJobs() async {
    try {
      await Future.wait([_loadInstallerPosts(), _loadMonthlyEarningsSummary()]);
    } catch (error) {
      AppLoggerHelper.error('Failed to refresh jobs', error);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/services/storage_service.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/features/admin_section/job_management/services/admin_job_api_service.dart';
import 'package:outdoorda_flutter/features/installer_section/management/models/management_job.dart';
import 'package:outdoorda_flutter/routes/app_routes.dart';

/// Controller for job management screen
/// Manages admin jobs list with offset-based pagination
class JobManagementController extends GetxController {
  static const int _pageSize = 10;

  final AdminJobApiService _adminJobApiService = AdminJobApiService();

  final RxList<ManagementJob> jobs = <ManagementJob>[].obs;
  final RxList<ManagementJob> allJobs = <ManagementJob>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreJobs = true.obs;
  final RxString loadJobsError = ''.obs;

  final Rxn<JobStatus> selectedFilter = Rxn<JobStatus>();

  final ScrollController scrollController = ScrollController();
  int _offset = 0;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    loadInitialJobs();
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  /// Initial list load for "See All" jobs screen
  Future<void> loadInitialJobs() async {
    _offset = 0;
    hasMoreJobs.value = true;
    loadJobsError.value = '';
    selectedFilter.value = null;
    allJobs.clear();
    jobs.clear();
    await _fetchJobsPage(isInitialLoad: true);
  }

  Future<void> loadMoreJobs() async {
    if (isLoading.value || isLoadingMore.value || !hasMoreJobs.value) return;
    await _fetchJobsPage(isInitialLoad: false);
  }

  Future<void> _fetchJobsPage({required bool isInitialLoad}) async {
    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      loadJobsError.value = 'Authorization missing. Please log in again.';
      hasMoreJobs.value = false;
      return;
    }

    try {
      if (isInitialLoad) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }

      final fetched = await _adminJobApiService.fetchRecentJobs(
        authorization: authorization,
        offset: _offset,
        limit: _pageSize,
      );

      if (isInitialLoad) {
        allJobs.assignAll(fetched);
      } else {
        for (final job in fetched) {
          final exists = allJobs.any((existing) => existing.id == job.id);
          if (!exists) {
            allJobs.add(job);
          }
        }
      }

      _offset += fetched.length;
      hasMoreJobs.value = fetched.length == _pageSize;
      loadJobsError.value = '';
      _applyCurrentFilter();

      AppLoggerHelper.info(
        'Admin jobs loaded: fetched=${fetched.length}, '
        'totalLoaded=${allJobs.length}, hasMore=${hasMoreJobs.value}',
      );
    } catch (error) {
      AppLoggerHelper.error('Failed to load admin jobs', error);
      loadJobsError.value = 'Failed to load jobs';
    } finally {
      if (isInitialLoad) {
        isLoading.value = false;
      } else {
        isLoadingMore.value = false;
      }
    }
  }

  /// Remove a job from local lists by ID
  void removeJobById(String postId) {
    allJobs.removeWhere((j) => j.id == postId);
    jobs.removeWhere((j) => j.id == postId);
  }

  /// Delete a post with confirmation dialog
  Future<void> deleteJob(ManagementJob job) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Post'),
        content: Text(
          'Are you sure you want to delete post ${job.jobNumber}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    if (confirmed != true) return;

    await deleteJobOnSwipe(job);
  }

  /// Execute job deletion after swipe confirmation
  Future<bool> deleteJobOnSwipe(ManagementJob job) async {
    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      EasyLoading.showError('Authorization missing. Please log in again.');
      return false;
    }

    try {
      EasyLoading.show(status: 'Deleting post...');
      await _adminJobApiService.deletePost(
        authorization: authorization,
        postId: job.id,
      );

      removeJobById(job.id);
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Post deleted successfully');
      AppLoggerHelper.info('Admin post deleted on swipe: ${job.id}');
      return true;
    } catch (error) {
      AppLoggerHelper.error('Failed to delete post ${job.id}', error);
      EasyLoading.dismiss();
      EasyLoading.showError('Failed to delete post');
      return false;
    }
  }

  /// Navigate to management details screen
  void navigateToDetails(ManagementJob job) {
    try {
      AppLoggerHelper.info('Navigating to details for job: ${job.jobNumber}');
      Get.toNamed(AppRoute.getAdminManagementDetailsScreen(), arguments: job);
    } catch (error) {
      AppLoggerHelper.error('Navigation to details failed', error);
    }
  }

  /// Filter jobs by status
  void filterJobs(JobStatus? status) {
    selectedFilter.value = status;
    _applyCurrentFilter();

    AppLoggerHelper.info(
      status == null
          ? 'Admin job filter cleared'
          : 'Admin job filter: ${status.displayName}',
    );
  }

  void _applyCurrentFilter() {
    final status = selectedFilter.value;

    if (status == null) {
      jobs.assignAll(allJobs);
      return;
    }

    jobs.assignAll(allJobs.where((job) => job.status == status).toList());
  }

  /// Pull to refresh list
  Future<void> refreshJobs() async {
    await loadInitialJobs();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final position = scrollController.position;
    if (position.maxScrollExtent <= 0) return;

    // Start loading next page around mid-scroll of current content.
    if (position.pixels >= position.maxScrollExtent * 0.5) {
      loadMoreJobs();
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

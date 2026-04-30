import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/services/storage_service.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/features/global_section/bottom_navbar/controllers/bottom_navbar_controller.dart';
import 'package:outdoorda_flutter/features/installer_section/management/controllers/installer_management_controller.dart';
import 'package:outdoorda_flutter/features/installer_section/management/models/management_job.dart';
import 'package:outdoorda_flutter/features/installer_section/management/services/installer_management_api_service.dart';

class InstallerAdminPostsController extends GetxController {
  final InstallerManagementApiService _installerManagementApiService =
      InstallerManagementApiService();

  final RxList<ManagementJob> jobs = <ManagementJob>[].obs;
  final RxBool isLoading = false.obs;
  final RxString loadJobsError = ''.obs;
  final RxString acceptingPostId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAdminPosts();
  }

  Future<void> loadAdminPosts() async {
    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      loadJobsError.value = 'Authorization missing. Please log in again.';
      jobs.clear();
      return;
    }

    isLoading.value = true;
    try {
      final fetched = await _installerManagementApiService
          .fetchAdminAssignedPosts(authorization: authorization);

      final sorted = [...fetched]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      jobs.assignAll(sorted);
      loadJobsError.value = '';

      AppLoggerHelper.info('Loaded admin posts for installer: ${jobs.length}');
    } catch (error) {
      AppLoggerHelper.error('Failed to load admin posts for installer', error);
      loadJobsError.value = _extractExceptionMessage(error);
      jobs.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> acceptJob(ManagementJob job) async {
    if (acceptingPostId.value.isNotEmpty) return;

    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      EasyLoading.showError('Authorization missing. Please log in again.');
      return;
    }

    try {
      acceptingPostId.value = job.id;
      EasyLoading.show(status: 'Accepting job...');

      await _installerManagementApiService.acceptAdminAssignedPost(
        postId: job.id,
        authorization: authorization,
      );

      if (Get.isRegistered<BottomNavbarController>()) {
        final navbarController = Get.find<BottomNavbarController>();
        if (navbarController.currentIndex.value != 0) {
          navbarController.changeTab(0);
        }
      }

      if (Get.isRegistered<InstallerManagementController>()) {
        final managementController = Get.find<InstallerManagementController>();
        managementController.selectTab(InstallerPostTab.assignedPosts);
        await managementController.refreshJobs();
      }

      EasyLoading.showSuccess('Job accepted successfully');
      Get.back(result: true);
    } catch (error) {
      AppLoggerHelper.error('Failed to accept admin-assigned job', error);
      EasyLoading.showError(_extractExceptionMessage(error));
    } finally {
      acceptingPostId.value = '';
      EasyLoading.dismiss();
    }
  }

  String? _buildAuthorizationHeader() {
    final token = StorageService.accessToken?.trim();
    if (token == null || token.isEmpty) return null;

    final type = StorageService.tokenType?.trim();
    final prefix = (type != null && type.isNotEmpty) ? type : 'Bearer';
    return '$prefix $token';
  }

  String _extractExceptionMessage(Object error) {
    final raw = error.toString();
    const prefix = 'Exception: ';
    if (raw.startsWith(prefix)) {
      final message = raw.substring(prefix.length).trim();
      if (message.isNotEmpty) return message;
    }
    return 'Something went wrong';
  }
}

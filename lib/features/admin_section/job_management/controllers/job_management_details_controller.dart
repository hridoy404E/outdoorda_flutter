// ignore_for_file: depend_on_referenced_packages

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:outdoorda_flutter/core/services/storage_service.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/features/admin_section/job_management/models/admin_job.dart';
import 'package:outdoorda_flutter/features/admin_section/job_management/controllers/job_management_controller.dart';
import 'package:outdoorda_flutter/features/admin_section/job_management/services/admin_job_api_service.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/models/customer_post_bid_model.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/services/customer_post_bids_api_service.dart';
import 'package:outdoorda_flutter/features/installer_section/management/models/management_job.dart';

/// Controller for admin job management details screen
/// Manages job details view for admin oversight
class JobManagementDetailsController extends GetxController {
  final CustomerPostBidsApiService _bidsApiService =
      CustomerPostBidsApiService();
  final AdminJobApiService _adminJobApiService = AdminJobApiService();

  // Current job being viewed
  final Rxn<AdminJob> currentJob = Rxn<AdminJob>();
  final RxList<CustomerPostBidModel> bids = <CustomerPostBidModel>[].obs;
  final RxBool isFetchingBids = false.obs;
  final RxString acceptingBidId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadJobFromArguments();
    _loadBidsIfNeeded();
  }

  /// Reload job data and bids from current arguments
  void reloadJobData() {
    _loadJobFromArguments();
    _loadBidsIfNeeded();
  }

  /// Load job data from navigation arguments
  void _loadJobFromArguments() {
    try {
      final arguments = Get.arguments;

      if (arguments is ManagementJob) {
        currentJob.value = AdminJob(
          id: arguments.id,
          jobNumber: arguments.jobNumber,
          customerName: arguments.customerName,
          price: arguments.price,
          location: arguments.location,
          doorType: arguments.doorType,
          status: _convertStatus(arguments),
          bidCount: arguments.bidCount,
          createdAt: arguments.createdAt,
          petDoorDescription: arguments.petDoorDescription,
          petDoorModel: 'XL2000',
          installationType: arguments.installationType,
          adminEstimatedPrice: arguments.adminEstimatedPrice,
          jobNotes: arguments.jobNotes,
          sitePhotos: arguments.sitePhotos,
          addressLine1: arguments.addressLine1,
          addressLine2: arguments.addressLine2,
          city: arguments.city,
          state: arguments.state,
          zipCode: arguments.zipCode,
          country: arguments.country,
          petName: arguments.petName,
          petType: arguments.petType,
          petSize: arguments.petSize,
          scheduledDate: arguments.scheduledDate,
          installerNotes: arguments.jobStatusNotes,
          additionalWorkPerformed: arguments.additionalWorkAnswer,
          additionalWorkDescription: arguments.additionalWorkNotes,
          customerSatisfied: arguments.customerSatisfiedAnswer,
          customerFeedback: arguments.customerSatisfiedNotes,
        );
        AppLoggerHelper.info(
          'Loaded job from ManagementJob: ${arguments.jobNumber}',
        );
      } else if (arguments is AdminJob) {
        currentJob.value = arguments;
        AppLoggerHelper.info(
          'Loaded job from AdminJob: ${arguments.jobNumber}',
        );
      } else {
        AppLoggerHelper.warning('No valid job data found in arguments');
      }
    } catch (error) {
      AppLoggerHelper.error('Error loading job from arguments', error);
    }
  }

  bool get shouldShowBids =>
      currentJob.value?.status == AdminJobStatus.receivingBids;

  Future<void> loadBids({bool forceRefresh = false}) async {
    final job = currentJob.value;
    if (job == null || (!forceRefresh && !shouldShowBids)) return;

    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      AppLoggerHelper.warning('Cannot load admin bids without authorization');
      return;
    }

    isFetchingBids.value = true;
    try {
      final fetchedBids = await _bidsApiService.fetchBids(
        postId: job.id,
        authorization: authorization,
      );
      bids.assignAll(fetchedBids);
      AppLoggerHelper.info(
        'Loaded ${fetchedBids.length} bids for admin job ${job.jobNumber}',
      );
    } catch (error) {
      AppLoggerHelper.error(
        'Failed to fetch bids for admin job ${job.id}',
        error,
      );
    } finally {
      isFetchingBids.value = false;
    }
  }

  Future<bool> acceptBid(CustomerPostBidModel bid) async {
    final job = currentJob.value;
    if (job == null) return false;

    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      EasyLoading.showError(AppStrings.authorizationRequired);
      return false;
    }

    try {
      acceptingBidId.value = bid.id;
      EasyLoading.show(status: 'Accepting offer...');
      await _bidsApiService.acceptBid(
        bidId: bid.id,
        authorization: authorization,
      );
      bids.clear();
      final acceptedPrice = bid.price ?? job.adminEstimatedPrice;
      currentJob.value = job.copyWith(
        status: AdminJobStatus.assigned,
        bidCount: 0,
        price: acceptedPrice,
        adminEstimatedPrice: acceptedPrice,
      );
      if (Get.isRegistered<JobManagementController>()) {
        final jobController = Get.find<JobManagementController>();
        await jobController.refreshJobs();
      }
      EasyLoading.dismiss();
      EasyLoading.showSuccess(AppStrings.offerAcceptedSuccess);
      return true;
    } catch (error) {
      AppLoggerHelper.error(
        'Failed to accept bid ${bid.id} for admin job ${job.id}',
        error,
      );
      EasyLoading.dismiss();
      EasyLoading.showError(AppStrings.offerAcceptError);
      return false;
    } finally {
      acceptingBidId.value = '';
    }
  }

  /// Delete current post with confirmation dialog
  Future<void> deletePost() async {
    final job = currentJob.value;
    if (job == null) return;

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

    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      EasyLoading.showError('Authorization missing. Please log in again.');
      return;
    }

    try {
      EasyLoading.show(status: 'Deleting post...');
      await _adminJobApiService.deletePost(
        authorization: authorization,
        postId: job.id,
      );

      if (Get.isRegistered<JobManagementController>()) {
        final jobController = Get.find<JobManagementController>();
        jobController.removeJobById(job.id);
      }

      EasyLoading.dismiss();
      EasyLoading.showSuccess('Post deleted successfully');
      AppLoggerHelper.info('Admin post deleted: ${job.id}');
      Get.back();
    } catch (error) {
      AppLoggerHelper.error('Failed to delete post ${job.id}', error);
      EasyLoading.dismiss();
      EasyLoading.showError('Failed to delete post');
    }
  }

  /// Update current job with new fields
  Future<bool> updateRecentJob({
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
  }) async {
    final job = currentJob.value;
    if (job == null) return false;

    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      EasyLoading.showError('Authorization missing. Please log in again.');
      return false;
    }

    try {
      EasyLoading.show(status: 'Updating job...');
      await _adminJobApiService.updateRecentJob(
        authorization: authorization,
        postId: job.id,
        fields: fields,
        files: files,
      );

      if (Get.isRegistered<JobManagementController>()) {
        final jobController = Get.find<JobManagementController>();
        await jobController.refreshJobs();
      }

      EasyLoading.dismiss();
      EasyLoading.showSuccess('Job updated successfully');
      AppLoggerHelper.info('Admin job updated: ${job.id}');
      return true;
    } catch (error) {
      AppLoggerHelper.error('Failed to update job ${job.id}', error);
      EasyLoading.dismiss();
      EasyLoading.showError(
        'Failed to update job: ${error.toString().replaceAll('Exception: ', '')}',
      );
      return false;
    }
  }

  /// Convert ManagementJob status to AdminJob status
  AdminJobStatus _convertStatus(ManagementJob job) {
    if (_isPendingLabel(job.statusLabel)) {
      return AdminJobStatus.pending;
    }
    if (_isReceivingBidsLabel(job.statusLabel)) {
      return AdminJobStatus.receivingBids;
    }

    switch (job.status) {
      case JobStatus.completed:
        return AdminJobStatus.completed;
      case JobStatus.assigned:
        return AdminJobStatus.assigned;
      case JobStatus.inProgress:
        return AdminJobStatus.inProgress;
    }
  }

  Future<void> _loadBidsIfNeeded() async {
    if (!shouldShowBids) return;
    await loadBids();
  }

  bool _isReceivingBidsLabel(String statusLabel) {
    final cleaned = statusLabel.trim().toLowerCase();
    return cleaned == 'receiving bids' || cleaned == 'receiving_bids';
  }

  bool _isPendingLabel(String statusLabel) {
    return statusLabel.trim().toLowerCase() == 'pending';
  }

  String? _buildAuthorizationHeader() {
    final token = StorageService.accessToken?.trim();
    if (token == null || token.isEmpty) return null;

    final type = StorageService.tokenType?.trim();
    final prefix = (type != null && type.isNotEmpty) ? type : 'Bearer';
    return '$prefix $token';
  }
}

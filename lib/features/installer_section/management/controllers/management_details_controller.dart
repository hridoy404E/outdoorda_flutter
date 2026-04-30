import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/services/storage_service.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/features/installer_section/management/controllers/installer_management_controller.dart';
import 'package:outdoorda_flutter/features/installer_section/management/models/management_job.dart';
import 'package:outdoorda_flutter/features/installer_section/management/services/installer_management_api_service.dart';
import 'package:outdoorda_flutter/features/installer_section/management/views/widgets/adjust_bid_widget.dart';

/// Controller for management details screen
/// Handles job details display and job progress tracking
class ManagementDetailsController extends GetxController {
  final InstallerManagementApiService _installerManagementApiService =
      InstallerManagementApiService();

  // Job data passed from previous screen
  final Rx<ManagementJob?> currentJob = Rx<ManagementJob?>(null);

  // Job Progress Tracking form fields
  final Rx<DateTime?> scheduledDate = Rx<DateTime?>(null);
  final TextEditingController jobStatusNotesController =
      TextEditingController();
  final Rx<bool?> additionalWorkAnswer = Rx<bool?>(null);
  final TextEditingController additionalWorkNotesController =
      TextEditingController();
  final Rx<bool?> customerSatisfiedAnswer = Rx<bool?>(null);
  final TextEditingController customerSatisfiedNotesController =
      TextEditingController();

  // Loading state
  final RxBool isSavingProgress = false.obs;
  final RxBool isSubmittingProgressUpdate = false.obs;
  final RxBool isCompletingJob = false.obs;

  // Validation state
  final RxString scheduledDateError = ''.obs;
  final RxString additionalWorkNotesError = ''.obs;

  // Track if user has made any changes
  final RxBool hasChanges = false.obs;

  // Bid adjustment form fields
  final TextEditingController proposedPriceController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  final RxBool isSubmittingBid = false.obs;
  final RxBool isAcceptingPost = false.obs;

  bool get isAssigned => currentJob.value?.status == JobStatus.assigned;
  bool get isInProgress => currentJob.value?.status == JobStatus.inProgress;
  bool get isCompleted => currentJob.value?.status == JobStatus.completed;

  // Section 1 editable only in-progress.
  bool get canEditScheduledDate => isInProgress;
  // Section 2 editable in in-progress and completed.
  bool get canEditAdditionalWork => isInProgress || isCompleted;
  bool get canEditCustomerSatisfaction => isInProgress || isCompleted;
  bool get canEditJobStatusNotes => isAssigned || isInProgress || isCompleted;

  // Check if Done button should be visible
  bool get showDoneButton => (isInProgress || isCompleted) && hasChanges.value;

  @override
  void onInit() {
    super.onInit();
    // Get job data from route arguments
    final job = Get.arguments as ManagementJob?;
    if (job != null) {
      currentJob.value = job;
      // Initialize form fields from job data
      scheduledDate.value = job.scheduledDate;
      jobStatusNotesController.text = job.jobStatusNotes ?? '';
      additionalWorkAnswer.value = job.additionalWorkAnswer;
      additionalWorkNotesController.text = job.additionalWorkNotes ?? '';
      customerSatisfiedAnswer.value = job.customerSatisfiedAnswer;
      customerSatisfiedNotesController.text = job.customerSatisfiedNotes ?? '';

      // Add listeners to detect changes
      jobStatusNotesController.addListener(_onFieldChanged);
      additionalWorkNotesController.addListener(_onFieldChanged);
      customerSatisfiedNotesController.addListener(_onFieldChanged);

      AppLoggerHelper.info('Loaded job details for: ${job.jobNumber}');
    } else {
      AppLoggerHelper.warning('No job data provided to details screen');
    }
  }

  @override
  void onClose() {
    jobStatusNotesController.removeListener(_onFieldChanged);
    additionalWorkNotesController.removeListener(_onFieldChanged);
    customerSatisfiedNotesController.removeListener(_onFieldChanged);
    jobStatusNotesController.dispose();
    additionalWorkNotesController.dispose();
    customerSatisfiedNotesController.dispose();
    proposedPriceController.dispose();
    reasonController.dispose();
    super.onClose();
  }

  /// Called when any field changes
  void _onFieldChanged() {
    if (!hasChanges.value) {
      hasChanges.value = true;
    }
    if (additionalWorkNotesController.text.trim().isNotEmpty) {
      additionalWorkNotesError.value = '';
    }
  }

  /// Show date picker for scheduled date
  Future<void> selectScheduledDate(BuildContext context) async {
    if (!canEditScheduledDate) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: scheduledDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      scheduledDate.value = picked;
      scheduledDateError.value = '';
      hasChanges.value = true;
      AppLoggerHelper.info('Scheduled date selected: $picked');
    }
  }

  /// Toggle additional work answer
  void setAdditionalWorkAnswer(bool? value) {
    if (!canEditAdditionalWork) return;
    additionalWorkAnswer.value = value;
    hasChanges.value = true;
    additionalWorkNotesError.value = '';
    // Clear notes if answer is No or null
    if (value != true) {
      additionalWorkNotesController.clear();
    }
  }

  /// Toggle customer satisfied answer
  void setCustomerSatisfiedAnswer(bool? value) {
    if (!canEditCustomerSatisfaction) return;
    customerSatisfiedAnswer.value = value;
    hasChanges.value = true;
  }

  /// Assigned -> In Progress
  Future<void> startJobInProgress() async {
    final job = currentJob.value;
    if (job == null || !isAssigned) return;

    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      EasyLoading.showError('Authorization missing. Please log in again.');
      return;
    }

    final statusNote = jobStatusNotesController.text.trim();

    try {
      isSavingProgress.value = true;
      EasyLoading.show(status: 'Updating job status...');

      await _installerManagementApiService.updateInstallerPostStatus(
        postId: job.id,
        authorization: authorization,
        newStatus: 'IN_PROGRESS',
        note: statusNote,
      );

      scheduledDate.value = null;
      additionalWorkAnswer.value = null;
      additionalWorkNotesController.clear();
      customerSatisfiedAnswer.value = null;
      customerSatisfiedNotesController.clear();
      hasChanges.value = false;

      currentJob.value = _copyJob(
        job,
        status: JobStatus.inProgress,
        scheduledDate: null,
        jobStatusNotes: statusNote.isNotEmpty ? statusNote : null,
        additionalWorkAnswer: null,
        additionalWorkNotes: null,
        customerSatisfiedAnswer: null,
        customerSatisfiedNotes: null,
      );

      AppLoggerHelper.info('Job moved to in progress: ${job.jobNumber}');
      EasyLoading.showSuccess('Job moved to In Progress');
      await _refreshManagementListIfNeeded();
    } catch (error) {
      AppLoggerHelper.error('Failed to move job to in progress', error);
      EasyLoading.showError('Failed to update job status');
    } finally {
      isSavingProgress.value = false;
      EasyLoading.dismiss();
    }
  }

  /// In Progress -> Completed
  Future<void> completeJob() async {
    final job = currentJob.value;
    if (job == null || !isInProgress) return;

    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      EasyLoading.showError('Authorization missing. Please log in again.');
      return;
    }

    try {
      // Validation
      if (!_validateInProgressRequiredFields()) return;

      isCompletingJob.value = true;
      EasyLoading.show(status: 'Completing job...');

      final statusNote = jobStatusNotesController.text.trim();
      final additionalNote = additionalWorkAnswer.value == true
          ? additionalWorkNotesController.text.trim()
          : '';

      await _installerManagementApiService.updateInstallerPostStatus(
        postId: job.id,
        authorization: authorization,
        newStatus: 'COMPLETED',
        scheduledDate: scheduledDate.value,
        note: statusNote,
        isAdditionalService: additionalWorkAnswer.value,
        additionalServiceNote: additionalNote,
        isCustomerSatisfied: customerSatisfiedAnswer.value,
        customerSatisfactionNote: customerSatisfiedNotesController.text.trim(),
      );

      currentJob.value = _copyJob(
        job,
        status: JobStatus.completed,
        scheduledDate: scheduledDate.value,
        jobStatusNotes: statusNote.isNotEmpty ? statusNote : null,
        additionalWorkAnswer: additionalWorkAnswer.value,
        additionalWorkNotes: additionalNote.isNotEmpty ? additionalNote : null,
        customerSatisfiedAnswer: customerSatisfiedAnswer.value,
        customerSatisfiedNotes:
            customerSatisfiedNotesController.text.trim().isNotEmpty
            ? customerSatisfiedNotesController.text.trim()
            : null,
      );
      hasChanges.value = false;

      AppLoggerHelper.info(
        'Job completed with progress tracking: ${currentJob.value?.jobNumber}',
      );

      EasyLoading.showSuccess('Job completed successfully!');
      await _refreshManagementListIfNeeded();

      // Navigate back after success
      await Future.delayed(const Duration(seconds: 1));
      Get.back(result: currentJob.value); // Return updated job
    } catch (error) {
      AppLoggerHelper.error('Failed to complete job', error);
      EasyLoading.showError('Failed to complete job');
    } finally {
      isCompletingJob.value = false;
      EasyLoading.dismiss();
    }
  }

  /// In Progress -> save updates without completing
  Future<void> submitInProgressUpdates() async {
    final job = currentJob.value;
    if (job == null || !isInProgress) return;

    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      EasyLoading.showError('Authorization missing. Please log in again.');
      return;
    }

    try {
      if (!_validateInProgressRequiredFields()) return;

      isSubmittingProgressUpdate.value = true;
      EasyLoading.show(status: 'Updating in-progress job...');

      final statusNote = jobStatusNotesController.text.trim();
      final additionalNote = additionalWorkAnswer.value == true
          ? additionalWorkNotesController.text.trim()
          : '';

      await _installerManagementApiService.updateInstallerPostStatus(
        postId: job.id,
        authorization: authorization,
        scheduledDate: scheduledDate.value,
        note: statusNote,
        isAdditionalService: additionalWorkAnswer.value,
        additionalServiceNote: additionalNote,
        isCustomerSatisfied: customerSatisfiedAnswer.value,
        customerSatisfactionNote: customerSatisfiedNotesController.text.trim(),
      );

      currentJob.value = _copyJob(
        job,
        status: JobStatus.inProgress,
        scheduledDate: scheduledDate.value,
        jobStatusNotes: statusNote.isNotEmpty ? statusNote : null,
        additionalWorkAnswer: additionalWorkAnswer.value,
        additionalWorkNotes: additionalNote.isNotEmpty ? additionalNote : null,
        customerSatisfiedAnswer: customerSatisfiedAnswer.value,
        customerSatisfiedNotes:
            customerSatisfiedNotesController.text.trim().isNotEmpty
            ? customerSatisfiedNotesController.text.trim()
            : null,
      );
      hasChanges.value = false;

      AppLoggerHelper.info(
        'In-progress job updated: ${currentJob.value?.jobNumber}',
      );
      EasyLoading.showSuccess('In-progress job updated successfully!');
      await _refreshManagementListIfNeeded();
    } catch (error) {
      AppLoggerHelper.error('Failed to update in-progress job', error);
      EasyLoading.showError('Failed to update in-progress job');
    } finally {
      isSubmittingProgressUpdate.value = false;
      EasyLoading.dismiss();
    }
  }

  /// Completed -> update editable sections (2 and 4)
  Future<void> submitCompletedUpdates() async {
    final job = currentJob.value;
    if (job == null || !isCompleted) return;

    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      EasyLoading.showError('Authorization missing. Please log in again.');
      return;
    }

    try {
      if (!_validateAdditionalWorkNotesIfNeeded()) return;

      isSavingProgress.value = true;
      EasyLoading.show(status: 'Updating completed job...');

      final statusNote = jobStatusNotesController.text.trim();
      final additionalNote = additionalWorkAnswer.value == true
          ? additionalWorkNotesController.text.trim()
          : '';

      await _installerManagementApiService.updateInstallerPostStatus(
        postId: job.id,
        authorization: authorization,
        note: statusNote,
        isAdditionalService: additionalWorkAnswer.value,
        additionalServiceNote: additionalNote,
        isCustomerSatisfied: customerSatisfiedAnswer.value,
        customerSatisfactionNote: customerSatisfiedNotesController.text.trim(),
      );

      currentJob.value = _copyJob(
        job,
        status: JobStatus.completed,
        scheduledDate: job.scheduledDate,
        jobStatusNotes: statusNote.isNotEmpty ? statusNote : null,
        additionalWorkAnswer: additionalWorkAnswer.value,
        additionalWorkNotes: additionalNote.isNotEmpty ? additionalNote : null,
        customerSatisfiedAnswer: customerSatisfiedAnswer.value,
        customerSatisfiedNotes:
            customerSatisfiedNotesController.text.trim().isNotEmpty
            ? customerSatisfiedNotesController.text.trim()
            : null,
      );
      hasChanges.value = false;

      AppLoggerHelper.info(
        'Completed job updated: ${currentJob.value?.jobNumber}',
      );
      EasyLoading.showSuccess('Completed job updated successfully!');
      await _refreshManagementListIfNeeded();
    } catch (error) {
      AppLoggerHelper.error('Failed to update completed job', error);
      EasyLoading.showError('Failed to update completed job');
    } finally {
      isSavingProgress.value = false;
      EasyLoading.dismiss();
    }
  }

  bool _validateInProgressRequiredFields() {
    scheduledDateError.value = '';
    final hasScheduledDate = scheduledDate.value != null;
    if (!hasScheduledDate) {
      scheduledDateError.value = 'This field is required';
    }

    final hasAdditionalWorkDetails = _validateAdditionalWorkNotesIfNeeded();
    return hasScheduledDate && hasAdditionalWorkDetails;
  }

  bool _validateAdditionalWorkNotesIfNeeded() {
    additionalWorkNotesError.value = '';
    if (additionalWorkAnswer.value == true &&
        additionalWorkNotesController.text.trim().isEmpty) {
      additionalWorkNotesError.value = 'This field is required';
      return false;
    }
    return true;
  }

  /// Submit bid adjustment for in-progress jobs
  Future<void> submitBid(BuildContext context) async {
    final job = currentJob.value;
    if (job == null) return;

    // Validate proposed price
    if (proposedPriceController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter your proposed price');
      return;
    }

    final proposedPrice = double.tryParse(proposedPriceController.text.trim());
    if (proposedPrice == null || proposedPrice < 0) {
      EasyLoading.showError('Please enter a valid price');
      return;
    }

    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      EasyLoading.showError('Authorization missing. Please log in again.');
      return;
    }

    try {
      isSubmittingBid.value = true;
      EasyLoading.show(status: 'Submitting bid...');

      await _installerManagementApiService.submitInstallerBid(
        postId: job.id,
        authorization: authorization,
        price: proposedPrice,
        note: reasonController.text.trim(),
      );

      final updatedJob = ManagementJob(
        id: job.id,
        isAssignedPost: job.isAssignedPost,
        jobNumber: job.jobNumber,
        customerName: job.customerName,
        price: proposedPrice,
        location: job.location,
        doorType: job.doorType,
        status: job.status,
        bidCount: (job.bidCount ?? 0) + 1,
        createdAt: job.createdAt,
        petDoorDescription: job.petDoorDescription,
        installationType: job.installationType,
        adminEstimatedPrice: job.adminEstimatedPrice,
        jobNotes: job.jobNotes,
        sitePhotos: job.sitePhotos,
        scheduledDate: job.scheduledDate,
        jobStatusNotes: job.jobStatusNotes,
        additionalWorkAnswer: job.additionalWorkAnswer,
        additionalWorkNotes: job.additionalWorkNotes,
        customerSatisfiedAnswer: job.customerSatisfiedAnswer,
        customerSatisfiedNotes: job.customerSatisfiedNotes,
      );
      currentJob.value = updatedJob;

      AppLoggerHelper.info(
        'Bid submitted: \$${proposedPrice.toStringAsFixed(2)} for job ${currentJob.value?.jobNumber}',
      );

      EasyLoading.showSuccess('Bid submitted successfully!');

      // Close dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Clear form
      proposedPriceController.clear();
      reasonController.clear();

      await _refreshManagementListIfNeeded();
    } catch (error) {
      AppLoggerHelper.error('Failed to submit bid', error);
      EasyLoading.showError('Failed to submit bid');
    } finally {
      isSubmittingBid.value = false;
      EasyLoading.dismiss();
    }
  }

  Future<void> acceptCurrentPost() async {
    final job = currentJob.value;
    if (job == null || job.isAssignedPost) return;

    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      EasyLoading.showError('Authorization missing. Please log in again.');
      return;
    }

    try {
      isAcceptingPost.value = true;
      EasyLoading.show(status: 'Accepting post...');

      await _installerManagementApiService.acceptInstallerPost(
        postId: job.id,
        authorization: authorization,
      );

      currentJob.value = _copyJob(
        job,
        isAssignedPost: true,
        status: JobStatus.assigned,
      );

      AppLoggerHelper.info('Installer accepted post: ${job.jobNumber}');
      EasyLoading.showSuccess('Post accepted successfully!');
      await _refreshManagementListIfNeeded();
      Get.back(result: true);
    } catch (error) {
      AppLoggerHelper.error('Failed to accept installer post', error);
      EasyLoading.showError('Failed to accept post');
    } finally {
      isAcceptingPost.value = false;
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

  Future<void> _refreshManagementListIfNeeded() async {
    if (Get.isRegistered<InstallerManagementController>()) {
      await Get.find<InstallerManagementController>().refreshJobs();
    }
  }

  ManagementJob _copyJob(
    ManagementJob source, {
    bool? isAssignedPost,
    required JobStatus status,
    DateTime? scheduledDate,
    String? jobStatusNotes,
    bool? additionalWorkAnswer,
    String? additionalWorkNotes,
    bool? customerSatisfiedAnswer,
    String? customerSatisfiedNotes,
  }) {
    return ManagementJob(
      id: source.id,
      isAssignedPost: isAssignedPost ?? source.isAssignedPost,
      jobNumber: source.jobNumber,
      customerName: source.customerName,
      location: source.location,
      doorType: source.doorType,
      price: source.price,
      status: status,
      bidCount: source.bidCount,
      createdAt: source.createdAt,
      petDoorDescription: source.petDoorDescription,
      installationType: source.installationType,
      adminEstimatedPrice: source.adminEstimatedPrice,
      jobNotes: source.jobNotes,
      sitePhotos: source.sitePhotos,
      scheduledDate: scheduledDate,
      jobStatusNotes: jobStatusNotes,
      additionalWorkAnswer: additionalWorkAnswer,
      additionalWorkNotes: additionalWorkNotes,
      customerSatisfiedAnswer: customerSatisfiedAnswer,
      customerSatisfiedNotes: customerSatisfiedNotes,
    );
  }

  /// Show adjust bid dialog
  void showAdjustBidDialog() {
    if (currentJob.value == null) return;

    // Import will be added in the screen file
    Get.dialog(
      AdjustBidWidget(
        proposedPriceController: proposedPriceController,
        currentJob: currentJob,
        reasonController: reasonController,
        context: Get.context!,
        onSubmitBid: submitBid,
        isSubmittingBid: isSubmittingBid,
      ),
    );
  }
}

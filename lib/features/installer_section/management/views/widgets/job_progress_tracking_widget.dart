import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/features/installer_section/management/controllers/management_details_controller.dart';
import 'package:outdoorda_flutter/features/installer_section/management/models/management_job.dart';

class JobProgressTrackingWidget extends StatelessWidget {
  const JobProgressTrackingWidget({
    super.key,
    required this.controller,
    required this.job,
  });

  final ManagementDetailsController controller;
  final ManagementJob job;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFFEBE8E3),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24.r,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Job Progress Tracking',
            style: figtreeTextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E242C),
            ),
          ),
          SizedBox(height: 8.h),
          Container(height: 1.h, color: const Color(0xFFC2CCD3)),
          SizedBox(height: 20.h),

          // 1. Customer/Job Scheduled Date
          _buildScheduledDateSection(context),
          SizedBox(height: 20.h),

          // 2. Did the job have any additional work/charges?
          _buildAdditionalWorkSection(),
          SizedBox(height: 20.h),

          // 3. Was the customer satisfied with your work?
          _buildCustomerSatisfactionSection(),
          SizedBox(height: 20.h),

          // 4. Job Status
          _buildJobStatusSection(),
        ],
      ),
    );
  }

  /// Build Job Status section
  Widget _buildJobStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '4. Job Status',
          style: figtreeTextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E242C),
          ),
        ),
        SizedBox(height: 12.h),

        Text(
          'Notes (include any problems or issues)',
          style: figtreeTextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF1E242C),
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFEDF1F3)),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: TextField(
            controller: controller.jobStatusNotesController,
            enabled: controller.canEditJobStatusNotes,
            maxLines: 3,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'type here...',
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            style: figtreeTextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF1E242C),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Obx(() {
          final jobStatus = controller.currentJob.value?.status;
          final isSaving = controller.isSavingProgress.value;
          final isSubmitting = controller.isSubmittingProgressUpdate.value;
          final isCompleting = controller.isCompletingJob.value;
          final isInProgressActionRunning = isSubmitting || isCompleting;

          if (jobStatus == JobStatus.assigned) {
            return GestureDetector(
              onTap: isSaving ? null : controller.startJobInProgress,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF395C70),
                  border: Border.all(color: const Color(0xFF414D60)),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: Text(
                    isSaving ? 'Updating...' : 'In Progress',
                    style: figtreeTextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          }

          if (jobStatus == JobStatus.inProgress) {
            return Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: isInProgressActionRunning
                        ? null
                        : controller.submitInProgressUpdates,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF395C70),
                        border: Border.all(color: const Color(0xFF414D60)),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Center(
                        child: Text(
                          isSubmitting ? 'Submitting...' : 'Submit Update',
                          style: figtreeTextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: GestureDetector(
                    onTap: isInProgressActionRunning
                        ? null
                        : controller.completeJob,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C5302),
                        border: Border.all(color: const Color(0xFF0C5302)),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Center(
                        child: Text(
                          isCompleting ? 'Completing...' : 'Complete',
                          style: figtreeTextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          if (jobStatus == JobStatus.completed) {
            return GestureDetector(
              onTap: isSaving ? null : controller.submitCompletedUpdates,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF414D60),
                  border: Border.all(color: const Color(0xFF414D60)),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: Text(
                    isSaving ? 'Submitting...' : 'Submit Update',
                    style: figtreeTextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        }),
      ],
    );
  }

  /// Build scheduled date section
  Widget _buildScheduledDateSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '1. Customer/Job Scheduled Date',
          style: figtreeTextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E242C),
          ),
        ),
        SizedBox(height: 12.h),
        GestureDetector(
          onTap: controller.canEditScheduledDate
              ? () => controller.selectScheduledDate(context)
              : null,
          child: Obx(
            () => Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFEDF1F3)),
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE4E5E7).withValues(alpha: 0.24),
                    blurRadius: 2.r,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16.r,
                    color: const Color(0xFF1E242C),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    controller.scheduledDate.value != null
                        ? DateFormat(
                            'MMMM d, yyyy',
                          ).format(controller.scheduledDate.value!)
                        : '-',
                    style: figtreeTextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF1E242C),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Obx(() => _buildFieldError(controller.scheduledDateError.value)),
      ],
    );
  }

  /// Build additional work/charges section with Yes/No and conditional notes
  Widget _buildAdditionalWorkSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '2. Did the job have any additional work/charges?',
          style: figtreeTextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E242C),
          ),
        ),
        SizedBox(height: 16.h),
        Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Yes option
              GestureDetector(
                onTap: controller.canEditAdditionalWork
                    ? () => controller.setAdditionalWorkAnswer(true)
                    : null,
                child: Row(
                  children: [
                    Icon(
                      controller.additionalWorkAnswer.value == true
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      size: 20.r,
                      color: controller.additionalWorkAnswer.value == true
                          ? const Color(0xFF34C759)
                          : const Color(0xFF414D60),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Yes',
                      style: figtreeTextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF414D60),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              // No option
              GestureDetector(
                onTap: controller.canEditAdditionalWork
                    ? () => controller.setAdditionalWorkAnswer(false)
                    : null,
                child: Row(
                  children: [
                    Icon(
                      controller.additionalWorkAnswer.value == false
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      size: 20.r,
                      color: controller.additionalWorkAnswer.value == false
                          ? const Color(0xFF34C759)
                          : const Color(0xFF414D60),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'No',
                      style: figtreeTextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF414D60),
                      ),
                    ),
                  ],
                ),
              ),
              // Show notes field only if Yes is selected
              if (controller.additionalWorkAnswer.value == true) ...[
                SizedBox(height: 16.h),
                Text(
                  "* please include type of work and how much extra was charged",
                  style: figtreeTextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF333333),
                  ),
                ),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFEDF1F3)),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: TextField(
                    controller: controller.additionalWorkNotesController,
                    enabled: controller.canEditAdditionalWork,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'type here...',
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: figtreeTextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF1E242C),
                    ),
                  ),
                ),
                _buildFieldError(controller.additionalWorkNotesError.value),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerSatisfactionSection() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '3. Was the customer satisfied with your work?',
            style: figtreeTextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E242C),
            ),
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: controller.canEditCustomerSatisfaction
                ? () => controller.setCustomerSatisfiedAnswer(true)
                : null,
            child: Row(
              children: [
                Icon(
                  controller.customerSatisfiedAnswer.value == true
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  size: 20.r,
                  color: controller.customerSatisfiedAnswer.value == true
                      ? const Color(0xFF34C759)
                      : const Color(0xFF414D60),
                ),
                SizedBox(width: 4.w),
                Text(
                  'Yes',
                  style: figtreeTextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF414D60),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: controller.canEditCustomerSatisfaction
                ? () => controller.setCustomerSatisfiedAnswer(false)
                : null,
            child: Row(
              children: [
                Icon(
                  controller.customerSatisfiedAnswer.value == false
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  size: 20.r,
                  color: controller.customerSatisfiedAnswer.value == false
                      ? const Color(0xFF34C759)
                      : const Color(0xFF414D60),
                ),
                SizedBox(width: 4.w),
                Text(
                  'No',
                  style: figtreeTextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF414D60),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFEDF1F3)),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: TextField(
              controller: controller.customerSatisfiedNotesController,
              enabled: controller.canEditCustomerSatisfaction,
              maxLines: 3,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Add customer satisfaction notes...',
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: figtreeTextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF1E242C),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildFieldError(String errorText) {
    if (errorText.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: 6.h),
      child: Text(
        errorText,
        style: figtreeTextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          color: const Color(0xFFFF383C),
        ),
      ),
    );
  }
}

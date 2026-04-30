import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_appbar.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/features/admin_section/job_management/controllers/job_management_controller.dart';
import 'package:outdoorda_flutter/features/installer_section/management/models/management_job.dart';
import 'package:outdoorda_flutter/features/installer_section/management/views/widgets/management_item_card.dart';

/// Admin management screen - 100% Figma pixel-perfect implementation
/// Background: #EBE8E3, Content width: 330w with 14w left margin
class JobManagementScreen extends StatelessWidget {
  const JobManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<JobManagementController>();

    return Scaffold(
      appBar: CustomAppBar(
        greetingText: 'Dashboard',
        userType: 'Real-time screening program management and compliance',
        loadProfileImageFromApi: true,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.jobs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.jobs.isEmpty) {
            if (controller.selectedFilter.value != null &&
                controller.hasMoreJobs.value &&
                !controller.isLoadingMore.value) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller.loadMoreJobs();
              });
            }

            if (controller.loadJobsError.value.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.loadJobsError.value,
                      style: figtreeTextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.neutral400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    TextButton(
                      onPressed: controller.loadInitialJobs,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'No jobs found',
                    style: figtreeTextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.neutral400,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  InkWell(
                    onTap: controller.loadInitialJobs,
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.settingsBorderSky),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'Reload',
                        style: figtreeTextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.settingsBorderSky,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.refreshJobs,
            child: ListView(
              controller: controller.scrollController,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              children: [
                // Title section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Jobs',
                      style: figtreeTextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600, // SemiBold
                        color: const Color(0xFF2B4554), // #2b4554
                      ),
                    ),
                    // Filter dropdown button
                    PopupMenuButton<JobStatus?>(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      offset: Offset(0, 50.h),
                      onSelected: (JobStatus? status) {
                        controller.filterJobs(status);
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<JobStatus?>(
                          value: null,
                          child: Text(
                            'All Jobs',
                            style: figtreeTextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF2B4554),
                            ),
                          ),
                        ),
                        PopupMenuItem<JobStatus>(
                          value: JobStatus.inProgress,
                          child: Text(
                            'In Progress',
                            style: figtreeTextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF2B4554),
                            ),
                          ),
                        ),
                        PopupMenuItem<JobStatus>(
                          value: JobStatus.assigned,
                          child: Text(
                            'Assigned',
                            style: figtreeTextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF2B4554),
                            ),
                          ),
                        ),
                        PopupMenuItem<JobStatus>(
                          value: JobStatus.completed,
                          child: Text(
                            'Completed',
                            style: figtreeTextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF2B4554),
                            ),
                          ),
                        ),
                      ],
                      child: Card(
                        color: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          side: BorderSide(
                            color: const Color(0xFFB0B0B0), // #B0B0B0
                            width: 1.5.w,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(8.r),
                          child: Icon(
                            Iconsax.filter,
                            color: AppColors.assignedBadgeEnd,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 14.h), // Gap before job list
                // Job list with exact 16h spacing
                ...controller.jobs.asMap().entries.map((entry) {
                  final job = entry.value;
                  final isLast = entry.key == controller.jobs.length - 1;
                  return Column(
                    children: [
                      ManagementItemCard(
                        job: job,
                        onTap: () => controller.navigateToDetails(job),
                      ),
                      if (!isLast)
                        SizedBox(height: 16.h), // 16px gap between cards
                    ],
                  );
                }),

                if (controller.isLoadingMore.value)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: const Center(child: CircularProgressIndicator()),
                  ),

                SizedBox(height: 10.h), // Bottom padding
              ],
            ),
          );
        }),
      ),
    );
  }
}

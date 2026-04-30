import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/features/admin_section/home/controllers/create_new_job_controller.dart';
import 'package:outdoorda_flutter/features/admin_section/home/views/widgets/step_indicator_widget.dart';

/// Step 4: Select Installers
/// Checkboxes for installers, Back and Create Job buttons
class Step4SelectInstallers extends StatelessWidget {
  const Step4SelectInstallers({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateNewJobController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Step indicator
        const StepIndicatorWidget(currentStep: 3),
        SizedBox(height: 16.h),

        /// Installers dropdown
        Obx(() {
          final selectedCount = controller.installers
              .where((e) => e.isSelected)
              .length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: controller.toggleInstallerDropdown,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackgroundHover,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedCount == 0
                              ? 'Select installers'
                              : '$selectedCount installer(s) selected',
                          style: figtreeTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.neutral900,
                          ),
                        ),
                      ),
                      Icon(
                        controller.isInstallerDropdownExpanded.value
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 22.r,
                        color: AppColors.neutral400,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              if (controller.isInstallerDropdownExpanded.value)
                if (controller.isInstallersLoading.value)
                  const Center(child: CircularProgressIndicator())
                else if (controller.installers.isEmpty)
                  Text(
                    'No installers found',
                    style: figtreeTextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.neutral400,
                    ),
                  )
                else
                  SizedBox(
                    height: 240.h,
                    child: ListView.separated(
                      itemCount: controller.installers.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 8.h),
                      itemBuilder: (context, index) {
                        final installer = controller.installers[index];
                        return GestureDetector(
                          onTap: () =>
                              controller.toggleInstallerSelection(index),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 12.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackgroundHover,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 16.r,
                                  height: 16.r,
                                  decoration: BoxDecoration(
                                    gradient: installer.isSelected
                                        ? AppColors.primaryGradient
                                        : null,
                                    color: installer.isSelected
                                        ? null
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: installer.isSelected
                                          ? AppColors.gradientStart
                                          : AppColors.checkboxBorder,
                                    ),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: installer.isSelected
                                      ? Icon(
                                          Icons.check,
                                          size: 12.r,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        installer.name,
                                        style: figtreeTextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.neutral900,
                                        ),
                                      ),
                                      SizedBox(height: 5.h),
                                      Text(
                                        installer.location,
                                        style: figtreeTextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.neutral400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            ],
          );
        }),
        SizedBox(height: 8.h),

        /// Back and Create Job buttons
        Obx(
          () => Row(
            children: [
              /// Back button
              GestureDetector(
                onTap: controller.isSubmittingJob.value
                    ? null
                    : controller.previousStep,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.skyDark),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    AppStrings.back,
                    style: figtreeTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.skyDark,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),

              /// Create Job button
              Expanded(
                child: Container(
                  height: 40.h,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: controller.isSubmittingJob.value
                          ? null
                          : controller.submitJob,
                      borderRadius: BorderRadius.circular(8.r),
                      child: Center(
                        child: Text(
                          controller.isSubmittingJob.value
                              ? 'Creating...'
                              : AppStrings.createJob,
                          style: figtreeTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

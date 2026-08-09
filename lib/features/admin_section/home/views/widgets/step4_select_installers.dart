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

        /// Service Area Filter Dropdown
        Text(
          'Service Area*',
          style: figtreeTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral900,
          ),
        ),
        SizedBox(height: 6.h),
        Obx(() {
          final currentArea = controller.selectedStep4ServiceArea.value ??
              controller.selectedServiceArea.value;

          return Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: BoxDecoration(
              color: AppColors.cardBackgroundHover,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: currentArea == null
                    ? const Color(0xFFFF6A00)
                    : AppColors.cardBorder,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<dynamic>(
                value: currentArea,
                isExpanded: true,
                hint: Text(
                  'Select Service Area (Required)*',
                  style: figtreeTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.neutral400,
                  ),
                ),
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  size: 22.r,
                  color: AppColors.neutral400,
                ),
                items: controller.serviceAreas.map(
                  (area) => DropdownMenuItem<dynamic>(
                    value: area,
                    child: Text(
                      area.name,
                      style: figtreeTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.neutral900,
                      ),
                    ),
                  ),
                ).toList(),
                onChanged: (val) {
                  controller.selectStep4ServiceArea(val);
                },
              ),
            ),
          );
        }),
        SizedBox(height: 16.h),

        /// Installers Section Header & Mode Status Banner
        Obx(() {
          final currentArea = controller.selectedStep4ServiceArea.value ??
              controller.selectedServiceArea.value;

          if (currentArea == null) {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: AppColors.cardBackgroundHover,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 36.r,
                    color: const Color(0xFFFF6A00),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Please select a Service Area above to view installers',
                    textAlign: TextAlign.center,
                    style: figtreeTextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral700,
                    ),
                  ),
                ],
              ),
            );
          }

          final selectedCount = controller.installers
              .where((e) => e.isSelected)
              .length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Installers',
                    style: figtreeTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral900,
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      selectedCount == 0
                          ? 'Broadcast to All'
                          : '$selectedCount Selected',
                      key: ValueKey('header_badge_$selectedCount'),
                      style: figtreeTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selectedCount == 0
                            ? const Color(0xFFD97706)
                            : const Color(0xFF059669),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SizeTransition(
                      sizeFactor: animation,
                      alignment: Alignment.center,
                      child: child,
                    ),
                  );
                },
                child: selectedCount == 0
                    ? _buildBroadcastModeBanner(currentArea.name)
                    : _buildTargetedModeBanner(selectedCount),
              ),
              SizedBox(height: 12.h),

              /// Installers dropdown / list container
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
                              ? 'View Installers (${controller.installers.length})'
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
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Center(
                      child: Text(
                        'No installers found for this service area',
                        style: figtreeTextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.neutral400,
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 200.h,
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

  Widget _buildBroadcastModeBanner(String? areaName) {
    final areaText = (areaName != null && areaName.isNotEmpty)
        ? ' ($areaName)'
        : '';

    return Container(
      key: ValueKey('broadcast_mode_banner_$areaName'),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFFCD34D)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: const BoxDecoration(
              color: Color(0xFFFDE68A),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.sensors_outlined,
              size: 20.r,
              color: const Color(0xFFD97706),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Broadcast Mode',
                  style: figtreeTextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF92400E),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Broadcast to this service area$areaText',
                  style: figtreeTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetedModeBanner(int count) {
    return Container(
      key: ValueKey('targeted_mode_banner_$count'),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF6EE7B7)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.08),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: const BoxDecoration(
              color: Color(0xFFA7F3D0),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_pin_circle_outlined,
              size: 20.r,
              color: const Color(0xFF059669),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Targeted Mode ($count Selected)',
                  style: figtreeTextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF065F46),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Job post will be assigned specifically to the chosen installer(s).',
                  style: figtreeTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF047857),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

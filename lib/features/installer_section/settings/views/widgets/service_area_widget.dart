import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import '../../controllers/installer_setting_controller.dart';

class ServiceAreaWidget extends StatelessWidget {
  const ServiceAreaWidget({super.key, required this.controller});

  final InstallerSettingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.settingsCardBg,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Section Header
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 32.r,
                color: AppColors.textNormal,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  AppStrings.servicesArea,
                  style: figtreeTextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.settingsTextPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Divider(color: AppColors.dividerColor, height: 1),

          /// Service Area Checkboxes
          Obx(() {
            if (controller.isServiceAreaLoading.value) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            if (controller.availableServiceAreas.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Text(
                  AppStrings.noServiceAreasAvailable,
                  style: figtreeTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textTertiary,
                  ),
                ),
              );
            }

            return Column(
              children: controller.availableServiceAreas.map((area) {
                final isSelected = controller.selectedServiceAreaIds.contains(
                  area.id,
                );
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: InkWell(
                    onTap: () => controller.toggleServiceArea(area.id),
                    borderRadius: BorderRadius.circular(6.r),
                    child: Padding(
                      padding: EdgeInsets.all(10.r),
                      child: Row(
                        children: [
                          Container(
                            width: 20.w,
                            height: 20.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.gradientStart
                                    : AppColors.textTertiary,
                              ),
                              gradient: isSelected
                                  ? AppColors.primaryGradient
                                  : null,
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check,
                                    size: 14.r,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            area.name,
                            style: figtreeTextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
          SizedBox(height: 16.h),

          /// Update Button
          Obx(
            () => InkWell(
              onTap: controller.isUpdatingServiceArea.value
                  ? null
                  : controller.updateServiceArea,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.settingsBorderSky),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  AppStrings.updateServiceArea,
                  textAlign: TextAlign.center,
                  style: figtreeTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.settingsBorderSky,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

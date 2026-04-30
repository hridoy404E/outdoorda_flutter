import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/features/installer_section/settings/controllers/installer_setting_controller.dart';

class InstallerServiceAreaRequiredDialog extends StatelessWidget {
  const InstallerServiceAreaRequiredDialog({
    super.key,
    required this.controller,
  });

  final InstallerSettingController controller;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.settingsWhite,
      insetPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 24.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.78,
        ),
        child: Padding(
          padding: EdgeInsets.all(18.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.location_on_outlined,
                      color: AppColors.textNormal,
                      size: 22.r,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Select service area',
                      style: figtreeTextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.settingsTextPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                'Choose at least one service area so you can receive matching installer jobs.',
                style: figtreeTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.settingsTextSecondary,
                ),
              ),
              SizedBox(height: 16.h),
              Flexible(
                child: Obx(() {
                  if (controller.isServiceAreaLoading.value) {
                    return SizedBox(
                      height: 120.h,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (controller.availableServiceAreas.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 18.h),
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

                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: controller.availableServiceAreas.length,
                    separatorBuilder: (_, __) => SizedBox(height: 8.h),
                    itemBuilder: (context, index) {
                      final area = controller.availableServiceAreas[index];

                      return Obx(() {
                        final isSelected = controller.selectedServiceAreaIds
                            .contains(area.id);

                        return InkWell(
                          onTap: () => controller.toggleServiceArea(area.id),
                          borderRadius: BorderRadius.circular(8.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 12.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.settingsBorderSky
                                    : AppColors.cardBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 22.w,
                                  height: 22.h,
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
                                          size: 15.r,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text(
                                    area.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: figtreeTextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.settingsTextPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                    },
                  );
                }),
              ),
              SizedBox(height: 18.h),
              Row(
                children: [
                  TextButton(
                    onPressed: Get.back,
                    child: Text(
                      'Later',
                      style: figtreeTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.settingsTextSecondary,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Obx(
                      () => InkWell(
                        onTap: controller.isUpdatingServiceArea.value
                            ? null
                            : () async {
                                final updated = await controller
                                    .updateServiceArea();
                                if (updated && Get.isDialogOpen == true) {
                                  Get.back();
                                }
                              },
                        borderRadius: BorderRadius.circular(8.r),
                        child: Container(
                          height: 44.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            gradient: AppColors.primaryGradient,
                          ),
                          child: Text(
                            controller.isUpdatingServiceArea.value
                                ? 'Updating...'
                                : AppStrings.updateServiceArea,
                            style: figtreeTextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

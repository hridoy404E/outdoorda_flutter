import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_button.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_text_field.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import '../../controllers/new_service_controller.dart';
import '../../models/service_area_model.dart';

class Step2 extends StatelessWidget {
  const Step2({super.key, required this.controller});

  final NewServiceController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Subtitle
                  Text(
                    AppStrings.whereShouldWeInstallTheDoor,
                    style: interTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.neutral700,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  /// Service area dropdown
                  Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.serviceArea,
                          style: interTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.neutral800,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: AppColors.neutral25,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: AppColors.borderColor,
                              width: 1,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<ServiceAreaModel>(
                              isExpanded: true,
                              value: controller.selectedServiceArea.value,
                              hint: Text(
                                controller.isServiceAreaLoading.value
                                    ? AppStrings.loadingServiceAreas
                                    : AppStrings.selectServiceArea,
                                style: interTextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.neutral700,
                                ),
                              ),
                              items: controller.serviceAreas
                                  .map(
                                    (area) =>
                                        DropdownMenuItem<ServiceAreaModel>(
                                          value: area,
                                          child: Text(
                                            area.name,
                                            style: interTextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.neutral700,
                                            ),
                                          ),
                                        ),
                                  )
                                  .toList(),
                              icon: controller.isServiceAreaLoading.value
                                  ? SizedBox(
                                      height: 16.r,
                                      width: 16.r,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.gradientStart,
                                      ),
                                    )
                                  : Icon(
                                      Icons.arrow_drop_down_outlined,
                                      color: AppColors.neutral700,
                                    ),
                              onChanged: controller.isServiceAreaLoading.value
                                  ? null
                                  : controller.selectServiceArea,
                            ),
                          ),
                        ),
                        if (!controller.isServiceAreaLoading.value &&
                            controller.serviceAreas.isEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 6.h),
                            child: Text(
                              AppStrings.noServiceAreasAvailable,
                              style: interTextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.neutral300,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  CustomTextField(
                    label: 'Address Line 1',
                    star: ' *',
                    placeholder: 'Enter address line 1',
                    controller: controller.addressLine1Controller,
                  ),
                  SizedBox(height: 16.h),
                  CustomTextField(
                    label: 'Address Line 2',
                    placeholder: 'Enter address line 2',
                    controller: controller.addressLine2Controller,
                  ),
                  SizedBox(height: 16.h),
                  CustomTextField(
                    label: 'City',
                    star: ' *',
                    placeholder: 'Enter city',
                    controller: controller.cityController,
                  ),
                  SizedBox(height: 16.h),
                  CustomTextField(
                    label: 'State',
                    star: ' *',
                    placeholder: 'Enter state',
                    controller: controller.stateController,
                  ),
                  SizedBox(height: 16.h),
                  CustomTextField(
                    label: 'Zip Code',
                    star: ' *',
                    placeholder: 'Enter zip code',
                    controller: controller.zipCodeController,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 24.h),

                  /// Installation Surface label
                  Text(
                    AppStrings.installationSurface,
                    style: interTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.neutral800,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  /// Surface options grid
                  Row(
                    children: [
                      /// Door button
                      Expanded(
                        child: Obx(
                          () => _buildSurfaceButton(
                            label: AppStrings.door,
                            isSelected:
                                controller.selectedSurface.value ==
                                AppStrings.door,
                            onTap: () =>
                                controller.selectSurface(AppStrings.door),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),

                      /// Wall button
                      Expanded(
                        child: Obx(
                          () => _buildSurfaceButton(
                            label: AppStrings.wall,
                            isSelected:
                                controller.selectedSurface.value ==
                                AppStrings.wall,
                            onTap: () =>
                                controller.selectSurface(AppStrings.wall),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      /// Glass button
                      Expanded(
                        child: Obx(
                          () => _buildSurfaceButton(
                            label: AppStrings.glass,
                            isSelected:
                                controller.selectedSurface.value ==
                                AppStrings.glass,
                            onTap: () =>
                                controller.selectSurface(AppStrings.glass),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),

                      /// Other button
                      Expanded(
                        child: Obx(
                          () => _buildSurfaceButton(
                            label: AppStrings.other,
                            isSelected:
                                controller.selectedSurface.value ==
                                AppStrings.other,
                            onTap: () =>
                                controller.selectSurface(AppStrings.other),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          /// Back and Next buttons
          Row(
            children: [
              /// Back button
              Expanded(
                child: CustomButton(
                  text: AppStrings.back,
                  // textColor: AppColors.neutral700,
                  onPressed: controller.previousStep,
                ),
              ),
              SizedBox(width: 12.w),

              /// Next button
              Expanded(
                child: CustomButton(
                  text: AppStrings.nextPhotos,
                  onPressed: controller.nextStep,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  /// Build surface selection button
  Widget _buildSurfaceButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : AppColors.neutral25,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.borderColor,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: poppinsTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? AppColors.neutral25 : AppColors.neutral700,
            ),
          ),
        ),
      ),
    );
  }
}

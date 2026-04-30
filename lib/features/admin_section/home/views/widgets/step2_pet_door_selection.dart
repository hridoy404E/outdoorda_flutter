import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/features/admin_section/home/controllers/create_new_job_controller.dart';
import 'package:outdoorda_flutter/features/admin_section/home/views/widgets/job_input_field.dart';
import 'package:outdoorda_flutter/features/admin_section/home/views/widgets/step_indicator_widget.dart';

/// Step 2: Pet Door Selection
/// 3 input fields with Back and Next buttons
class Step2PetDoorSelection extends StatelessWidget {
  const Step2PetDoorSelection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateNewJobController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Step indicator
        const StepIndicatorWidget(currentStep: 1),
        SizedBox(height: 16.h),

        /// Pet Door Type
        JobInputField(
          label: AppStrings.petDoorType,
          controller: controller.petDoorTypeController,
        ),
        SizedBox(height: 16.h),

        /// Door Model
        JobInputField(
          label: AppStrings.doorModel,
          controller: controller.doorModelController,
        ),
        SizedBox(height: 16.h),

        /// Installation Type
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.installationType,
              style: figtreeTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.textColor,
              ),
            ),
            SizedBox(height: 4.h),
            Container(
              height: 46.h,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.inputBorderColor),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Obx(
                () => DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedInstallationSurface.value,
                    isExpanded: true,
                    hint: Text(
                      'Select surface',
                      style: montserratTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.secondary500,
                      ),
                    ),
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.secondary500,
                    ),
                    style: montserratTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.secondary500,
                    ),
                    items: CreateNewJobController.installationSurfaceOptions
                        .map(
                          (surface) => DropdownMenuItem<String>(
                            value: surface,
                            child: Text(surface),
                          ),
                        )
                        .toList(),
                    onChanged: controller.setInstallationSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),

        /// Back and Next buttons
        Row(
          children: [
            /// Back button
            GestureDetector(
              onTap: controller.previousStep,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
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

            /// Next button
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
                    onTap: controller.nextStep,
                    borderRadius: BorderRadius.circular(8.r),
                    child: Center(
                      child: Text(
                        AppStrings.nextPricing,
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
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_button.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_text_field.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import '../../controllers/new_service_controller.dart';

class Step1 extends StatelessWidget {
  const Step1({super.key, required this.controller});

  final NewServiceController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Subtitle
        Text(
          AppStrings.letsStartWithWhoThisDoorIsFor,
          style: interTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.neutral700,
          ),
        ),
        SizedBox(height: 24.h),

        /// Pet Name field
        CustomTextField(
          label: AppStrings.petName,
          placeholder: AppStrings.petNamePlaceholder,
          controller: controller.petNameController,
        ),
        SizedBox(height: 16.h),

        // CustomTextField(
        //   label: 'Adjust Price',
        //   placeholder: '\$ Enter the price',
        //   controller: controller.priceController,
        // ),
        // SizedBox(height: 16.h),
        CustomTextField(
          label: AppStrings.type,
          placeholder: AppStrings.typePlaceholder,
          controller: controller.typeController,
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          label: AppStrings.size,
          placeholder: AppStrings.sizePlaceholder,
          controller: controller.sizeController,
        ),

        const Spacer(),

        /// Next button
        CustomButton(
          text: AppStrings.nextInstallation,
          onPressed: controller.nextStep,
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}

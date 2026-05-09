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
          label: 'Customer Name',
          star: ' *',
          placeholder: 'Enter customer name',
          controller: controller.customerNameController,
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          label: 'Email',
          star: ' *',
          placeholder: 'Enter email',
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          label: 'Phone',
          star: ' *',
          placeholder: 'Enter phone number',
          controller: controller.phoneController,
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          label: AppStrings.petName,
          star: ' *',
          placeholder: AppStrings.petNamePlaceholder,
          controller: controller.petNameController,
        ),
        SizedBox(height: 16.h),

        CustomTextField(
          label: AppStrings.type,
          star: ' *',
          placeholder: AppStrings.typePlaceholder,
          controller: controller.typeController,
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          label: AppStrings.size,
          star: ' *',
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

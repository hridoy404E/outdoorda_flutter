import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_button.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/features/admin_section/home/controllers/create_new_job_controller.dart';
import 'package:outdoorda_flutter/features/admin_section/home/views/widgets/job_input_field.dart';
import 'package:outdoorda_flutter/features/admin_section/home/views/widgets/step_indicator_widget.dart';

/// Step 1: Customer & Pet Details
/// 7 input fields with gradient button
class Step1CustomerPetDetails extends StatelessWidget {
  const Step1CustomerPetDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateNewJobController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Step indicator
        const StepIndicatorWidget(currentStep: 0),
        SizedBox(height: 16.h),

        /// Customer Name
        JobInputField(
          label: "${AppStrings.customerName}* ",
          controller: controller.customerNameController,
        ),
        SizedBox(height: 16.h),

        /// Email
        JobInputField(
          label: "${AppStrings.email}* ",
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 16.h),

        /// Phone
        JobInputField(
          label: "${AppStrings.phone}* ",
          controller: controller.phoneController,
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: 16.h),

        JobInputField(
          label: 'Address Line 1*',
          controller: controller.addressLine1Controller,
        ),
        SizedBox(height: 16.h),

        JobInputField(
          label: 'Address Line 2',
          controller: controller.addressLine2Controller,
        ),
        SizedBox(height: 16.h),

        JobInputField(label: 'City*', controller: controller.cityController),
        SizedBox(height: 16.h),

        JobInputField(label: 'State*', controller: controller.stateController),
        SizedBox(height: 16.h),

        JobInputField(
          label: 'Zip Code*',
          controller: controller.zipCodeController,
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 16.h),

        /// Pet Name
        JobInputField(
          label: '${AppStrings.petName}*',
          controller: controller.petNameController,
        ),
        SizedBox(height: 16.h),

        /// Pet Type
        JobInputField(
          label: '${AppStrings.petType}*',
          controller: controller.petTypeController,
        ),
        SizedBox(height: 16.h),

        /// Pet Size
        JobInputField(
          label: '${AppStrings.petSize}*',
          controller: controller.petSizeController,
        ),
        SizedBox(height: 24.h),

        /// Next button
        CustomButton(
          text: AppStrings.nextPetDoorSelection,
          onPressed: controller.nextStep,
        ),
      ],
    );
  }
}

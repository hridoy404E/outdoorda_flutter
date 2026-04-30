import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import '../../controllers/new_service_controller.dart';
import '../widgets/step1.dart';
import '../widgets/step2.dart';
import '../widgets/step3.dart';

/// Bottom sheet for adding new service request with 3 steps
class NewServiceScreen extends StatelessWidget {
  const NewServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NewServiceController>();

    return Container(
      height: 500.h,
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Header
              _buildHeader(),
              SizedBox(height: 24.h),

              /// Progress indicator
              Obx(() => _buildProgressIndicator(controller.currentStep.value)),
              SizedBox(height: 24.h),

              /// Content based on current step
              Expanded(
                child: Obx(() {
                  switch (controller.currentStep.value) {
                    case 0:
                      return Step1(controller: controller);
                    case 1:
                      return Step2(controller: controller);
                    case 2:
                      return Step3(controller: controller);
                    default:
                      return Step1(controller: controller);
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build header with title
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.requestService,
          style: poppinsTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral800,
          ),
        ),
      ],
    );
  }

  /// Build progress indicator with 3 steps
  Widget _buildProgressIndicator(int currentStep) {
    return Row(
      children: [
        /// Step 1
        Expanded(
          child: Container(
            height: 4.h,
            decoration: BoxDecoration(
              gradient: currentStep >= 0 ? AppColors.primaryGradient : null,
              color: currentStep >= 0 ? null : Colors.white,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ),
        SizedBox(width: 8.w),

        /// Step 2
        Expanded(
          child: Container(
            height: 4.h,
            decoration: BoxDecoration(
              gradient: currentStep >= 1 ? AppColors.primaryGradient : null,
              color: currentStep >= 1 ? null : Colors.white,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ),
        SizedBox(width: 8.w),

        /// Step 3
        Expanded(
          child: Container(
            height: 4.h,
            decoration: BoxDecoration(
              gradient: currentStep >= 2 ? AppColors.primaryGradient : null,
              color: currentStep >= 2 ? null : Colors.white,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ),
      ],
    );
  }
}

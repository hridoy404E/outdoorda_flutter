import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/features/admin_section/home/controllers/create_new_job_controller.dart';
import 'package:outdoorda_flutter/features/admin_section/home/views/widgets/step1_customer_pet_details.dart';
import 'package:outdoorda_flutter/features/admin_section/home/views/widgets/step2_pet_door_selection.dart';
import 'package:outdoorda_flutter/features/admin_section/home/views/widgets/step3_pricing_site_photos.dart';
import 'package:outdoorda_flutter/features/admin_section/home/views/widgets/step4_select_installers.dart';

/// Create New Job Bottom Sheet
/// 4-step slider form for creating new jobs
class CreateNewJobBottomSheet extends StatelessWidget {
  const CreateNewJobBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateNewJobController());

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          /// Header with title and divider
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    _getStepTitle(controller.currentStep.value),
                    style: figtreeTextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral900,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(height: 1, color: AppColors.dividerColor),
              ],
            ),
          ),

          /// PageView with 4 steps
          Expanded(
            child: PageView(
              controller: controller.pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                controller.currentStep.value = index;
              },
              children: const [
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Step1CustomerPetDetails(),
                ),
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Step2PetDoorSelection(),
                ),
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Step3PricingSitePhotos(),
                ),
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Step4SelectInstallers(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Get step title based on current step
  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return AppStrings.customerAndPetDetails;
      case 1:
        return AppStrings.petDoorSelection;
      case 2:
        return AppStrings.pricingAndSitePhotos;
      case 3:
        return AppStrings.selectInstallers;
      default:
        return AppStrings.customerAndPetDetails;
    }
  }
}

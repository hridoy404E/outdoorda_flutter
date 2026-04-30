import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_button.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';

import '../../controllers/installer_setting_controller.dart';

class PaymentInformationWidget extends StatelessWidget {
  const PaymentInformationWidget({super.key, required this.controller});

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
              Icon(Icons.credit_card, size: 32.r, color: AppColors.textNormal),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  AppStrings.paymentInformation,
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
          SizedBox(height: 16.h),

          Obx(() {
            final isLaunching = controller.isLaunchingStripeOnboarding.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: AppColors.neutral25,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Text(
                    'Set up Stripe to receive payments.',
                    style: figtreeTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.settingsTextSecondary,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                CustomButton(
                  text: 'Setup Payment',
                  isLoading: isLaunching,
                  onPressed: controller.startPaymentSetupProcess,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

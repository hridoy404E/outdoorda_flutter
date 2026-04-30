import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_button.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/features/global_section/authentication/login/controllers/login_controller.dart';

class InstallerPaymentSetupScreen extends StatelessWidget {
  const InstallerPaymentSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Center(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: AppColors.neutral25,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Obx(
                () => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 52.r,
                      color: AppColors.textNormal,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Link Your Payment Account',
                      textAlign: TextAlign.center,
                      style: figtreeTextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral800,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'You can setup Stripe now or skip and complete it later from Settings.',
                      textAlign: TextAlign.center,
                      style: interTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.neutral700,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    CustomButton(
                      text: 'Link Account',
                      isLoading: controller.isLaunchingStripeOnboarding.value,
                      onPressed: controller.startInstallerAccountLinking,
                    ),
                    SizedBox(height: 12.h),
                    _SecondaryButton(
                      text: 'I Have Setup Link',
                      isLoading:
                          controller.isCheckingInstallerPaymentReady.value,
                      onPressed:
                          controller.confirmInstallerPaymentReadyAndContinue,
                    ),
                    SizedBox(height: 12.h),
                    // _SecondaryButton(
                    //   text: 'Logout',
                    //   isLoading: controller.isLoggingOut.value,
                    //   onPressed: controller.logoutFromPaymentSetup,
                    // ),
                    // SizedBox(height: 12.h),
                    _SecondaryButton(
                      text: 'Skip for Now',
                      isLoading: false,
                      onPressed:
                          controller.skipInstallerPaymentSetupAndContinue,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Complete the Stripe page, then return and tap "I Have Setup Link", or use Settings later.',
                      textAlign: TextAlign.center,
                      style: interTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.neutral300,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.text,
    required this.onPressed,
    required this.isLoading,
  });

  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          height: 46.h,
          decoration: BoxDecoration(
            color: AppColors.neutral25,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.textNormal),
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 18.r,
                    height: 18.r,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    text,
                    style: interTextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textNormal,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

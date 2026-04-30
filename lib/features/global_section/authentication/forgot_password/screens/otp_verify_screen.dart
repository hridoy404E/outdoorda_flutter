import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_button.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/features/global_section/authentication/forgot_password/controllers/otp_verify_controller.dart';

/// OTP Verify Screen - Similar design to Email Verify
/// User enters OTP code received via email
class OtpVerifyScreen extends StatelessWidget {
  const OtpVerifyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OtpVerifyController>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Form(
              key: controller.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// Header Section
                  _buildHeader(controller),
                  SizedBox(height: 48.h),

                  /// OTP Input Fields
                  _buildOtpFields(controller),
                  SizedBox(height: 24.h),

                  /// Verify OTP Button
                  Obx(
                    () => CustomButton(
                      text: AppStrings.verifyOTP,
                      onPressed: controller.verifyOTP,
                      isLoading: controller.isLoading.value,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  /// Resend OTP Link
                  _buildResendLink(controller),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Header with title and subtitle
  Widget _buildHeader(OtpVerifyController controller) {
    return Obx(
      () => Column(
        children: [
          /// Title
          Text(
            AppStrings.otpVerificationTitle,
            textAlign: TextAlign.center,
            style: figtreeTextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral800,
            ),
          ),
          SizedBox(height: 10.h),

          /// Subtitle with backend response message
          Text(
            controller.verificationMessage.value,
            textAlign: TextAlign.center,
            style: figtreeTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.neutral700,
            ),
          ),
        ],
      ),
    );
  }

  /// OTP Input Fields (6 digits)
  Widget _buildOtpFields(OtpVerifyController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) => _buildOtpBox(controller, index)),
    );
  }

  /// Single OTP input box
  Widget _buildOtpBox(OtpVerifyController controller, int index) {
    return SizedBox(
      width: 45.w,
      height: 50.h,
      child: TextFormField(
        controller: controller.otpControllers[index],
        focusNode: controller.focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: figtreeTextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral800,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppColors.neutral25,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: AppColors.borderColor, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: AppColors.borderColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: AppColors.gradientStart, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: AppColors.error, width: 1),
          ),
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) => controller.onOtpChanged(value, index),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '';
          }
          return null;
        },
      ),
    );
  }

  /// Resend OTP link
  Widget _buildResendLink(OtpVerifyController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.didNotReceiveCode,
          style: interTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.neutral700,
          ),
        ),
        SizedBox(width: 4.w),
        Obx(
          () => TextButton(
            onPressed: controller.canResend.value ? controller.resendOTP : null,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              controller.canResend.value
                  ? AppStrings.resendOTP
                  : 'Wait ${controller.formattedResendTimer}',
              style: interTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: controller.canResend.value
                    ? AppColors.gradientStart
                    : AppColors.neutral300,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

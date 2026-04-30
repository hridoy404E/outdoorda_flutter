import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_button.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_text_field.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/core/utils/validators/app_validator.dart';
import 'package:outdoorda_flutter/features/global_section/authentication/forgot_password/controllers/email_verify_controller.dart';

/// Email Verify Screen - Pixel-perfect Figma implementation
/// User enters email to receive password reset link
class EmailVerifyScreen extends StatelessWidget {
  const EmailVerifyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EmailVerifyController>();

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
                  _buildHeader(),
                  SizedBox(height: 48.h),

                  /// Email Input Field
                  CustomTextField(
                    label: AppStrings.emailLabel,
                    placeholder: AppStrings.emailPlaceholder,
                    controller: controller.emailController,
                    validator: AppValidator.validateEmail,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.mail_outline,
                    showHelpIcon: true,
                  ),
                  SizedBox(height: 24.h),

                  /// Send Reset Link Button
                  Obx(
                    () => CustomButton(
                      text: AppStrings.sendResetPasswordLink,
                      onPressed: controller.sendResetLink,
                      isLoading: controller.isLoading.value,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Header with title and subtitle
  Widget _buildHeader() {
    return Column(
      children: [
        /// Title
        Text(
          AppStrings.forgotPasswordTitle,
          textAlign: TextAlign.center,
          style: figtreeTextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral800,
          ),
        ),
        SizedBox(height: 10.h),

        /// Subtitle
        Text(
          AppStrings.forgotPasswordSubtitle,
          textAlign: TextAlign.center,
          style: figtreeTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.neutral700,
          ),
        ),
      ],
    );
  }
}

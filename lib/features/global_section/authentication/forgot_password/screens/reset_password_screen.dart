import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_button.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_text_field.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/core/utils/validators/app_validator.dart';
import 'package:outdoorda_flutter/features/global_section/authentication/forgot_password/controllers/reset_password_controller.dart';

/// Reset Password Screen - Pixel-perfect Figma implementation
/// User enters new password and confirms it
class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ResetPasswordController>();

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

                  /// Password Input Field
                  CustomTextField(
                    label: AppStrings.passwordLabel,
                    placeholder: AppStrings.passwordPlaceholder,
                    controller: controller.passwordController,
                    validator: AppValidator.validatePassword,
                    obscureText: true,
                  ),
                  SizedBox(height: 20.h),

                  /// Confirm Password Input Field
                  CustomTextField(
                    label: AppStrings.confirmPasswordLabel,
                    placeholder: AppStrings.confirmPasswordPlaceholder,
                    controller: controller.confirmPasswordController,
                    validator: (value) => AppValidator.validateConfirmPassword(
                      value,
                      controller.passwordController.text,
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 24.h),

                  /// Reset Password Button
                  Obx(
                    () => CustomButton(
                      text: AppStrings.resetPassword,
                      onPressed: controller.resetPassword,
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
          AppStrings.resetPasswordTitle,
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
          AppStrings.resetPasswordSubtitle,
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

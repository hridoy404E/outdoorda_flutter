import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_button.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_text_field.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/features/global_section/authentication/create_account/controllers/create_account_controller.dart';

/// Create account screen with pixel-perfect Figma implementation
/// User type tabs (Installer/Customer), full name, email, password fields
/// Agreement checkbox with license and privacy policy links
class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateAccountController>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40.h),

                /// Create your account heading
                Text(
                  AppStrings.createYourAccount,
                  style: figtreeTextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral800,
                  ),
                ),
                SizedBox(height: 16.h),

                /// Description
                Text(
                  AppStrings.enterEmailPasswordCreate,
                  style: interTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.neutral700,
                  ),
                ),
                SizedBox(height: 32.h),

                /// User type tabs (Installer/Customer)
                Obx(
                  () => Container(
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: AppColors.neutral25,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: AppColors.borderColor,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: controller.userTypes.map((type) {
                        final isSelected =
                            controller.selectedUserType.value == type;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => controller.selectUserType(type),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? AppColors.primaryGradient
                                    : null,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Center(
                                child: Text(
                                  type,
                                  style: interTextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.neutral25
                                        : AppColors.neutral300,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                /// Full name field
                CustomTextField(
                  label: AppStrings.fullName,
                  placeholder: AppStrings.enterYourFullName,
                  controller: controller.fullNameController,
                  validator: controller.validateFullName,
                  keyboardType: TextInputType.name,
                ),
                SizedBox(height: 16.h),

                /// Email field
                CustomTextField(
                  label: AppStrings.email,
                  placeholder: AppStrings.enterYourEmail,
                  controller: controller.emailController,
                  validator: controller.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.mail_outline,
                ),
                SizedBox(height: 16.h),

                /// Password field
                CustomTextField(
                  label: AppStrings.password,
                  placeholder: AppStrings.enterYourPassword,
                  controller: controller.passwordController,
                  validator: controller.validatePassword,
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                ),
                SizedBox(height: 16.h),

                /// Confirm password field
                CustomTextField(
                  label: AppStrings.confirmPassword,
                  placeholder: AppStrings.confirmYourPassword,
                  controller: controller.confirmPasswordController,
                  validator: controller.validateConfirmPassword,
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                ),
                SizedBox(height: 16.h),

                /// Agreement checkbox with links
                Obx(
                  () => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Agreement checkbox
                      SizedBox(
                        width: 20.r,
                        height: 20.r,
                        child: Checkbox(
                          value: controller.agreeToTerms.value,
                          onChanged: controller.toggleAgreement,
                          activeColor: AppColors.gradientStart,
                          side: BorderSide(
                            color: AppColors.neutral700,
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),

                      /// Agreement text with links
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: interTextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.neutral700,
                            ),
                            children: [
                              TextSpan(text: AppStrings.iAgreeToThetaAnalyzer),
                              TextSpan(
                                text: AppStrings.licenseAgreement,
                                style: interTextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gradientStart,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = controller.openLicenseAgreement,
                              ),
                              TextSpan(text: AppStrings.and),
                              TextSpan(
                                text: AppStrings.privacyPolicy,
                                style: interTextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gradientStart,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = controller.openPrivacyPolicy,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),

                /// Register button
                Obx(
                  () => CustomButton(
                    text: AppStrings.registerNow,
                    onPressed: controller.register,
                    isLoading: controller.isLoading.value,
                  ),
                ),
                SizedBox(height: 24.h),

                /// Login navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.alreadyHaveAccount,
                      style: interTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.neutral700,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    GestureDetector(
                      onTap: controller.navigateToLogin,
                      child: Text(
                        AppStrings.logInNow,
                        style: interTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gradientStart,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

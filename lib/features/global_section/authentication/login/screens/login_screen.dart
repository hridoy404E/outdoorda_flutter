import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_button.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_text_field.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import '../controllers/login_controller.dart';

/// Login screen with pixel-perfect Figma implementation
/// User type tabs, email/password fields, remember me, forgot password
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 50.h),

                /// Welcome back heading
                Text(
                  AppStrings.welcomeBack,
                  style: figtreeTextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral800,
                  ),
                ),
                SizedBox(height: 8.h),

                /// Description
                Text(
                  textAlign: TextAlign.center,
                  AppStrings.enterEmailPasswordAccess,
                  style: interTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.neutral700,
                  ),
                ),
                SizedBox(height: 32.h),

                /// Email field
                CustomTextField(
                  label: AppStrings.email,
                  placeholder: AppStrings.enterYourEmail,
                  controller: controller.emailController,
                  // validator: controller.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.mail_outline,
                ),
                SizedBox(height: 16.h),

                /// Password field
                CustomTextField(
                  label: AppStrings.password,
                  placeholder: AppStrings.enterYourPassword,
                  controller: controller.passwordController,
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    /// Forgot password link
                    GestureDetector(
                      onTap: controller.navigateToForgotPassword,
                      child: Text(
                        AppStrings.forgotPassword,
                        style: interTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.gradientStart,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),

                /// Login button
                CustomButton(
                  text: AppStrings.logIn,
                  onPressed: () => controller.login(_formKey),
                  // isLoading: controller.isLoading.value,
                ),
                SizedBox(height: 24.h),

                /// Create account navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.dontHaveAccount,
                      style: interTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.neutral700,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    GestureDetector(
                      onTap: controller.navigateToCreateAccount,
                      child: Text(
                        AppStrings.registerNow,
                        style: interTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gradientStart,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

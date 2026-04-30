import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_button.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/features/global_section/authentication/signup_otp/controllers/signup_otp_controller.dart';

class SignupOtpScreen extends StatelessWidget {
  const SignupOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SignupOtpController>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Verify OTP',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.neutral800,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24.h),
                Text(
                  AppStrings.otpVerificationSubtitle,
                  style: TextStyle(color: AppColors.neutral700, fontSize: 14),
                ),
                SizedBox(height: 16.h),
                Text(
                  controller.message,
                  style: TextStyle(fontSize: 12, color: AppColors.neutral700),
                ),
                SizedBox(height: 32.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    6,
                    (index) => SizedBox(
                      width: 40.w,
                      height: 52.h,
                      child: TextFormField(
                        controller: controller.otpControllers[index],
                        focusNode: controller.focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: AppColors.neutral25,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide(
                              color: AppColors.borderColor,
                              width: 1,
                            ),
                          ),
                        ),
                        onChanged: (value) =>
                            controller.onOtpChanged(value, index),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
                Obx(
                  () => CustomButton(
                    text: AppStrings.verifyOTP,
                    onPressed: controller.verifyOtp,
                    isLoading: controller.isLoading.value,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

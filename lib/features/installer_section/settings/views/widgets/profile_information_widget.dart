import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_text_field.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import '../../controllers/installer_setting_controller.dart';

class ProfileInformationWidget extends StatelessWidget {
  const ProfileInformationWidget({super.key, required this.controller});

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
              Icon(
                Icons.person_outline,
                size: 32.r,
                color: AppColors.textNormal,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  AppStrings.profileInformation,
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
          SizedBox(height: 8.h),

          /// Profile Image Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                ImageProvider? imageProvider;
                if (controller.profileImagePath.value.isNotEmpty) {
                  imageProvider = FileImage(
                    File(controller.profileImagePath.value),
                  );
                } else if (controller.profileImageUrl.value.isNotEmpty) {
                  imageProvider = NetworkImage(
                    controller.profileImageUrl.value,
                  );
                }

                return Container(
                  width: 62.w,
                  height: 62.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.neutral300,
                    image: imageProvider != null
                        ? DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: imageProvider == null
                      ? Icon(
                          Icons.person,
                          size: 30.r,
                          color: AppColors.neutral25,
                        )
                      : null,
                );
              }),
              SizedBox(height: 8.h),
              Row(
                children: [
                  /// Name and Email
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => Text(
                            controller.displayName.value,
                            style: figtreeTextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.settingsTextPrimary,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Obx(
                          () => Text(
                            controller.displayEmail.value,
                            style: figtreeTextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.settingsTextPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Change Photo Button
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: InkWell(
                      onTap: controller.changeProfilePhoto,
                      borderRadius: BorderRadius.circular(8.r),
                      child: Text(
                        AppStrings.changePhoto,
                        style: figtreeTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24.h),

          /// Form Fields
          CustomTextField(
            label: AppStrings.fullName,
            placeholder: '',
            controller: controller.fullNameController,
            validator: controller.validateFullName,
          ),
          SizedBox(height: 16.h),
          CustomTextField(
            label: AppStrings.emailAddress,
            placeholder: '',
            controller: controller.emailController,
            validator: controller.validateEmail,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 16.h),
          CustomTextField(
            label: AppStrings.phoneNumber,
            placeholder: '',
            controller: controller.phoneController,
            validator: controller.validatePhoneNumber,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            showCounter: true,
          ),
          SizedBox(height: 24.h),

          /// Save Button
          Obx(
            () => InkWell(
              onTap: controller.isSavingProfile.value
                  ? null
                  : controller.saveProfileChanges,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.settingsBorderSky),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  AppStrings.saveProfileChanges,
                  textAlign: TextAlign.center,
                  style: figtreeTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.settingsBorderSky,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

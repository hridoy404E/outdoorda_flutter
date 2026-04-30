import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_button.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_text_field.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/core/utils/validators/app_validator.dart';
import 'package:outdoorda_flutter/features/customer_section/settings/controllers/customar_setting_controller.dart';

/// Edit Profile Dialog
/// Shows a dialog to edit user profile information
/// Similar to project's authentication pattern
class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({super.key});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final controller = Get.find<CustomerSettingController>();
    _nameController.text = controller.userName.value;
    _emailController.text = controller.userEmail.value;
    _phoneController.text = controller.userPhone.value;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CustomerSettingController>();

    return Dialog(
      backgroundColor: AppColors.bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Container(
        constraints: BoxConstraints(maxHeight: 450.h),
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title
            Text(
              AppStrings.editProfile,
              style: figtreeTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.settingsTextTitle,
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() {
                  ImageProvider? imageProvider;
                  if (controller.userPhotoPath.value.isNotEmpty) {
                    imageProvider = FileImage(File(controller.userPhotoPath.value));
                  } else if (controller.userPhotoUrl.value.isNotEmpty) {
                    imageProvider = NetworkImage(controller.userPhotoUrl.value);
                  }

                  return GestureDetector(
                    onTap: controller.changeProfilePhoto,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 40.r,
                          backgroundColor: AppColors.blackTextSecondary,
                          backgroundImage: imageProvider,
                          child: imageProvider == null
                              ? Icon(
                                  Icons.person,
                                  size: 48.r,
                                  color: AppColors.neutral300,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0.h,
                          right: 0.h,
                          child: Container(
                            width: 24.r,
                            height: 24.r,
                            decoration: BoxDecoration(
                              color: AppColors.gradientEnd,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.bg,
                                width: 2.r,
                              ),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: AppColors.neutral25,
                              size: 16.r,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
            SizedBox(height: 8.h),
            Center(
              child: TextButton(
                onPressed: controller.changeProfilePhoto,
                child: Text(
                  AppStrings.changePhoto,
                  style: figtreeTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gradientEnd,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),

            /// Form
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      /// Name Field
                      CustomTextField(
                        label: AppStrings.name,
                        placeholder: AppStrings.namePlaceholder,
                        controller: _nameController,
                        validator: AppValidator.validateFullName,
                      ),
                      SizedBox(height: 20.h),

                      /// Email Field
                      CustomTextField(
                        label: AppStrings.emailLabel,
                        placeholder: AppStrings.emailPlaceholder,
                        controller: _emailController,
                        validator: AppValidator.validateEmail,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.mail_outline,
                      ),
                      SizedBox(height: 20.h),

                      /// Phone Number Field
                      CustomTextField(
                        label: AppStrings.phoneNumber,
                        placeholder: AppStrings.phoneNumberPlaceholder,
                        controller: _phoneController,
                        validator: AppValidator.validatePhoneNumber,
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_outlined,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 24.h),

            /// Update Button
            Obx(
              () => CustomButton(
                text: AppStrings.updateProfile,
                onPressed: _handleUpdate,
                isLoading: controller.isLoading.value,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handle profile update
  void _handleUpdate() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final controller = Get.find<CustomerSettingController>();
    controller.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
    );
  }
}

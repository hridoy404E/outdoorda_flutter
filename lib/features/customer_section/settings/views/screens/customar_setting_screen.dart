import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_appbar.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/features/customer_section/settings/controllers/customar_setting_controller.dart';
import 'package:outdoorda_flutter/features/customer_section/settings/models/pet_model.dart';
import 'package:outdoorda_flutter/features/customer_section/settings/views/widgets/add_pet_dialog.dart';
import 'package:outdoorda_flutter/features/customer_section/settings/views/widgets/edit_profile_dialog.dart';

/// Customer Settings Screen
/// 100% pixel-perfect implementation matching Figma design
/// Includes profile section, pets management, and settings options
class CustomerSettingScreen extends StatelessWidget {
  const CustomerSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CustomerSettingController>();

    return Obx(
      () => Scaffold(
        appBar: CustomAppBar(
          greetingText: AppStrings.goodMorning,
          userType: AppStrings.customer,
        ),
        body: controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : !controller.hasSettingsData
            ? _buildNoDataState()
            : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Settings Title
                      Text(
                        AppStrings.settings,
                        style: figtreeTextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.settingsTextTitle,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      /// Profile Card
                      _buildProfileCard(controller),
                      SizedBox(height: 16.h),

                      /// My Pets Card
                      _buildMyPetsCard(controller),
                      SizedBox(height: 16.h),

                      /// Settings Options
                      _buildSettingsOptions(controller),
                      SizedBox(height: 16.h),

                      /// Logout Button
                      _buildDeleteAccountButton(controller),
                      SizedBox(height: 16.h),

                      /// Logout Button
                      _buildLogoutButton(controller),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildNoDataState() {
    return Center(
      child: Text(
        'No data',
        style: figtreeTextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  /// Profile Card Widget
  Widget _buildProfileCard(CustomerSettingController controller) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: AppColors.settingsCardBg,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 24,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            /// Avatar and Info Row
            Row(
              children: [
                /// Avatar
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.neutral300,
                    image: controller.userPhotoUrl.value.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(controller.userPhotoUrl.value),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: controller.userPhotoUrl.value.isEmpty
                      ? Icon(
                          Icons.person,
                          size: 20.r,
                          color: AppColors.neutral25,
                        )
                      : null,
                ),
                SizedBox(width: 10.w),

                /// Name and Email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.userName.value,
                        style: figtreeTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.settingsTextPrimary,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        controller.userEmail.value,
                        style: figtreeTextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.settingsTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),

            /// Edit Profile Button
            _buildOutlineButton(
              text: AppStrings.editProfile,
              onPressed: () {
                Get.dialog(const EditProfileDialog());
              },
            ),
          ],
        ),
      ),
    );
  }

  /// My Pets Card Widget
  Widget _buildMyPetsCard(CustomerSettingController controller) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: AppColors.settingsCardBg,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 24,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title and Divider
            Text(
              AppStrings.myPets,
              style: figtreeTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.settingsTextPrimary,
              ),
            ),
            Divider(color: AppColors.borderColor, thickness: 1, height: 1),
            SizedBox(height: 14.h),

            /// Pet List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.pets.length,
              itemBuilder: (context, index) {
                final pet = controller.pets[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: _buildPetCard(pet, controller),
                );
              },
            ),

            /// Add New Pet Button
            _buildOutlineButton(
              text: AppStrings.addNewPet,
              onPressed: () {
                Get.dialog(const AddPetDialog());
              },
              showIcon: true,
            ),
          ],
        ),
      ),
    );
  }

  /// Individual Pet Card
  Widget _buildPetCard(Pet pet, CustomerSettingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.settingsPetCardBg,
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      child: Row(
        children: [
          /// Pet Avatar
          Container(
            width: 40.w,
            height: 40.h,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neutral300,
            ),
            child: Icon(Icons.pets, size: 20.r, color: AppColors.neutral25),
          ),
          SizedBox(width: 10.w),

          /// Pet Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: figtreeTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.settingsTextPrimary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  '${pet.size} ${pet.type}',
                  style: figtreeTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.settingsTextSecondary,
                  ),
                ),
              ],
            ),
          ),

          /// Edit Icon
          InkWell(
            onTap: () {
              Get.dialog(AddPetDialog(pet: pet));
            },
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.all(8.r),
              child: Icon(
                Icons.edit_outlined,
                size: 24.r,
                color: AppColors.settingsIconEdit,
              ),
            ),
          ),
          SizedBox(width: 4.w),

          /// Delete Icon
          InkWell(
            onTap: () => _confirmAndDeletePet(controller, pet),
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.all(8.r),
              child: Icon(
                Icons.delete_outline,
                size: 24.r,
                color: AppColors.settingsLogoutText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndDeletePet(
    CustomerSettingController controller,
    Pet pet,
  ) async {
    final shouldDelete = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Pet'),
        content: Text('Delete ${pet.name}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await controller.deletePet(pet.id);
    }
  }

  /// Settings Options Widget
  Widget _buildSettingsOptions(CustomerSettingController controller) {
    final options = [
      (
        title: AppStrings.notifications,
        onTap: () {
          controller.manageNotifications();
        },
      ),
      (title: AppStrings.paymentMethods, onTap: () {}),
      (
        title: AppStrings.changePassword,
        onTap: () {
          controller.changePassword();
        },
      ),
    ];

    return Column(
      children: [
        ...options.map(
          (option) => _buildSettingOption(option.title, onTap: option.onTap),
        ),
        _buildTwoFactorOption(controller),
      ],
    );
  }

  Widget _buildTwoFactorOption(CustomerSettingController controller) {
    return Obx(
      () => Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: AppColors.settingsWhite,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: controller.isTogglingTwoFactor.value
                ? null
                : () => controller.toggleTwoFactorAuth(),
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Two-Factor Authentication',
                          style: figtreeTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.settingsTextPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          controller.isTogglingTwoFactor.value
                              ? 'Updating security setting...'
                              : controller.twoFactorEnabled.value
                              ? 'Enabled for this account'
                              : 'Tap to enable extra sign-in protection',
                          style: figtreeTextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.settingsTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: controller.twoFactorEnabled.value,
                    onChanged: controller.isTogglingTwoFactor.value
                        ? null
                        : (_) => controller.toggleTwoFactorAuth(),
                    activeTrackColor: AppColors.settingsBorderSky,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Individual Setting Option
  Widget _buildSettingOption(String title, {required VoidCallback onTap}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.settingsWhite,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: figtreeTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.settingsTextPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 24.r,
                  color: AppColors.settingsTextPrimary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Logout Button Widget
  Widget _buildDeleteAccountButton(CustomerSettingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.settingsWhite,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.settingsLogoutText, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: controller.deleteAccount,
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            height: 40.h,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.delete_outline,
                  size: 20.r,
                  color: AppColors.settingsLogoutText,
                ),
                SizedBox(width: 8.w),
                Text(
                  AppStrings.deleteAccount,
                  style: figtreeTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.settingsLogoutText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Logout Button Widget
  Widget _buildLogoutButton(CustomerSettingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.settingsLogoutBg,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.settingsLogoutBorder, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: controller.logout,
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            height: 40.h,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout,
                  size: 20.r,
                  color: AppColors.settingsLogoutText,
                ),
                SizedBox(width: 8.w),
                Text(
                  AppStrings.logOut,
                  style: figtreeTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.settingsLogoutText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Outline Button Widget
  Widget _buildOutlineButton({
    required String text,
    required VoidCallback onPressed,
    bool showIcon = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.settingsBorderSky, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            height: 40.h,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showIcon) ...[
                  Icon(
                    Icons.add,
                    size: 20.r,
                    color: AppColors.settingsBorderSky,
                  ),
                  SizedBox(width: 8.w),
                ],
                Text(
                  text,
                  style: figtreeTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.settingsBorderSky,
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

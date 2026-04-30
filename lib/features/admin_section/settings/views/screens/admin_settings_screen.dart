import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_appbar.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_button.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/features/admin_section/settings/controllers/admin_settings_controller.dart';

/// Admin Settings Screen
/// Displays comprehensive settings for administrators including:
/// - Profile information management
/// - Contact information
/// - Notification preferences
/// - Job management settings
/// - Security settings
/// - Logout functionality
class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminSettingsController>();

    return Obx(
      () => Scaffold(
        backgroundColor: AppColors.bg,
        appBar: CustomAppBar(
          greetingText: 'Dashboard',
          userType: 'Real-time screening program management and compliance',
          profileImageUrl: controller.profileImageUrl.value.isEmpty
              ? null
              : controller.profileImageUrl.value,
        ),
        body: controller.isInitialLoading
            ? const Center(child: CircularProgressIndicator())
            : !controller.hasSettingsData
            ? _buildNoDataState()
            : SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Page Header
                    _buildPageHeader(),
                    SizedBox(height: 20.h),

                    /// Profile Information Section
                    _buildProfileInformationSection(controller),
                    SizedBox(height: 20.h),

                    /// Contact Information Section
                    _buildContactInformationSection(controller),
                    SizedBox(height: 20.h),

                    /// Notifications Section
                    _buildNotificationsSection(controller),
                    SizedBox(height: 20.h),

                    /// Stripe Payment Section
                    _buildStripePaymentSection(controller),
                    SizedBox(height: 20.h),

                    /// Job Management Settings Section
                    _buildJobManagementSection(controller),
                    SizedBox(height: 20.h),

                    /// Security Section
                    _buildSecuritySection(controller),
                    SizedBox(height: 30.h),

                    /// Logout Button
                    _buildLogoutButton(controller),
                    SizedBox(height: 10.h),
                  ],
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

  /// Page Header
  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: figtreeTextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'Manage your account and preferences',
          style: figtreeTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  /// Profile Information Section
  Widget _buildProfileInformationSection(AdminSettingsController controller) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Section Header
          _buildSectionHeader(
            icon: Icons.person_outline,
            title: 'Profile Information',
          ),
          SizedBox(height: 16.h),

          /// Profile Photo
          Obx(() {
            final imagePath = controller.profileImagePath.value;
            final imageUrl = controller.profileImageUrl.value;
            final name = controller.displayName.value;
            final email = controller.displayEmail.value;
            ImageProvider? imageProvider;
            if (imagePath.isNotEmpty) {
              imageProvider = FileImage(File(imagePath));
            } else if (imageUrl.isNotEmpty) {
              imageProvider = NetworkImage(imageUrl);
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                /// Profile Image
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 62.r,
                        height: 62.r,
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
                      ),
                      SizedBox(height: 14.h),
                      Text(
                        name,
                        style: figtreeTextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textNormal,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        email,
                        style: figtreeTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textNormal,
                        ),
                      ),
                    ],
                  ),
                ),

                /// Change Photo Button
                InkWell(
                  onTap: controller.changeProfilePhoto,
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'Change Photo',
                      style: figtreeTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.neutral25,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
          SizedBox(height: 24.h),

          /// Full Name Field
          _buildInputField(
            label: 'Full Name',
            controller: controller.fullNameController,
          ),
          SizedBox(height: 16.h),

          /// Email Address Field
          _buildInputField(
            label: 'Email Address',
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 16.h),

          /// Phone Number Field
          _buildInputField(
            label: 'Phone Number',
            controller: controller.phoneController,
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 24.h),

          /// Save Profile Changes Button
          _buildOutlineButton(
            text: 'Save Profile Changes',
            onPressed: controller.saveProfileChanges,
          ),
        ],
      ),
    );
  }

  /// Contact Information Section
  Widget _buildContactInformationSection(AdminSettingsController controller) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Section Header
          _buildSectionHeader(
            icon: Icons.business_outlined,
            title: 'Contact Information',
          ),
          SizedBox(height: 24.h),

          /// Email Field
          _buildInputField(
            label: 'Email',
            controller: controller.contactEmailController,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 16.h),

          /// Phone Field
          _buildInputField(
            label: 'Phone',
            controller: controller.contactPhoneController,
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 24.h),

          /// Update Contact Info Button
          _buildOutlineButton(
            text: 'Update Contact Info',
            onPressed: controller.updateContactInfo,
          ),
        ],
      ),
    );
  }

  /// Notifications Section
  Widget _buildNotificationsSection(AdminSettingsController controller) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Section Header
          _buildSectionHeader(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
          ),
          SizedBox(height: 24.h),

          /// Push Notifications Toggle
          Obx(
            () => _buildToggleItem(
              icon: Icons.notifications_active_outlined,
              title: 'Push Notifications',
              subtitle: 'Receive push notifications',
              value: controller.pushNotificationsEnabled.value,
              onChanged: (value) {
                controller.togglePushNotifications(value);
              },
            ),
          ),
          SizedBox(height: 24.h),

          /// Save Notification Settings Button
          _buildOutlineButton(
            text: 'Open Notification Settings',
            onPressed: controller.saveNotificationSettings,
          ),
        ],
      ),
    );
  }

  /// Stripe Payment Section
  Widget _buildStripePaymentSection(AdminSettingsController controller) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.credit_card_outlined,
            title: 'Stripe Payment Settings',
          ),
          SizedBox(height: 24.h),
          Obx(
            () => _buildToggleItem(
              icon: Icons.payments_outlined,
              title: 'Enable Stripe Payments',
              subtitle: controller.isLoadingStripePayments.value
                  ? 'Loading current Stripe payment status...'
                  : 'Turn customer Stripe payments on or off system-wide',
              value: controller.stripePaymentsEnabled.value,
              onChanged:
                  controller.isLoadingStripePayments.value ||
                      controller.isSavingStripePayments.value
                  ? (_) {}
                  : (value) {
                      controller.toggleStripePayments(value);
                    },
            ),
          ),
          SizedBox(height: 8.h),
          Obx(
            () => Text(
              controller.isSavingStripePayments.value
                  ? 'Updating Stripe payment status...'
                  : 'Changes apply immediately for the admin payment setting.',
              style: figtreeTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Job Management Settings Section
  Widget _buildJobManagementSection(AdminSettingsController controller) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Section Header
          _buildSectionHeader(
            icon: Icons.work_outline,
            title: 'Job Management Settings',
          ),
          SizedBox(height: 24.h),

          /// Auto-assign Jobs Toggle
          Obx(
            () => _buildToggleItem(
              icon: null,
              title: 'Auto-assign Jobs',
              subtitle: 'Automatically assign jobs to best-rated installers',
              value: controller.autoAssignJobsEnabled.value,
              onChanged: controller.toggleAutoAssignJobs,
            ),
          ),
          SizedBox(height: 16.h),

          /// Bid Response Timeout Field
          _buildInputField(
            label: 'Bid Response Timeout (hours)',
            controller: controller.bidTimeoutController,
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 8.h),

          Text(
            'Time installers have to respond to job offers',
            style: figtreeTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 24.h),
          Obx(
            () => _buildOutlineButton(
              text: controller.isSavingJobSettings.value
                  ? 'Saving...'
                  : 'Save Job Settings',
              onPressed: controller.isSavingJobSettings.value
                  ? () {}
                  : controller.saveJobManagementSettings,
            ),
          ),
        ],
      ),
    );
  }

  /// Security Section
  Widget _buildSecuritySection(AdminSettingsController controller) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Section Header
          _buildSectionHeader(icon: Icons.security_outlined, title: 'Security'),
          SizedBox(height: 24.h),

          /// Change Password Button
          CustomButton(
            text: 'Change Password',
            onPressed: controller.changePassword,
          ),
          SizedBox(height: 16.h),

          /// Two-Factor Authentication Toggle
          Obx(
            () => _buildToggleItem(
              icon: Icons.verified_user_outlined,
              title: 'Two-Factor Authentication',
              subtitle: controller.isTogglingTwoFactor.value
                  ? 'Updating security setting...'
                  : controller.twoFactorEnabled.value
                  ? 'Enabled for this account'
                  : 'Tap to add an extra login verification step',
              value: controller.twoFactorEnabled.value,
              onChanged: (_) => controller.toggleTwoFactorAuth(),
            ),
          ),
        ],
      ),
    );
  }

  /// Logout Button
  Widget _buildLogoutButton(AdminSettingsController controller) {
    return InkWell(
      onTap: controller.logout,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: double.infinity,
        height: 40.h,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF4D7D99), width: 1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 20.r, color: const Color(0xFF4D7D99)),
            SizedBox(width: 8.w),
            Text(
              'Logout',
              style: figtreeTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF4D7D99),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Section Header
  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 32.r,
              height: 32.r,
              decoration: BoxDecoration(
                color: AppColors.textNormal,
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Icon(icon, size: 20.r, color: AppColors.neutral25),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                title,
                style: figtreeTextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textNormal,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(height: 1, color: AppColors.dividerColor),
      ],
    );
  }

  /// Input Field
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: figtreeTextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.blackText,
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          height: 46.h,
          decoration: BoxDecoration(
            color: AppColors.neutral25,
            border: Border.all(color: const Color(0xFFEDF1F3), width: 1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: montserratTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF1A1C1E),
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 14.h,
              ),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  /// Toggle Item
  Widget _buildToggleItem({
    IconData? icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 24.r, color: AppColors.textNormal),
          SizedBox(width: 8.w),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: figtreeTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textNormal,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: figtreeTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        _buildCustomSwitch(value: value, onChanged: onChanged),
      ],
    );
  }

  /// Custom Switch
  Widget _buildCustomSwitch({
    required bool value,
    required Function(bool) onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 40.w,
        height: 24.h,
        decoration: BoxDecoration(
          gradient: value ? AppColors.primaryGradient : null,
          color: value ? null : const Color(0xFFC2CCD3),
          borderRadius: BorderRadius.circular(9999.r),
        ),
        padding: EdgeInsets.all(4.r),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 16.r,
          height: 16.r,
          decoration: BoxDecoration(
            color: AppColors.neutral25,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Outline Button
  Widget _buildOutlineButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: double.infinity,
        height: 40.h,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF4D7D99), width: 1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: figtreeTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF4D7D99),
          ),
        ),
      ),
    );
  }
}

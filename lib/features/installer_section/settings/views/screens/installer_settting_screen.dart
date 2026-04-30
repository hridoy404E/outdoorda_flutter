import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_appbar.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_button.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import '../../controllers/installer_setting_controller.dart';
import '../widgets/availability_widget.dart';
import '../widgets/notification_widget.dart';
import '../widgets/payment_widget.dart';
import '../widgets/profile_information_widget.dart';
import '../widgets/installer_profile_drawer.dart';
import '../widgets/service_area_widget.dart';

/// Installer Settings Screen
/// 100% Pixel-perfect implementation from Figma design
/// Includes profile, service area, availability, payment, notifications, security
class InstallerSettingScreen extends StatelessWidget {
  const InstallerSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InstallerSettingController>();
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Obx(
      () => Scaffold(
        key: scaffoldKey,
        appBar: CustomAppBar(
          greetingText: AppStrings.dashboard,
          userType: AppStrings.realTimeScreeningProgramManagement,
          profileImageUrl: controller.profileImageUrl.value.isEmpty
              ? null
              : controller.profileImageUrl.value,
          onProfileTap: () {
            controller.refreshUserProfileForDrawer();
            scaffoldKey.currentState?.openEndDrawer();
          },
        ),
        endDrawer: InstallerProfileDrawer(controller: controller),
        body: controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : !controller.hasSettingsData
            ? _buildNoDataState()
            : ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                children: [
                  /// Header Section
                  _buildHeaderSection(),
                  SizedBox(height: 24.h),

                  /// Profile Information Section
                  ProfileInformationWidget(controller: controller),
                  SizedBox(height: 24.h),

                  /// Service Area Section
                  ServiceAreaWidget(controller: controller),
                  SizedBox(height: 24.h),

                  /// Availability Section
                  AvailabilityWidget(controller: controller),
                  SizedBox(height: 24.h),

                  /// Payment Information Section
                  PaymentInformationWidget(controller: controller),
                  SizedBox(height: 24.h),

                  /// Notifications Section
                  NotificationWidget(controller: controller),
                  SizedBox(height: 24.h),

                  /// Security Section
                  _buildSecuritySection(controller),
                  SizedBox(height: 28.h),

                  /// Logout Button
                  _buildDeleteAccountButton(controller),
                  SizedBox(height: 16.h),

                  /// Logout Button
                  _buildLogoutButton(controller),
                  SizedBox(height: 10.h),
                ],
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

  /// Header Section
  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.settings,
          style: figtreeTextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          AppStrings.manageYourAccountAndPreferences,
          style: figtreeTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  /// Security Section
  Widget _buildSecuritySection(InstallerSettingController controller) {
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
              Icon(Icons.security, size: 32.r, color: AppColors.textNormal),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  AppStrings.security,
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
          SizedBox(height: 16.h),

          /// Change Password Button
          CustomButton(
            text: AppStrings.changePassword,
            onPressed: controller.changePassword,
          ),
          SizedBox(height: 16.h),

          /// Two-Factor Authentication Toggle
          Obx(
            () => Row(
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 24.r,
                  color: AppColors.settingsTextPrimary,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Two-Factor Authentication',
                        style: figtreeTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.settingsTextPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        controller.isTogglingTwoFactor.value
                            ? 'Updating security setting...'
                            : controller.twoFactorEnabled.value
                            ? 'Enabled for this account'
                            : 'Tap to add an extra login verification step',
                        style: figtreeTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.settingsTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                CupertinoSwitch(
                  value: controller.twoFactorEnabled.value,
                  onChanged: controller.isTogglingTwoFactor.value
                      ? null
                      : (_) => controller.toggleTwoFactorAuth(),
                  activeTrackColor: AppColors.gradientEnd,
                  inactiveTrackColor: AppColors.cardBorder,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Logout Button
  Widget _buildDeleteAccountButton(InstallerSettingController controller) {
    return InkWell(
      onTap: controller.deleteAccount,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.settingsLogoutText),
          borderRadius: BorderRadius.circular(8.r),
        ),
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
    );
  }

  /// Logout Button
  Widget _buildLogoutButton(InstallerSettingController controller) {
    return InkWell(
      onTap: controller.logout,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.settingsBorderSky),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 20.r, color: AppColors.settingsBorderSky),
            SizedBox(width: 8.w),
            Text(
              AppStrings.logout,
              style: figtreeTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.settingsBorderSky,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

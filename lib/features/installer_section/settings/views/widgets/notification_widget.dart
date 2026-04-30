import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';

import '../../controllers/installer_setting_controller.dart';

class NotificationWidget extends StatelessWidget {
  const NotificationWidget({super.key, required this.controller});

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
                Icons.notifications_outlined,
                size: 32.r,
                color: AppColors.textNormal,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  AppStrings.notifications,
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

          /// Push Notifications Toggle
          Row(
            children: [
              Icon(
                Icons.notifications_active_outlined,
                size: 24.r,
                color: AppColors.settingsTextPrimary,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.pushNotifications,
                      style: figtreeTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.settingsTextPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      AppStrings.receivePushNotifications,
                      style: figtreeTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.settingsTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Obx(
                () => CupertinoSwitch(
                  value: controller.pushNotificationsEnabled.value,
                  onChanged: (value) {
                    controller.togglePushNotifications(value);
                  },
                  activeTrackColor: AppColors.gradientEnd,
                  inactiveTrackColor: AppColors.cardBorder,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          /// Save Button
          Obx(
            () => InkWell(
              onTap: controller.isSavingNotifications.value
                  ? null
                  : controller.saveNotificationSettings,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.settingsBorderSky),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  AppStrings.openNotificationSettings,
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

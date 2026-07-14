import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_button.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/features/installer_section/settings/controllers/installer_setting_controller.dart';
import 'package:outdoorda_flutter/routes/app_routes.dart';

class InstallerProfileDrawer extends StatelessWidget {
  const InstallerProfileDrawer({super.key, required this.controller});

  final InstallerSettingController controller;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.86,
      backgroundColor: AppColors.bg,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 24.h),
          children: [
            Row(
              children: [
                Text(
                  'Profile Details',
                  style: figtreeTextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            _ProfileHeader(controller: controller),
            SizedBox(height: 18.h),
            _ProfileStats(controller: controller),
            SizedBox(height: 18.h),
            _InfoSection(controller: controller),
            SizedBox(height: 22.h),
            CustomButton(
              text: 'Payment Details',
              onPressed: () => _openPaymentDetails(context),
            ),
            SizedBox(height: 12.h),
            CustomButton(
              text: 'Pay Commission',
              onPressed: () => _openCommissionPayment(context),
            ),
          ],
        ),
      ),
    );
  }

  void _openPaymentDetails(BuildContext context) {
    Navigator.of(context).pop();
    Future.microtask(() {
      if (Get.currentRoute == AppRoute.getInstallerPaymentDetailsScreen()) {
        return;
      }
      Get.toNamed(AppRoute.getInstallerPaymentDetailsScreen());
    });
  }

  void _openCommissionPayment(BuildContext context) {
    Navigator.of(context).pop();
    Future.microtask(() {
      if (Get.currentRoute == AppRoute.getInstallerCommissionPaymentScreen()) {
        return;
      }
      Get.toNamed(AppRoute.getInstallerCommissionPaymentScreen());
    });
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.controller});

  final InstallerSettingController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final imageUrl = controller.profileImageUrl.value.trim();
      final name = controller.displayName.value.trim().isEmpty
          ? 'Installer'
          : controller.displayName.value.trim();
      final userId = controller.displayUserId.value.trim();

      return Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFFEBEFF1)),
        ),
        child: Row(
          children: [
            Container(
              width: 58.w,
              height: 58.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neutral300,
                image: imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl.isEmpty
                  ? Icon(Icons.person, size: 28.r, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: figtreeTextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    userId.isEmpty ? 'Installer ID unavailable' : userId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: figtreeTextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _ProfileStats extends StatelessWidget {
  const _ProfileStats({required this.controller});

  final InstallerSettingController controller;

  /// Local visibility toggle — `true` = values shown (default).
  static final ValueNotifier<bool> _isBalanceVisible =
      ValueNotifier<bool>(true);

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: r'$', decimalDigits: 2);

    return Obx(
      () {
        final earnings =
            formatter.format(controller.displayTotalEarnings.value);
        final commission = formatter.format(
          controller.displayPayableCommissionAmount.value,
        );

        return Column(
          children: [
            // Toggle row
            Align(
              alignment: Alignment.centerRight,
              child: ValueListenableBuilder<bool>(
                valueListenable: _isBalanceVisible,
                builder: (_, visible, __) => GestureDetector(
                  onTap: () => _isBalanceVisible.value = !visible,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        visible ? 'Hide Balance' : 'Show Balance',
                        style: figtreeTextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        visible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 18.r,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            // Stat boxes
            ValueListenableBuilder<bool>(
              valueListenable: _isBalanceVisible,
              builder: (_, visible, __) => Row(
                children: [
                  Expanded(
                    child: _StatBox(
                      label: 'Earnings',
                      value: visible ? earnings : '••••',
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _StatBox(
                      label: 'Commission',
                      value: visible ? commission : '••••',
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78.h,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: figtreeTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textNormal,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: figtreeTextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.controller});

  final InstallerSettingController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFFEBEFF1)),
        ),
        child: Column(
          children: [
            _InfoRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: controller.displayEmail.value,
            ),
            _InfoDivider(),
            _InfoRow(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: controller.displayPhone.value,
            ),
            _InfoDivider(),
            _InfoRow(
              icon: Icons.badge_outlined,
              label: 'Role',
              value: controller.displayRole.value,
            ),
            _InfoDivider(),
            _InfoRow(
              icon: Icons.verified_user_outlined,
              label: 'Status',
              value: controller.displayIsActive.value ? 'Active' : 'Inactive',
              valueColor: controller.displayIsActive.value
                  ? AppColors.success
                  : AppColors.error,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final cleanedValue = value.trim().isEmpty ? 'N/A' : value.trim();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 17.r, color: AppColors.textNormal),
          ),
          SizedBox(width: 10.w),
          SizedBox(
            width: 70.w,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: figtreeTextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              cleanedValue,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: figtreeTextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: valueColor ?? AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 1.h, color: const Color(0xFFEBEFF1));
  }
}

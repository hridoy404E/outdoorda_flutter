import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_appbar.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_button.dart';
import 'package:outdoorda_flutter/core/common/widgets/shimmer_placeholder.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/features/installer_section/management/controllers/installer_management_controller.dart';
import 'package:outdoorda_flutter/features/installer_section/management/views/widgets/management_item_card.dart';
import 'package:outdoorda_flutter/features/installer_section/settings/controllers/installer_setting_controller.dart';
import 'package:outdoorda_flutter/features/installer_section/settings/views/widgets/installer_profile_drawer.dart';
import 'package:outdoorda_flutter/routes/app_routes.dart';

/// Installer management screen - 100% Figma pixel-perfect implementation
/// Background: #EBE8E3, Content width: 330w with 14w left margin
class InstallerManagementScreen extends StatelessWidget {
  const InstallerManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InstallerManagementController>();
    final settingController = Get.find<InstallerSettingController>();
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Obx(
      () => Scaffold(
        key: scaffoldKey,
        appBar: CustomAppBar(
          greetingText: 'Dashboard',
          userType: 'Real-time screening program management and compliance',
          profileImageUrl: settingController.profileImageUrl.value.isEmpty
              ? null
              : settingController.profileImageUrl.value,
          onProfileTap: () {
            settingController.refreshUserProfileForDrawer();
            scaffoldKey.currentState?.openEndDrawer();
          },
        ),
        endDrawer: InstallerProfileDrawer(controller: settingController),
        body: SafeArea(
          child: Obx(() {
            final hasAnyJobs =
                controller.newPosts.isNotEmpty ||
                controller.assignedPosts.isNotEmpty;

            if (controller.isLoading.value && !hasAnyJobs) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.loadJobsError.value.isNotEmpty && !hasAnyJobs) {
              return _buildErrorState(controller);
            }

            final visibleJobs = controller.visibleJobs;
            final isNewTabSelected =
                controller.selectedTab.value == InstallerPostTab.newPosts;

            return RefreshIndicator(
              onRefresh: () => _refreshHome(
                controller: controller,
                settingController: settingController,
              ),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // KPI Card: "This Month"
                      _buildKPICard(controller),

                      SizedBox(height: 14.h),
                      _buildPayableCommissionCard(settingController),

                      SizedBox(height: 24.h),

                      // // Title section
                      // Text(
                      //   'Installer Management',
                      //   style: figtreeTextStyle(
                      //     fontSize: 18.sp,
                      //     fontWeight: FontWeight.w600, // SemiBold
                      //     color: const Color(0xFF2B4554), // #2b4554
                      //   ),
                      // ),
                      // SizedBox(height: 4.h),
                      // Text(
                      //   'Switch between new and assigned posts',
                      //   style: figtreeTextStyle(
                      //     fontSize: 12.sp,
                      //     fontWeight: FontWeight.w400, // Regular
                      //     color: const Color(0xFF6C7787), // #6c7787
                      //   ),
                      // ),
                      // SizedBox(height: 16.h),
                      _buildPostsToggle(controller),

                      SizedBox(height: 20.h), // 32px gap before job list
                      if (visibleJobs.isEmpty)
                        _buildEmptyState(
                          isNewTabSelected
                              ? 'No new posts found'
                              : 'No assigned posts found',
                        )
                      else
                        ...visibleJobs.asMap().entries.map((entry) {
                          final job = entry.value;
                          final isLast = entry.key == visibleJobs.length - 1;
                          return Column(
                            children: [
                              ManagementItemCard(
                                job: job,
                                onTap: () => controller.navigateToDetails(job),
                              ),
                              if (!isLast)
                                SizedBox(
                                  height: 16.h,
                                ), // 16px gap between cards
                            ],
                          );
                        }),

                      SizedBox(height: 10.h), // Bottom padding
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Future<void> _refreshHome({
    required InstallerManagementController controller,
    required InstallerSettingController settingController,
  }) async {
    await Future.wait([
      controller.refreshJobs(),
      settingController.refreshUserProfile(),
    ]);
  }

  /// Builds KPI card with exact Figma specs
  /// Outer: #F2FAFF bg with #EBEFF1 border
  /// Inner: White with 20w/16h padding
  Widget _buildKPICard(InstallerManagementController controller) {
    final formatter = NumberFormat.currency(symbol: r'$', decimalDigits: 2);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2FAFF), // #f2faff outer background
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFEBEFF1), // #ebeff1 border
          width: 1.w,
        ),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white, // White inner container
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF395C70), // #395c70
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.monetization_on_outlined,
                    size: 18.r,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'This Month',
                  style: figtreeTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500, // Medium
                    color: const Color(0xFF395C70), // #395c70
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Monthly stats
            Row(
              children: [
                Expanded(
                  child: _buildStatColumn(
                    value: '${controller.completedCount.value}',
                    label: 'Completed',
                    isLoading: controller.isEarningsLoading.value,
                    shimmerWidth: 34.w,
                  ),
                ),
                _buildStatDivider(),
                Expanded(
                  child: _buildStatColumn(
                    value: '${controller.inProgressCount.value}',
                    label: 'In Progress',
                    isLoading: controller.isEarningsLoading.value,
                    shimmerWidth: 34.w,
                  ),
                ),
                _buildStatDivider(),
                Expanded(
                  child: _buildStatColumn(
                    value: '${controller.assignedPosts.length}',
                    label: 'Assigned',
                    isLoading:
                        controller.isLoading.value &&
                        controller.assignedPosts.isEmpty,
                    shimmerWidth: 34.w,
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Container(height: 1.h, color: const Color(0xFFEBEFF1)),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: _buildStatColumn(
                    value: formatter.format(controller.totalEarned.value),
                    label: 'Total Money',
                    isLoading: controller.isEarningsLoading.value,
                    shimmerWidth: 64.w,
                  ),
                ),
                _buildStatDivider(),
                Expanded(
                  child: _buildStatColumn(
                    value: formatter.format(controller.myBalance),
                    label: 'My Balance',
                    isLoading: controller.isEarningsLoading.value,
                    shimmerWidth: 56.w,
                  ),
                ),
                _buildStatDivider(),
                Expanded(
                  child: _buildStatColumn(
                    value: formatter.format(controller.calculatedCommission),
                    label: 'Commission',
                    isLoading: controller.isEarningsLoading.value,
                    shimmerWidth: 64.w,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayableCommissionCard(
    InstallerSettingController settingController,
  ) {
    final formatter = NumberFormat.currency(symbol: r'$', decimalDigits: 2);

    return Obx(
      () => Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFFEBEFF1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 21.r,
                    color: AppColors.textNormal,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payable Commission',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: figtreeTextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        formatter.format(
                          settingController
                              .displayPayableCommissionAmount
                              .value,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: figtreeTextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            CustomButton(
              text: 'Pay Commission',
              onPressed: () {
                if (Get.currentRoute ==
                    AppRoute.getInstallerCommissionPaymentScreen()) {
                  return;
                }
                Get.toNamed(AppRoute.getInstallerCommissionPaymentScreen());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 40.h,
      width: 1.w,
      color: const Color(0xFFEBEFF1),
      margin: EdgeInsets.symmetric(horizontal: 7.w),
    );
  }

  /// Builds individual stat column for KPI card
  Widget _buildStatColumn({
    required String value,
    required String label,
    required bool isLoading,
    required double shimmerWidth,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (isLoading)
          ShimmerPlaceholder(
            child: Container(
              width: shimmerWidth,
              height: 28.h,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
          )
        else
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: figtreeTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600, // SemiBold
              color: Colors.black,
            ),
          ),
        SizedBox(height: 4.h),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: figtreeTextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500, // Medium
            color: const Color(0xFFAAB1BA), // #aab1ba light gray
          ),
        ),
      ],
    );
  }

  Widget _buildPostsToggle(InstallerManagementController controller) {
    final isNewSelected =
        controller.selectedTab.value == InstallerPostTab.newPosts;

    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEFF1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleItem(
              label: 'New Post (${controller.newPosts.length})',
              isSelected: isNewSelected,
              onTap: () => controller.selectTab(InstallerPostTab.newPosts),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _buildToggleItem(
              label: 'Assigned Post (${controller.assignedPosts.length})',
              isSelected: !isNewSelected,
              onTap: () => controller.selectTab(InstallerPostTab.assignedPosts),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF6FAACC), Color(0xFF395C70)],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Center(
          child: Text(
            label,
            style: figtreeTextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF6C7787),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Center(
        child: Text(
          message,
          style: figtreeTextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6C7787),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(InstallerManagementController controller) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              controller.loadJobsError.value,
              textAlign: TextAlign.center,
              style: figtreeTextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6C7787),
              ),
            ),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: controller.refreshJobs,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

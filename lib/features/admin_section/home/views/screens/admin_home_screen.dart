import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_appbar.dart';
import 'package:outdoorda_flutter/core/common/widgets/shimmer_placeholder.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/features/admin_section/home/controllers/admin_home_controller.dart';
import 'package:outdoorda_flutter/features/admin_section/home/views/widgets/activity_item_widget.dart';
import 'package:outdoorda_flutter/features/admin_section/home/views/widgets/kpi_metric_card.dart';
import 'package:outdoorda_flutter/features/installer_section/management/views/widgets/management_item_card.dart';

/// Admin Home Screen - 100% Figma pixel-perfect implementation
/// Background: #EBE8E3
class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminHomeController>();

    return Scaffold(
      appBar: CustomAppBar(
        greetingText: AppStrings.dashboard,
        userType: AppStrings.dashboardSubtitle,
        loadProfileImageFromApi: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildDashboardShimmer();
        }

        return RefreshIndicator(
          color: AppColors.gradientStart,
          onRefresh: controller.refreshDashboardData,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            children: [
              // Welcome Back card (controlled by visibility state)
              Obx(() {
                if (!controller.isWelcomeCardVisible.value) {
                  return const SizedBox.shrink();
                }
                return Column(
                  children: [
                    _buildWelcomeCard(controller),
                    SizedBox(height: 20.h),
                  ],
                );
              }),

              // KPI Metrics (4 cards in 2 rows)
              _buildKPIMetrics(controller),
              SizedBox(height: 20.h),
              // Create New Job button
              _buildCreateNewJobButton(controller),
              SizedBox(height: 20.h),
              _buildCreateServiceAreaButton(controller),
              SizedBox(height: 20.h),

              // Recent Jobs section
              _buildRecentJobsSection(controller),
              SizedBox(height: 20.h),
              // Recent Activity section
              _buildRecentActivitySection(controller),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDashboardShimmer() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      children: [
        _buildShimmerWelcomeCard(),
        SizedBox(height: 20.h),
        _buildShimmerKPIMetrics(),
        SizedBox(height: 20.h),
        _buildShimmerPrimaryActionButton(),
        SizedBox(height: 20.h),
        _buildShimmerSecondaryActionButton(),
        SizedBox(height: 20.h),
        _buildShimmerSectionHeader(),
        SizedBox(height: 20.h),
        for (int i = 0; i < 3; i++) ...[
          _buildShimmerRecentJobCard(),
          if (i != 2) SizedBox(height: 16.h),
        ],
        SizedBox(height: 20.h),
        _buildShimmerRecentActivitySection(),
      ],
    );
  }

  Widget _buildShimmerWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFF9CB2C1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ShimmerPlaceholder(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShimmerBlock(height: 20.h, width: 180.w),
            SizedBox(height: 4.h),
            _buildShimmerBlock(height: 12.h, width: 240.w),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerKPIMetrics() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildShimmerKPICard()),
            SizedBox(width: 16.w),
            Expanded(child: _buildShimmerKPICard()),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(child: _buildShimmerKPICard()),
            SizedBox(width: 16.w),
            Expanded(child: _buildShimmerKPICard()),
          ],
        ),
      ],
    );
  }

  Widget _buildShimmerKPICard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFEBEFF1), width: 1),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: ShimmerPlaceholder(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShimmerBlock(height: 32.r, width: 32.r, radius: 8.r),
            SizedBox(height: 16.h),
            _buildShimmerBlock(height: 16.h, width: double.infinity),
            SizedBox(height: 14.h),
            _buildShimmerBlock(height: 22.h, width: 54.w),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerPrimaryActionButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF87ABC0),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: ShimmerPlaceholder(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildShimmerBlock(height: 20.h, width: 20.w, radius: 6.r),
            SizedBox(width: 8.w),
            _buildShimmerBlock(height: 14.h, width: 110.w),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerSecondaryActionButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColors.gradientEnd.withValues(alpha: 0.4),
        ),
      ),
      child: ShimmerPlaceholder(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildShimmerBlock(height: 20.h, width: 20.w, radius: 6.r),
            SizedBox(width: 8.w),
            _buildShimmerBlock(height: 14.h, width: 130.w),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ShimmerPlaceholder(
          child: _buildShimmerBlock(height: 22.h, width: 140.w),
        ),
        ShimmerPlaceholder(
          child: _buildShimmerBlock(height: 14.h, width: 52.w),
        ),
      ],
    );
  }

  Widget _buildShimmerRecentJobCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEFF1),
        borderRadius: BorderRadius.circular(24.r),
        border: Border(
          left: BorderSide(color: const Color(0xFF6FAACC), width: 1.w),
        ),
      ),
      child: ShimmerPlaceholder(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildShimmerBlock(height: 28.h, width: 84.w, radius: 999.r),
                SizedBox(width: 8.w),
                _buildShimmerBlock(height: 28.h, width: 76.w, radius: 999.r),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _buildShimmerBlock(height: 20.h, width: 140.w),
                ),
                SizedBox(width: 10.w),
                _buildShimmerBlock(height: 20.h, width: 54.w),
              ],
            ),
            SizedBox(height: 16.h),
            _buildShimmerBlock(height: 16.h, width: double.infinity),
            SizedBox(height: 12.h),
            _buildShimmerBlock(height: 1.h, width: double.infinity, radius: 0),
            SizedBox(height: 12.h),
            _buildShimmerBlock(height: 16.h, width: 150.w),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerRecentActivitySection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerPlaceholder(
            child: _buildShimmerBlock(height: 22.h, width: 160.w),
          ),
          SizedBox(height: 16.h),
          for (int i = 0; i < 3; i++) ...[
            _buildShimmerActivityItem(),
            if (i != 2) SizedBox(height: 16.h),
          ],
        ],
      ),
    );
  }

  Widget _buildShimmerActivityItem() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: const Color(0xFFECF8FF),
        border: Border.symmetric(
          horizontal: BorderSide(color: const Color(0xFF6FAACC), width: 1),
        ),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: ShimmerPlaceholder(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerBlock(height: 14.r, width: 14.r, radius: 999.r),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    children: [
                      _buildShimmerBlock(height: 14.h, width: double.infinity),
                      SizedBox(height: 8.h),
                      _buildShimmerBlock(height: 14.h, width: 180.w),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            _buildShimmerBlock(height: 14.h, width: 96.w),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerBlock({
    required double height,
    required double width,
    double radius = 8,
    Color color = const Color(0xFFE0E0E0),
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _buildCreateServiceAreaButton(AdminHomeController controller) {
    return GestureDetector(
      onTap: controller.onCreateServiceAreaTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: AppColors.gradientEnd.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_city_outlined,
              size: 22.r,
              color: AppColors.textDark,
            ),
            SizedBox(width: 8.w),
            Text(
              AppStrings.createServiceArea,
              style: figtreeTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Welcome Back card with gradient background and close button
  Widget _buildWelcomeCard(AdminHomeController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF395C70), // Foundation/Blue/Normal
            Color(0xFF395C70),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0073C5).withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.welcomeBackExclamation,
                style: figtreeTextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4.h),
              Padding(
                padding: EdgeInsets.only(right: 28.w), // prevent text overlap with close button
                child: Text(
                  AppStrings.businessOverview,
                  style: figtreeTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => controller.isWelcomeCardVisible.value = false,
              child: Icon(
                Icons.close,
                color: Colors.white.withValues(alpha: 0.8),
                size: 20.r,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// KPI Metrics - 4 cards in 2 rows
  Widget _buildKPIMetrics(AdminHomeController controller) {
    return Column(
      children: [
        // First row: New Job Offers & Bids Pending
        Row(
          children: [
            Expanded(
              child: KPIMetricCard(
                icon: Icons.money_rounded,
                title: AppStrings.newJobOffers,
                value: controller.newJobOffers.value.toString(),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: KPIMetricCard(
                icon: Icons.attach_money_rounded,
                title: AppStrings.bidsPending,
                value: controller.bidsPending.value.toString(),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        // Second row: Jobs Assigned & Follow-ups Due
        Row(
          children: [
            Expanded(
              child: KPIMetricCard(
                icon: Icons.folder_outlined,
                title: AppStrings.jobsAssigned,
                value: controller.jobsAssigned.value.toString(),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: KPIMetricCard(
                icon: Icons.speed_outlined,
                title: AppStrings.followUpsDue,
                value: controller.followUpsDue.value.toString(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Create New Job button with gradient and icon
  Widget _buildCreateNewJobButton(AdminHomeController controller) {
    return GestureDetector(
      onTap: controller.onCreateNewJobTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6FAACC), // Gradient start
              Color(0xFF395C70), // Gradient end
            ],
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 24.r, color: Colors.white),
            SizedBox(width: 8.w),
            Text(
              AppStrings.createNewJob,
              style: figtreeTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Recent Jobs section with View All toggle
  Widget _buildRecentJobsSection(AdminHomeController controller) {
    return Column(
      children: [
        // Section header with View All
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.recentJobs,
              style: figtreeTextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2B4554), // Foundation/Blue/Dark
              ),
            ),
            GestureDetector(
              onTap: controller.onViewAllTap,
              child: Text(
                AppStrings.viewAll,
                style: figtreeTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2B4554),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        // Job cards list
        if (controller.recentJobs.isEmpty)
          Text(
            'No recent jobs found',
            style: figtreeTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.neutral400,
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.recentJobs.length,
            separatorBuilder: (context, index) => SizedBox(height: 16.h),
            itemBuilder: (context, index) {
              final job = controller.recentJobs[index];
              return ManagementItemCard(
                job: job,
                onTap: () => controller.onJobTap(job),
              );
            },
          ),
      ],
    );
  }

  /// Recent Activity section
  Widget _buildRecentActivitySection(AdminHomeController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.recentActivity,
            style: figtreeTextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2B4554),
            ),
          ),
          SizedBox(height: 16.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.recentActivities.length,
            separatorBuilder: (context, index) => SizedBox(height: 16.h),
            itemBuilder: (context, index) {
              final activity = controller.recentActivities[index];
              return ActivityItemWidget(activity: activity);
            },
          ),
        ],
      ),
    );
  }
}

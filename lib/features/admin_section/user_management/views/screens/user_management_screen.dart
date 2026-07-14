import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_appbar.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/features/admin_section/user_management/controllers/user_management_controller.dart';
import 'package:outdoorda_flutter/features/admin_section/user_management/views/widgets/user_card.dart';
import 'package:outdoorda_flutter/features/admin_section/user_management/views/widgets/user_management_shimmer.dart';

/// User Management Screen for Admin Section
/// Displays installer and customer users with suspend/undo functionality
class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserManagementController());

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: CustomAppBar(
        greetingText: 'Dashboard',
        userType: 'Real-time screening program management and compliance',
        loadProfileImageFromApi: true,
      ),
      body: Column(
        children: [
          /// Header Section
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Title and Subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Management',
                      style: figtreeTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Manage your network of users',
                      style: figtreeTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                /// Search Field
                TextField(
                  controller: controller.searchController,
                  style: figtreeTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textDark,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by name or email...',
                    hintStyle: figtreeTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.neutral400,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.neutral400,
                      size: 20.r,
                    ),
                    suffixIcon: Obx(() {
                      if (controller.searchQuery.value.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return GestureDetector(
                        onTap: controller.clearSearch,
                        child: Icon(
                          Icons.clear,
                          color: AppColors.neutral400,
                          size: 20.r,
                        ),
                      );
                    }),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10.h,
                      horizontal: 16.w,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: AppColors.skyDark,
                        width: 1.w,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: AppColors.skyDark.withValues(alpha: 0.5),
                        width: 1.w,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: AppColors.gradientStart,
                        width: 1.w,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),

                /// Tab Buttons (Installer / Customer)
                Obx(() {
                  return Row(
                    children: [
                      /// Installer Tab
                      Expanded(
                        child: GestureDetector(
                          onTap: () => controller.selectTab(0),
                          child: Container(
                            height: 36.h,
                            decoration: BoxDecoration(
                              gradient: controller.selectedTabIndex.value == 0
                                  ? AppColors.primaryGradient
                                  : null,
                              color: controller.selectedTabIndex.value == 0
                                  ? null
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8.r),
                              border: controller.selectedTabIndex.value == 0
                                  ? null
                                  : Border.all(
                                      color: AppColors.skyDark,
                                      width: 1.w,
                                    ),
                            ),
                            child: Center(
                              child: Text(
                                'Installer',
                                style: figtreeTextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: controller.selectedTabIndex.value == 0
                                      ? AppColors.neutral25
                                      : AppColors.skyDark,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),

                      /// Customer Tab
                      Expanded(
                        child: GestureDetector(
                          onTap: () => controller.selectTab(1),
                          child: Container(
                            height: 36.h,
                            decoration: BoxDecoration(
                              gradient: controller.selectedTabIndex.value == 1
                                  ? AppColors.primaryGradient
                                  : null,
                              color: controller.selectedTabIndex.value == 1
                                  ? null
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8.r),
                              border: controller.selectedTabIndex.value == 1
                                  ? null
                                  : Border.all(
                                      color: AppColors.skyDark,
                                      width: 1.w,
                                    ),
                            ),
                            child: Center(
                              child: Text(
                                'Customer',
                                style: figtreeTextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: controller.selectedTabIndex.value == 1
                                      ? AppColors.neutral25
                                      : AppColors.skyDark,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),

          /// User List
          Expanded(
            child: Obx(() {
              final users = controller.currentTabUsers;
              final isInstaller = controller.selectedTabIndex.value == 0;
              final isLoading = isInstaller
                  ? controller.isLoadingInstallers.value
                  : controller.isLoadingCustomers.value;
              final isLoadingMore = isInstaller
                  ? controller.isLoadingMoreInstallers.value
                  : controller.isLoadingMoreCustomers.value;
              final hasMore = isInstaller
                  ? controller.hasMoreInstallers.value
                  : controller.hasMoreCustomers.value;

              if (isLoading) {
                return UserManagementShimmer(isInstaller: isInstaller);
              }

              if (users.isEmpty) {
                if (controller.loadUsersError.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          controller.loadUsersError.value,
                          style: figtreeTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.neutral400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12.h),
                        TextButton(
                          onPressed: controller.loadUsers,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (hasMore && !isLoadingMore) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    controller.loadMoreUsers();
                  });
                }

                if (hasMore) {
                  return UserManagementShimmer(isInstaller: isInstaller);
                }

                return Center(
                  child: Text(
                    'No users found',
                    style: figtreeTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.neutral400,
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshUsers,
                child: ListView.separated(
                  controller: controller.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  itemCount: users.length + (isLoadingMore ? 1 : 0),
                  separatorBuilder: (context, index) => SizedBox(height: 16.h),
                  itemBuilder: (context, index) {
                    if (index >= users.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final user = users[index];
                    return UserCard(
                      user: user,
                      onProfileTap: () => controller.showProfileDetails(user),
                      onPaymentTap: user.userType == 'installer'
                          ? () => controller.openInstallerPaymentDetails(user)
                          : null,
                      onActionTap: () {
                        if (user.isSuspended) {
                          controller.undoSuspendUser(user);
                        } else {
                          controller.suspendUser(user);
                        }
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_appbar.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/features/installer_section/message_section/controllers/message_list_controller.dart';
import 'package:outdoorda_flutter/features/installer_section/settings/controllers/installer_setting_controller.dart';
import 'package:outdoorda_flutter/features/installer_section/settings/views/widgets/installer_profile_drawer.dart';
import 'package:outdoorda_flutter/features/installer_section/message_section/views/widgets/message_list_item_widget.dart';

/// Message list screen showing all conversations
/// Displays list of conversations with user avatars, names, last messages, and unread counts
class InstallerConversationListScreen extends StatelessWidget {
  const InstallerConversationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InstallerMessageListController>();
    final settingController = Get.find<InstallerSettingController>();
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Obx(
      () => Scaffold(
        key: scaffoldKey,
        appBar: CustomAppBar(
          greetingText: 'Good Morning',
          userType: 'Installer',
          profileImageUrl: settingController.profileImageUrl.value.isEmpty
              ? null
              : settingController.profileImageUrl.value,
          onProfileTap: () {
            settingController.refreshUserProfileForDrawer();
            scaffoldKey.currentState?.openEndDrawer();
          },
        ),
        endDrawer: InstallerProfileDrawer(controller: settingController),
        body: Obx(() {
          // Show loading state
          if (controller.isLoading.value && controller.conversations.isEmpty) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.gradientEnd),
            );
          }

          // Show empty state
          if (controller.conversations.isEmpty) {
            return RefreshIndicator(
              onRefresh: controller.refreshConversations,
              color: AppColors.gradientEnd,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.62,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64.sp,
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          AppStrings.noConversations,
                          style: figtreeTextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          AppStrings.startConversation,
                          style: figtreeTextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          // Show conversation list
          return RefreshIndicator(
            onRefresh: controller.refreshConversations,
            color: AppColors.gradientEnd,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: controller.conversations.length,
              itemBuilder: (context, index) {
                final conversation = controller.conversations[index];
                return InstallerMessageListItemWidget(
                  conversation: conversation,
                  onTap: () => controller.openConversation(conversation),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}

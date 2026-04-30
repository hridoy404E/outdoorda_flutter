import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_appbar.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/features/customer_section/home/messaging/controllers/message_list_controller.dart';
import 'package:outdoorda_flutter/features/customer_section/home/messaging/views/widgets/message_list_item_widget.dart';

/// Message list screen showing all conversations
/// Displays list of conversations with user avatars, names, last messages, and unread counts
class MessageListScreen extends StatelessWidget {
  const MessageListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageListController>();

    return Scaffold(
      appBar: CustomAppBar(greetingText: 'Good Morning', userType: 'Customer'),
      body: Obx(() {
        // Show loading state
        if (controller.isLoading.value && controller.conversations.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.gradientEnd),
          );
        }

        // Show empty state
        if (controller.conversations.isEmpty) {
          return Center(
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
              return MessageListItemWidget(
                conversation: conversation,
                onTap: () => controller.openConversation(conversation),
              );
            },
          ),
        );
      }),
    );
  }
}

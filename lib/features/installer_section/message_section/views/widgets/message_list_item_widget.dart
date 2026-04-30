import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/features/installer_section/message_section/models/message.dart';

/// Reusable widget for displaying conversation items in message list
/// Shows avatar, name, last message preview, timestamp, and unread count
class InstallerMessageListItemWidget extends StatelessWidget {
  const InstallerMessageListItemWidget({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  final Conversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 14.w),
        decoration: BoxDecoration(
          color: AppColors.messageBubbleReceived,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: Image.network(
                conversation.userAvatar,
                width: 40.w,
                height: 40.h,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: AppColors.gradientStart,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Center(
                      child: Text(
                        conversation.userName.isNotEmpty
                            ? conversation.userName[0].toUpperCase()
                            : '?',
                        style: figtreeTextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.cardBackgroundWhite,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 12.w),

            // Name, message preview, and time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and time row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Name
                      Expanded(
                        child: Text(
                          conversation.userName,
                          style: figtreeTextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),

                      // Time
                      Text(
                        _formatTime(conversation.lastMessageTime),
                        style: figtreeTextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.messageListTime,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),

                  // Last message and unread count row
                  Row(
                    children: [
                      // Last message preview
                      Expanded(
                        child: Text(
                          conversation.lastMessage,
                          style: figtreeTextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.messageListPreview,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Unread count badge
                      if (conversation.unreadCount > 0) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.unreadBadgeGradientStart,
                                AppColors.unreadBadgeGradientEnd,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            conversation.unreadCount.toString(),
                            style: figtreeTextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.unreadBadgeText,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Format time for display
  String _formatTime(DateTime time) {
    final localTime = time.toLocal();
    final now = DateTime.now();
    final difference = now.difference(localTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return '1d';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${localTime.day}/${localTime.month}';
    }
  }
}

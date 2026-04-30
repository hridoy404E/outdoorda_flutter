import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';

/// Quick actions section widget with action buttons
/// Displays New Request, Message, and Help Center buttons
class QuickActions extends StatelessWidget {
  const QuickActions({
    super.key,
    this.onNewRequestTap,
    this.onMessageTap,
    this.onHelpCenterTap,
  });

  final VoidCallback? onNewRequestTap;
  final VoidCallback? onMessageTap;
  final VoidCallback? onHelpCenterTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          child: Text(
            AppStrings.quickActions,
            style: figtreeTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 13.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionButton(
                icon: Icons.add,
                label: AppStrings.newRequest,
                onTap: onNewRequestTap,
              ),
              _buildActionButton(
                icon: Icons.chat_bubble_outline,
                label: AppStrings.message,
                onTap: onMessageTap,
              ),
              _buildActionButton(
                icon: Icons.help_outline,
                label: AppStrings.helpCenter,
                onTap: onHelpCenterTap,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build individual action button
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 106.w,
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0073C5).withValues(alpha: 0.2),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 32.r, color: AppColors.iconColor),
            SizedBox(height: 4.h),
            Text(
              label,
              style: figtreeTextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.neutral800,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

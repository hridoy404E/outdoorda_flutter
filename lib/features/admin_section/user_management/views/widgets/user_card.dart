import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/features/admin_section/user_management/models/user_model.dart';

/// Reusable User Card Widget
/// Displays user information with avatar, name, address, joined date
/// Includes suspend/undo button based on user suspension status
class UserCard extends StatelessWidget {
  const UserCard({
    super.key,
    required this.user,
    required this.onActionTap,
    required this.onProfileTap,
    this.onPaymentTap,
  });

  final UserModel user;
  final VoidCallback onActionTap;
  final VoidCallback onProfileTap;
  final VoidCallback? onPaymentTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 330.w,
      decoration: BoxDecoration(
        color: AppColors.settingsCardBg,
        borderRadius: BorderRadius.circular(24.r),
        border: Border(
          left: BorderSide(color: AppColors.gradientStart, width: 1.w),
        ),
      ),
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Top Row: Avatar + Name + Action Button
          Row(
            children: [
              /// User Avatar
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.settingsWhite,
                  image: user.profileImageUrl.trim().isEmpty
                      ? null
                      : DecorationImage(
                          image: NetworkImage(user.profileImageUrl),
                          fit: BoxFit.cover,
                        ),
                ),
                child: user.profileImageUrl.trim().isEmpty
                    ? Icon(
                        Icons.person,
                        size: 20.r,
                        color: AppColors.neutral400,
                      )
                    : null,
              ),
              SizedBox(width: 16.w),

              /// User Name
              Expanded(
                child: Text(
                  user.name,
                  style: figtreeTextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral900,
                  ),
                ),
              ),

              /// Suspend/Undo Button
              GestureDetector(
                onTap: onActionTap,
                child: Container(
                  width: 36.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.skyDark, width: 1.w),
                  ),
                  child: Center(
                    child: Icon(
                      user.isSuspended ? Icons.play_arrow : Icons.pause,
                      size: 20.r,
                      color: AppColors.gradientStart,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          /// Address Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 24.r,
                color: AppColors.neutral400,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  user.address,
                  style: figtreeTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.neutral400,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          /// Divider
          Container(height: 1.h, color: AppColors.dividerColor),
          SizedBox(height: 12.h),

          /// Joined Date Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Joined Date',
                style: figtreeTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutral400,
                ),
              ),
              Text(
                user.joinedDate,
                style: figtreeTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral400,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'User Details',
                  icon: Icons.person_outline,
                  onTap: onProfileTap,
                ),
              ),
              if (onPaymentTap != null) ...[
                SizedBox(width: 10.w),
                Expanded(
                  child: _ActionButton(
                    label: 'Payment Details',
                    icon: Icons.payments_outlined,
                    onTap: onPaymentTap!,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        height: 40.h,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.skyDark, width: 1.w),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17.r, color: AppColors.skyDark),
            SizedBox(width: 6.w),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: figtreeTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.skyDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

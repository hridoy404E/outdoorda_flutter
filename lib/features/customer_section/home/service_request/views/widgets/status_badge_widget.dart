import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';

class StatusBadgeWidget extends StatelessWidget {
  const StatusBadgeWidget({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    LinearGradient badgeGradient;
    String badgeText;

    switch (status) {
      case 'Installer Assigned':
        badgeGradient = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.installerAssignedStart,
            AppColors.installerAssignedEnd,
          ],
        );
        badgeText = AppStrings.installerAssigned;
        break;
      case 'In Progress':
        badgeGradient = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.inProgressBadgeStart,
            AppColors.inProgressBadgeEnd,
          ],
        );
        badgeText = AppStrings.inProgress;
        break;
      case 'Receiving Bids':
        badgeGradient = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.receivingBidsStart, AppColors.receivingBidsEnd],
        );
        badgeText = AppStrings.receivingBids;
        break;
      case 'Completed':
        badgeGradient = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.completedBadge, AppColors.completedBadge],
        );
        badgeText = AppStrings.completed;
        break;
      default:
        badgeGradient = AppColors.primaryGradient;
        badgeText = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        gradient: badgeGradient,
        borderRadius: BorderRadius.circular(9999.r),
      ),
      child: Text(
        badgeText,
        style: figtreeTextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.neutral25,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/models/service_request_model.dart';

/// Reusable history card widget for service requests
/// Supports 3 status types: Installer Assigned, Receiving Bids, Completed
class HistoryCard extends StatelessWidget {
  const HistoryCard({
    super.key,
    required this.service,
    this.onTap,
    this.onInstallerTap,
  });

  final ServiceRequest service;
  final VoidCallback? onTap;
  final VoidCallback? onInstallerTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          border: Border.all(color: const Color(0xFF6FAACC), width: 1),
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and date row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    service.title,
                    style: figtreeTextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E242C),
                    ),
                  ),
                ),
                Text(
                  service.date,
                  style: figtreeTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6C7787),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Status badge
            _buildStatusBadge(service.status),
            SizedBox(height: 12.h),

            // Divider line
            Container(height: 1.h, color: AppColors.dividerColor),
            SizedBox(height: 12.h),

            // Installer info and price/additional info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Installer info - Hidden for 'Receiving Bids' and 'Pending' statuses
                if (service.status != 'Receiving Bids' &&
                    service.status != 'Pending')
                  GestureDetector(
                    onTap: onInstallerTap,
                    child: Row(
                      children: [
                        Container(
                          width: 24.w,
                          height: 24.h,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.neutral300,
                          ),
                          child: Icon(
                            Icons.person,
                            size: 14.r,
                            color: AppColors.neutral25,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          service.installerName,
                          style: figtreeTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Price or additional info
                if (service.price != null)
                  Text(
                    service.price!,
                    style: figtreeTextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: service.status == 'Completed'
                          ? AppColors.completedBadge
                          : AppColors.priceColor,
                    ),
                  )
                else if (service.additionalInfo != null)
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: _getAdditionalInfoGradientColors(service.status),
                    ).createShader(bounds),
                    child: Text(
                      service.additionalInfo!,
                      style: figtreeTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build status badge based on service status
  Widget _buildStatusBadge(String status) {
    LinearGradient? badgeGradient;
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
        badgeGradient = LinearGradient(
          colors: [AppColors.completedBadge, AppColors.completedBadge],
        );
        badgeText = AppStrings.completed;
        break;
      case 'Pending':
        badgeGradient = AppColors.primaryGradient;
        badgeText = AppStrings.pending;
        break;
      default:
        badgeGradient = LinearGradient(
          colors: [AppColors.neutral300, AppColors.neutral300],
        );
        badgeText = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 7.h),
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

  /// Get gradient colors for additional info based on status
  List<Color> _getAdditionalInfoGradientColors(String status) {
    if (status == 'Pending') {
      return [AppColors.gradientStart, AppColors.gradientEnd];
    }
    return [AppColors.receivingBidsStart, AppColors.receivingBidsEnd];
  }
}

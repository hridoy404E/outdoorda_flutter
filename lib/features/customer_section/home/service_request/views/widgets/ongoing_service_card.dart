import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/common/widgets/shimmer_placeholder.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/models/service_request_model.dart';

/// Ongoing service card widget with gradient background
/// Displays current service details with status badge
class OngoingServiceCard extends StatelessWidget {
  const OngoingServiceCard({
    super.key,
    required this.service,
    this.onTap,
    this.onInstallerTap,
  }) : isLoading = false;

  const OngoingServiceCard.loading({super.key})
    : service = const ServiceRequest(
        id: '',
        title: '',
        address: '',
        installerName: '',
        installerImageUrl: '',
        status: '',
        date: '',
      ),
      onTap = null,
      onInstallerTap = null,
      isLoading = true;

  final ServiceRequest service;
  final VoidCallback? onTap;
  final VoidCallback? onInstallerTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        margin: EdgeInsets.only(left: 13.w, right: 13.w, top: 13.h),
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.ongoingCardGradientStart,
              AppColors.ongoingCardGradientEnd,
            ],
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge
            if (isLoading)
              ShimmerPlaceholder(
                child: Container(
                  width: 90.w,
                  height: 28.h,
                  decoration: BoxDecoration(
                    color: AppColors.neutral25.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(9999.r),
                  ),
                ),
              )
            else
              Container(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 7.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.ongoingBadgeStart,
                      AppColors.ongoingBadgeEnd,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(9999.r),
                ),
                child: Text(
                  AppStrings.ongoing,
                  style: figtreeTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral25,
                  ),
                ),
              ),
            SizedBox(height: 12.h),

            // Service title
            if (isLoading)
              ShimmerPlaceholder(
                child: Container(
                  width: 210.w,
                  height: 28.h,
                  decoration: BoxDecoration(
                    color: AppColors.neutral25.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              )
            else
              Text(
                service.title,
                style: figtreeTextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral25,
                ),
              ),
            SizedBox(height: 8.h),

            // Address
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 18.r,
                  color: const Color(0xFFEFEEEE),
                ),
                SizedBox(width: 6.w),
                if (isLoading)
                  Expanded(
                    child: ShimmerPlaceholder(
                      child: Container(
                        height: 16.h,
                        decoration: BoxDecoration(
                          color: AppColors.neutral25.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  )
                else
                  Text(
                    service.address,
                    style: figtreeTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFEFEEEE),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12.h),

            // Assigned installer section
            GestureDetector(
              onTap: isLoading ? null : onInstallerTap,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFC2CCD3),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    _buildInstallerAvatar(),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isLoading)
                            ShimmerPlaceholder(
                              child: Container(
                                width: 130.w,
                                height: 14.h,
                                decoration: BoxDecoration(
                                  color: AppColors.textNormal.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                              ),
                            )
                          else
                            Text(
                              AppStrings.assignedInstaller,
                              style: figtreeTextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textNormal,
                              ),
                            ),
                          SizedBox(height: 6.h),
                          if (isLoading)
                            ShimmerPlaceholder(
                              child: Container(
                                width: 150.w,
                                height: 20.h,
                                decoration: BoxDecoration(
                                  color: AppColors.textDark.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                              ),
                            )
                          else
                            Text(
                              service.installerName.trim().isNotEmpty
                                  ? service.installerName
                                  : '-',
                              style: figtreeTextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 24.r,
                      color: AppColors.neutral300,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstallerAvatar() {
    if (isLoading) {
      return ShimmerPlaceholder(
        child: Container(
          width: 42.w,
          height: 42.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.neutral25.withValues(alpha: 0.65),
          ),
        ),
      );
    }
    return _defaultAvatar();
  }

  Widget _defaultAvatar() {
    return Container(
      width: 42.w,
      height: 42.h,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.neutral300,
      ),
      child: Icon(Icons.person, size: 24.r, color: AppColors.neutral25),
    );
  }
}

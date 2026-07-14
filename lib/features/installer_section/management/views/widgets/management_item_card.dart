import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/features/installer_section/management/models/management_job.dart';

/// Reusable card widget for displaying management job items
/// 100% Figma pixel-perfect implementation
/// Card: 330w, 24r radius, 20 padding, #EBEFF1 bg, 1w left border #6FAACC
class ManagementItemCard extends StatelessWidget {
  const ManagementItemCard({super.key, required this.job, required this.onTap});

  final ManagementJob job;
  final VoidCallback onTap;

  String get _normalizedStatusLabel => job.statusLabel.trim().toLowerCase();

  bool get _isReceivingBids =>
      _normalizedStatusLabel == 'receiving bids' ||
      _normalizedStatusLabel == 'receiving_bids';

  bool get _isPending => _normalizedStatusLabel == 'pending';

  String get _statusText {
    if (_isReceivingBids) return 'Receiving Bids';
    return job.statusLabel.trim().isNotEmpty
        ? job.statusLabel
        : job.status.displayName;
  }

  String get _locationText {
    final city = job.city.trim();
    final state = job.state.trim();
    final parts = <String>[
      if (city.isNotEmpty) city,
      if (state.isNotEmpty) state,
    ];
    if (parts.isNotEmpty) return parts.join(', ');

    final addressLine1 = job.addressLine1.trim();
    if (addressLine1.isNotEmpty) return addressLine1;
    return job.location.trim().isNotEmpty ? job.location : '-';
  }

  /// Get gradient colors based on job status (Figma exact)
  LinearGradient _getStatusGradient() {
    if (_isPending) {
      return const LinearGradient(
        colors: [
          Color(0xFFFEA642), // #fea642
          Color(0xFFFF6A00), // #ff6a00
        ],
      );
    }

    switch (job.status) {
      case JobStatus.completed:
        return const LinearGradient(
          colors: [
            Color(0xFF11D000), // #11d000
            Color(0xFF0C5302), // #0c5302
          ],
        );
      case JobStatus.assigned:
        return const LinearGradient(
          colors: [
            Color(0xFFFEA642), // #fea642
            Color(0xFFFF6A00), // #ff6a00
          ],
        );
      case JobStatus.inProgress:
        return const LinearGradient(
          colors: [
            Color(0xFF429AFE), // #429afe
            Color(0xFF006FFF), // #006fff
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: const Color(0xFFEBEFF1), // #ebeff1
          borderRadius: BorderRadius.circular(24.r),
          border: Border(
            left: BorderSide(
              color: const Color(0xFF6FAACC), // #6faacc
              width: 1.w,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job number and status badge row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job number badge with orange gradient
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 7.h,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFEBE8E3), // #ffa642
                    borderRadius: BorderRadius.circular(9999.r),
                  ),
                  child: Text(
                    job.jobNumber,
                    style: figtreeTextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700, // Bold
                      color: Color(0xFF6C7787),
                    ),
                  ),
                ),

                SizedBox(width: 8.w), // Gap between badges
                // Status badge
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 7.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: _getStatusGradient(),
                      borderRadius: BorderRadius.circular(9999.r),
                    ),
                    child: Text(
                      _statusText,
                      style: figtreeTextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700, // Bold
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h), // Gap after badges
            // Customer name and price row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Customer name
                Expanded(
                  child: Text(
                    job.customerName,
                    style: figtreeTextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600, // SemiBold
                      color: const Color(0xFF1E242C), // #1e242c
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w),
                // Price
                Text(
                  '\$${job.price.toStringAsFixed(0)}',
                  style: figtreeTextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600, // SemiBold
                    color: const Color(0xFF609CBF), // #609cbf
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h), // Gap after name/price
            // Location with icon
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 24.r, // 24px icon size from Figma
                  color: const Color(0xFF6C7787), // #6c7787
                ),
                SizedBox(width: 8.w), // Gap between icon and text
                Expanded(
                  child: Text(
                    _locationText,
                    style: figtreeTextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400, // Regular
                      color: const Color(0xFF6C7787), // #6c7787
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h), // Gap before divider
            // Divider
            Container(
              height: 1.h,
              color: const Color(0xFFC2CCD3), // Divider color
            ),
            SizedBox(height: 12.h), // Gap after divider
            // Door type and optional bid count row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Door type
                Expanded(
                  child: Text(
                    job.doorType,
                    style: figtreeTextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500, // Medium
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Bid count badge (only show if bidCount exists and > 0)
                if (job.bidCount != null && job.bidCount! > 0) ...[
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 7.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFEEEE), // #efeeee
                      borderRadius: BorderRadius.circular(9999.r),
                    ),
                    child: Text(
                      '${job.bidCount} bids',
                      style: figtreeTextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600, // SemiBold
                        color: const Color(0xFF1E242C), // #1e242c
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

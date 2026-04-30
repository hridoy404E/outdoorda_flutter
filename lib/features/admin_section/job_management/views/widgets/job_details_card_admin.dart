import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/common/styles/global_text_style.dart';
import '../../models/admin_job.dart';

class JobDetailsCardAdmin extends StatelessWidget {
  const JobDetailsCardAdmin({super.key, required this.job});

  final AdminJob? job;

  @override
  Widget build(BuildContext context) {
    final totalPrice = job?.adminEstimatedPrice ?? 0;
    final adminCommission = totalPrice * 0.20;
    final installerPrice = totalPrice - adminCommission;
    final jobNotes = job?.jobNotes.trim() ?? '';

    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: const Color(0xFFEBE8E3), // #ebe8e3
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24.r,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Job Details" title
          Text(
            'Job Details',
            style: figtreeTextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600, // SemiBold
              color: const Color(0xFF2B4554), // #2b4554
            ),
          ),
          SizedBox(height: 12.h),

          // Divider
          Container(
            height: 1.h,
            color: const Color(0xFFC2CCD3), // Divider
          ),
          SizedBox(height: 12.h),

          // Location section
          Text(
            'Location:',
            style: figtreeTextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400, // Regular
              color: const Color(0xFF2B4554), // #2b4554
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            job?.location ?? '',
            style: figtreeTextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600, // SemiBold
              color: const Color(0xFF2B4554), // #2b4554
            ),
          ),
          SizedBox(height: 16.h),

          // Divider
          Container(height: 1.h, color: const Color(0xFFC2CCD3)),
          SizedBox(height: 16.h),

          // Pet Door section
          Text(
            'Pet Door:',
            style: figtreeTextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400, // Regular
              color: const Color(0xFF2B4554), // #2b4554
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            job?.petDoorDescription.isNotEmpty == true
                ? job!.petDoorDescription
                : 'Extra Large Pet Door',
            style: figtreeTextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600, // SemiBold
              color: const Color(0xFF2B4554), // #2b4554
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            '(Model: ${job?.petDoorModel ?? ''})',
            style: figtreeTextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400, // Regular
              color: const Color(0xFF2B4554), // #2b4554
            ),
          ),
          SizedBox(height: 16.h),

          // Installation Type section
          Text(
            'Installation Type:',
            style: figtreeTextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400, // Regular
              color: const Color(0xFF2B4554), // #2b4554
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            job?.installationType ?? '',
            style: figtreeTextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600, // SemiBold
              color: const Color(0xFF2B4554), // #2b4554
            ),
          ),
          SizedBox(height: 16.h),

          // Divider
          Container(height: 1.h, color: const Color(0xFFC2CCD3)),
          SizedBox(height: 16.h),

          // Total Price
          Text(
            'Total Price:',
            style: figtreeTextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400, // Regular
              color: const Color(0xFF2B4554), // #2b4554
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            _formatCurrency(totalPrice),
            style: figtreeTextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600, // SemiBold
              color: const Color(0xFF2B4554), // #2b4554
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Installer Price:',
            style: figtreeTextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400, // Regular
              color: const Color(0xFF2B4554), // #2b4554
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            _formatCurrency(installerPrice),
            style: figtreeTextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600, // SemiBold
              color: const Color(0xFF2B4554), // #2b4554
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Admin Commission (20%):',
            style: figtreeTextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400, // Regular
              color: const Color(0xFF2B4554), // #2b4554
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            _formatCurrency(adminCommission),
            style: figtreeTextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600, // SemiBold
              color: const Color(0xFF609CBF),
            ),
          ),
          SizedBox(height: 16.h),

          // Divider
          Container(height: 1.h, color: const Color(0xFFC2CCD3)),
          SizedBox(height: 16.h),

          // Job Notes section
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Job Notes: ',
                  style: figtreeTextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600, // SemiBold
                    color: const Color(0xFF2B4554), // #2b4554
                  ),
                ),
                TextSpan(
                  text: jobNotes.isNotEmpty ? jobNotes : 'No job notes',
                  style: figtreeTextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400, // Regular
                    color: const Color(0xFF2B4554), // #2b4554
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    if (value == value.truncateToDouble()) {
      return '\$${value.toStringAsFixed(0)}';
    }
    return '\$${value.toStringAsFixed(2)}';
  }
}

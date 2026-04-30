import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../../core/common/styles/global_text_style.dart';
import '../../models/admin_job.dart';

/// Job Progress Tracking widget for Admin - 100% Figma pixel-perfect
/// Shows tracking information for completed jobs only
class JobTrackingViewAdmin extends StatelessWidget {
  const JobTrackingViewAdmin({super.key, required this.job});

  final AdminJob job;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
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
          // Header with icon and title
          Text(
            'Job Progress Tracking',
            style: figtreeTextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600, // SemiBold
              color: const Color(0xFF2B4554), // #2b4554
            ),
          ),
          SizedBox(height: 20.h),

          // 1. Customer/Job Scheduled Date
          Text(
            '1. Customer/Job Scheduled Date',
            style: figtreeTextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600, // SemiBold
              color: const Color(0xFF2B4554), // #2b4554
            ),
          ),
          SizedBox(height: 12.h),

          // Date input field
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: const Color(0xFFD1D5DB), // Light border
                width: 1.w,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 20.r,
                  color: const Color(0xFF6B7280), // Gray icon
                ),
                SizedBox(width: 12.w),
                Text(
                  job.scheduledDate != null
                      ? DateFormat(
                          'MMMM d\'th\', yyyy',
                        ).format(job.scheduledDate!)
                      : '-',
                  style: figtreeTextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280), // #6b7280
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Installer Notes label
          Text(
            'Installer Notes:',
            style: figtreeTextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500, // Medium
              color: const Color(0xFF2B4554), // #2b4554
            ),
          ),
          SizedBox(height: 8.h),

          // Installer notes text area
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFD1D5DB), width: 1.w),
            ),
            child: Text(
              _displayValue(job.installerNotes),
              style: figtreeTextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6B7280), // #6b7280
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // 3. Additional Work/Charges
          Text(
            '2. Additional Work/Charges',
            style: figtreeTextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600, // SemiBold
              color: const Color(0xFF2B4554), // #2b4554
            ),
          ),
          SizedBox(height: 12.h),

          // Additional work status
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFD1D5DB), width: 1.w),
            ),
            child: Text(
              job.additionalWorkPerformed == null
                  ? '-'
                  : job.additionalWorkPerformed == true
                  ? 'Yes - Additional Work Performed'
                  : 'No - No Additional Work',
              style: figtreeTextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Work Description label
          Text(
            'Work Description:',
            style: figtreeTextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2B4554),
            ),
          ),
          SizedBox(height: 8.h),

          // Work description text area
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFD1D5DB), width: 1.w),
            ),
            child: Text(
              _displayValue(job.additionalWorkDescription),
              style: figtreeTextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // 4. Customer Satisfaction
          Text(
            '3. Was the customer satisfied with your work?',
            style: figtreeTextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600, // SemiBold
              color: const Color(0xFF2B4554), // #2b4554
            ),
          ),
          SizedBox(height: 12.h),

          // Satisfaction status with green background
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: job.customerSatisfied == true
                  ? const Color(0xFFD1FAE5) // Light green #d1fae5
                  : const Color(0xFFFEE2E2), // Light red for dissatisfied
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              job.customerSatisfied == null
                  ? 'Not provided'
                  : job.customerSatisfied == true
                  ? 'Customer Satisfied'
                  : 'Customer Not Satisfied',
              style: figtreeTextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500, // Medium
                color: job.customerSatisfied == null
                    ? const Color(0xFF6B7280)
                    : job.customerSatisfied == true
                    ? const Color(0xFF059669) // Green text #059669
                    : const Color(0xFFDC2626), // Red text
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Feedback label
          Text(
            'Feedback:',
            style: figtreeTextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2B4554),
            ),
          ),
          SizedBox(height: 8.h),

          // Feedback text area
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFD1D5DB), width: 1.w),
            ),
            child: Text(
              _displayValue(job.customerFeedback),
              style: figtreeTextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _displayValue(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? '-' : trimmed;
  }
}

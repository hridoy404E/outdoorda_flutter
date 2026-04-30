import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../../../core/common/styles/global_text_style.dart';
import '../../models/service_request_model.dart';

/// Job Progress Tracking widget for Customer - 100% Figma pixel-perfect
/// Shows tracking information for completed service requests only
class JobTrackingViewCustomer extends StatelessWidget {
  const JobTrackingViewCustomer({super.key, required this.service});

  final ServiceRequest service;

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
          // Header title
          Text(
            'Job Progress Tracking',
            style: figtreeTextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600, // SemiBold
              color: const Color(0xFF2B4554), // #2b4554
            ),
          ),
          SizedBox(height: 20.h),

          // 1. Customer Satisfaction
          Text(
            '1. Are you satisfied?',
            style: figtreeTextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600, // SemiBold
              color: const Color(0xFF2B4554), // #2b4554
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Customer details are view only.',
            style: figtreeTextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 12.h),

          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.w),
            ),
            child: Text(
              _buildSatisfactionLabel(service.customerSatisfied),
              style: figtreeTextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
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

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.w),
            ),
            child: Text(
              _displayValue(service.customerFeedback),
              style: figtreeTextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // 2. Customer/Job Scheduled Date
          Text(
            '2. Customer/Job Scheduled Date',
            style: figtreeTextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600, // SemiBold
              color: const Color(0xFF2B4554), // #2b4554
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Installer updates this section (read-only)',
            style: figtreeTextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 12.h),

          // Date input field
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: const Color(0xFFE5E7EB), // Disabled-style border
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
                  service.scheduledDate != null
                      ? DateFormat(
                          'MMMM d\'th\', yyyy',
                        ).format(service.scheduledDate!)
                      : '',
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
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.w),
            ),
            child: Text(
              _displayValue(service.installerNotes),
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
            '3. Additional Work/Charges',
            style: figtreeTextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600, // SemiBold
              color: const Color(0xFF2B4554), // #2b4554
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Installer updates this section (read-only)',
            style: figtreeTextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 12.h),

          // Additional work status
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.w),
            ),
            child: Text(
              service.additionalWorkPerformed == null
                  ? '-'
                  : service.additionalWorkPerformed == true
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
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.w),
            ),
            child: Text(
              _displayValue(service.additionalWorkDescription),
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

  String _buildSatisfactionLabel(bool? isSatisfied) {
    if (isSatisfied == true) return 'Yes';
    if (isSatisfied == false) return 'No';
    return '-';
  }

  String _displayValue(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty) {
      return '-';
    }
    return text;
  }
}

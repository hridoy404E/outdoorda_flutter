import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/features/admin_section/home/models/activity_model.dart';

/// Activity Item Widget for Admin Dashboard
/// 100% Figma pixel-perfect implementation
class ActivityItemWidget extends StatelessWidget {
  const ActivityItemWidget({super.key, required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: const Color(0xFFECF8FF), // Foundation/Sky/Light:hover
        border: Border.symmetric(
          horizontal: BorderSide(
            color: const Color(0xFF6FAACC), // Foundation/Blue/Normal
            width: 1,
          ),
        ),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description with bullet point
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bullet point
              Container(
                margin: EdgeInsets.only(top: 6.h),
                width: 14.r,
                height: 14.r,
                decoration: const BoxDecoration(
                  color: Color(0xFF6FAACC), // Foundation/Blue/Normal
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8.w),
              // Description text
              Expanded(
                child: Text(
                  activity.description,
                  style: figtreeTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E242C), // Neutral/900
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Timestamp
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16.r,
                color: const Color(0xFF6C7787), // Neutral/400
              ),
              SizedBox(width: 8.w),
              Text(
                activity.timeAgo,
                style: figtreeTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6C7787), // Neutral/400
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

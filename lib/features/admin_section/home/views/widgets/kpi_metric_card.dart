import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';

/// KPI Metric Card widget for Admin Dashboard
/// 100% Figma pixel-perfect implementation
class KPIMetricCard extends StatelessWidget {
  const KPIMetricCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: const Color(0xFFEBEFF1), // Foundation/Blue/Light
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container
            Container(
              width: 32.r,
              height: 32.r,
              decoration: BoxDecoration(
                color: const Color(0xFF395C70), // Foundation/Blue/Normal
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, size: 18.r, color: Colors.white),
            ),
            SizedBox(height: 16.h),
            // Title
            Text(
              title,
              style: figtreeTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF395C70), // Foundation/Blue/Normal
              ),
            ),
            SizedBox(height: 16.h),
            // Value
            Text(
              value,
              style: figtreeTextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF395C70), // Foundation/Blue/Normal
              ),
            ),
          ],
        ),
      ),
    );
  }
}

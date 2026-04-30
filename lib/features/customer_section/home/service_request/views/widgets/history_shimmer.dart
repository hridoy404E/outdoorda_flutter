import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:outdoorda_flutter/core/common/widgets/shimmer_placeholder.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';

class HistoryShimmer extends StatelessWidget {
  const HistoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: index == 2 ? 0 : 16.h),
            child: ShimmerPlaceholder(
              child: Container(
                height: 120.h,
                decoration: BoxDecoration(
                  color: AppColors.neutral25,
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

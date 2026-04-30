import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';

/// Reusable step indicator widget
/// Shows 4 horizontal bars with gradient for active step
class StepIndicatorWidget extends StatelessWidget {
  const StepIndicatorWidget({super.key, required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (index) {
        return Expanded(
          child: Container(
            height: 7.h,
            margin: EdgeInsets.only(right: index < 3 ? 24.w : 0),
            decoration: BoxDecoration(
              gradient: index == currentStep ? AppColors.primaryGradient : null,
              color: index == currentStep ? null : Colors.white,
              borderRadius: BorderRadius.circular(99999.r),
            ),
          ),
        );
      }),
    );
  }
}

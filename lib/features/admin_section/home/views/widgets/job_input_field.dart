import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';

/// Custom input field for create new job bottom sheet
/// Matches Figma design with white background and specific styling
class JobInputField extends StatelessWidget {
  const JobInputField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Label
        Text(
          label,
          style: figtreeTextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.textColor,
          ),
        ),
        SizedBox(height: 4.h),

        /// Input field
        Container(
          height: maxLines == 1 ? 46.h : null,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.inputBorderColor),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: montserratTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.secondary500,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: maxLines == 1 ? 13.h : 14.h,
              ),
              border: InputBorder.none,
              hintText: '',
              hintStyle: montserratTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.secondary500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

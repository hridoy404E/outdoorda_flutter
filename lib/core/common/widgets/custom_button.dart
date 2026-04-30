import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';

/// Custom gradient button widget matching Figma design
/// Full-width gradient button with rounded corners
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.textColor,
  });

  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool enabled;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 46.h,
      decoration: BoxDecoration(
        gradient: enabled ? AppColors.primaryGradient : null,
        color: enabled ? null : Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: enabled ? Colors.transparent : AppColors.borderColor,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled && !isLoading ? onPressed : null,
          borderRadius: BorderRadius.circular(8.r),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 20.r,
                    height: 20.r,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    text,
                    style: poppinsTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor ?? AppColors.neutral25,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

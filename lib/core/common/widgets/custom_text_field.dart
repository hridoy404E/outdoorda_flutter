import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';

/// Custom text field widget matching Figma design
/// Supports icons, validation, password visibility toggle
class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    this.label,
    this.star,
    required this.placeholder,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.showHelpIcon = false,
    this.onChanged,
    this.enabled = true,
    this.prefixIconOnPressed,
  });

  final String? label;
  final String? star;
  final String placeholder;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final bool showHelpIcon;
  final Function(String)? onChanged;
  final bool enabled;
  final Function()? prefixIconOnPressed;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Label with asterisk
        Row(
          children: [
            Text(
              widget.label ?? '',
              style: interTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.neutral800,
              ),
            ),
            Text(
              widget.star ?? '',
              style: interTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.neutral800,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),

        /// Text field
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          obscureText: widget.obscureText && _isObscured,
          keyboardType: widget.keyboardType,
          onChanged: widget.onChanged,
          enabled: widget.enabled,
          style: interTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.neutral700,
          ),
          decoration: InputDecoration(
            hintText: widget.placeholder,
            hintStyle: interTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.neutral700,
            ),
            filled: true,
            fillColor: AppColors.neutral25,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),

            /// Prefix icon (e.g., email icon)
            prefixIcon: widget.prefixIcon != null
                ? IconButton(
                    onPressed: widget.prefixIconOnPressed,
                    icon: Icon(
                      widget.prefixIcon,
                      size: 20.r,
                      color: AppColors.neutral700,
                    ),
                  )
                : null,

            /// Suffix icon (password visibility toggle or help icon)
            suffixIcon: widget.obscureText
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                    icon: Icon(
                      _isObscured
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20.r,
                      color: AppColors.neutral700,
                    ),
                    padding: EdgeInsets.only(right: 16.w),
                  )
                : widget.showHelpIcon
                ? Padding(
                    padding: EdgeInsets.only(right: 16.w),
                    child: Icon(
                      Icons.help_outline,
                      size: 16.r,
                      color: AppColors.neutral700,
                    ),
                  )
                : null, // Invisible icon to maintain layout
            suffixIconConstraints: BoxConstraints(
              minWidth: 44.w,
              minHeight: 20.h,
            ),

            /// Border styling
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.borderColor, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.borderColor, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.borderColor, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.error, width: 1),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.borderColor, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}

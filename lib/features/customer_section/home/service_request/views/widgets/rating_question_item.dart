import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';

/// Reusable widget for displaying a rating question with stars
class RatingQuestionItem extends StatelessWidget {
  const RatingQuestionItem({
    super.key,
    required this.question,
    required this.rating,
    required this.onRatingChanged,
    required this.isEnabled,
  });

  final String question;
  final double rating;
  final Function(double) onRatingChanged;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.neutral25,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFD9D9D9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text
          Text(
            question,
            style: figtreeTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 12.h),

          // Star rating
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              return GestureDetector(
                onTap: isEnabled
                    ? () => onRatingChanged(starIndex.toDouble())
                    : null,
                child: Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: Icon(
                    rating >= starIndex ? Icons.star : Icons.star_border,
                    size: 28.r,
                    color: rating >= starIndex
                        ? const Color(0xFFFBBC05)
                        : AppColors.textSecondary,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

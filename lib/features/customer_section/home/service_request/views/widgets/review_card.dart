import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/models/review_model.dart';

/// Reusable review card widget for Happy Tails section
/// Displays star rating, review text, and reviewer information
class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key, required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 286.w,
      margin: EdgeInsets.only(right: 8.w),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.cardBorder, width: 1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Star rating
          _buildStarRating(review.rating),
          SizedBox(height: 10.h),

          // // Review text
          // Text(
          //   review.reviewText,
          //   style: figtreeTextStyle(
          //     fontSize: 13,
          //     fontWeight: FontWeight.w400,
          //     color: AppColors.textNormal,
          //   ),
          //   maxLines: 2,
          //   overflow: TextOverflow.ellipsis,
          // ),
          // SizedBox(height: 12.h),

          // Reviewer info
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(review.reviewerImageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName,
                      style: figtreeTextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      review.petName,
                      style: figtreeTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build star rating widget
  Widget _buildStarRating(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Padding(
          padding: EdgeInsets.only(right: index < 4 ? 4.w : 0),
          child: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: AppColors.starYellow,
            size: 17.r,
          ),
        );
      }),
    );
  }
}

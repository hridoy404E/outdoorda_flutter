import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';

import '../../controllers/review_controller.dart';
import '../../models/service_request_model.dart';
import 'rating_question_item.dart';

class ReviewCardWidget extends StatelessWidget {
  const ReviewCardWidget({
    super.key,
    required this.service,
    required this.controller,
  });

  final ServiceRequest service;
  final RequestDetailsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(24.r),
          border: const Border(
            left: BorderSide(color: AppColors.completedBadge, width: 2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              AppStrings.rating,
              style: figtreeTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            // SizedBox(height: 8.h),

            // // Subtitle
            // Text(
            //   AppStrings.rateYourExperience,
            //   style: figtreeTextStyle(
            //     fontSize: 14,
            //     fontWeight: FontWeight.w400,
            //     color: AppColors.textSecondary,
            //   ),
            // ),
            SizedBox(height: 16.h),

            // List of all questions with ratings
            ...List.generate(
              controller.ratingQuestions.length,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: RatingQuestionItem(
                  question: controller.ratingQuestions[index],
                  rating: controller.getRating(index),
                  onRatingChanged: (newRating) {
                    controller.setRating(index, newRating);
                  },
                  isEnabled: !controller.isReviewSubmitted.value,
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Show average rating if all questions are rated
            if (controller.allQuestionsRated) ...[
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6FAACC), Color(0xFF395C70)],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.averageRating,
                      style: figtreeTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral25,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          controller.averageRating.toStringAsFixed(1),
                          style: figtreeTextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.neutral25,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        const Icon(
                          Icons.star,
                          color: Color(0xFFFBBC05),
                          size: 24,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
            ],

            Text(
              AppStrings.yourReview,
              style: figtreeTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: controller.reviewNoteController,
              enabled: !controller.isReviewSubmitted.value,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: AppStrings.reviewPlaceholder,
                hintStyle: figtreeTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: AppColors.neutral25,
                contentPadding: EdgeInsets.all(12.r),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: AppColors.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: AppColors.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: AppColors.gradientStart),
                ),
              ),
              style: figtreeTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 16.h),

            // Submit Button
            if (!controller.isReviewSubmitted.value)
              GestureDetector(
                onTap: controller.isSubmitting.value
                    ? null
                    : () => controller.submitReview(
                        serviceId: service.id,
                        installerId: service.installerName,
                      ),
                child: Container(
                  width: double.infinity,
                  height: 48.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF6FAACC), Color(0xFF395C70)],
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: controller.isSubmitting.value
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: const CircularProgressIndicator(
                              color: AppColors.neutral25,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            AppStrings.submitReview,
                            style: figtreeTextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.neutral25,
                            ),
                          ),
                  ),
                ),
              ),

            // Success message after submission
            if (controller.isReviewSubmitted.value)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.completedBadge.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.completedBadge,
                      size: 20.r,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      AppStrings.reviewSubmittedSuccess,
                      style: figtreeTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.completedBadge,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

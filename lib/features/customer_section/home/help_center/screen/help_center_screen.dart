import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_button.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/features/customer_section/home/help_center/controller/help_center_controller.dart';

/// Help Center Screen
/// Displays FAQ section with accordion and support contact option
class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HelpCenterController>();

    return Scaffold(
      body: Column(
        children: [
          // Header Section with gradient background
          _buildHeader(controller),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24.h),

                    // FAQ Section Title
                    Text(
                      'Frequently Asked Questions',
                      style: figtreeTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // FAQ Accordion List
                    _buildFaqAccordion(controller),
                    SizedBox(height: 24.h),

                    // Support Contact Card
                    _buildSupportContactCard(controller),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build header with gradient background
  Widget _buildHeader(HelpCenterController controller) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.priceColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(17.w, 6.h, 17.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button and title
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(
                      Icons.arrow_back,
                      color: AppColors.neutral25,
                      size: 24.r,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'Help Center',
                    style: figtreeTextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cardBackground,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // "How can we help?" section
              Text(
                'How can we help?',
                style: figtreeTextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral25,
                ),
              ),
              SizedBox(height: 6.h),

              // Search field
              Container(
                height: 46.h,
                decoration: BoxDecoration(
                  color: AppColors.neutral25,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: const Color(0xFFEDF1F3), width: 1),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 14.w),
                    Icon(Icons.search, size: 16.r, color: AppColors.neutral300),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Search for help...',
                        style: montserratTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF1A1C1E),
                        ),
                      ),
                    ),
                    SizedBox(width: 14.w),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build FAQ accordion list
  Widget _buildFaqAccordion(HelpCenterController controller) {
    final faqList = [
      {
        'question': 'How do I measure my pet?',
        'answer':
            'Measure your pet\'s neck, chest, and back length with a snug tape to ensure proper sizing.',
      },
      {
        'question': 'What if I need to reschedule?',
        'answer':
            'You can reschedule your appointment by contacting our support team or through the app settings.',
      },
      {
        'question': 'Is there a warranty?',
        'answer':
            'Yes, we provide a comprehensive warranty on all our products and services. Please contact support for details.',
      },
    ];

    return Column(
      children: List.generate(faqList.length, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Obx(
            () => _buildAccordionItem(
              question: faqList[index]['question']!,
              answer: faqList[index]['answer']!,
              isExpanded: controller.isExpanded(index),
              onTap: () => controller.toggleFaqItem(index),
            ),
          ),
        );
      }),
    );
  }

  /// Build individual accordion item
  Widget _buildAccordionItem({
    required String question,
    required String answer,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isExpanded ? AppColors.cardBorder : AppColors.settingsWhite,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isExpanded ? Colors.transparent : AppColors.borderColor,
          width: 1,
        ),
        boxShadow: isExpanded
            ? [
                BoxShadow(
                  color: const Color(0xFF0073C5).withValues(alpha: 0.2),
                  offset: const Offset(0, 0),
                  blurRadius: 10,
                ),
              ]
            : [],
      ),
      child: Column(
        children: [
          // Question header
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      question,
                      style: figtreeTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(width: 24.w),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 24.r,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),

          // Answer section (only visible when expanded)
          if (isExpanded)
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
              child: Text(
                answer,
                style: figtreeTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.neutral400,
                  lineHeight: 1.43,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Build support contact card
  Widget _buildSupportContactCard(HelpCenterController controller) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFFECF8FF),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0073C5).withValues(alpha: 0.2),
            offset: const Offset(0, 0),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and text section
          Row(
            children: [
              Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.phone, color: AppColors.textDark, size: 24.r),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Still need help?',
                    style: figtreeTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral900,
                    ),
                  ),
                  Text(
                    'Our support team is available 24/7',
                    style: figtreeTextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.neutral300,
                      lineHeight: 1.33,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Call Support Button
          CustomButton(
            text: 'Call Support',
            onPressed: () => controller.callSupport(),
          ),
        ],
      ),
    );
  }
}

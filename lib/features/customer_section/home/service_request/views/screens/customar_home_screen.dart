import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_appbar.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/controllers/customar_home_controller.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/views/widgets/history_card.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/views/widgets/history_shimmer.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/views/widgets/ongoing_service_card.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/views/widgets/quick_actions.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/views/widgets/review_card.dart';

/// Service request screen displaying ongoing services, history, and reviews
class CustomarHomeScreen extends StatelessWidget {
  const CustomarHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CustomarHomeController>();

    return Scaffold(
      appBar: CustomAppBar(
        greetingText: AppStrings.goodMorning,
        userType: AppStrings.customer,
        onProfileTap: controller.onProfileTap,
      ),
      body: Obx(
        () => RefreshIndicator(
          onRefresh: controller.refreshCustomerHistory,
          child: ListView(
            padding: EdgeInsets.zero,
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              // Ongoing service card section
              if (controller.isLoading.value &&
                  controller.ongoingServices.isEmpty)
                const OngoingServiceCard.loading()
              else if (controller.ongoingServices.isNotEmpty)
                OngoingServiceCard(
                  service: controller.ongoingServices.first,
                  onTap: () => controller.onServiceTap(
                    controller.ongoingServices.first.id,
                  ),
                  onInstallerTap: () => controller.onInstallerTap(
                    controller.ongoingServices.first.installerName,
                  ),
                ),

              SizedBox(height: 20.h),

              // Quick actions section
              QuickActions(
                onNewRequestTap: controller.onNewRequestTap,
                onMessageTap: controller.onMessageTap,
                onHelpCenterTap: controller.onHelpCenterTap,
              ),

              SizedBox(height: 20.h),

              // Your history section
              if (controller.isLoading.value)
                const HistoryShimmer()
              else if (controller.historyServices.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.yourHistory,
                        style: figtreeTextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          controller.onViewAllTap();
                        },
                        child: Text(
                          'view all',
                          style: figtreeTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  child: Column(
                    children: controller.historyServices
                        .map(
                          (service) => HistoryCard(
                            service: service,
                            onTap: () => controller.onServiceTap(service.id),
                            onInstallerTap: () => controller.onInstallerTap(
                              service.installerName,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],

              SizedBox(height: 8.h),

              // Happy tails section
              if (controller.happyTailsReviews.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  child: Text(
                    AppStrings.happyTails,
                    style: figtreeTextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  height: 100.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.only(left: 14.w, right: 14.w),
                    itemCount: controller.happyTailsReviews.length,
                    itemBuilder: (context, index) {
                      return ReviewCard(
                        review: controller.happyTailsReviews[index],
                      );
                    },
                  ),
                ),
              ],

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}

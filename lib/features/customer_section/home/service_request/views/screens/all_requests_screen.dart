import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_appbar.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/controllers/customar_home_controller.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/views/widgets/history_card.dart';

/// All Requests Screen - Shows list of all service requests
/// Matches Figma design (node-id: 1-6195)
class AllRequestsScreen extends StatelessWidget {
  const AllRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CustomarHomeController>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const CustomAppBar(
        greetingText: AppStrings.goodMorning,
        userType: AppStrings.customer,
      ),
      body: Column(
        children: [
          // Header with title and add button
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.myRequests,
                  style: figtreeTextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                // Add button with gradient background
                GestureDetector(
                  onTap: controller.onNewRequestTap,
                  child: Container(
                    width: 44.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.add,
                      color: AppColors.neutral25,
                      size: 24.r,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // List of requests
          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                itemCount: controller.historyServices.length,
                itemBuilder: (context, index) {
                  final service = controller.historyServices[index];

                  return HistoryCard(
                    service: service,
                    onTap: () => controller.onServiceTap(service.id),
                    onInstallerTap: () =>
                        controller.onInstallerTap(service.installerName),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

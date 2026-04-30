import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/features/installer_section/management/controllers/installer_admin_posts_controller.dart';
import 'package:outdoorda_flutter/features/installer_section/management/views/widgets/management_item_card.dart';

class InstallerAdminPostsScreen extends StatelessWidget {
  const InstallerAdminPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InstallerAdminPostsController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Post Jobs')),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.jobs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.loadJobsError.value.isNotEmpty &&
              controller.jobs.isEmpty) {
            return _buildErrorState(controller);
          }

          if (controller.jobs.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: controller.loadAdminPosts,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              itemCount: controller.jobs.length,
              itemBuilder: (context, index) {
                final job = controller.jobs[index];
                final isAccepting = controller.acceptingPostId.value == job.id;

                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: Column(
                    children: [
                      ManagementItemCard(job: job, onTap: () {}),
                      SizedBox(height: 10.h),
                      _buildAcceptButton(
                        isAccepting: isAccepting,
                        onTap: isAccepting
                            ? null
                            : () => controller.acceptJob(job),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAcceptButton({
    required bool isAccepting,
    required VoidCallback? onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          backgroundColor: const Color(0xFF395C70),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        child: Text(
          isAccepting ? 'Accepting...' : 'Accept Job',
          style: figtreeTextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No admin post jobs found',
        style: figtreeTextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF6C7787),
        ),
      ),
    );
  }

  Widget _buildErrorState(InstallerAdminPostsController controller) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              controller.loadJobsError.value,
              textAlign: TextAlign.center,
              style: figtreeTextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6C7787),
              ),
            ),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: controller.loadAdminPosts,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

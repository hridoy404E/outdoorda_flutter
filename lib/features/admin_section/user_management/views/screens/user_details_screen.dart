import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/features/admin_section/user_management/controllers/user_management_controller.dart';
import 'package:outdoorda_flutter/features/admin_section/user_management/models/user_model.dart';

class UserDetailsScreen extends StatelessWidget {
  const UserDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<UserManagementController>()
        ? Get.find<UserManagementController>()
        : Get.put(UserManagementController());
    final user = Get.arguments is UserModel ? Get.arguments as UserModel : null;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        surfaceTintColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'User Details',
          style: figtreeTextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: user == null
          ? const _MissingUserState()
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileHeader(user: user),
                  SizedBox(height: 16.h),
                  _DetailsPanel(user: user),
                  SizedBox(height: 20.h),
                  _ActionButtons(controller: controller, user: user),
                ],
              ),
            ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final imageUrl = user.profileImageUrl.trim();
    final displayName = user.name.trim().isNotEmpty ? user.name.trim() : 'User';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFEBEFF1)),
      ),
      child: Row(
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cardBackground,
              image: imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageUrl.isEmpty
                ? Icon(Icons.person, size: 32.r, color: AppColors.neutral400)
                : null,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: figtreeTextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    _StatusBadge(
                      label: user.userType.capitalizeFirst ?? user.userType,
                      color: AppColors.skyDark,
                    ),
                    SizedBox(width: 8.w),
                    _StatusBadge(
                      label: user.isSuspended ? 'Suspended' : 'Active',
                      color: user.isSuspended
                          ? AppColors.error
                          : AppColors.success,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsPanel extends StatelessWidget {
  const _DetailsPanel({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFEBEFF1)),
      ),
      child: Column(
        children: [
          _DetailRow(label: 'Name', value: user.name),
          _DetailDivider(),
          _DetailRow(label: 'User ID', value: user.id),
          _DetailDivider(),
          _DetailRow(label: 'Type', value: user.userType),
          _DetailDivider(),
          _DetailRow(label: 'Contact', value: user.address),
          _DetailDivider(),
          _DetailRow(label: 'Joined Date', value: user.joinedDate),
          _DetailDivider(),
          _DetailRow(
            label: 'Status',
            value: user.isSuspended ? 'Suspended' : 'Active',
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.controller, required this.user});

  final UserManagementController controller;
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 46.h,
            child: ElevatedButton.icon(
              onPressed: () => controller.openUserMessage(user),
              icon: Icon(Icons.chat_bubble_outline, size: 18.r),
              label: Text(
                'Message',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: figtreeTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gradientEnd,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: SizedBox(
            height: 46.h,
            child: OutlinedButton.icon(
              onPressed: () => controller.deleteUser(user),
              icon: Icon(Icons.delete_outline, size: 18.r),
              label: Text(
                'Delete',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: figtreeTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cleanedValue = value.trim().isEmpty ? 'N/A' : value.trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 108.w,
          child: Text(
            label,
            style: figtreeTextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            cleanedValue,
            textAlign: TextAlign.right,
            style: figtreeTextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Container(height: 1.h, color: const Color(0xFFEBEFF1)),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 112.w),
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: figtreeTextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _MissingUserState extends StatelessWidget {
  const _MissingUserState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Text(
          'User details missing',
          textAlign: TextAlign.center,
          style: figtreeTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_button.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';

import '../../controllers/new_service_controller.dart';

enum _AttachmentOption { camera, image, file }

class Step3 extends StatelessWidget {
  const Step3({super.key, required this.controller});

  final NewServiceController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Subtitle
                  Text(
                    AppStrings.helpUsSeeDoorInstallationArea,
                    style: interTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.neutral700,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  /// Photo upload area
                  Obx(() => _buildPhotoUploadArea(controller)),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),

          /// Back and Submit buttons
          Row(
            children: [
              /// Back button
              Expanded(
                child: CustomButton(
                  text: AppStrings.back,
                  onPressed: controller.previousStep,
                ),
              ),
              SizedBox(width: 12.w),

              /// Submit button
              Expanded(
                child: Obx(
                  () => CustomButton(
                    text: AppStrings.submitRequest,
                    onPressed: controller.submitRequest,
                    isLoading: controller.isLoading.value,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  /// Build photo upload area
  Widget _buildPhotoUploadArea(NewServiceController controller) {
    final selectedAttachment = controller.selectedAttachment.value;
    final attachmentName = controller.selectedAttachmentName.value;
    final isImage =
        selectedAttachment != null &&
        _isImageFile(
          attachmentName.isNotEmpty
              ? attachmentName
              : selectedAttachment.path.split('/').last,
        );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.neutral25,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selectedAttachment == null) ...[
            /// Camera icon
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(32.r),
              ),
              child: Icon(
                Icons.camera_alt_outlined,
                size: 32.r,
                color: AppColors.gradientEnd,
              ),
            ),
            SizedBox(height: 16.h),
          ] else ...[
            if (isImage) ...[
              /// Selected image preview
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.file(
                  selectedAttachment,
                  height: 180.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.insert_drive_file_outlined,
                      size: 40.r,
                      color: AppColors.gradientEnd,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      AppStrings.file,
                      style: interTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 12.h),
            Text(
              attachmentName.isNotEmpty
                  ? attachmentName
                  : selectedAttachment.path.split('/').last,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: interTextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.neutral700,
              ),
            ),
            SizedBox(height: 16.h),
          ],

          /// Upload text
          Text(
            AppStrings.uploadAttachmentForInstallationArea,
            textAlign: TextAlign.center,
            style: interTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.neutral700,
            ),
          ),
          SizedBox(height: 16.h),

          /// Browse button
          PopupMenuButton<_AttachmentOption>(
            onSelected: (option) =>
                _handleAttachmentSelection(option, controller),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            itemBuilder: (context) => [
              PopupMenuItem<_AttachmentOption>(
                value: _AttachmentOption.camera,
                child: _buildMenuItem(
                  icon: Icons.camera_alt_outlined,
                  label: AppStrings.camera,
                ),
              ),
              PopupMenuItem<_AttachmentOption>(
                value: _AttachmentOption.image,
                child: _buildMenuItem(
                  icon: Icons.image_outlined,
                  label: AppStrings.image,
                ),
              ),
              PopupMenuItem<_AttachmentOption>(
                value: _AttachmentOption.file,
                child: _buildMenuItem(
                  icon: Icons.attach_file_outlined,
                  label: AppStrings.file,
                ),
              ),
            ],
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.neutral25,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.gradientEnd, width: 1),
              ),
              child: Text(
                AppStrings.browseFile,
                style: poppinsTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gradientEnd,
                ),
              ),
            ),
          ),

          /// Show selected image name
          if (selectedAttachment != null) ...[
            SizedBox(height: 12.h),
            Text(
              '✓ ${AppStrings.attachmentSelected}',
              style: interTextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.success,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleAttachmentSelection(
    _AttachmentOption option,
    NewServiceController controller,
  ) async {
    switch (option) {
      case _AttachmentOption.camera:
        await controller.pickFromCamera();
        break;
      case _AttachmentOption.image:
        await controller.pickFromGallery();
        break;
      case _AttachmentOption.file:
        await controller.pickFile();
        break;
    }
  }

  Widget _buildMenuItem({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(icon, size: 18.r, color: AppColors.neutral700),
        SizedBox(width: 10.w),
        Text(
          label,
          style: interTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.neutral700,
          ),
        ),
      ],
    );
  }

  bool _isImageFile(String path) {
    final lowerPath = path.toLowerCase();
    return lowerPath.endsWith('.jpg') ||
        lowerPath.endsWith('.jpeg') ||
        lowerPath.endsWith('.png') ||
        lowerPath.endsWith('.gif') ||
        lowerPath.endsWith('.webp') ||
        lowerPath.endsWith('.bmp') ||
        lowerPath.endsWith('.heic');
  }
}

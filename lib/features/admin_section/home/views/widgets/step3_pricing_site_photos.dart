import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/features/admin_section/home/controllers/create_new_job_controller.dart';
import 'package:outdoorda_flutter/features/admin_section/home/views/widgets/job_input_field.dart';
import 'package:outdoorda_flutter/features/admin_section/home/views/widgets/step_indicator_widget.dart';

/// Step 3: Pricing & Site Photos
/// Pricing fields, photo upload, Back and Next buttons
class Step3PricingSitePhotos extends StatelessWidget {
  const Step3PricingSitePhotos({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateNewJobController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Step indicator
        const StepIndicatorWidget(currentStep: 2),
        SizedBox(height: 16.h),

        /// Estimated Labor Price
        JobInputField(
          label: AppStrings.estimatedLaborPrice,
          controller: controller.estimatedPriceController,
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 6.h),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller.estimatedPriceController,
          builder: (context, value, _) {
            final installerPrice = _parsePrice(value.text);
            final adminCommission = installerPrice * 0.20;

            return Text(
              'Admin Commission (20%): ${_formatCurrency(adminCommission)}',
              style: figtreeTextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.neutral400,
              ),
            );
          },
        ),
        SizedBox(height: 16.h),

        /// Site Photos section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.sitePhotos,
              style: figtreeTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.neutral900,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              AppStrings.uploadPhotosOfInstallationSite,
              style: figtreeTextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.neutral400,
              ),
            ),
            SizedBox(height: 18.h),

            /// Upload button
            GestureDetector(
              onTap: controller.uploadPhoto,
              child: Container(
                height: 36.h,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.uploadBorderGreen),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.upload_outlined,
                      size: 16.r,
                      color: AppColors.uploadBorderGreen,
                    ),
                    SizedBox(width: 8.w),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF11D000), Color(0xFF0C5302)],
                      ).createShader(bounds),
                      child: Text(
                        AppStrings.upload,
                        style: figtreeTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 6.h),

            Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (controller.uploadedImages.isNotEmpty) ...[
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: List.generate(
                        controller.uploadedImages.length,
                        (index) {
                          final image = controller.uploadedImages[index];
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: Image.file(
                                  image,
                                  width: 72.w,
                                  height: 72.w,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: -6.h,
                                right: -6.w,
                                child: GestureDetector(
                                  onTap: () =>
                                      controller.removeUploadedImage(index),
                                  child: Container(
                                    width: 18.w,
                                    height: 18.h,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE53935),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      size: 12.r,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],
                  if (controller.uploadedFiles.isNotEmpty) ...[
                    Column(
                      children: List.generate(
                        controller.uploadedFiles.length,
                        (index) => Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: _buildUploadedFileTile(controller, index),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                  ],
                  Text(
                    '${controller.uploadedImages.length} / 10 images, '
                    '${controller.uploadedFiles.length} / 5 files uploaded',
                    style: figtreeTextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.neutral300,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Use Upload to add from camera, gallery, or file',
              style: figtreeTextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppColors.neutral400,
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),

        /// Back and Next buttons
        Row(
          children: [
            /// Back button
            GestureDetector(
              onTap: controller.previousStep,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.skyDark),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  AppStrings.back,
                  style: figtreeTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.skyDark,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),

            /// Next button
            Expanded(
              child: Container(
                height: 40.h,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: controller.nextStep,
                    borderRadius: BorderRadius.circular(8.r),
                    child: Center(
                      child: Text(
                        AppStrings.nextPricing,
                        style: figtreeTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUploadedFileTile(CreateNewJobController controller, int index) {
    final file = controller.uploadedFiles[index];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.neutral25,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Icon(
            Icons.insert_drive_file_outlined,
            size: 20.r,
            color: AppColors.skyDark,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              _fileName(file.path),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: figtreeTextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.neutral700,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => controller.removeUploadedFile(index),
            child: Container(
              width: 22.w,
              height: 22.h,
              decoration: const BoxDecoration(
                color: Color(0xFFE53935),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 13.r, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _fileName(String path) {
    final slashIndex = path.lastIndexOf('/');
    if (slashIndex == -1 || slashIndex == path.length - 1) return path;
    return path.substring(slashIndex + 1);
  }

  double _parsePrice(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  String _formatCurrency(double value) {
    if (value == value.truncateToDouble()) {
      return '\$${value.toStringAsFixed(0)}';
    }
    return '\$${value.toStringAsFixed(2)}';
  }
}

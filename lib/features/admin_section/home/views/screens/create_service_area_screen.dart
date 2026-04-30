import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/features/admin_section/home/controllers/create_service_area_controller.dart';

class CreateServiceAreaScreen extends StatelessWidget {
  const CreateServiceAreaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateServiceAreaController());

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text(
          AppStrings.createServiceAreaTitle,
          style: figtreeTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.serviceAreaName,
                style: figtreeTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: controller.nameController,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => controller.createServiceArea(),
                decoration: InputDecoration(
                  hintText: AppStrings.enterServiceAreaName,
                  hintStyle: figtreeTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.neutral400,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: AppColors.inputBorderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: AppColors.inputBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: AppColors.gradientEnd),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : controller.createServiceArea,
                    icon: Icon(Icons.add_circle_outline, size: 18.r),
                    label: Text(
                      AppStrings.createServiceArea,
                      style: figtreeTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gradientEnd,
                      disabledBackgroundColor: AppColors.textSecondary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.currentServiceAreas,
                      style: figtreeTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: controller.loadServiceAreas,
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: AppColors.textDark,
                      size: 20.r,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Expanded(
                child: Obx(() {
                  if (controller.isServiceAreasLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.gradientStart,
                      ),
                    );
                  }

                  if (controller.serviceAreas.isEmpty) {
                    return Center(
                      child: Text(
                        AppStrings.noServiceAreasAvailable,
                        style: figtreeTextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.neutral400,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: controller.serviceAreas.length,
                    separatorBuilder: (_, __) => SizedBox(height: 8.h),
                    itemBuilder: (context, index) {
                      final area = controller.serviceAreas[index];
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: AppColors.inputBorderColor),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16.r,
                              color: AppColors.gradientEnd,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                area.name,
                                style: figtreeTextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_button.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_text_field.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/core/utils/validators/app_validator.dart';
import 'package:outdoorda_flutter/features/installer_section/management/models/management_job.dart';

/// Dialog widget for adjusting bid on a job
class AdjustBidWidget extends StatelessWidget {
  const AdjustBidWidget({
    super.key,
    required this.proposedPriceController,
    required this.currentJob,
    required this.reasonController,
    required this.context,
    required this.onSubmitBid,
    required this.isSubmittingBid,
  });

  final TextEditingController proposedPriceController;
  final Rx<ManagementJob?> currentJob;
  final TextEditingController reasonController;
  final BuildContext context;
  final Function(BuildContext) onSubmitBid;
  final RxBool isSubmittingBid;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dialog title
            Text(
              AppStrings.adjustYourBid,
              style: figtreeTextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 16.h),
            // SizedBox(width: 8.w),
            CustomTextField(
              validator: AppValidator.validatePrice,
              prefixIcon: Icons.attach_money,
              label: AppStrings.yourProposedPrice,
              controller: proposedPriceController,
              placeholder: AppStrings.enterYourProposedPrice,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20.h),

            // Reason field
            CustomTextField(
              label: AppStrings.reasonForAdjustment,
              controller: reasonController,
              placeholder: AppStrings.enterReason,
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: 24.h),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppColors.dividerColor,
                        width: 1.5.w,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text(
                      AppStrings.cancel,
                      style: figtreeTextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textNormal,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Obx(
                    () => CustomButton(
                      text: AppStrings.submitBid,
                      onPressed: () => onSubmitBid(context),
                      isLoading: isSubmittingBid.value,
                      enabled: !isSubmittingBid.value,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

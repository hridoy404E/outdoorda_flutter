import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_button.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/features/installer_section/payment/controllers/installer_commission_payment_controller.dart';
import 'package:outdoorda_flutter/features/installer_section/settings/controllers/installer_setting_controller.dart';

class InstallerCommissionPaymentScreen extends StatelessWidget {
  const InstallerCommissionPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InstallerCommissionPaymentController>();
    final settingController = Get.find<InstallerSettingController>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        surfaceTintColor: AppColors.bg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Pay Commission',
          style: figtreeTextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
          children: [
            _PayableCommissionCard(settingController: settingController),
            SizedBox(height: 18.h),
            _AmountCard(controller: controller),
            SizedBox(height: 18.h),
            Text(
              'Payment Method',
              style: figtreeTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 10.h),
            Obx(
              () => Column(
                children: [
                  _PaymentMethodTile(
                    icon: Icons.credit_card_outlined,
                    title: 'Stripe',
                    subtitle: 'Pay now with card using Stripe',
                    selected:
                        controller.selectedMethod.value ==
                        InstallerCommissionPaymentMethod.stripe,
                    onTap: () => controller.selectMethod(
                      InstallerCommissionPaymentMethod.stripe,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _PaymentMethodTile(
                    icon: Icons.payments_outlined,
                    title: 'Cash',
                    subtitle: 'Submit this commission as cash payment',
                    selected:
                        controller.selectedMethod.value ==
                        InstallerCommissionPaymentMethod.cash,
                    onTap: () => controller.selectMethod(
                      InstallerCommissionPaymentMethod.cash,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Obx(
              () => CustomButton(
                text:
                    controller.selectedMethod.value ==
                        InstallerCommissionPaymentMethod.stripe
                    ? 'Pay with Stripe'
                    : 'Submit Cash Payment',
                isLoading: controller.isPaying.value,
                enabled: !controller.isPaying.value,
                onPressed: controller.submitPayment,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayableCommissionCard extends StatelessWidget {
  const _PayableCommissionCard({required this.settingController});

  final InstallerSettingController settingController;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: r'$', decimalDigits: 2);

    return Obx(
      () => Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 23.r,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payable Commission',
                    style: figtreeTextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    formatter.format(
                      settingController.displayPayableCommissionAmount.value,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: figtreeTextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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

class _AmountCard extends StatelessWidget {
  const _AmountCard({required this.controller});

  final InstallerCommissionPaymentController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFEBEFF1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amount',
            style: figtreeTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 10.h),
          TextField(
            controller: controller.amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              prefixText: r'$ ',
              hintText: '0.00',
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 14.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: Color(0xFFDFE1E6)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: Color(0xFFDFE1E6)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: AppColors.gradientEnd),
              ),
            ),
            style: figtreeTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF2FAFF) : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: selected ? AppColors.gradientEnd : const Color(0xFFEBEFF1),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.gradientEnd
                    : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                size: 22.r,
                color: selected ? Colors.white : AppColors.textNormal,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: figtreeTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: figtreeTextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 22.r,
              color: selected ? AppColors.gradientEnd : AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

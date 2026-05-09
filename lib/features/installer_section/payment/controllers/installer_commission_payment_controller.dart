import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/services/payments/stripe_payment_service.dart';
import 'package:outdoorda_flutter/core/services/storage_service.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/features/installer_section/payment/controllers/installer_payment_details_controller.dart';
import 'package:outdoorda_flutter/features/installer_section/payment/services/installer_payment_api_service.dart';
import 'package:outdoorda_flutter/features/installer_section/settings/controllers/installer_setting_controller.dart';

enum InstallerCommissionPaymentMethod { stripe, cash }

class InstallerCommissionPaymentController extends GetxController {
  InstallerCommissionPaymentController();

  final InstallerPaymentApiService _paymentApiService =
      InstallerPaymentApiService();
  final StripePaymentService _stripePaymentService = StripePaymentService();

  final TextEditingController amountController = TextEditingController();
  final Rx<InstallerCommissionPaymentMethod> selectedMethod =
      InstallerCommissionPaymentMethod.stripe.obs;
  final RxBool isPaying = false.obs;

  @override
  void onInit() {
    super.onInit();
    _prefillPayableCommission();
  }

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }

  void selectMethod(InstallerCommissionPaymentMethod method) {
    selectedMethod.value = method;
  }

  Future<void> submitPayment() async {
    if (isPaying.value) return;

    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      EasyLoading.showError('Please enter a valid amount');
      return;
    }

    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      EasyLoading.showError(AppStrings.authorizationRequired);
      return;
    }

    final method = selectedMethod.value;
    String? stripePaymentId;

    try {
      isPaying.value = true;
      EasyLoading.show(
        status: method == InstallerCommissionPaymentMethod.stripe
            ? AppStrings.preparingPayment
            : 'Submitting cash payment...',
      );

      final result = await _paymentApiService.createCommissionPayment(
        authorization: authorization,
        amount: amount,
        paymentType: _paymentTypeValue(method),
      );

      if (method == InstallerCommissionPaymentMethod.stripe) {
        stripePaymentId = result.payment?.id.trim();
        final clientSecret = result.clientSecret?.trim();
        if (clientSecret == null || clientSecret.isEmpty) {
          throw Exception('Stripe client secret missing from payment response');
        }

        await _stripePaymentService.payWithPaymentSheet(
          clientSecret: clientSecret,
        );

        if (stripePaymentId != null && stripePaymentId.isNotEmpty) {
          await _notifyStripeWebhook(paymentId: stripePaymentId, status: true);
        }
      }

      EasyLoading.dismiss();
      EasyLoading.showSuccess(
        method == InstallerCommissionPaymentMethod.stripe
            ? 'Commission payment completed'
            : 'Cash commission payment submitted',
      );
      _refreshDependentData();
      Get.back();
    } on PaymentCancelledException {
      await _notifyStripeWebhook(paymentId: stripePaymentId, status: false);
      EasyLoading.dismiss();
      EasyLoading.showInfo(AppStrings.paymentCancelled);
    } on StripeException catch (error) {
      AppLoggerHelper.error(
        'Installer Stripe commission payment failed',
        error,
      );
      await _notifyStripeWebhook(paymentId: stripePaymentId, status: false);
      EasyLoading.dismiss();
      EasyLoading.showError(AppStrings.paymentFailed);
    } catch (error) {
      AppLoggerHelper.error('Installer commission payment failed', error);
      if (method == InstallerCommissionPaymentMethod.stripe) {
        await _notifyStripeWebhook(paymentId: stripePaymentId, status: false);
      }
      EasyLoading.dismiss();
      EasyLoading.showError('Failed to submit commission payment');
    } finally {
      isPaying.value = false;
    }
  }

  String _paymentTypeValue(InstallerCommissionPaymentMethod method) {
    switch (method) {
      case InstallerCommissionPaymentMethod.stripe:
        return 'stripe';
      case InstallerCommissionPaymentMethod.cash:
        return 'others';
    }
  }

  void _prefillPayableCommission() {
    if (!Get.isRegistered<InstallerSettingController>()) return;
    final payable = Get.find<InstallerSettingController>()
        .displayPayableCommissionAmount
        .value;
    if (payable > 0) {
      amountController.text = payable.toStringAsFixed(2);
    }
  }

  void _refreshDependentData() {
    if (Get.isRegistered<InstallerPaymentDetailsController>()) {
      Get.find<InstallerPaymentDetailsController>().refreshPayments();
    }
  }

  Future<void> _notifyStripeWebhook({
    required String? paymentId,
    required bool status,
  }) async {
    final cleanedPaymentId = paymentId?.trim() ?? '';
    if (cleanedPaymentId.isEmpty) return;

    try {
      await _paymentApiService.notifyStripeManualWebhook(
        paymentId: cleanedPaymentId,
        status: status,
      );
    } catch (error) {
      AppLoggerHelper.error(
        'Failed to notify installer Stripe manual webhook',
        error,
      );
    }
  }

  String? _buildAuthorizationHeader() {
    final token = StorageService.accessToken;
    if (token == null || token.isEmpty) return null;

    final type = StorageService.tokenType?.trim();
    final prefix = (type != null && type.isNotEmpty) ? type : 'Bearer';
    return '$prefix $token';
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:outdoorda_flutter/core/utils/constants/stripe_config.dart';

class PaymentCancelledException implements Exception {
  const PaymentCancelledException();
}

class StripePaymentService {
  Future<void> payWithPaymentSheet({required String clientSecret}) async {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: StripeConfig.merchantDisplayName,
        style: ThemeMode.light,
        allowsDelayedPaymentMethods: false,
      ),
    );

    try {
      await Stripe.instance.presentPaymentSheet();
    } on StripeException catch (error) {
      if (error.error.code == FailureCode.Canceled) {
        throw const PaymentCancelledException();
      }
      rethrow;
    }
  }
}

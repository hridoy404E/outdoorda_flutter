import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:outdoorda_flutter/core/services/firebase/fcm_handler.dart';
import 'package:outdoorda_flutter/core/services/firebase/firebase_service.dart';
import 'package:outdoorda_flutter/core/services/storage_service.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/core/utils/constants/stripe_config.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await FirebaseService.init();
  FCMHandler.registerBackgroundHandler();

  await StorageService.init();
  Stripe.publishableKey = StripeConfig.publishableKey;
  await Stripe.instance.applySettings();

  _configureEasyLoading();

  runApp(const Outdoorda());
}

void _configureEasyLoading() {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.ring
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 48.0
    ..radius = 26.0
    ..maskColor = Colors.black45
    ..backgroundColor = Colors.grey.shade900.withValues(alpha: 0.92)
    ..indicatorColor = AppColors.priceColor
    ..textColor = Colors.white
    ..contentPadding = const EdgeInsets.symmetric(horizontal: 28, vertical: 16)
    ..dismissOnTap = false
    ..userInteractions = false
    ..boxShadow = [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.55),
        blurRadius: 24.0,
        offset: const Offset(0, 8),
      ),
    ]
    ..toastPosition = EasyLoadingToastPosition.center
    ..displayDuration = const Duration(milliseconds: 1200)
    ..progressColor = AppColors.priceColor;
}

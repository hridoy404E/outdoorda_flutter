import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/services/auth_redirect_service.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resolveRouteAndNavigate();
    });
  }

  Future<void> _resolveRouteAndNavigate() async {
    final targetRoute = await AuthRedirectService.resolveInitialRoute();
    if (!mounted) return;
    Get.offAllNamed(targetRoute);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.priceColor),
      ),
    );
  }
}

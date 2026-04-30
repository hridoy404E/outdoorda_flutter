import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/features/global_section/authentication/auth_api_services/auth_api_service.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/routes/app_routes.dart';

class SignupOtpController extends GetxController {
  final AuthApiService _authApiService = AuthApiService();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>(
    debugLabel: 'signupOtpForm',
  );

  final List<TextEditingController> otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  final RxBool isLoading = false.obs;

  late final String name;
  late final String email;
  late final String password;
  late final String purpose;
  late final String message;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    name = args['name'] ?? '';
    email = args['email'] ?? '';
    password = args['password'] ?? '';
    purpose = args['purpose'] ?? 'signup';
    message = args['message'] ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNodes.first.requestFocus();
    });
  }

  @override
  void onClose() {
    for (final controller in otpControllers) {
      controller.dispose();
    }
    for (final node in focusNodes) {
      node.dispose();
    }
    super.onClose();
  }

  String _getOtpCode() =>
      otpControllers.map((controller) => controller.text).join();

  Future<void> verifyOtp() async {
    if (_getOtpCode().length != 6) {
      EasyLoading.showError('Please enter the complete OTP');
      return;
    }

    try {
      isLoading.value = true;
      EasyLoading.show(status: 'Verifying OTP...');

      final response = await _authApiService.signup(
        name: name,
        email: email,
        password: password,
        otpValue: _getOtpCode(),
        purpose: purpose,
      );

      if (!response.isSuccess) {
        EasyLoading.showError(
          response.errorMessage.isNotEmpty
              ? response.errorMessage
              : 'OTP verification failed',
        );
        return;
      }

      final responseData = response.responseData is Map<String, dynamic>
          ? response.responseData as Map<String, dynamic>
          : <String, dynamic>{};

      final successMessage =
          responseData['message']?.toString() ?? 'Account created successfully';

      EasyLoading.showSuccess(successMessage);
      await Future.delayed(const Duration(milliseconds: 300));
      Get.offAllNamed(AppRoute.loginScreen);
    } catch (error) {
      AppLoggerHelper.error('Signup OTP error: $error', error);
      EasyLoading.showError('Signup failed. Please try again.');
    } finally {
      EasyLoading.dismiss();
      isLoading.value = false;
    }
  }

  void onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < focusNodes.length - 1) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }
}

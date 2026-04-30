import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/features/global_section/authentication/auth_api_services/auth_api_service.dart';
import 'package:outdoorda_flutter/routes/app_routes.dart';

/// OTP Verify Controller
/// Handles OTP validation and verification logic
class OtpVerifyController extends GetxController {
  final AuthApiService _authApiService = AuthApiService();

  /// Form key for validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>(
    debugLabel: 'otpVerifyForm',
  );

  /// OTP text controllers (6 digits)
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  /// Focus nodes for OTP fields
  final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());

  /// Loading state
  final RxBool isLoading = false.obs;

  /// Resend OTP timer
  final RxInt resendTimer = 0.obs;
  final RxBool canResend = false.obs;
  Timer? _timer;

  /// Email from previous screen
  late String email;
  final RxString verificationMessage = AppStrings.otpVerificationSubtitle.obs;

  @override
  void onInit() {
    super.onInit();
    // Get email from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    email = args?['email'] ?? '';
    final message = args?['message']?.toString().trim() ?? '';
    if (message.isNotEmpty) {
      verificationMessage.value = message;
    }

    // Start resend timer
    _startResendTimer();
  }

  @override
  void onClose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.onClose();
  }

  /// Handles OTP input change and auto-focus
  void onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      // Move to next field
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      // Move to previous field on backspace
      focusNodes[index - 1].requestFocus();
    }
  }

  /// Gets complete OTP code
  String _getOtpCode() {
    return otpControllers.map((controller) => controller.text).join();
  }

  /// Verifies OTP code
  Future<void> verifyOTP() async {
    if (!formKey.currentState!.validate()) {
      EasyLoading.showError('Please enter complete OTP code');
      return;
    }

    final otpCode = _getOtpCode();
    if (otpCode.length != 6) {
      EasyLoading.showError(AppStrings.invalidOTP);
      return;
    }

    try {
      isLoading.value = true;
      EasyLoading.show(status: 'Verifying...');

      final response = await _authApiService.verifyOtp(
        email: email.trim().toLowerCase(),
        otpValue: otpCode,
        purpose: 'forgot_password',
      );

      if (!response.isSuccess) {
        EasyLoading.showError(
          response.errorMessage.isNotEmpty
              ? response.errorMessage
              : AppStrings.otpVerifyError,
        );
        return;
      }

      final sessionKey = _extractSessionKey(response.responseData);
      if (sessionKey == null || sessionKey.isEmpty) {
        EasyLoading.showError(AppStrings.otpVerifyError);
        return;
      }

      EasyLoading.showSuccess(AppStrings.otpVerifiedSuccess);

      Get.toNamed(
        AppRoute.resetPasswordScreen,
        arguments: {'email': email, 'session_key': sessionKey},
      );
    } catch (error) {
      EasyLoading.showError(AppStrings.otpVerifyError);
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }

  /// Resends OTP code
  Future<void> resendOTP() async {
    if (!canResend.value) return;

    try {
      EasyLoading.show(status: 'Sending OTP...');

      final response = await _authApiService.sendOtp(
        email: email.trim().toLowerCase(),
        purpose: 'forgot_password',
      );

      if (!response.isSuccess) {
        EasyLoading.showError(
          response.errorMessage.isNotEmpty
              ? response.errorMessage
              : AppStrings.emailSendError,
        );
        return;
      }

      final responseMessage = _extractMessage(response.responseData);
      if (responseMessage != null && responseMessage.isNotEmpty) {
        verificationMessage.value = responseMessage;
      }

      EasyLoading.showSuccess('OTP sent successfully!');

      for (var controller in otpControllers) {
        controller.clear();
      }

      focusNodes[0].requestFocus();

      _startResendTimer();
    } catch (error) {
      EasyLoading.showError('Failed to resend OTP');
    } finally {
      EasyLoading.dismiss();
    }
  }

  /// Starts resend timer (60 seconds)
  void _startResendTimer() {
    canResend.value = false;
    resendTimer.value = 300;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimer.value > 0) {
        resendTimer.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  String get formattedResendTimer {
    final minutes = resendTimer.value ~/ 60;
    final seconds = resendTimer.value % 60;
    final minuteText = minutes.toString().padLeft(2, '0');
    final secondText = seconds.toString().padLeft(2, '0');
    return '$minuteText:$secondText';
  }

  String? _extractSessionKey(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final directKey = responseData['session_key']?.toString().trim();
      if (directKey != null && directKey.isNotEmpty) {
        return directKey;
      }

      final camelCaseKey = responseData['sessionKey']?.toString().trim();
      if (camelCaseKey != null && camelCaseKey.isNotEmpty) {
        return camelCaseKey;
      }

      final nestedData = responseData['data'];
      if (nestedData is Map<String, dynamic>) {
        final nestedKey = nestedData['session_key']?.toString().trim();
        if (nestedKey != null && nestedKey.isNotEmpty) {
          return nestedKey;
        }

        final nestedCamelCaseKey = nestedData['sessionKey']?.toString().trim();
        if (nestedCamelCaseKey != null && nestedCamelCaseKey.isNotEmpty) {
          return nestedCamelCaseKey;
        }
      }
    }

    return null;
  }

  String? _extractMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final message = responseData['message']?.toString().trim();
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }

    return null;
  }
}

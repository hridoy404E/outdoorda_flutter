import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/features/global_section/authentication/auth_api_services/auth_api_service.dart';
import 'package:outdoorda_flutter/routes/app_routes.dart';

/// Email Verify Controller
/// Handles email validation and sending reset password link
class EmailVerifyController extends GetxController {
  final AuthApiService _authApiService = AuthApiService();

  /// Form key for validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>(
    debugLabel: 'emailVerifyForm',
  );

  /// Text controller for email input
  final TextEditingController emailController = TextEditingController();

  /// Loading state
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    final initialEmail = args?['email']?.toString().trim() ?? '';
    if (initialEmail.isNotEmpty) {
      emailController.text = initialEmail;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  /// Sends OTP for forgot password flow.
  Future<void> sendResetLink() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final email = emailController.text.trim().toLowerCase();

    try {
      isLoading.value = true;
      EasyLoading.show(status: 'Sending OTP...');

      final response = await _authApiService.sendOtp(
        email: email,
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
      EasyLoading.showSuccess(AppStrings.emailSentSuccess);

      Get.toNamed(
        AppRoute.otpVerifyScreen,
        arguments: {
          'email': email,
          if (responseMessage != null && responseMessage.isNotEmpty)
            'message': responseMessage,
        },
      );
    } catch (error) {
      EasyLoading.showError(AppStrings.emailSendError);
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
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

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/features/global_section/authentication/auth_api_services/auth_api_service.dart';
import 'package:outdoorda_flutter/routes/app_routes.dart';

/// Reset Password Controller
/// Handles password validation and reset logic
class ResetPasswordController extends GetxController {
  final AuthApiService _authApiService = AuthApiService();

  /// Form key for validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>(
    debugLabel: 'resetPasswordForm',
  );

  /// Text controllers for password inputs
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  /// Loading state
  final RxBool isLoading = false.obs;

  /// Email and session key from previous screens
  late String email;
  late String sessionKey;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    email = args?['email'] ?? '';
    sessionKey = args?['session_key'] ?? '';
  }

  @override
  void onClose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> resetPassword() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      EasyLoading.showError('Passwords do not match');
      return;
    }

    if (sessionKey.trim().isEmpty) {
      EasyLoading.showError(AppStrings.passwordResetError);
      return;
    }

    try {
      isLoading.value = true;
      EasyLoading.show(status: 'Resetting...');

      final response = await _authApiService.forgotPassword(
        email: email.trim().toLowerCase(),
        password: passwordController.text.trim(),
        sessionKey: sessionKey.trim(),
      );

      if (!response.isSuccess) {
        EasyLoading.showError(
          response.errorMessage.isNotEmpty
              ? response.errorMessage
              : AppStrings.passwordResetError,
        );
        return;
      }

      EasyLoading.showSuccess(AppStrings.passwordResetSuccess);

      await Future.delayed(const Duration(milliseconds: 500));

      Get.offAllNamed(AppRoute.getLoginScreen());
    } catch (error) {
      EasyLoading.showError(AppStrings.passwordResetError);
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }
}

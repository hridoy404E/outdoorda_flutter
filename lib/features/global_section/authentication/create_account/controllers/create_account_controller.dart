import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/features/global_section/authentication/auth_api_services/auth_api_service.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/core/utils/validators/app_validator.dart';
import 'package:outdoorda_flutter/routes/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';

/// Create account controller managing registration business logic
/// Handles full name, email, password, confirm password validation
/// User type selection (Installer/Customer), agreement checkbox
class CreateAccountController extends GetxController {
  final AuthApiService _authApiService = AuthApiService();

  /// Form key for validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>(
    debugLabel: 'createAccountForm',
  );

  /// Text editing controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  /// Observable state
  final RxString selectedUserType = 'Installer'.obs;
  final RxBool agreeToTerms = false.obs;
  final RxBool isLoading = false.obs;

  /// User type options (no Admin for create account)
  final List<String> userTypes = ['Installer', 'Customer'];

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  /// Validate full name field
  String? validateFullName(String? value) {
    return AppValidator.validateFullName(value);
  }

  /// Validate email field
  String? validateEmail(String? value) {
    return AppValidator.validateEmail(value);
  }

  /// Validate password field
  String? validatePassword(String? value) {
    return AppValidator.validatePassword(value);
  }

  /// Validate confirm password field
  String? validateConfirmPassword(String? value) {
    return AppValidator.validateConfirmPassword(value, passwordController.text);
  }

  /// Select user type
  void selectUserType(String type) {
    selectedUserType.value = type;
  }

  /// Toggle agreement checkbox
  void toggleAgreement(bool? value) {
    agreeToTerms.value = value ?? false;
  }

  /// Handle registration
  Future<void> register() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (!agreeToTerms.value) {
      EasyLoading.showError('Please agree to the terms and conditions');
      return;
    }

    final name = fullNameController.text.trim();
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text.trim();
    final purpose = selectedUserType.value == 'Customer'
        ? 'signup'
        : 'installer_signup';

    try {
      isLoading.value = true;
      EasyLoading.show(status: 'Sending OTP...');

      final response = await _authApiService.sendOtp(
        email: email,
        purpose: purpose,
      );

      if (!response.isSuccess) {
        EasyLoading.showError(
          response.errorMessage.isNotEmpty
              ? response.errorMessage
              : 'Failed to send OTP',
        );
        return;
      }

      final responseData = response.responseData is Map<String, dynamic>
          ? response.responseData as Map<String, dynamic>
          : <String, dynamic>{};

      EasyLoading.dismiss();
      final otpResponseMessage =
          responseData['message']?.toString() ??
          'OTP sent to $email. Please enter the code.';

      Get.toNamed(
        AppRoute.signupOtpScreen,
        arguments: {
          'name': name,
          'email': email,
          'password': password,
          'purpose': purpose,
          'message': otpResponseMessage,
        },
      );
    } catch (error) {
      AppLoggerHelper.error('Registration error: $error', error);
      EasyLoading.showError('Registration failed. Please try again.');
    } finally {
      EasyLoading.dismiss();
      isLoading.value = false;
    }
  }

  /// Navigate to login screen
  void navigateToLogin() {
    Get.back();
  }

  /// Open license agreement
  void openLicenseAgreement() {
    AppLoggerHelper.info('Open license agreement');
    _launchUrl('https://sites.google.com/view/petdoorusa/home');
  }

  /// Open privacy policy
  void openPrivacyPolicy() {
    AppLoggerHelper.info('Open privacy policy');
    _launchUrl('https://sites.google.com/view/petdoorusa/home');
  }

  /// Launch URL helper method
  void _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Unable to open link. Please visit: $url',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      AppLoggerHelper.error('Failed to open URL: $e', e);
      Get.snackbar(
        'Error',
        'Unable to open link. Please visit: $url',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }
}

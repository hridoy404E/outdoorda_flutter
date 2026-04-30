import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/services/firebase/notification_controller.dart';
import 'package:outdoorda_flutter/core/services/network_caller.dart';
import 'package:outdoorda_flutter/core/services/payments/installer_payment_account_api_service.dart';
import 'package:outdoorda_flutter/core/services/storage_service.dart';
import 'package:outdoorda_flutter/core/services/user_profile_api_service.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/core/utils/validators/app_validator.dart';
import 'package:outdoorda_flutter/features/global_section/authentication/login/widgets/otp_dialog.dart';
import 'package:outdoorda_flutter/core/utils/constants/api_endpoints.dart';
import 'package:outdoorda_flutter/routes/app_routes.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// Login controller managing authentication business logic
/// Handles email/password validation, remember me, user type selection
class LoginController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  final UserProfileApiService _userProfileApiService = UserProfileApiService();
  final InstallerPaymentAccountApiService _installerPaymentApiService =
      InstallerPaymentAccountApiService();

  /// Text editing controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  /// Observable state
  final RxString selectedUserRole = ''.obs;
  final RxBool rememberMe = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLaunchingStripeOnboarding = false.obs;
  final RxBool isCheckingInstallerPaymentReady = false.obs;
  final RxBool isLoggingOut = false.obs;

  /// User type options
  final List<String> userRole = ['ADMIN', 'INSTALLER', 'CUSTOMER'];

  @override
  void onClose() {
    emailController.clear();
    passwordController.clear();
    super.onClose();
  }

  /// Validate email field
  String? validateEmail(String? value) {
    return AppValidator.validateEmail(value);
  }

  /// Validate password field
  String? validatePassword(String? value) {
    return AppValidator.validatePassword(value);
  }

  /// Select user type
  void selectUserType(String role) {
    selectedUserRole.value = role;
  }

  Future<void> login(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text.trim();

    isLoading.value = true;
    EasyLoading.show(status: 'Logging in...');

    try {
      final response = await _networkCaller.postRequest(
        ApiEndpoints.login,
        body: {'email': email, 'password': password},
        headers: {'accept': 'application/json'},
        formUrlEncoded: true,
      );

      final data = response.responseData is Map<String, dynamic>
          ? response.responseData as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode == 200 && _shouldPromptOtp(data)) {
        EasyLoading.dismiss();
        final message = data['message']?.toString() ?? '';
        final otp = await _showOtpDialog(
          message.isNotEmpty ? message : AppStrings.otpVerificationSubtitle,
        );
        if (otp != null) {
          await _verifyOtp(email, password, otp);
        }
        return;
      }

      if (response.statusCode == 200) {
        EasyLoading.dismiss();
        await _finalizeLogin(data);
        return;
      }

      EasyLoading.dismiss();
      EasyLoading.showError(
        response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Login failed. Please try again.',
      );
    } catch (error) {
      AppLoggerHelper.error('Login error: $error');
      EasyLoading.dismiss();
      EasyLoading.showError('Login failed. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _verifyOtp(
    String email,
    String password,
    String otpValue,
  ) async {
    try {
      EasyLoading.show(status: 'Verifying OTP...');

      final uri = Uri.parse(
        ApiEndpoints.login,
      ).replace(queryParameters: {'otp_value': otpValue});

      final response = await _networkCaller.postRequest(
        uri.toString(),
        body: {'email': email, 'password': password},
        headers: {'accept': 'application/json'},
        formUrlEncoded: true,
      );

      final data = response.responseData is Map<String, dynamic>
          ? response.responseData as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode == 200) {
        EasyLoading.dismiss();
        await _finalizeLogin(data);
        return;
      }

      EasyLoading.dismiss();
      EasyLoading.showError(
        response.errorMessage.isNotEmpty
            ? response.errorMessage
            : AppStrings.otpVerifyError,
      );
    } catch (error) {
      AppLoggerHelper.error('OTP verify error: $error');
      EasyLoading.dismiss();
      EasyLoading.showError(AppStrings.otpVerifyError);
    }
  }

  Future<void> _finalizeLogin(Map<String, dynamic> data) async {
    final accessToken = data['access_token'] as String?;
    final refreshToken = data['refresh_token'] as String?;
    final tokenType = data['token_type'] as String?;
    final rawRole = (data['role'] as String?) ?? selectedUserRole.value;
    final normalizedRole = _normalizeRole(rawRole);

    await StorageService.saveAuthData(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: tokenType,
      role: normalizedRole,
    );
    await _cacheUserIdFromProfile();
    await _syncNotificationTokenAfterLogin();

    selectedUserRole.value = normalizedRole;

    AppLoggerHelper.info('Login successful: Role=$normalizedRole');

    EasyLoading.showSuccess('Login successful!');

    await Future.delayed(const Duration(milliseconds: 400));

    _navigateToAppHome(normalizedRole);
  }

  Future<void> startInstallerAccountLinking() async {
    if (isLaunchingStripeOnboarding.value) return;

    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      EasyLoading.showError(AppStrings.authorizationRequired);
      return;
    }

    isLaunchingStripeOnboarding.value = true;
    try {
      EasyLoading.show(status: 'Preparing Stripe onboarding...');

      await _installerPaymentApiService.createInstallerStripeAccount(
        authorization: authorization,
      );
      final onboardingUrl = await _installerPaymentApiService
          .createInstallerOnboardingLink(authorization: authorization);

      final launched = await launchUrlString(
        onboardingUrl,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw Exception('Unable to open Stripe onboarding link');
      }

      EasyLoading.showSuccess('Stripe onboarding opened.');
    } catch (error) {
      AppLoggerHelper.error('Failed to open installer onboarding', error);
      EasyLoading.showError(
        'Could not start Stripe onboarding. Please try again.',
      );
    } finally {
      isLaunchingStripeOnboarding.value = false;
      EasyLoading.dismiss();
    }
  }

  Future<void> confirmInstallerPaymentReadyAndContinue() async {
    if (isCheckingInstallerPaymentReady.value) return;

    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      EasyLoading.showError(AppStrings.authorizationRequired);
      return;
    }

    isCheckingInstallerPaymentReady.value = true;
    try {
      EasyLoading.show(status: 'Checking payment account...');
      final isReady = await _installerPaymentApiService.isAccountReady(
        authorization: authorization,
      );

      if (!isReady) {
        EasyLoading.showError(
          'Installer not ready for payments. Complete Stripe onboarding first.',
        );
        return;
      }

      await _cacheUserIdFromProfile();
      await _syncNotificationTokenAfterLogin();
      EasyLoading.showSuccess('Payment account verified.');
      await Future.delayed(const Duration(milliseconds: 300));
      _navigateToAppHome('Installer');
    } catch (error) {
      AppLoggerHelper.error(
        'Failed to verify installer payment readiness',
        error,
      );
      EasyLoading.showError(
        'Could not verify payment account status. Please try again.',
      );
    } finally {
      isCheckingInstallerPaymentReady.value = false;
      EasyLoading.dismiss();
    }
  }

  Future<void> logoutFromPaymentSetup() async {
    if (isLoggingOut.value) return;

    isLoggingOut.value = true;
    try {
      EasyLoading.show(status: 'Logging out...');
      await StorageService.logoutUser();
      selectedUserRole.value = '';
      rememberMe.value = false;
      emailController.clear();
      passwordController.clear();

      EasyLoading.dismiss();
      Get.offAllNamed(AppRoute.getLoginScreen());
    } catch (error) {
      AppLoggerHelper.error('Logout from payment setup failed', error);
      EasyLoading.dismiss();
      EasyLoading.showError('Failed to logout. Please try again.');
    } finally {
      isLoggingOut.value = false;
    }
  }

  void skipInstallerPaymentSetupAndContinue() {
    _navigateToAppHome('Installer');
  }

  void _navigateToAppHome(String role) {
    Get.offAllNamed(
      AppRoute.bottomNavbarScreen,
      arguments: {
        'role': role,
        'showInstallerServiceAreaPrompt': role == 'Installer',
      },
    );
  }

  Future<void> _cacheUserIdFromProfile() async {
    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      return;
    }

    try {
      final profile = await _userProfileApiService.fetchCurrentUser(
        authorization: authorization,
      );
      await StorageService.saveUserId(profile.id);
      AppLoggerHelper.info('User profile cached after login: ${profile.id}');
    } catch (error) {
      AppLoggerHelper.warning(
        'Unable to cache user profile after login: $error',
      );
    }
  }

  Future<void> _syncNotificationTokenAfterLogin() async {
    try {
      final notificationController = Get.isRegistered<NotificationController>()
          ? Get.find<NotificationController>()
          : Get.put<NotificationController>(
              NotificationController(),
              permanent: true,
            );
      await notificationController.syncFcmTokenWithBackend(force: true);
    } catch (error) {
      AppLoggerHelper.warning(
        'Notification token sync after login failed: $error',
      );
    }
  }

  String? _buildAuthorizationHeader() {
    final accessToken = StorageService.accessToken?.trim();
    if (accessToken == null || accessToken.isEmpty) return null;

    final tokenType = StorageService.tokenType?.trim();
    final prefix = (tokenType != null && tokenType.isNotEmpty)
        ? tokenType
        : 'Bearer';
    return '$prefix $accessToken';
  }

  String _normalizeRole(String role) {
    final cleaned = role.trim().toLowerCase();
    switch (cleaned) {
      case 'admin':
        return 'Admin';
      case 'installer':
        return 'Installer';
      case 'customer':
      default:
        return 'Customer';
    }
  }

  Future<String?> _showOtpDialog(String message) {
    final context = Get.context;
    if (context == null) {
      return Get.dialog<String>(
        OtpDialog(message: message),
        barrierDismissible: false,
      );
    }

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => OtpDialog(message: message),
    );
  }

  bool _shouldPromptOtp(Map<String, dynamic> data) {
    final details = data['details']?.toString().toLowerCase() ?? '';
    return details.contains('otp required');
  }

  /// Navigate to create account screen
  void navigateToCreateAccount() {
    Get.toNamed(AppRoute.createAccountScreen);
  }

  /// Navigate to forgot password screen
  void navigateToForgotPassword() {
    Get.toNamed(
      AppRoute.emailVerifyScreen,
      arguments: {'email': emailController.text.trim().toLowerCase()},
    );
    AppLoggerHelper.info('Navigate to forgot password');
  }
}

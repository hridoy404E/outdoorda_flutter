import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:outdoorda_flutter/core/models/payment_settings_status_model.dart';
import 'package:outdoorda_flutter/core/services/firebase/notification_controller.dart';
import 'package:outdoorda_flutter/core/services/payments/payment_settings_api_service.dart';
import 'package:outdoorda_flutter/core/services/storage_service.dart';
import 'package:outdoorda_flutter/core/services/two_factor_api_service.dart';
import 'package:outdoorda_flutter/core/services/user_profile_api_service.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/features/admin_section/settings/services/admin_job_management_settings_api_service.dart';
import 'package:outdoorda_flutter/features/global_section/authentication/auth_api_services/auth_api_service.dart';
import 'package:outdoorda_flutter/routes/app_routes.dart';

/// Admin Settings Controller
/// Manages all admin settings functionality including:
/// - Profile information management
/// - Contact information
/// - Notification preferences
/// - Job management settings
/// - Security settings
class AdminSettingsController extends GetxController {
  final UserProfileApiService _userProfileApiService = UserProfileApiService();
  final AdminJobManagementSettingsApiService _jobSettingsApiService =
      AdminJobManagementSettingsApiService();
  final PaymentSettingsApiService _paymentSettingsApiService =
      PaymentSettingsApiService();
  final AuthApiService _authApiService = AuthApiService();
  final TwoFactorApiService _twoFactorApiService = TwoFactorApiService();
  final NotificationController _notificationController =
      Get.find<NotificationController>();

  /// Profile Information Controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  /// Contact Information Controllers
  final TextEditingController contactEmailController = TextEditingController();
  final TextEditingController contactPhoneController = TextEditingController();

  /// Job Management Settings
  final TextEditingController bidTimeoutController = TextEditingController();

  /// Profile Image
  final RxString profileImagePath = ''.obs;
  final RxString profileImageUrl = ''.obs;
  final RxString displayName = ''.obs;
  final RxString displayEmail = ''.obs;

  /// Notification Settings
  final RxBool pushNotificationsEnabled = true.obs;
  final RxBool stripePaymentsEnabled = false.obs;
  final RxBool twoFactorEnabled = false.obs;
  final RxString stripePaymentSettingsId = ''.obs;
  final RxString stripePaymentSettingsUpdatedAt = ''.obs;
  final RxString stripePaymentSettingsRawStatus = ''.obs;

  /// Job Management Settings
  final RxBool autoAssignJobsEnabled = false.obs;

  /// Loading States
  final RxBool isLoadingProfile = false.obs;
  final RxBool isLoadingContact = false.obs;
  final RxBool isLoadingNotifications = false.obs;
  final RxBool isLoadingStripePayments = false.obs;
  final RxBool isSavingStripePayments = false.obs;
  final RxBool isLoadingJobSettings = false.obs;
  final RxBool isSavingJobSettings = false.obs;
  final RxBool isChangingPassword = false.obs;
  final RxBool isTogglingTwoFactor = false.obs;
  Worker? _notificationPermissionWorker;

  bool get hasSettingsData =>
      displayName.value.trim().isNotEmpty ||
      displayEmail.value.trim().isNotEmpty ||
      fullNameController.text.trim().isNotEmpty ||
      emailController.text.trim().isNotEmpty;

  bool get isInitialLoading =>
      isLoadingProfile.value ||
      isLoadingStripePayments.value ||
      isLoadingJobSettings.value;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  /// Initialize admin data
  void _initializeData() {
    // Load existing admin data from storage or API
    // Seed editable fields, then refresh profile from API
    fullNameController.clear();
    emailController.clear();
    phoneController.clear();

    contactEmailController.clear();
    contactPhoneController.clear();

    bidTimeoutController.clear();

    pushNotificationsEnabled.value = true;
    autoAssignJobsEnabled.value = false;
    twoFactorEnabled.value = _twoFactorApiService.getSavedStatus();

    AppLoggerHelper.info('Admin settings initialized');
    _bindNotificationPermission();
    _loadUserProfile();
    _loadStripePaymentSettings();
    _loadJobManagementSettings();
  }

  void _bindNotificationPermission() {
    pushNotificationsEnabled.value =
        _notificationController.permissionGranted.value;
    _notificationPermissionWorker ??= ever<bool>(
      _notificationController.permissionGranted,
      (isGranted) {
        pushNotificationsEnabled.value = isGranted;
      },
    );
    _notificationController.refreshPermissionStatus();
  }

  Future<void> _loadUserProfile() async {
    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      AppLoggerHelper.warning('Admin profile request missing token');
      return;
    }

    try {
      isLoadingProfile.value = true;
      final profile = await _userProfileApiService.fetchCurrentUser(
        authorization: authorization,
      );

      fullNameController.text = profile.name;
      emailController.text = profile.email;
      phoneController.text = profile.phone;

      contactEmailController.text = profile.email;
      contactPhoneController.text = profile.phone;

      displayName.value = profile.name;
      displayEmail.value = profile.email;
      profileImageUrl.value = profile.photo;
      twoFactorEnabled.value = _twoFactorApiService.getSavedStatus();

      AppLoggerHelper.info('Admin profile loaded: ${profile.id}');
    } catch (error) {
      AppLoggerHelper.error('Failed to load admin profile', error);
    } finally {
      isLoadingProfile.value = false;
    }
  }

  Future<void> _loadJobManagementSettings() async {
    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      AppLoggerHelper.warning('Admin job settings request missing token');
      return;
    }

    try {
      isLoadingJobSettings.value = true;
      final settings = await _jobSettingsApiService.fetchSettings(
        authorization: authorization,
      );
      autoAssignJobsEnabled.value = settings.autoAssignJob;
      bidTimeoutController.text = settings.jobTimeoutHours.toString();
      AppLoggerHelper.info(
        'Admin job settings loaded: timeout=${settings.jobTimeoutHours}, '
        'autoAssign=${settings.autoAssignJob}',
      );
    } catch (error) {
      AppLoggerHelper.error('Failed to load admin job settings', error);
    } finally {
      isLoadingJobSettings.value = false;
    }
  }

  Future<void> _loadStripePaymentSettings() async {
    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      AppLoggerHelper.warning('Admin payment settings request missing token');
      return;
    }

    try {
      isLoadingStripePayments.value = true;
      final settings = await _paymentSettingsApiService.fetchPaymentSettings(
        authorization: authorization,
      );
      _applyStripePaymentSettings(settings);
      AppLoggerHelper.info(
        'Admin Stripe payment setting loaded: ${settings.status}',
      );
    } catch (error) {
      AppLoggerHelper.error('Failed to load Stripe payment setting', error);
    } finally {
      isLoadingStripePayments.value = false;
    }
  }

  void _applyStripePaymentSettings(PaymentSettingsStatusModel settings) {
    stripePaymentsEnabled.value = settings.status;
    stripePaymentSettingsId.value = settings.id?.toString() ?? '';
    stripePaymentSettingsUpdatedAt.value = settings.updatedAt;
    stripePaymentSettingsRawStatus.value = settings.status.toString();
  }

  String? _buildAuthorizationHeader() {
    final token = StorageService.accessToken;
    if (token == null || token.isEmpty) return null;

    final type = StorageService.tokenType?.trim();
    final prefix = (type != null && type.isNotEmpty) ? type : 'Bearer';
    return '$prefix $token';
  }

  /// Change profile photo
  Future<void> changeProfilePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        profileImagePath.value = image.path;
        EasyLoading.showInfo('Photo selected. Tap Save Profile Changes.');
        AppLoggerHelper.info('Admin profile photo selected: ${image.path}');
      }
    } catch (error) {
      AppLoggerHelper.error('Change photo error: $error', error);
      EasyLoading.showError('Failed to change photo');
    }
  }

  /// Save profile changes
  Future<void> saveProfileChanges() async {
    if (!_validateProfileForm()) {
      return;
    }

    try {
      final authorization = _buildAuthorizationHeader();
      if (authorization == null) {
        EasyLoading.showError('Authorization missing. Please log in again.');
        return;
      }

      isLoadingProfile.value = true;
      EasyLoading.show(status: 'Saving...');

      final profile = await _userProfileApiService.updateCurrentUserProfile(
        authorization: authorization,
        name: fullNameController.text.trim(),
        phone: phoneController.text.trim(),
        photoPath: profileImagePath.value.isEmpty
            ? null
            : profileImagePath.value,
      );

      fullNameController.text = profile.name;
      emailController.text = profile.email;
      phoneController.text = profile.phone;

      contactEmailController.text = profile.email;
      contactPhoneController.text = profile.phone;

      displayName.value = profile.name;
      displayEmail.value = profile.email;
      profileImageUrl.value = profile.photo;
      profileImagePath.value = '';

      EasyLoading.showSuccess('Profile updated successfully');
      AppLoggerHelper.info('Admin profile updated: ${profile.id}');
    } catch (error) {
      AppLoggerHelper.error('Save profile error: $error', error);
      EasyLoading.showError('Failed to save profile');
    } finally {
      isLoadingProfile.value = false;
      EasyLoading.dismiss();
    }
  }

  /// Validate profile form
  bool _validateProfileForm() {
    if (fullNameController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter your full name');
      return false;
    }

    if (emailController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter your email');
      return false;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      EasyLoading.showError('Please enter a valid email');
      return false;
    }

    if (phoneController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter your phone number');
      return false;
    }

    return true;
  }

  /// Update contact information
  Future<void> updateContactInfo() async {
    if (!_validateContactForm()) {
      return;
    }

    try {
      isLoadingContact.value = true;
      EasyLoading.show(status: 'Updating...');

      // TODO: API call to update contact info
      // await _apiService.updateContactInfo({
      //   'email': contactEmailController.text,
      //   'phone': contactPhoneController.text,
      // });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      EasyLoading.showSuccess('Contact info updated successfully');
      AppLoggerHelper.info('Contact info updated');
    } catch (error) {
      AppLoggerHelper.error('Update contact error: $error', error);
      EasyLoading.showError('Failed to update contact info');
    } finally {
      isLoadingContact.value = false;
      EasyLoading.dismiss();
    }
  }

  /// Validate contact form
  bool _validateContactForm() {
    if (contactEmailController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter contact email');
      return false;
    }

    if (!GetUtils.isEmail(contactEmailController.text.trim())) {
      EasyLoading.showError('Please enter a valid email');
      return false;
    }

    if (contactPhoneController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter contact phone');
      return false;
    }

    return true;
  }

  /// Toggle push notifications
  Future<void> togglePushNotifications(bool value) async {
    if (value) {
      await _notificationController.enableNotifications();
    } else {
      await _notificationController.disableNotifications();
    }

    pushNotificationsEnabled.value =
        _notificationController.permissionGranted.value;
    AppLoggerHelper.info('Push notifications: $value');
  }

  /// Save notification settings
  Future<void> saveNotificationSettings() async {
    try {
      isLoadingNotifications.value = true;
      await _notificationController.openSystemNotificationSettings(
        message: pushNotificationsEnabled.value
            ? 'Manage this app notification setting from your device settings.'
            : 'Turn on notifications for this app in your device settings.',
      );
      AppLoggerHelper.info('Notification settings screen opened');
    } catch (error) {
      AppLoggerHelper.error('Save notifications error: $error', error);
      EasyLoading.showError('Failed to open notification settings');
    } finally {
      isLoadingNotifications.value = false;
    }
  }

  Future<void> toggleStripePayments(bool value) async {
    if (isSavingStripePayments.value) return;

    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      EasyLoading.showError('Authorization missing. Please log in again.');
      return;
    }

    final previousValue = stripePaymentsEnabled.value;
    stripePaymentsEnabled.value = value;

    try {
      isSavingStripePayments.value = true;
      EasyLoading.show(
        status: value
            ? 'Enabling Stripe payments...'
            : 'Disabling Stripe payments...',
      );

      final settings = await _paymentSettingsApiService
          .updateStripePaymentStatus(
            authorization: authorization,
            newStatus: value,
          );
      _applyStripePaymentSettings(settings);

      EasyLoading.showSuccess(
        settings.status
            ? 'Stripe payments enabled successfully'
            : 'Stripe payments disabled successfully',
      );
      AppLoggerHelper.info(
        'Admin Stripe payment setting updated: ${settings.status}',
      );
    } catch (error) {
      stripePaymentsEnabled.value = previousValue;
      AppLoggerHelper.error(
        'Toggle Stripe payment setting error: $error',
        error,
      );
      EasyLoading.showError('Failed to update Stripe payment setting');
    } finally {
      isSavingStripePayments.value = false;
      EasyLoading.dismiss();
    }
  }

  /// Toggle auto-assign jobs
  void toggleAutoAssignJobs(bool value) {
    autoAssignJobsEnabled.value = value;
    AppLoggerHelper.info('Auto-assign jobs: $value');
  }

  /// Save job management settings
  Future<void> saveJobManagementSettings() async {
    if (bidTimeoutController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter bid timeout hours');
      return;
    }

    final timeout = int.tryParse(bidTimeoutController.text.trim());
    if (timeout == null || timeout <= 0) {
      EasyLoading.showError('Please enter a valid timeout value');
      return;
    }

    try {
      final authorization = _buildAuthorizationHeader();
      if (authorization == null) {
        EasyLoading.showError('Authorization missing. Please log in again.');
        return;
      }

      isSavingJobSettings.value = true;
      EasyLoading.show(status: 'Saving...');

      final settings = await _jobSettingsApiService.saveSettings(
        authorization: authorization,
        autoAssignJob: autoAssignJobsEnabled.value,
        jobTimeoutHours: timeout,
      );
      autoAssignJobsEnabled.value = settings.autoAssignJob;
      bidTimeoutController.text = settings.jobTimeoutHours.toString();

      EasyLoading.showSuccess('Job settings saved successfully');
      AppLoggerHelper.info('Job management settings saved');
    } catch (error) {
      AppLoggerHelper.error('Save job settings error: $error', error);
      EasyLoading.showError('Failed to save job settings');
    } finally {
      isSavingJobSettings.value = false;
      EasyLoading.dismiss();
    }
  }

  /// Change password
  Future<void> changePassword() async {
    if (isChangingPassword.value) return;

    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Old Password'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Update'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      final oldPassword = oldPasswordController.text.trim();
      final newPassword = newPasswordController.text.trim();
      final confirmPassword = confirmPasswordController.text.trim();

      if (oldPassword.isEmpty) {
        EasyLoading.showError('Please enter old password');
        return;
      }
      if (newPassword.isEmpty) {
        EasyLoading.showError('Please enter new password');
        return;
      }
      if (newPassword.length < 6) {
        EasyLoading.showError('New password must be at least 6 characters');
        return;
      }
      if (newPassword != confirmPassword) {
        EasyLoading.showError('New password and confirm password must match');
        return;
      }
      if (oldPassword == newPassword) {
        EasyLoading.showError('New password must be different');
        return;
      }

      final authorization = _buildAuthorizationHeader();
      if (authorization == null) {
        EasyLoading.showError('Authorization missing. Please log in again.');
        return;
      }

      isChangingPassword.value = true;
      EasyLoading.show(status: 'Updating password...');

      final response = await _authApiService.resetPassword(
        authorization: authorization,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      if (!response.isSuccess) {
        EasyLoading.showError(
          response.errorMessage.isNotEmpty
              ? response.errorMessage
              : 'Failed to change password',
        );
        return;
      }

      AppLoggerHelper.info('Admin password updated successfully');
      EasyLoading.showSuccess('Password updated successfully');
    } catch (error) {
      AppLoggerHelper.error('Change password error', error);
      EasyLoading.showError('Failed to change password');
    } finally {
      oldPasswordController.dispose();
      newPasswordController.dispose();
      confirmPasswordController.dispose();
      isChangingPassword.value = false;
      EasyLoading.dismiss();
    }
  }

  /// Toggle two-factor authentication
  Future<void> toggleTwoFactorAuth() async {
    if (isTogglingTwoFactor.value) return;

    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      EasyLoading.showError('Authorization missing. Please log in again.');
      return;
    }

    try {
      isTogglingTwoFactor.value = true;
      EasyLoading.show(
        status: twoFactorEnabled.value
            ? 'Disabling two-factor authentication...'
            : 'Enabling two-factor authentication...',
      );

      final enabled = await _twoFactorApiService.toggleTwoFactor(
        authorization: authorization,
      );
      twoFactorEnabled.value = enabled;

      AppLoggerHelper.info('Admin two-factor authentication updated: $enabled');
      EasyLoading.showSuccess(
        enabled
            ? 'Two-factor authentication enabled'
            : 'Two-factor authentication disabled',
      );
    } catch (error) {
      AppLoggerHelper.error('Toggle two-factor authentication error', error);
      EasyLoading.showError('Failed to update two-factor authentication');
    } finally {
      isTogglingTwoFactor.value = false;
      EasyLoading.dismiss();
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      // Show confirmation dialog
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Logout'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        EasyLoading.show(status: 'Logging out...');

        await StorageService.logoutUser();

        EasyLoading.dismiss();
        AppLoggerHelper.info('User logged out');
        EasyLoading.showSuccess('Logged out successfully');
        Get.offAllNamed(AppRoute.loginScreen);
      }
    } catch (error) {
      AppLoggerHelper.error('Logout error: $error', error);
      EasyLoading.showError('Failed to logout');
    }
  }

  @override
  void onClose() {
    // Dispose controllers
    _notificationPermissionWorker?.dispose();
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    contactEmailController.dispose();
    contactPhoneController.dispose();
    bidTimeoutController.dispose();
    super.onClose();
  }
}

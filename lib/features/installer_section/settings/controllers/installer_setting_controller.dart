import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:outdoorda_flutter/core/services/firebase/notification_controller.dart';
import 'package:outdoorda_flutter/core/services/storage_service.dart';
import 'package:outdoorda_flutter/core/services/payments/installer_payment_account_api_service.dart';
import 'package:outdoorda_flutter/core/services/two_factor_api_service.dart';
import 'package:outdoorda_flutter/core/services/user_profile_api_service.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/core/utils/helpers/app_helper.dart';
import 'package:outdoorda_flutter/core/utils/validators/app_validator.dart';
import 'package:outdoorda_flutter/features/global_section/authentication/auth_api_services/auth_api_service.dart';
import 'package:outdoorda_flutter/features/installer_section/management/controllers/installer_management_controller.dart';
import 'package:outdoorda_flutter/features/installer_section/settings/models/installer_service_area_option.dart';
import 'package:outdoorda_flutter/features/installer_section/settings/services/installer_availability_api_service.dart';
import 'package:outdoorda_flutter/features/installer_section/settings/services/installer_service_area_api_service.dart';
import 'package:outdoorda_flutter/routes/app_routes.dart';

/// Installer Setting Controller
/// Manages all settings screen business logic including:
/// - Profile information management
/// - Service area selection
/// - Availability settings
/// - Payment information
/// - Notification preferences
/// - Security actions
class InstallerSettingController extends GetxController {
  final UserProfileApiService _userProfileApiService = UserProfileApiService();
  final InstallerAvailabilityApiService _installerAvailabilityApiService =
      InstallerAvailabilityApiService();
  final InstallerServiceAreaApiService _installerServiceAreaApiService =
      InstallerServiceAreaApiService();
  final AuthApiService _authApiService = AuthApiService();
  final InstallerPaymentAccountApiService _installerPaymentApiService =
      InstallerPaymentAccountApiService();
  final TwoFactorApiService _twoFactorApiService = TwoFactorApiService();
  final NotificationController _notificationController =
      Get.find<NotificationController>();

  /// Profile Information Controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  /// Profile Display Observables
  final RxString displayUserId = ''.obs;
  final RxString displayName = ''.obs;
  final RxString displayEmail = ''.obs;
  final RxString displayPhone = ''.obs;
  final RxString displayRole = ''.obs;
  final RxBool displayIsActive = false.obs;
  final RxDouble displayTotalEarnings = 0.0.obs;
  final RxDouble displayPayableCommissionAmount = 0.0.obs;

  /// Service Area Selection
  final RxList<int> selectedServiceAreaIds = <int>[].obs;
  final RxList<InstallerServiceAreaOption> availableServiceAreas =
      <InstallerServiceAreaOption>[].obs;

  /// Availability Settings
  final RxBool isAvailableForNewJobs = false.obs;
  final TextEditingController availableHoursController =
      TextEditingController();

  /// Payment Information Controllers
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController routingNumberController = TextEditingController();

  /// Notification Settings
  final RxBool pushNotificationsEnabled = true.obs;
  final RxBool twoFactorEnabled = false.obs;

  /// Loading states
  final RxBool isLoading = false.obs;
  final RxBool isSavingProfile = false.obs;
  final RxBool isUpdatingServiceArea = false.obs;
  final RxBool isServiceAreaLoading = false.obs;
  final RxBool hasLoadedServiceAreas = false.obs;
  final RxBool isUpdatingAvailability = false.obs;
  final RxBool isUpdatingPayment = false.obs;
  final RxBool isLaunchingStripeOnboarding = false.obs;
  final RxBool isSavingNotifications = false.obs;
  final RxBool isChangingPassword = false.obs;
  final RxBool isTogglingTwoFactor = false.obs;
  Worker? _notificationPermissionWorker;

  /// User profile data
  final RxString profileImageUrl = ''.obs;
  final RxString profileImagePath = ''.obs;
  Future<void>? _serviceAreasLoadFuture;

  bool get hasSettingsData =>
      displayName.value.trim().isNotEmpty ||
      displayEmail.value.trim().isNotEmpty ||
      fullNameController.text.trim().isNotEmpty ||
      emailController.text.trim().isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    AppLoggerHelper.info('InstallerSettingController initialized');
  }

  @override
  void onClose() {
    _notificationPermissionWorker?.dispose();
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    availableHoursController.dispose();
    bankNameController.dispose();
    accountNumberController.dispose();
    routingNumberController.dispose();
    super.onClose();
  }

  /// Load user data from storage or API
  void _loadUserData() {
    try {
      isLoading.value = true;

      // Availability
      isAvailableForNewJobs.value = false;
      availableHoursController.clear();

      // Payment info (empty for security)
      bankNameController.clear();
      accountNumberController.clear();
      routingNumberController.clear();

      // Notifications
      pushNotificationsEnabled.value = true;
      twoFactorEnabled.value = _twoFactorApiService.getSavedStatus();

      AppLoggerHelper.info('User data loaded successfully');
    } catch (error) {
      AppLoggerHelper.error('Failed to load user data', error);
      EasyLoading.showError('Failed to load settings');
    } finally {
      isLoading.value = false;
    }

    _loadUserProfile();
    _bindNotificationPermission();
    _loadServiceAreasData();
    _loadAvailabilityData();
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

  Future<void> refreshUserProfileForDrawer() {
    return _loadUserProfile(showLoader: false);
  }

  Future<void> refreshUserProfile({bool showLoader = false}) {
    return _loadUserProfile(showLoader: showLoader);
  }

  Future<void> _loadUserProfile({bool showLoader = true}) async {
    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      AppLoggerHelper.warning('Installer profile request missing token');
      return;
    }

    try {
      if (showLoader) isLoading.value = true;
      final profile = await _userProfileApiService.fetchCurrentUser(
        authorization: authorization,
      );

      fullNameController.text = profile.name;
      emailController.text = profile.email;
      phoneController.text = profile.phone;
      profileImageUrl.value = profile.photo;
      profileImagePath.value = '';

      displayUserId.value = profile.id;
      displayName.value = profile.name;
      displayEmail.value = profile.email;
      displayPhone.value = profile.phone;
      displayRole.value = profile.role;
      displayIsActive.value = profile.isActive;
      displayTotalEarnings.value = profile.totalEarnings;
      displayPayableCommissionAmount.value = profile.payableCommissionAmount;
      twoFactorEnabled.value = profile.twoFactorEnabled;

      AppLoggerHelper.info('Installer profile loaded: ${profile.id}');
    } catch (error) {
      AppLoggerHelper.error('Failed to load installer profile', error);
    } finally {
      if (showLoader) isLoading.value = false;
    }
  }

  Future<void> ensureServiceAreasLoaded({bool forceRefresh = false}) async {
    if (!forceRefresh && hasLoadedServiceAreas.value) return;
    await _loadServiceAreasData(showError: false);
  }

  Future<void> _loadServiceAreasData({bool showError = true}) {
    _serviceAreasLoadFuture ??= _fetchServiceAreasData(showError: showError)
        .whenComplete(() {
          _serviceAreasLoadFuture = null;
        });
    return _serviceAreasLoadFuture!;
  }

  Future<void> _fetchServiceAreasData({required bool showError}) async {
    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      AppLoggerHelper.warning('Installer service area request missing token');
      return;
    }

    try {
      isServiceAreaLoading.value = true;
      hasLoadedServiceAreas.value = false;

      final results = await Future.wait<List<InstallerServiceAreaOption>>([
        _installerServiceAreaApiService.fetchAvailableServiceAreas(
          authorization: authorization,
        ),
        _installerServiceAreaApiService.fetchInstallerServiceAreas(
          authorization: authorization,
        ),
      ]);

      final availableAreas = results[0];
      final assignedAreas = results[1];

      availableServiceAreas.assignAll(availableAreas);

      final availableIdSet = availableAreas.map((e) => e.id).toSet();
      final selectedIds = assignedAreas
          .map((e) => e.id)
          .where(availableIdSet.contains)
          .toSet()
          .toList();
      selectedServiceAreaIds.assignAll(selectedIds);

      AppLoggerHelper.info(
        'Installer service areas loaded. '
        'available=${availableServiceAreas.length}, '
        'selected=${selectedServiceAreaIds.length}',
      );
      hasLoadedServiceAreas.value = true;
    } catch (error) {
      AppLoggerHelper.error('Failed to load installer service areas', error);
      if (showError) {
        EasyLoading.showError(AppStrings.serviceAreasLoadError);
      }
    } finally {
      isServiceAreaLoading.value = false;
    }
  }

  Future<void> _loadAvailabilityData() async {
    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      AppLoggerHelper.warning('Installer availability request missing token');
      return;
    }

    try {
      final availability = await _installerAvailabilityApiService
          .fetchInstallerAvailability(authorization: authorization);

      isAvailableForNewJobs.value = availability.isAvailable;
      availableHoursController.text = availability.activeHoursPerWeek > 0
          ? availability.activeHoursPerWeek.toString()
          : '';

      AppLoggerHelper.info(
        'Installer availability loaded: '
        'is_available=${availability.isAvailable}, '
        'active_hours_per_week=${availability.activeHoursPerWeek}',
      );
    } catch (error) {
      AppLoggerHelper.error('Failed to load installer availability', error);
    }
  }

  Future<void> startPaymentSetupProcess() async {
    if (isLaunchingStripeOnboarding.value) return;

    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      EasyLoading.showError(AppStrings.authorizationRequired);
      return;
    }

    try {
      isLaunchingStripeOnboarding.value = true;
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

      EasyLoading.showSuccess(
        'Stripe onboarding opened. Return and tap "Check Again".',
      );
    } catch (error) {
      AppLoggerHelper.error('Failed to start installer payment setup', error);
      EasyLoading.showError('Could not start payment setup. Please try again.');
    } finally {
      isLaunchingStripeOnboarding.value = false;
      EasyLoading.dismiss();
    }
  }

  String? _buildAuthorizationHeader() {
    final token = StorageService.accessToken;
    if (token == null || token.isEmpty) return null;

    final type = StorageService.tokenType?.trim();
    final prefix = (type != null && type.isNotEmpty) ? type : 'Bearer';
    return '$prefix $token';
  }

  /// Validate profile fields
  String? validateFullName(String? value) =>
      AppValidator.validateFullName(value);
  String? validateEmail(String? value) => AppValidator.validateEmail(value);
  String? validatePhoneNumber(String? value) =>
      AppValidator.validatePhoneNumber(value);

  /// Toggle service area selection
  void toggleServiceArea(int areaId) {
    if (selectedServiceAreaIds.contains(areaId)) {
      selectedServiceAreaIds.remove(areaId);
    } else {
      selectedServiceAreaIds.add(areaId);
    }
    AppLoggerHelper.debug('Service area ids updated: $selectedServiceAreaIds');
  }

  /// Toggle availability for new jobs
  void toggleAvailability(bool value) {
    isAvailableForNewJobs.value = value;
    AppLoggerHelper.debug('Availability toggled: $value');
  }

  /// Update installer availability
  Future<void> updateAvailability() async {
    final weekHours = int.tryParse(availableHoursController.text.trim());
    if (weekHours == null || weekHours <= 0) {
      EasyLoading.showError('Please enter valid available hours per week');
      return;
    }
    if (weekHours > 168) {
      EasyLoading.showError('Available hours per week cannot exceed 168');
      return;
    }

    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      EasyLoading.showError(AppStrings.authorizationRequired);
      return;
    }

    try {
      isUpdatingAvailability.value = true;
      EasyLoading.show(status: 'Updating availability...');

      await _installerAvailabilityApiService.updateInstallerAvailability(
        authorization: authorization,
        isAvailable: isAvailableForNewJobs.value,
        weekHours: weekHours,
      );

      AppLoggerHelper.info(
        'Availability updated: is_available=${isAvailableForNewJobs.value}, '
        'week_hours=$weekHours',
      );
      EasyLoading.showSuccess('Availability updated successfully!');
    } catch (error) {
      AppLoggerHelper.error('Failed to update availability', error);
      EasyLoading.showError('Failed to update availability');
    } finally {
      isUpdatingAvailability.value = false;
      EasyLoading.dismiss();
    }
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
    AppLoggerHelper.debug('Push notifications toggled: $value');
  }

  /// Save profile changes
  Future<void> saveProfileChanges() async {
    // Validate inputs
    if (fullNameController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter your full name');
      return;
    }

    if (emailController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter your email');
      return;
    }

    // Validate email format
    final emailValidation = AppValidator.validateEmail(emailController.text);
    if (emailValidation != null) {
      EasyLoading.showError(emailValidation);
      return;
    }

    // Validate phone if provided
    if (phoneController.text.trim().isNotEmpty) {
      final phoneValidation = AppValidator.validatePhoneNumber(
        phoneController.text,
      );
      if (phoneValidation != null) {
        EasyLoading.showError(phoneValidation);
        return;
      }
    }

    try {
      final authorization = _buildAuthorizationHeader();
      if (authorization == null) {
        EasyLoading.showError(AppStrings.authorizationRequired);
        return;
      }

      isSavingProfile.value = true;
      EasyLoading.show(status: 'Saving profile...');

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
      profileImageUrl.value = profile.photo;
      profileImagePath.value = '';

      displayUserId.value = profile.id;
      displayName.value = profile.name;
      displayEmail.value = profile.email;
      displayPhone.value = profile.phone;
      displayRole.value = profile.role;
      displayIsActive.value = profile.isActive;
      displayTotalEarnings.value = profile.totalEarnings;
      displayPayableCommissionAmount.value = profile.payableCommissionAmount;

      AppLoggerHelper.info(
        'Installer profile updated: ${profile.id}, '
        '${profile.email}, ${profile.phone}',
      );

      EasyLoading.showSuccess('Profile updated successfully!');
    } catch (error) {
      AppLoggerHelper.error('Failed to save profile', error);
      EasyLoading.showError('Failed to update profile');
    } finally {
      isSavingProfile.value = false;
      EasyLoading.dismiss();
    }
  }

  Future<void> changeProfilePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      EasyLoading.show(status: 'Processing photo...');
      final compressedPath = await AppHelperFunctions.compressImageIfNeeded(image.path);
      profileImagePath.value = compressedPath;
      EasyLoading.dismiss();

      AppLoggerHelper.info('Installer profile photo selected: $compressedPath');
      EasyLoading.showInfo('Photo selected. Tap Save Profile Changes.');
    } catch (error) {
      EasyLoading.dismiss();
      AppLoggerHelper.error('Failed to change photo', error);
      EasyLoading.showError('Failed to change photo');
    }
  }

  /// Update service area
  Future<bool> updateServiceArea() async {
    if (isUpdatingServiceArea.value) return false;

    if (selectedServiceAreaIds.isEmpty) {
      EasyLoading.showError('Please select at least one service area');
      return false;
    }

    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      EasyLoading.showError(AppStrings.authorizationRequired);
      return false;
    }

    try {
      isUpdatingServiceArea.value = true;
      EasyLoading.show(status: 'Updating service area...');

      await _installerServiceAreaApiService.updateInstallerServiceAreas(
        authorization: authorization,
        areaIds: selectedServiceAreaIds.toList(),
      );

      final refreshedSelected = await _installerServiceAreaApiService
          .fetchInstallerServiceAreas(authorization: authorization);
      final refreshedIds = refreshedSelected.map((e) => e.id).toSet().toList();
      selectedServiceAreaIds.assignAll(refreshedIds);

      AppLoggerHelper.info('Service area ids updated: $refreshedIds');
      await _refreshInstallerHomeAfterServiceAreaUpdate();
      EasyLoading.showSuccess('Service area updated successfully!');
      return true;
    } catch (error) {
      AppLoggerHelper.error('Failed to update service area', error);
      EasyLoading.showError('Failed to update service area');
      return false;
    } finally {
      isUpdatingServiceArea.value = false;
      EasyLoading.dismiss();
    }
  }

  Future<void> _refreshInstallerHomeAfterServiceAreaUpdate() async {
    if (!Get.isRegistered<InstallerManagementController>()) return;

    try {
      await Get.find<InstallerManagementController>().refreshJobs();
    } catch (error) {
      AppLoggerHelper.warning(
        'Service area updated, but installer home refresh failed: $error',
      );
    }
  }

  /// Update payment information
  Future<void> updatePaymentInfo() async {
    // Validate payment fields
    if (bankNameController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter bank name');
      return;
    }

    if (accountNumberController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter account number');
      return;
    }

    if (routingNumberController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter routing number');
      return;
    }

    try {
      isUpdatingPayment.value = true;
      EasyLoading.show(status: 'Updating payment info...');

      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      AppLoggerHelper.info('Payment info updated');
      EasyLoading.showSuccess('Payment info updated successfully!');

      // Clear sensitive data after successful update
      bankNameController.clear();
      accountNumberController.clear();
      routingNumberController.clear();
    } catch (error) {
      AppLoggerHelper.error('Failed to update payment info', error);
      EasyLoading.showError('Failed to update payment info');
    } finally {
      isUpdatingPayment.value = false;
      EasyLoading.dismiss();
    }
  }

  /// Save notification settings
  Future<void> saveNotificationSettings() async {
    try {
      isSavingNotifications.value = true;
      await _notificationController.openSystemNotificationSettings(
        message: pushNotificationsEnabled.value
            ? 'Manage this app notification setting from your device settings.'
            : 'Turn on notifications for this app in your device settings.',
      );
      AppLoggerHelper.info(
        'Notification settings screen opened: '
        'Push=${pushNotificationsEnabled.value}',
      );
    } catch (error) {
      AppLoggerHelper.error('Failed to save notification settings', error);
      EasyLoading.showError('Failed to open notification settings');
    } finally {
      isSavingNotifications.value = false;
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
        EasyLoading.showError(AppStrings.authorizationRequired);
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

      AppLoggerHelper.info('Installer password updated successfully');
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
      EasyLoading.showError(AppStrings.authorizationRequired);
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

      AppLoggerHelper.info(
        'Installer two-factor authentication updated: $enabled',
      );
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

  Future<void> deleteAccount() async {
    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      EasyLoading.showError(AppStrings.authorizationRequired);
      return;
    }

    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text(AppStrings.deleteAccountTitle),
          content: const Text(AppStrings.deleteAccountConfirmation),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text(AppStrings.cancel),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text(AppStrings.delete),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      EasyLoading.show(status: 'Deleting account...');

      final response = await _authApiService.deleteCurrentUserAccount(
        authorization: authorization,
      );

      if (!response.isSuccess) {
        EasyLoading.showError(
          response.errorMessage.isNotEmpty
              ? response.errorMessage
              : 'Failed to delete account',
        );
        return;
      }

      await StorageService.logoutUser();
      AppLoggerHelper.info('Installer account deleted successfully');
      EasyLoading.showSuccess(AppStrings.accountDeletedSuccess);
      Get.offAllNamed(AppRoute.loginScreen);
    } catch (error) {
      AppLoggerHelper.error('Delete account error', error);
      EasyLoading.showError('Failed to delete account');
    } finally {
      EasyLoading.dismiss();
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text(AppStrings.logout),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text(AppStrings.cancel),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text(AppStrings.logout),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        EasyLoading.show(status: 'Logging out...');

        // TODO: Call logout API and clear local storage
        await Future.delayed(const Duration(seconds: 1));
        await StorageService.logoutUser();

        AppLoggerHelper.info('User logged out successfully');
        EasyLoading.showSuccess('Logged out successfully');

        // Navigate to login screen
        Get.offAllNamed(AppRoute.loginScreen);
      }
    } catch (error) {
      AppLoggerHelper.error('Logout error', error);
      EasyLoading.showError('Failed to logout');
    } finally {
      EasyLoading.dismiss();
    }
  }
}

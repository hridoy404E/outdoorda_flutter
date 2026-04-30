import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:outdoorda_flutter/core/services/firebase/notification_controller.dart';
import 'package:outdoorda_flutter/core/services/storage_service.dart';
import 'package:outdoorda_flutter/core/services/two_factor_api_service.dart';
import 'package:outdoorda_flutter/core/services/user_profile_api_service.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/features/global_section/authentication/auth_api_services/auth_api_service.dart';
import 'package:outdoorda_flutter/features/customer_section/settings/models/pet_model.dart';
import 'package:outdoorda_flutter/features/customer_section/settings/services/customer_pet_api_service.dart';
import 'package:outdoorda_flutter/routes/app_routes.dart';

/// Customer Settings Controller
/// Manages customer profile, pets, and settings functionality
class CustomerSettingController extends GetxController {
  final UserProfileApiService _userProfileApiService = UserProfileApiService();
  final CustomerPetApiService _customerPetApiService = CustomerPetApiService();
  final AuthApiService _authApiService = AuthApiService();
  final TwoFactorApiService _twoFactorApiService = TwoFactorApiService();
  final NotificationController _notificationController =
      Get.find<NotificationController>();

  /// Observable list of user's pets
  final RxList<Pet> pets = <Pet>[].obs;

  /// Loading state
  final RxBool isLoading = false.obs;
  final RxBool isChangingPassword = false.obs;
  final RxBool isTogglingTwoFactor = false.obs;

  /// User profile data
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString userPhone = ''.obs;
  final RxString userPhotoUrl = ''.obs;
  final RxString userPhotoPath = ''.obs;
  final RxBool twoFactorEnabled = false.obs;

  bool get hasSettingsData =>
      userName.value.trim().isNotEmpty ||
      userEmail.value.trim().isNotEmpty ||
      userPhone.value.trim().isNotEmpty;

  /// Pet Types and Sizes
  final List<String> petTypes = [AppStrings.dog, AppStrings.cat];
  final List<String> petSizes = [
    AppStrings.smallSize,
    AppStrings.mediumSize,
    AppStrings.largeSize,
  ];

  @override
  void onInit() {
    super.onInit();
    twoFactorEnabled.value = _twoFactorApiService.getSavedStatus();
    _loadUserProfile();
    _loadPets();
  }

  Future<void> _loadUserProfile() async {
    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      AppLoggerHelper.warning('Customer profile request missing token');
      return;
    }

    try {
      isLoading.value = true;
      final profile = await _userProfileApiService.fetchCurrentUser(
        authorization: authorization,
      );

      userName.value = profile.name;
      userEmail.value = profile.email;
      userPhone.value = profile.phone;
      userPhotoUrl.value = profile.photo;
      userPhotoPath.value = '';
      twoFactorEnabled.value = _twoFactorApiService.getSavedStatus();

      AppLoggerHelper.info('Customer profile loaded: ${profile.id}');
    } catch (error) {
      AppLoggerHelper.error('Failed to load customer profile', error);
    } finally {
      isLoading.value = false;
    }
  }

  String? _buildAuthorizationHeader() {
    final token = StorageService.accessToken;
    if (token == null || token.isEmpty) return null;

    final type = StorageService.tokenType?.trim();
    final prefix = (type != null && type.isNotEmpty) ? type : 'Bearer';
    return '$prefix $token';
  }

  Future<void> _loadPets() async {
    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      AppLoggerHelper.warning('Customer pets request missing token');
      return;
    }

    try {
      isLoading.value = true;
      await _fetchPets(authorization: authorization);
    } catch (error) {
      AppLoggerHelper.error('Failed to load customer pets', error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchPets({required String authorization}) async {
    final fetchedPets = await _customerPetApiService.fetchCustomerPets(
      authorization: authorization,
    );
    pets.assignAll(fetchedPets);
    AppLoggerHelper.info('Customer pets loaded: ${fetchedPets.length}');
  }

  /// Add new pet
  Future<void> addPet({
    required String name,
    required String type,
    required String size,
    String? breed,
  }) async {
    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      EasyLoading.showError(AppStrings.authorizationRequired);
      return;
    }

    try {
      isLoading.value = true;
      EasyLoading.show();

      await _customerPetApiService.createPet(
        authorization: authorization,
        name: name,
        type: type,
        size: size,
        breed: breed,
      );

      await _fetchPets(authorization: authorization);

      AppLoggerHelper.info('Pet added successfully');
      EasyLoading.showSuccess(AppStrings.petAddedSuccess);

      /// Close dialog
      Get.back();
    } catch (error) {
      AppLoggerHelper.error('Add pet error: $error', error);
      EasyLoading.showError('Failed to add pet');
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }

  /// Update existing pet
  Future<void> updatePet({
    required String petId,
    required String name,
    required String type,
    required String size,
    String? breed,
  }) async {
    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      EasyLoading.showError(AppStrings.authorizationRequired);
      return;
    }

    try {
      isLoading.value = true;
      EasyLoading.show();

      await _customerPetApiService.updatePet(
        authorization: authorization,
        petId: petId,
        name: name,
        type: type,
        size: size,
        breed: breed,
      );

      await _fetchPets(authorization: authorization);

      AppLoggerHelper.info('Pet updated: $petId');
      EasyLoading.showSuccess(AppStrings.petUpdatedSuccess);

      /// Close dialog
      Get.back();
    } catch (error) {
      AppLoggerHelper.error('Update pet error: $error', error);
      EasyLoading.showError('Failed to update pet');
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }

  /// Delete pet
  Future<void> deletePet(String petId) async {
    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      EasyLoading.showError(AppStrings.authorizationRequired);
      return;
    }

    try {
      isLoading.value = true;
      EasyLoading.show();

      await _customerPetApiService.deletePet(
        authorization: authorization,
        petId: petId,
      );

      await _fetchPets(authorization: authorization);

      AppLoggerHelper.info('Pet deleted: $petId');
      EasyLoading.showSuccess(AppStrings.petDeletedSuccess);
    } catch (error) {
      AppLoggerHelper.error('Delete pet error: $error', error);
      EasyLoading.showError('Failed to delete pet');
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    required String name,
    required String email,
    String? phone,
  }) async {
    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      EasyLoading.showError(AppStrings.authorizationRequired);
      return;
    }

    try {
      isLoading.value = true;
      EasyLoading.show(status: 'Updating profile...');

      final profile = await _userProfileApiService.updateCurrentUserProfile(
        authorization: authorization,
        name: name,
        phone: phone?.trim().isEmpty == true ? '' : phone?.trim(),
        photoPath: userPhotoPath.value.isEmpty ? null : userPhotoPath.value,
      );

      userName.value = profile.name;
      userEmail.value = profile.email;
      userPhone.value = profile.phone;
      userPhotoUrl.value = profile.photo;
      userPhotoPath.value = '';

      AppLoggerHelper.info('Customer profile updated: ${profile.id}');
      EasyLoading.showSuccess(AppStrings.profileUpdatedSuccess);

      /// Close dialog
      Get.back();
    } catch (error) {
      AppLoggerHelper.error('Update profile error: $error', error);
      EasyLoading.showError('Failed to update profile');
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }

  Future<void> changeProfilePhoto() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      userPhotoPath.value = image.path;
      AppLoggerHelper.info('Customer profile photo selected: ${image.path}');
      EasyLoading.showInfo('Photo selected. Tap Update Profile.');
    } catch (error) {
      AppLoggerHelper.error('Failed to select customer profile photo', error);
      EasyLoading.showError('Failed to change photo');
    }
  }

  Future<void> manageNotifications() async {
    try {
      await _notificationController.openSystemNotificationSettings(
        message:
            'Manage this app notification setting from your device settings.',
      );
    } catch (error) {
      AppLoggerHelper.error('Open notification settings error: $error', error);
      EasyLoading.showError('Failed to open notification settings');
    }
  }

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
        'Customer two-factor authentication updated: $enabled',
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

      isLoading.value = true;
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

      AppLoggerHelper.info('Customer account deleted successfully');
      await StorageService.logoutUser();
      EasyLoading.showSuccess(AppStrings.accountDeletedSuccess);
      Get.offAllNamed(AppRoute.loginScreen);
    } catch (error) {
      AppLoggerHelper.error('Delete account error: $error', error);
      EasyLoading.showError('Failed to delete account');
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }

  /// Handle logout
  Future<void> logout() async {
    try {
      /// Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Log Out'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        isLoading.value = true;
        EasyLoading.show(status: 'Logging out...');

        /// TODO: Replace with actual API call
        await Future.delayed(const Duration(seconds: 1));

        AppLoggerHelper.info('User logged out');
        await StorageService.logoutUser();
        EasyLoading.showSuccess('Logged out successfully');
        EasyLoading.dismiss();

        /// Navigate to login screen
        Get.offAllNamed(AppRoute.loginScreen);
      }
    } catch (error) {
      AppLoggerHelper.error('Logout error: $error', error);
      EasyLoading.showError('Failed to log out');
    } finally {
      isLoading.value = false;
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

      AppLoggerHelper.info('Customer password updated successfully');
      EasyLoading.showSuccess('Password updated successfully');
    } catch (error) {
      AppLoggerHelper.error('Change password error: $error', error);
      EasyLoading.showError('Failed to change password');
    } finally {
      oldPasswordController.dispose();
      newPasswordController.dispose();
      confirmPasswordController.dispose();
      isChangingPassword.value = false;
      EasyLoading.dismiss();
    }
  }
}

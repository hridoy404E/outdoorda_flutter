import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/services/storage_service.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/features/customer_section/home/messaging/models/message.dart';
import 'package:outdoorda_flutter/features/admin_section/user_management/models/user_model.dart';
import 'package:outdoorda_flutter/features/admin_section/user_management/services/user_management_api_service.dart';
import 'package:outdoorda_flutter/routes/app_routes.dart';

/// Controller for managing users in admin section
/// Handles both installer and customer user management
class UserManagementController extends GetxController {
  static const int _pageSize = 20;

  final UserManagementApiService _userManagementApiService =
      UserManagementApiService();

  /// Selected tab index (0 = Installer, 1 = Customer)
  final RxInt selectedTabIndex = 0.obs;

  /// Error state
  final RxString loadUsersError = ''.obs;

  /// Installer states
  final RxBool isLoadingInstallers = false.obs;
  final RxBool isLoadingMoreInstallers = false.obs;
  final RxBool hasMoreInstallers = true.obs;
  final RxInt totalInstallers = 0.obs;
  int _installerOffset = 0;
  String _lastSearchQueryInstaller = '';

  /// Customer states
  final RxBool isLoadingCustomers = false.obs;
  final RxBool isLoadingMoreCustomers = false.obs;
  final RxBool hasMoreCustomers = true.obs;
  final RxInt totalCustomers = 0.obs;
  int _customerOffset = 0;
  String _lastSearchQueryCustomer = '';

  /// Search controller and query
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  // Backwards compatibility legacy states
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreUsers = true.obs;
  final RxInt totalUsers = 0.obs;

  /// List of installer users
  final RxList<UserModel> installers = <UserModel>[].obs;

  /// List of customer users
  final RxList<UserModel> customers = <UserModel>[].obs;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    searchController.addListener(_onSearchTextChanged);
    loadUsers();

    // Listen for search query changes and trigger search after debounce
    debounce(searchQuery, (_) {
      loadTabUsers(tabIndex: selectedTabIndex.value, isInitialLoad: true);
    }, time: const Duration(milliseconds: 500));

    AppLoggerHelper.info('UserManagementController initialized');
  }

  void _onSearchTextChanged() {
    searchQuery.value = searchController.text.trim();
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    searchController.removeListener(_onSearchTextChanged);
    searchController.dispose();
    super.onClose();
  }

  /// Load users for the current tab
  Future<void> loadUsers() async {
    await loadTabUsers(tabIndex: selectedTabIndex.value, isInitialLoad: true);
  }

  Future<void> loadMoreUsers() async {
    final tabIndex = selectedTabIndex.value;
    if (tabIndex == 0) {
      if (isLoadingInstallers.value || isLoadingMoreInstallers.value || !hasMoreInstallers.value) return;
    } else {
      if (isLoadingCustomers.value || isLoadingMoreCustomers.value || !hasMoreCustomers.value) return;
    }
    await loadTabUsers(tabIndex: tabIndex, isInitialLoad: false);
  }

  Future<void> refreshUsers() async {
    await loadTabUsers(tabIndex: selectedTabIndex.value, isInitialLoad: true);
  }

  Future<void> loadTabUsers({required int tabIndex, required bool isInitialLoad}) async {
    final role = tabIndex == 0 ? 'INSTALLER' : 'CUSTOMER';
    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      loadUsersError.value = 'Authorization missing. Please log in again.';
      if (tabIndex == 0) {
        hasMoreInstallers.value = false;
      } else {
        hasMoreCustomers.value = false;
      }
      _updateLegacyStates();
      return;
    }

    try {
      if (isInitialLoad) {
        if (tabIndex == 0) {
          isLoadingInstallers.value = true;
          _installerOffset = 0;
          installers.clear();
          hasMoreInstallers.value = true;
        } else {
          isLoadingCustomers.value = true;
          _customerOffset = 0;
          customers.clear();
          hasMoreCustomers.value = true;
        }
        loadUsersError.value = '';
      } else {
        if (tabIndex == 0) {
          isLoadingMoreInstallers.value = true;
        } else {
          isLoadingMoreCustomers.value = true;
        }
      }
      _updateLegacyStates();

      final currentOffset = tabIndex == 0 ? _installerOffset : _customerOffset;
      final currentSearch = searchQuery.value;

      final page = await _userManagementApiService.fetchUsers(
        authorization: authorization,
        offset: currentOffset,
        limit: _pageSize,
        role: role,
        search: currentSearch,
      );

      if (tabIndex == 0) {
        _lastSearchQueryInstaller = currentSearch;
        totalInstallers.value = page.total;
        _installerOffset = page.offset + page.count;

        for (final user in page.results) {
          if (user.userType == 'installer') {
            final alreadyExists = installers.any((item) => item.id == user.id);
            if (!alreadyExists) {
              installers.add(user);
            }
          }
        }
        hasMoreInstallers.value = page.count > 0 && installers.length < page.total;
      } else {
        _lastSearchQueryCustomer = currentSearch;
        totalCustomers.value = page.total;
        _customerOffset = page.offset + page.count;

        for (final user in page.results) {
          if (user.userType == 'customer') {
            final alreadyExists = customers.any((item) => item.id == user.id);
            if (!alreadyExists) {
              customers.add(user);
            }
          }
        }
        hasMoreCustomers.value = page.count > 0 && customers.length < page.total;
      }

      loadUsersError.value = '';
      AppLoggerHelper.info(
        'Users loaded for tab $tabIndex: offset=${page.offset}, count=${page.count}, '
        'total=${page.total}, currentCount=${tabIndex == 0 ? installers.length : customers.length}',
      );
    } catch (error) {
      AppLoggerHelper.error('Failed to load users for tab $tabIndex', error);
      loadUsersError.value = 'Failed to load users';
    } finally {
      if (isInitialLoad) {
        if (tabIndex == 0) {
          isLoadingInstallers.value = false;
        } else {
          isLoadingCustomers.value = false;
        }
      } else {
        if (tabIndex == 0) {
          isLoadingMoreInstallers.value = false;
        } else {
          isLoadingMoreCustomers.value = false;
        }
      }
      _updateLegacyStates();
    }
  }

  void _updateLegacyStates() {
    isLoading.value = selectedTabIndex.value == 0 ? isLoadingInstallers.value : isLoadingCustomers.value;
    isLoadingMore.value = selectedTabIndex.value == 0 ? isLoadingMoreInstallers.value : isLoadingMoreCustomers.value;
    hasMoreUsers.value = selectedTabIndex.value == 0 ? hasMoreInstallers.value : hasMoreCustomers.value;
    totalUsers.value = selectedTabIndex.value == 0 ? totalInstallers.value : totalCustomers.value;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  /// Switch between Installer and Customer tabs
  void selectTab(int index) {
    selectedTabIndex.value = index;
    _updateLegacyStates();
    final currentList = index == 0 ? installers : customers;
    final lastSearch = index == 0 ? _lastSearchQueryInstaller : _lastSearchQueryCustomer;

    if (currentList.isEmpty || lastSearch != searchQuery.value) {
      loadTabUsers(tabIndex: index, isInitialLoad: true);
    }
    AppLoggerHelper.debug(
      'Switched to tab: ${index == 0 ? 'Installer' : 'Customer'}',
    );
  }

  String? _buildAuthorizationHeader() {
    final token = StorageService.accessToken;
    if (token == null || token.isEmpty) return null;

    final type = StorageService.tokenType?.trim();
    final prefix = (type != null && type.isNotEmpty) ? type : 'Bearer';
    return '$prefix $token';
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      loadMoreUsers();
    }
  }

  /// Suspend a user with confirmation dialog
  Future<void> suspendUser(UserModel user) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Suspend User'),
        content: Text(
          'Are you sure you want to suspend ${user.name}? They will not be able to access the platform.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Suspend'),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    if (confirmed == true) {
      try {
        EasyLoading.show(status: 'Suspending user...');
        final authorization = _buildAuthorizationHeader();
        if (authorization == null) {
          EasyLoading.showError('Authorization missing. Please log in again.');
          return;
        }
        if (user.id.trim().isEmpty) {
          EasyLoading.showError('Invalid user id');
          return;
        }

        await _userManagementApiService.suspendUser(
          authorization: authorization,
          userId: user.id,
        );

        final updatedUser = user.copyWith(isSuspended: true);
        _updateUserInList(updatedUser);

        EasyLoading.showSuccess('${user.name} has been suspended');
        AppLoggerHelper.info('User suspended: ${user.name}');
      } catch (error) {
        AppLoggerHelper.error('Failed to suspend user', error);
        EasyLoading.showError('Failed to suspend user');
      }
    }
  }

  /// Undo suspend (reactivate) a user with confirmation dialog
  Future<void> undoSuspendUser(UserModel user) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Reactivate User'),
        content: Text(
          'Are you sure you want to reactivate ${user.name}? They will regain access to the platform.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Reactivate'),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    if (confirmed == true) {
      try {
        EasyLoading.show(status: 'Reactivating user...');

        final updatedUser = user.copyWith(isSuspended: false);
        _updateUserInList(updatedUser);

        EasyLoading.showSuccess('${user.name} has been reactivated');
        AppLoggerHelper.info('User reactivated: ${user.name}');
      } catch (error) {
        AppLoggerHelper.error('Failed to reactivate user', error);
        EasyLoading.showError('Failed to reactivate user');
      }
    }
  }

  /// Get current tab users
  List<UserModel> get currentTabUsers {
    return selectedTabIndex.value == 0 ? installers : customers;
  }

  void showProfileDetails(UserModel user) {
    Get.toNamed(AppRoute.getAdminUserDetailsScreen(), arguments: user);
  }

  void openUserMessage(UserModel user) {
    final userId = user.id.trim();
    if (userId.isEmpty) {
      EasyLoading.showError('Invalid user id');
      return;
    }

    final currentUserId = StorageService.userId?.trim();
    final conversation = Conversation(
      id: '${currentUserId?.isNotEmpty == true ? currentUserId : 'admin'}_$userId',
      userId: userId,
      userName: user.name.trim().isNotEmpty ? user.name.trim() : userId,
      userAvatar: user.profileImageUrl,
      userType: user.userType,
      lastMessage: 'Tap to chat',
      lastMessageTime: DateTime.now(),
    );

    Get.toNamed(AppRoute.getMessagingScreen(), arguments: conversation);
  }

  void openInstallerPaymentDetails(UserModel user) {
    if (user.userType != 'installer') {
      EasyLoading.showInfo('Payment details are available for installers only');
      return;
    }
    Get.toNamed(AppRoute.getAdminInstallerPaymentsScreen(), arguments: user);
  }

  Future<void> deleteUser(UserModel user) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete User'),
        content: Text(
          'Are you sure you want to delete ${user.name.trim().isNotEmpty ? user.name : 'this user'}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    if (confirmed != true) return;

    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      EasyLoading.showError('Authorization missing. Please log in again.');
      return;
    }

    if (user.id.trim().isEmpty) {
      EasyLoading.showError('Invalid user id');
      return;
    }

    try {
      EasyLoading.show(status: 'Deleting user...');
      await _userManagementApiService.deleteUser(
        authorization: authorization,
        userId: user.id,
      );

      _removeUserFromList(user);
      if (Get.currentRoute == AppRoute.getAdminUserDetailsScreen()) {
        Get.back<void>();
      }
      EasyLoading.showSuccess('User deleted successfully');
      AppLoggerHelper.info('User deleted: ${user.id}');
    } catch (error) {
      AppLoggerHelper.error('Failed to delete user', error);
      EasyLoading.showError('Failed to delete user');
    }
  }

  void _updateUserInList(UserModel updatedUser) {
    if (updatedUser.userType == 'installer') {
      final index = installers.indexWhere((u) => u.id == updatedUser.id);
      if (index != -1) installers[index] = updatedUser;
      return;
    }

    final index = customers.indexWhere((u) => u.id == updatedUser.id);
    if (index != -1) customers[index] = updatedUser;
  }

  void _removeUserFromList(UserModel user) {
    if (user.userType == 'installer') {
      installers.removeWhere((item) => item.id == user.id);
      return;
    }

    customers.removeWhere((item) => item.id == user.id);
  }
}

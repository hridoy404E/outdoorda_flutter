import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/services/storage_service.dart';
import 'package:outdoorda_flutter/core/utils/constants/image_path.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/features/admin_section/home/views/screens/admin_home_screen.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/views/screens/all_requests_screen.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/views/screens/customar_home_screen.dart';
import 'package:outdoorda_flutter/features/customer_section/settings/views/screens/customar_setting_screen.dart';
import 'package:outdoorda_flutter/features/installer_section/management/views/screens/installer_management_screen.dart';
import 'package:outdoorda_flutter/features/installer_section/settings/views/screens/installer_settting_screen.dart';
import '../../../admin_section/job_management/views/screens/job_management_screen.dart';
import '../../../admin_section/settings/views/screens/admin_settings_screen.dart';
import '../../../admin_section/user_management/views/screens/user_management_screen.dart';
import '../../../installer_section/message_section/views/screens/conversation_list_screen.dart';

/// Bottom navbar controller managing role-based navigation
/// Handles different navigation items for Customer (3), Admin (3), Installer (2)
class BottomNavbarController extends GetxController {
  /// Current selected tab index
  final RxInt currentIndex = 0.obs;

  /// User role from login screen
  final RxString userRole = 'Customer'.obs;

  @override
  void onInit() {
    super.onInit();

    syncRoleFromNavigation();
  }

  void syncRoleFromNavigation() {
    final args = Get.arguments;
    final argRole = args is Map ? args['role']?.toString() : null;
    final savedRole = StorageService.role;
    final normalizedRole = _normalizeRole(argRole ?? savedRole);

    userRole.value = normalizedRole;
    if (argRole != null) {
      currentIndex.value = 0;
    }
    AppLoggerHelper.info('BottomNavbar initialized with role: $normalizedRole');
  }

  /// Get navigation items based on user role
  List<BottomNavItem> getNavItems() {
    switch (userRole.value) {
      case 'Customer':
        return _getCustomerNavItems();
      case 'Admin':
        return _getAdminNavItems();
      case 'Installer':
        return _getInstallerNavItems();
      default:
        return [];
    }
  }

  /// Get screens based on user role
  List<Widget> getScreens() {
    switch (userRole.value) {
      case 'Customer':
        return _getCustomerScreens();
      case 'Admin':
        return _getAdminScreens();
      case 'Installer':
        return _getInstallerScreens();
      default:
        return [];
    }
  }

  /// Customer screens (3 screens)
  List<Widget> _getCustomerScreens() {
    return [
      const CustomarHomeScreen(), // Home screen
      const AllRequestsScreen(), // Bookings screen
      const CustomerSettingScreen(), // Settings screen
    ];
  }

  /// Admin screens (3 screens)
  List<Widget> _getAdminScreens() {
    return [
      const AdminHomeScreen(), // Admin home screen
      const UserManagementScreen(), // User management screen
      const JobManagementScreen(), // Job management screen
      const AdminSettingsScreen(), // Settings screen
    ];
  }

  /// Installer screens (3 screens)
  List<Widget> _getInstallerScreens() {
    return [
      const InstallerManagementScreen(), // Jobs/Bids screen
      const InstallerConversationListScreen(), // Messages screen (placeholder)
      const InstallerSettingScreen(), // Settings screen
    ];
  }

  /// Admin navigation items (3 items)
  List<BottomNavItem> _getAdminNavItems() {
    return [
      BottomNavItem(activeIcon: ImagePath.home1, inactiveIcon: ImagePath.home2),
      BottomNavItem(activeIcon: ImagePath.user1, inactiveIcon: ImagePath.user2),
      BottomNavItem(activeIcon: ImagePath.beg1, inactiveIcon: ImagePath.beg2),
      BottomNavItem(
        activeIcon: ImagePath.setting1,
        inactiveIcon: ImagePath.setting2,
      ),
    ];
  }

  /// Installer navigation items (3 items)
  List<BottomNavItem> _getInstallerNavItems() {
    return [
      BottomNavItem(activeIcon: ImagePath.beg1, inactiveIcon: ImagePath.beg2),
      BottomNavItem(
        activeIcon: ImagePath.message1,
        inactiveIcon: ImagePath.message2,
      ),
      BottomNavItem(
        activeIcon: ImagePath.setting1,
        inactiveIcon: ImagePath.setting2,
      ),
    ];
  }

  /// Customer navigation items (3 items)
  List<BottomNavItem> _getCustomerNavItems() {
    return [
      BottomNavItem(activeIcon: ImagePath.home1, inactiveIcon: ImagePath.home2),
      BottomNavItem(activeIcon: ImagePath.book1, inactiveIcon: ImagePath.book2),
      BottomNavItem(
        activeIcon: ImagePath.setting1,
        inactiveIcon: ImagePath.setting2,
      ),
    ];
  }

  /// Change tab index
  void changeTab(int index) {
    currentIndex.value = index;
    AppLoggerHelper.info('Tab changed to: $index');
  }

  String _normalizeRole(String? role) {
    final cleaned = role?.trim().toLowerCase();
    switch (cleaned) {
      case 'admin':
        return 'Admin';
      case 'installer':
        return 'Installer';
      default:
        return 'Customer';
    }
  }
}

/// Bottom navigation item model
class BottomNavItem {
  final String activeIcon;
  final String inactiveIcon;

  BottomNavItem({required this.activeIcon, required this.inactiveIcon});
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/features/global_section/bottom_navbar/controllers/bottom_navbar_controller.dart';
import 'package:outdoorda_flutter/features/installer_section/settings/controllers/installer_setting_controller.dart';
import 'package:outdoorda_flutter/features/installer_section/settings/views/widgets/installer_service_area_required_dialog.dart';

/// Bottom navbar screen with role-based navigation
/// Customer: 3 items, Admin: 3 items, Installer: 2 items
class BottomNavbarScreen extends StatefulWidget {
  const BottomNavbarScreen({super.key});

  @override
  State<BottomNavbarScreen> createState() => _BottomNavbarScreenState();
}

class _BottomNavbarScreenState extends State<BottomNavbarScreen> {
  late final BottomNavbarController controller;
  bool _handledInstallerServiceAreaPrompt = false;

  @override
  void initState() {
    super.initState();
    controller = Get.find<BottomNavbarController>();
    controller.syncRoleFromNavigation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowInstallerServiceAreaPrompt();
    });
  }

  Future<void> _maybeShowInstallerServiceAreaPrompt() async {
    if (_handledInstallerServiceAreaPrompt) return;
    _handledInstallerServiceAreaPrompt = true;

    final args = Get.arguments;
    final shouldPrompt =
        args is Map && args['showInstallerServiceAreaPrompt'] == true;
    if (!shouldPrompt || controller.userRole.value != 'Installer') return;

    final settingController = Get.find<InstallerSettingController>();
    await settingController.ensureServiceAreasLoaded(forceRefresh: true);

    if (!mounted || Get.isDialogOpen == true) return;
    if (!settingController.hasLoadedServiceAreas.value ||
        settingController.availableServiceAreas.isEmpty ||
        settingController.selectedServiceAreaIds.isNotEmpty) {
      return;
    }

    await Get.dialog<void>(
      InstallerServiceAreaRequiredDialog(controller: settingController),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: AppColors.bg,
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: controller.getScreens(),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.neutral25,
              border: Border(
                top: BorderSide(color: AppColors.borderColor, width: 1),
              ),
            ),
            child: SizedBox(
              height: 65.h,
              child: Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _buildNavItems(controller),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build navigation items based on role
  List<Widget> _buildNavItems(BottomNavbarController controller) {
    final items = controller.getNavItems();
    return List.generate(
      items.length,
      (index) => _buildNavItem(
        activeIcon: items[index].activeIcon,
        inactiveIcon: items[index].inactiveIcon,
        isActive: controller.currentIndex.value == index,
        onTap: () => controller.changeTab(index),
      ),
    );
  }

  /// Build single navigation item matching Figma design
  Widget _buildNavItem({
    required String activeIcon,
    required String inactiveIcon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              isActive ? activeIcon : inactiveIcon,
              width: isActive ? 26.w : 24.w,
              height: isActive ? 26.h : 24.h,
            ),
            // SizedBox(height: 6.h),
            Container(
              height: 2.h,
              width: 25.w,
              decoration: BoxDecoration(
                gradient: isActive ? AppColors.primaryGradient : null,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

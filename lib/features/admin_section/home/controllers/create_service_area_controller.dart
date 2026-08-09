import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/services/storage_service.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/features/admin_section/home/services/admin_service_area_api_service.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/models/service_area_model.dart';

class CreateServiceAreaController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final RxBool isSubmitting = false.obs;
  final RxBool isServiceAreasLoading = false.obs;
  final RxList<ServiceAreaModel> serviceAreas = <ServiceAreaModel>[].obs;

  final AdminServiceAreaApiService _adminServiceAreaApiService =
      AdminServiceAreaApiService();

  @override
  void onInit() {
    super.onInit();
    loadServiceAreas();
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  Future<void> loadServiceAreas() async {
    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      serviceAreas.clear();
      return;
    }

    try {
      isServiceAreasLoading.value = true;
      final areas = await _adminServiceAreaApiService.fetchServiceAreas(
        authorization: authorization,
      );
      serviceAreas.assignAll(areas);
    } catch (error) {
      AppLoggerHelper.error('Failed to load service areas', error);
      EasyLoading.showError(AppStrings.serviceAreasLoadError);
    } finally {
      isServiceAreasLoading.value = false;
    }
  }

  Future<void> createServiceArea() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      EasyLoading.showError('Please enter service area name');
      return;
    }

    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      EasyLoading.showError(AppStrings.authorizationRequired);
      return;
    }

    try {
      isSubmitting.value = true;
      EasyLoading.show(status: 'Creating service area...');

      final response = await _adminServiceAreaApiService.createServiceArea(
        authorization: authorization,
        name: name,
      );

      EasyLoading.dismiss();

      if (!response.isSuccess) {
        EasyLoading.showError(
          response.errorMessage.isNotEmpty
              ? response.errorMessage
              : 'Failed to create service area',
        );
        return;
      }

      AppLoggerHelper.info('Service area created successfully');
      EasyLoading.showSuccess(AppStrings.serviceAreaCreatedSuccessfully);
      nameController.clear();
      await loadServiceAreas();
    } catch (error) {
      EasyLoading.dismiss();
      AppLoggerHelper.error('Failed to create service area', error);
      EasyLoading.showError('Failed to create service area');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> updateServiceArea(ServiceAreaModel area, String newName) async {
    final name = newName.trim();
    if (name.isEmpty) {
      EasyLoading.showError('Please enter service area name');
      return;
    }

    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      EasyLoading.showError(AppStrings.authorizationRequired);
      return;
    }

    try {
      EasyLoading.show(status: 'Updating service area...');
      final response = await _adminServiceAreaApiService.updateServiceArea(
        authorization: authorization,
        id: area.id,
        name: name,
      );
      EasyLoading.dismiss();

      if (!response.isSuccess) {
        EasyLoading.showError(
          response.errorMessage.isNotEmpty
              ? response.errorMessage
              : 'Failed to update service area',
        );
        return;
      }

      EasyLoading.showSuccess('Service area updated successfully');
      await loadServiceAreas();
    } catch (error) {
      EasyLoading.dismiss();
      AppLoggerHelper.error('Failed to update service area', error);
      EasyLoading.showError('Failed to update service area');
    }
  }

  Future<void> deleteServiceArea(ServiceAreaModel area) async {
    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      EasyLoading.showError(AppStrings.authorizationRequired);
      return;
    }

    try {
      EasyLoading.show(status: 'Deleting service area...');
      final response = await _adminServiceAreaApiService.deleteServiceArea(
        authorization: authorization,
        id: area.id,
      );
      EasyLoading.dismiss();

      if (!response.isSuccess) {
        EasyLoading.showError(
          response.errorMessage.isNotEmpty
              ? response.errorMessage
              : 'Failed to delete service area',
        );
        return;
      }

      serviceAreas.removeWhere((item) => item.id == area.id);
      EasyLoading.showSuccess('Service area deleted successfully');
    } catch (error) {
      EasyLoading.dismiss();
      AppLoggerHelper.error('Failed to delete service area', error);
      EasyLoading.showError('Failed to delete service area');
    }
  }

  String? _buildAuthorizationHeader() {
    final token = StorageService.accessToken;
    if (token == null || token.isEmpty) return null;

    final type = StorageService.tokenType?.trim();
    final prefix = (type != null && type.isNotEmpty) ? type : 'Bearer';
    return '$prefix $token';
  }
}

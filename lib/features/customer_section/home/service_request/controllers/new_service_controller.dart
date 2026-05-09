import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:outdoorda_flutter/core/services/storage_service.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/controllers/customar_home_controller.dart';
import 'package:outdoorda_flutter/features/global_section/bottom_navbar/controllers/bottom_navbar_controller.dart';

import '../models/service_area_model.dart';
import '../services/service_area_api_service.dart';
import '../services/service_request_api_service.dart';

/// Controller for managing add service request flow
class NewServiceController extends GetxController {
  /// Current step in the form (0 = Pet Info, 1 = Installation, 2 = Photos)
  final RxInt currentStep = 0.obs;

  /// Text controllers
  final petNameController = TextEditingController();
  final typeController = TextEditingController();
  final sizeController = TextEditingController();
  final customerNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressLine1Controller = TextEditingController();
  final addressLine2Controller = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final zipCodeController = TextEditingController();
  final countryController = TextEditingController();

  /// Selected installation surface
  final RxString selectedSurface = ''.obs;

  /// Selected attachment file
  final Rx<File?> selectedAttachment = Rx<File?>(null);
  final RxString selectedAttachmentName = ''.obs;

  /// Service area metadata
  final RxList<ServiceAreaModel> serviceAreas = <ServiceAreaModel>[].obs;
  final Rxn<ServiceAreaModel> selectedServiceArea = Rxn<ServiceAreaModel>();
  final RxBool isServiceAreaLoading = false.obs;
  final ServiceAreaApiService _serviceAreaApiService = ServiceAreaApiService();
  final ServiceRequestApiService _serviceRequestApiService =
      ServiceRequestApiService();

  /// Loading state
  final RxBool isLoading = false.obs;

  /// Form key for validation
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    AppLoggerHelper.info('AddServiceController initialized');
    countryController.text = 'USA';
    loadServiceAreas();
  }

  @override
  void onClose() {
    petNameController.dispose();
    typeController.dispose();
    sizeController.dispose();
    customerNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    zipCodeController.dispose();
    countryController.dispose();
    super.onClose();
  }

  /// Reset all form fields
  void resetForm() {
    currentStep.value = 0;
    customerNameController.clear();
    emailController.clear();
    phoneController.clear();
    petNameController.clear();
    typeController.clear();
    sizeController.clear();
    addressLine1Controller.clear();
    addressLine2Controller.clear();
    cityController.clear();
    stateController.clear();
    zipCodeController.clear();
    countryController.text = 'USA';
    selectedSurface.value = '';
    selectedAttachment.value = null;
    selectedAttachmentName.value = '';
    selectedServiceArea.value = null;
  }

  /// Navigate to next step
  void nextStep() {
    if (currentStep.value == 0) {
      // Validate step 1 (Pet Info)
      if (!_validateStep1()) return;
      currentStep.value = 1;
      AppLoggerHelper.debug('Moved to step 2 (Installation)');
    } else if (currentStep.value == 1) {
      // Validate step 2 (Installation)
      if (!_validateStep2()) return;
      currentStep.value = 2;
      AppLoggerHelper.debug('Moved to step 3 (Photos)');
    }
  }

  /// Navigate to previous step
  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
      AppLoggerHelper.debug('Moved back to step ${currentStep.value + 1}');
    }
  }

  /// Validate step 1 (Pet Info)
  bool _validateStep1() {
    if (customerNameController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter customer name');
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter email');
      return false;
    }
    if (phoneController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter phone number');
      return false;
    }
    if (petNameController.text.trim().isEmpty) {
      EasyLoading.showError(AppStrings.pleaseEnterPetName);
      return false;
    }
    if (typeController.text.trim().isEmpty) {
      EasyLoading.showError(AppStrings.pleaseSelectType);
      return false;
    }
    if (sizeController.text.trim().isEmpty) {
      EasyLoading.showError(AppStrings.pleaseSelectSize);
      return false;
    }
    return true;
  }

  /// Validate step 2 (Installation)
  bool _validateStep2() {
    if (selectedServiceArea.value == null) {
      EasyLoading.showError(AppStrings.pleaseSelectServiceArea);
      return false;
    }

    if (addressLine1Controller.text.trim().isEmpty) {
      EasyLoading.showError('Please enter address line 1');
      return false;
    }
    if (cityController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter city');
      return false;
    }
    if (stateController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter state');
      return false;
    }
    if (zipCodeController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter zip code');
      return false;
    }
    if (selectedSurface.value.isEmpty) {
      EasyLoading.showError(AppStrings.pleaseSelectInstallationSurface);
      return false;
    }
    return true;
  }

  /// Validate step 3 (Photos)
  bool _validateStep3() {
    if (selectedAttachment.value == null) {
      EasyLoading.showError(AppStrings.pleaseUploadAttachment);
      return false;
    }
    return true;
  }

  /// Select installation surface
  void selectSurface(String surface) {
    selectedSurface.value = surface;
    AppLoggerHelper.debug('Selected surface: $surface');
  }

  void selectServiceArea(ServiceAreaModel? area) {
    selectedServiceArea.value = area;
    AppLoggerHelper.debug('Selected service area: ${area?.name}');
  }

  Future<void> pickFromCamera() async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        _setSelectedAttachment(file: File(image.path), name: image.name);
        AppLoggerHelper.info('Camera image selected: ${image.path}');
      }
    } catch (error) {
      AppLoggerHelper.error('Error picking camera image', error);
      EasyLoading.showError('Failed to open camera');
    }
  }

  Future<void> pickFromGallery() async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        _setSelectedAttachment(file: File(image.path), name: image.name);
        AppLoggerHelper.info('Gallery image selected: ${image.path}');
      }
    } catch (error) {
      AppLoggerHelper.error('Error picking gallery image', error);
      EasyLoading.showError('Failed to pick image');
    }
  }

  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: false,
        type: FileType.any,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.first;
      if (file.path == null || file.path!.trim().isEmpty) {
        EasyLoading.showError('Selected file path is unavailable');
        return;
      }

      _setSelectedAttachment(file: File(file.path!), name: file.name);
      AppLoggerHelper.info('File selected: ${file.path}');
    } catch (error) {
      AppLoggerHelper.error('Error picking file', error);
      EasyLoading.showError('Failed to pick file');
    }
  }

  /// Submit service request
  Future<void> submitRequest() async {
    if (!_validateStep3()) return;

    final selectedArea = selectedServiceArea.value;
    if (selectedArea == null) {
      EasyLoading.showError(AppStrings.pleaseSelectServiceArea);
      return;
    }

    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      EasyLoading.showError(AppStrings.authorizationRequired);
      return;
    }

    try {
      isLoading.value = true;
      EasyLoading.show(status: 'Submitting request...');

      final response = await _serviceRequestApiService.createServiceRequest(
        custName: customerNameController.text.trim(),
        custEmail: emailController.text.trim(),
        custPhone: phoneController.text.trim(),
        petName: petNameController.text.trim(),
        petType: typeController.text.trim(),
        price: '0',
        size: sizeController.text.trim(),
        installationSurface: _formatSurface(selectedSurface.value),
        serviceAreaId: selectedArea.id,
        addressLine1: addressLine1Controller.text.trim(),
        addressLine2: addressLine2Controller.text.trim(),
        city: cityController.text.trim(),
        state: stateController.text.trim(),
        zipCode: zipCodeController.text.trim(),
        country: 'USA',
        attachment: selectedAttachment.value!,
        authorization: authorization,
      );

      AppLoggerHelper.info('''
        Service Request Submitted:
        Pet Name: ${petNameController.text.trim()}
        Type: ${typeController.text.trim()}
        Size: ${sizeController.text.trim()}
        Customer Name: ${customerNameController.text.trim()}
        Email: ${emailController.text.trim()}
        Phone: ${phoneController.text.trim()}
        Address Line 1: ${addressLine1Controller.text.trim()}
        Address Line 2: ${addressLine2Controller.text.trim()}
        City: ${cityController.text.trim()}
        State: ${stateController.text.trim()}
        Zip Code: ${zipCodeController.text.trim()}
        Surface: ${selectedSurface.value}
        Service Area: ${selectedArea.name}
        Attachment: ${selectedAttachment.value?.path}
        Response: ${response.responseData}
      ''');

      if (!response.isSuccess) {
        EasyLoading.showError(
          response.errorMessage.isNotEmpty
              ? response.errorMessage
              : 'Failed to submit request',
        );
        return;
      }

      EasyLoading.showSuccess(AppStrings.requestSubmittedSuccessfully);

      resetForm();
      if (Get.isBottomSheetOpen ?? false) {
        Get.back();
      }
      await _goToHomeAndRefresh();
    } catch (error) {
      AppLoggerHelper.error('Error submitting request', error);
      EasyLoading.showError('Failed to submit request');
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }

  Future<void> loadServiceAreas() async {
    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      AppLoggerHelper.warning(
        'Service area request missing authorization token',
      );
    }

    isServiceAreaLoading.value = true;
    try {
      final areas = await _serviceAreaApiService.fetchServiceAreas(
        authorization: authorization,
      );
      serviceAreas.assignAll(areas);
    } catch (error) {
      AppLoggerHelper.error('Failed to load service areas', error);
      EasyLoading.showError(AppStrings.serviceAreasLoadError);
    } finally {
      isServiceAreaLoading.value = false;
    }
  }

  String? _buildAuthorizationHeader() {
    final token = StorageService.accessToken;
    if (token == null || token.isEmpty) return null;
    final type = StorageService.tokenType?.trim();
    final prefix = (type != null && type.isNotEmpty) ? type : 'Bearer';
    return '$prefix $token';
  }

  String _formatSurface(String surface) {
    return surface.trim().replaceAll(' ', '_').toUpperCase();
  }

  void _setSelectedAttachment({required File file, required String name}) {
    selectedAttachment.value = file;
    selectedAttachmentName.value = name.trim().isNotEmpty
        ? name.trim()
        : file.path.split('/').last;
  }

  Future<void> _goToHomeAndRefresh() async {
    if (Get.isRegistered<BottomNavbarController>()) {
      final navbarController = Get.find<BottomNavbarController>();
      if (navbarController.userRole.value == 'Customer' &&
          navbarController.currentIndex.value != 0) {
        navbarController.changeTab(0);
      }
    }

    if (Get.isRegistered<CustomarHomeController>()) {
      await Get.find<CustomarHomeController>().refreshCustomerHistory();
    }
  }
}

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:outdoorda_flutter/core/services/storage_service.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/features/admin_section/home/services/admin_create_post_api_service.dart';
import 'package:outdoorda_flutter/features/admin_section/home/services/admin_service_area_api_service.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/models/service_area_model.dart';
import 'package:outdoorda_flutter/features/admin_section/user_management/services/user_management_api_service.dart';

/// Controller for Create New Job Bottom Sheet
/// Manages 4-step form flow with PageView
class CreateNewJobController extends GetxController {
  static const int _installerPageSize = 20;
  static const int _maxSitePhotos = 10;
  static const int _maxAttachedFiles = 5;
  static const List<String> installationSurfaceOptions = <String>[
    'DOOR',
    'WALL',
    'GLASS',
    'OTHER',
  ];

  /// PageController for managing slider navigation
  late PageController pageController;

  final UserManagementApiService _userManagementApiService =
      UserManagementApiService();
  final AdminCreatePostApiService _adminCreatePostApiService =
      AdminCreatePostApiService();
  final AdminServiceAreaApiService _adminServiceAreaApiService =
      AdminServiceAreaApiService();

  /// Current step index (0-3)
  final RxInt currentStep = 0.obs;

  /// Form controllers for Step 1: Customer & Pet Details
  final customerNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final addressLine1Controller = TextEditingController();
  final addressLine2Controller = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final zipCodeController = TextEditingController();
  final countryController = TextEditingController();
  final petNameController = TextEditingController();
  final petTypeController = TextEditingController();
  final petSizeController = TextEditingController();
  final RxList<ServiceAreaModel> serviceAreas = <ServiceAreaModel>[].obs;
  final Rxn<ServiceAreaModel> selectedServiceArea = Rxn<ServiceAreaModel>();
  final RxBool isServiceAreaLoading = false.obs;

  /// Form controllers for Step 2: Pet Door Selection
  final petDoorTypeController = TextEditingController();
  final doorModelController = TextEditingController();
  final installationTypeController = TextEditingController();
  final RxnString selectedInstallationSurface = RxnString();

  /// Form controllers for Step 3: Pricing & Site Photos
  final estimatedPriceController = TextEditingController();
  final jobNotesController = TextEditingController();

  /// Uploaded images list
  final RxList<File> uploadedImages = <File>[].obs;

  /// Uploaded document/file attachments list
  final RxList<File> uploadedFiles = <File>[].obs;

  /// Step 4: Selected installers
  final RxList<InstallerModel> installers = <InstallerModel>[].obs;
  final RxBool isInstallersLoading = false.obs;
  final RxBool isInstallerDropdownExpanded = true.obs;
  final RxBool isSubmittingJob = false.obs;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    _loadServiceAreas();
    _loadInstallers();
    AppLoggerHelper.info('CreateNewJobController initialized');
  }

  @override
  void onClose() {
    pageController.dispose();
    customerNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    zipCodeController.dispose();
    countryController.dispose();
    petNameController.dispose();
    petTypeController.dispose();
    petSizeController.dispose();
    petDoorTypeController.dispose();
    doorModelController.dispose();
    installationTypeController.dispose();
    estimatedPriceController.dispose();
    jobNotesController.dispose();
    super.onClose();
  }

  /// Navigate to next step
  void nextStep() {
    if (currentStep.value < 3) {
      if (_validateCurrentStep()) {
        currentStep.value++;
        pageController.animateToPage(
          currentStep.value,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        AppLoggerHelper.info('Moved to step ${currentStep.value + 1}');
      }
    }
  }

  /// Navigate to previous step
  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
      pageController.animateToPage(
        currentStep.value,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      AppLoggerHelper.info('Moved back to step ${currentStep.value + 1}');
    }
  }

  /// Validate current step fields
  bool _validateCurrentStep() {
    switch (currentStep.value) {
      case 0:
        return _validateStep1();
      case 1:
        return _validateStep2();
      case 2:
        return _validateStep3();
      case 3:
        return true;
      default:
        return false;
    }
  }

  /// Validate Step 1: Customer & Pet Details
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
    if (addressController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter installation address');
      return false;
    }
    if (addressLine1Controller.text.trim().isEmpty) {
      EasyLoading.showError('Please enter address line 1');
      return false;
    }
    if (addressLine2Controller.text.trim().isEmpty) {
      EasyLoading.showError('Please enter address line 2');
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
    if (countryController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter country');
      return false;
    }
    if (selectedServiceArea.value == null) {
      EasyLoading.showError(AppStrings.pleaseSelectServiceArea);
      return false;
    }
    if (petNameController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter pet name');
      return false;
    }
    if (petTypeController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter pet type');
      return false;
    }
    if (petSizeController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter pet size');
      return false;
    }
    return true;
  }

  /// Validate Step 2: Pet Door Selection
  bool _validateStep2() {
    if (petDoorTypeController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter pet door type');
      return false;
    }
    if (doorModelController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter door model');
      return false;
    }
    if (selectedInstallationSurface.value == null) {
      EasyLoading.showError('Please select installation surface');
      return false;
    }
    return true;
  }

  void setInstallationSurface(String? value) {
    selectedInstallationSurface.value = value;
    installationTypeController.text = value ?? '';
  }

  void selectServiceArea(ServiceAreaModel? area) {
    selectedServiceArea.value = area;
    AppLoggerHelper.debug('Selected admin job service area: ${area?.name}');
  }

  /// Validate Step 3: Pricing & Site Photos
  bool _validateStep3() {
    if (estimatedPriceController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter estimated labor price');
      return false;
    }
    if (uploadedImages.isEmpty && uploadedFiles.isEmpty) {
      EasyLoading.showError('Please upload at least one site photo or file');
      return false;
    }
    return true;
  }

  /// Toggle installer dropdown expanded state
  void toggleInstallerDropdown() {
    isInstallerDropdownExpanded.value = !isInstallerDropdownExpanded.value;
  }

  /// Toggle installer selection
  void toggleInstallerSelection(int index) {
    installers[index].isSelected = !installers[index].isSelected;
    installers.refresh();
    AppLoggerHelper.info(
      'Installer ${installers[index].name} selection: ${installers[index].isSelected}',
    );
  }

  /// Upload site photo
  Future<void> uploadPhoto() async {
    final source = await Get.bottomSheet<_CreateJobAttachmentSource>(
      SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Camera'),
                onTap: () =>
                    Get.back(result: _CreateJobAttachmentSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Gallery'),
                onTap: () =>
                    Get.back(result: _CreateJobAttachmentSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.attach_file_outlined),
                title: const Text('File'),
                onTap: () => Get.back(result: _CreateJobAttachmentSource.file),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );

    if (source == null) return;

    try {
      switch (source) {
        case _CreateJobAttachmentSource.camera:
          await _pickCameraPhoto();
          break;
        case _CreateJobAttachmentSource.gallery:
          await _pickGalleryPhotos();
          break;
        case _CreateJobAttachmentSource.file:
          await _pickFiles();
          break;
      }
    } catch (error) {
      AppLoggerHelper.error('Upload attachment error: $error', error);
      EasyLoading.showError('Failed to upload attachment');
    }
  }

  void removeUploadedImage(int index) {
    if (index < 0 || index >= uploadedImages.length) return;
    uploadedImages.removeAt(index);
    AppLoggerHelper.info('Create job photo removed: index=$index');
  }

  void removeUploadedFile(int index) {
    if (index < 0 || index >= uploadedFiles.length) return;
    uploadedFiles.removeAt(index);
    AppLoggerHelper.info('Create job file removed: index=$index');
  }

  Future<void> _pickCameraPhoto() async {
    if (!_canAddMorePhotos()) return;

    final captured = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (captured == null) return;

    uploadedImages.add(File(captured.path));
    EasyLoading.showSuccess('1 photo uploaded');
    AppLoggerHelper.info(
      'Create job camera photo selected: total=${uploadedImages.length}',
    );
  }

  Future<void> _pickGalleryPhotos() async {
    if (!_canAddMorePhotos()) return;

    final remaining = _maxSitePhotos - uploadedImages.length;
    final selected = await ImagePicker().pickMultiImage(imageQuality: 85);
    if (selected.isEmpty) return;

    final toAdd = selected.take(remaining).map((item) => File(item.path));
    uploadedImages.addAll(toAdd);

    if (selected.length > remaining) {
      EasyLoading.showInfo('Only $remaining photos were added (max 10)');
    } else {
      EasyLoading.showSuccess('${selected.length} photo(s) uploaded');
    }

    AppLoggerHelper.info(
      'Create job gallery photos selected: total=${uploadedImages.length}',
    );
  }

  Future<void> _pickFiles() async {
    final remaining = _maxAttachedFiles - uploadedFiles.length;
    if (remaining <= 0) {
      EasyLoading.showInfo('Maximum $_maxAttachedFiles files allowed');
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: false,
      type: FileType.any,
    );
    if (result == null || result.files.isEmpty) return;

    final selected = result.files
        .where((file) => file.path != null && file.path!.trim().isNotEmpty)
        .take(remaining)
        .map((file) => File(file.path!))
        .toList();

    if (selected.isEmpty) {
      EasyLoading.showError('Selected file path is unavailable');
      return;
    }

    uploadedFiles.addAll(selected);

    if (result.files.length > remaining) {
      EasyLoading.showInfo('Only $remaining files were added (max 5)');
    } else {
      EasyLoading.showSuccess('${selected.length} file(s) uploaded');
    }

    AppLoggerHelper.info(
      'Create job files selected: total=${uploadedFiles.length}',
    );
  }

  bool _canAddMorePhotos() {
    if (uploadedImages.length >= _maxSitePhotos) {
      EasyLoading.showInfo('Maximum $_maxSitePhotos photos allowed');
      return false;
    }
    return true;
  }

  /// Submit job creation
  Future<void> submitJob() async {
    try {
      final selectedInstallerIds = installers
          .where((installer) => installer.isSelected)
          .map((e) => e.id)
          .toList();

      if (selectedInstallerIds.isEmpty) {
        EasyLoading.showError('Please select at least one installer');
        return;
      }

      if (uploadedImages.isEmpty && uploadedFiles.isEmpty) {
        EasyLoading.showError('Please upload at least one site photo or file');
        return;
      }
      if (selectedInstallationSurface.value == null) {
        EasyLoading.showError('Please select installation surface');
        return;
      }
      final selectedArea = selectedServiceArea.value;
      if (selectedArea == null) {
        EasyLoading.showError(AppStrings.pleaseSelectServiceArea);
        return;
      }

      final authorization = _buildAuthorizationHeader();
      if (authorization == null) {
        EasyLoading.showError('Authorization missing. Please log in again.');
        return;
      }

      isSubmittingJob.value = true;
      EasyLoading.show(status: 'Creating job...');

      final response = await _adminCreatePostApiService.createPost(
        authorization: authorization,
        size: petSizeController.text.trim(),
        photos: uploadedImages.toList(),
        attachments: uploadedFiles.toList(),
        custPhone: phoneController.text.trim(),
        installationSurface: selectedInstallationSurface.value!,
        price: estimatedPriceController.text.trim(),
        serviceAreaId: selectedArea.id,
        jobNotes: jobNotesController.text.trim(),
        petName: petNameController.text.trim(),
        custIds: selectedInstallerIds.join(','),
        custEmail: emailController.text.trim(),
        address: addressController.text.trim(),
        addressLine1: addressLine1Controller.text.trim(),
        addressLine2: addressLine2Controller.text.trim(),
        city: cityController.text.trim(),
        state: stateController.text.trim(),
        zipCode: zipCodeController.text.trim(),
        country: countryController.text.trim(),
        custName: customerNameController.text.trim(),
        petType: petTypeController.text.trim(),
      );

      if (!response.isSuccess) {
        EasyLoading.showError(
          response.errorMessage.isNotEmpty
              ? response.errorMessage
              : 'Failed to create job',
        );
        return;
      }

      AppLoggerHelper.info('Job created successfully via admin posts-admin');
      EasyLoading.showSuccess('Job created successfully!');
      _clearForm();
      Get.back(result: true);
    } catch (error) {
      AppLoggerHelper.error('Submit job error: $error', error);
      EasyLoading.showError('Failed to create job');
    } finally {
      isSubmittingJob.value = false;
      EasyLoading.dismiss();
    }
  }

  /// Clear form data
  void _clearForm() {
    customerNameController.clear();
    emailController.clear();
    phoneController.clear();
    addressController.clear();
    addressLine1Controller.clear();
    addressLine2Controller.clear();
    cityController.clear();
    stateController.clear();
    zipCodeController.clear();
    countryController.clear();
    selectedServiceArea.value = null;
    petNameController.clear();
    petTypeController.clear();
    petSizeController.clear();
    petDoorTypeController.clear();
    doorModelController.clear();
    installationTypeController.clear();
    selectedInstallationSurface.value = null;
    estimatedPriceController.clear();
    jobNotesController.clear();
    uploadedImages.clear();
    uploadedFiles.clear();
    currentStep.value = 0;

    for (final installer in installers) {
      installer.isSelected = false;
    }
    installers.refresh();
  }

  Future<void> _loadServiceAreas() async {
    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      serviceAreas.clear();
      return;
    }

    try {
      isServiceAreaLoading.value = true;
      final areas = await _adminServiceAreaApiService.fetchServiceAreas(
        authorization: authorization,
      );
      serviceAreas.assignAll(areas);
      AppLoggerHelper.info(
        'Loaded service areas for create job: ${serviceAreas.length}',
      );
    } catch (error) {
      AppLoggerHelper.error(
        'Failed to load service areas for create job',
        error,
      );
      EasyLoading.showError(AppStrings.serviceAreasLoadError);
    } finally {
      isServiceAreaLoading.value = false;
    }
  }

  Future<void> _loadInstallers() async {
    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      EasyLoading.showError('Authorization missing. Please log in again.');
      return;
    }

    try {
      isInstallersLoading.value = true;
      installers.clear();

      var offset = 0;
      var keepLoading = true;

      while (keepLoading) {
        final page = await _userManagementApiService.fetchUsers(
          authorization: authorization,
          offset: offset,
          limit: _installerPageSize,
        );

        final installerUsers = page.results
            .where((u) => u.userType == 'installer')
            .toList();

        for (final user in installerUsers) {
          final exists = installers.any((i) => i.id == user.id);
          if (!exists) {
            installers.add(
              InstallerModel(
                id: user.id,
                name: user.name,
                location: user.address,
                isSelected: false,
              ),
            );
          }
        }

        offset = page.offset + page.count;
        keepLoading = page.count > 0 && offset < page.total;
      }

      AppLoggerHelper.info(
        'Loaded installers for create job: ${installers.length}',
      );
    } catch (error) {
      AppLoggerHelper.error('Failed to load installers for create job', error);
      EasyLoading.showError('Failed to load installer list');
    } finally {
      isInstallersLoading.value = false;
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

enum _CreateJobAttachmentSource { camera, gallery, file }

/// Model for installer data
class InstallerModel {
  final String id;
  final String name;
  final String location;
  bool isSelected;

  InstallerModel({
    required this.id,
    required this.name,
    required this.location,
    required this.isSelected,
  });
}

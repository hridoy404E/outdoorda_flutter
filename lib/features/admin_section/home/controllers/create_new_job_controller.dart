import 'dart:convert';
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
  final Rxn<ServiceAreaModel> selectedStep4ServiceArea = Rxn<ServiceAreaModel>();
  final RxBool isServiceAreaLoading = false.obs;

  /// Form controllers for Step 2: Pet Door Selection
  final RxnString selectedInstallationSurface = RxnString();

  /// Form controllers for Step 3: Pricing & Site Photos
  final estimatedPriceController = TextEditingController();

  /// Uploaded images list
  final RxList<File> uploadedImages = <File>[].obs;

  /// Uploaded document/file attachments list
  final RxList<File> uploadedFiles = <File>[].obs;

  /// Step 4: Selected installers
  final RxList<InstallerModel> installers = <InstallerModel>[].obs;
  final RxBool isInstallersLoading = false.obs;
  final RxBool isInstallerDropdownExpanded = true.obs;
  final RxBool isSubmittingJob = false.obs;

  /// Draft state — IDs to re-select after async list loads.
  String? _draftServiceAreaId;
  List<String> _draftInstallerIds = [];
  bool _jobSubmittedSuccessfully = false;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    countryController.text = 'USA';
    _restoreDraft();
    _loadServiceAreas();
    _loadInstallers();
    AppLoggerHelper.info('CreateNewJobController initialized');
  }

  @override
  void onClose() {
    // Only save draft if the job was NOT just submitted successfully.
    if (!_jobSubmittedSuccessfully) {
      _saveDraft();
    }
    pageController.dispose();
    customerNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    zipCodeController.dispose();
    countryController.dispose();
    petNameController.dispose();
    petTypeController.dispose();
    petSizeController.dispose();
    estimatedPriceController.dispose();
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
    if (selectedInstallationSurface.value == null) {
      EasyLoading.showError('Please select installation surface');
      return false;
    }
    return true;
  }

  void setInstallationSurface(String? value) {
    selectedInstallationSurface.value = value;
  }

  void selectServiceArea(ServiceAreaModel? area) {
    selectedServiceArea.value = area;
    selectedStep4ServiceArea.value = area;
    loadInstallersForServiceArea(area?.id);
    AppLoggerHelper.debug('Selected admin job service area: ${area?.name}');
  }

  void selectStep4ServiceArea(ServiceAreaModel? area) {
    selectedStep4ServiceArea.value = area;
    if (area != null) {
      selectedServiceArea.value = area;
    }
    loadInstallersForServiceArea(area?.id);
    AppLoggerHelper.debug('Selected step 4 service area: ${area?.name}');
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

  /// Whether all loaded installers are selected
  bool get isAllInstallersSelected {
    if (installers.isEmpty) return false;
    return installers.every((i) => i.isSelected);
  }

  /// Toggle selection of all installers
  void toggleSelectAllInstallers() {
    final newValue = !isAllInstallersSelected;
    for (final installer in installers) {
      installer.isSelected = newValue;
    }
    installers.refresh();
    AppLoggerHelper.info('Toggled select all installers: $newValue');
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

      final String custIdsString;
      if (selectedInstallerIds.isEmpty) {
        custIdsString = "all";
      } else {
        custIdsString = jsonEncode(selectedInstallerIds);
      }

      if (uploadedImages.isEmpty && uploadedFiles.isEmpty) {
        EasyLoading.showError('Please upload at least one site photo or file');
        return;
      }
      if (selectedInstallationSurface.value == null) {
        EasyLoading.showError('Please select installation surface');
        return;
      }
      final selectedArea = selectedServiceArea.value ?? selectedStep4ServiceArea.value;
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
        petName: petNameController.text.trim(),
        custIds: custIdsString,
        custEmail: emailController.text.trim(),
        addressLine1: addressLine1Controller.text.trim(),
        addressLine2: addressLine2Controller.text.trim(),
        city: cityController.text.trim(),
        state: stateController.text.trim(),
        zipCode: zipCodeController.text.trim(),
        country: 'USA',
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
      _jobSubmittedSuccessfully = true;
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

  /// Clear form data and remove persisted draft.
  void _clearForm() {
    customerNameController.clear();
    emailController.clear();
    phoneController.clear();
    addressLine1Controller.clear();
    addressLine2Controller.clear();
    cityController.clear();
    stateController.clear();
    zipCodeController.clear();
    countryController.text = 'USA';
    selectedServiceArea.value = null;
    petNameController.clear();
    petTypeController.clear();
    petSizeController.clear();
    selectedInstallationSurface.value = null;
    estimatedPriceController.clear();
    uploadedImages.clear();
    uploadedFiles.clear();
    currentStep.value = 0;

    for (final installer in installers) {
      installer.isSelected = false;
    }
    installers.refresh();

    // Remove persisted draft from local storage.
    StorageService.clearJobDraft();
    _draftServiceAreaId = null;
    _draftInstallerIds = [];
    AppLoggerHelper.info('Job draft cleared');
  }

  // ── Draft Persistence ───────────────────────────────────────────────────

  /// Serialize current form state to JSON and persist to local storage.
  void _saveDraft() {
    // Don't save if the form is completely empty.
    if (!_hasDraftData) {
      StorageService.clearJobDraft();
      return;
    }

    final draft = <String, dynamic>{
      'currentStep': currentStep.value,
      'customerName': customerNameController.text,
      'email': emailController.text,
      'phone': phoneController.text,
      'addressLine1': addressLine1Controller.text,
      'addressLine2': addressLine2Controller.text,
      'city': cityController.text,
      'state': stateController.text,
      'zipCode': zipCodeController.text,
      'country': countryController.text,
      'petName': petNameController.text,
      'petType': petTypeController.text,
      'petSize': petSizeController.text,
      'serviceAreaId': selectedServiceArea.value?.id,
      'installationSurface': selectedInstallationSurface.value,
      'estimatedPrice': estimatedPriceController.text,
      'selectedInstallerIds': installers
          .where((i) => i.isSelected)
          .map((i) => i.id)
          .toList(),
    };

    try {
      StorageService.saveJobDraft(jsonEncode(draft));
      AppLoggerHelper.info('Job draft saved');
    } catch (e) {
      AppLoggerHelper.error('Failed to save job draft', e);
    }
  }

  /// Restore form state from a previously persisted draft.
  void _restoreDraft() {
    final jsonString = StorageService.getJobDraft();
    if (jsonString == null || jsonString.isEmpty) return;

    try {
      final draft = jsonDecode(jsonString) as Map<String, dynamic>;

      customerNameController.text = draft['customerName'] as String? ?? '';
      emailController.text = draft['email'] as String? ?? '';
      phoneController.text = draft['phone'] as String? ?? '';
      addressLine1Controller.text = draft['addressLine1'] as String? ?? '';
      addressLine2Controller.text = draft['addressLine2'] as String? ?? '';
      cityController.text = draft['city'] as String? ?? '';
      stateController.text = draft['state'] as String? ?? '';
      zipCodeController.text = draft['zipCode'] as String? ?? '';
      countryController.text = draft['country'] as String? ?? 'USA';
      petNameController.text = draft['petName'] as String? ?? '';
      petTypeController.text = draft['petType'] as String? ?? '';
      petSizeController.text = draft['petSize'] as String? ?? '';
      estimatedPriceController.text =
          draft['estimatedPrice'] as String? ?? '';

      selectedInstallationSurface.value =
          draft['installationSurface'] as String?;

      // Store IDs to re-select after async loads complete.
      final areaId = draft['serviceAreaId'];
      _draftServiceAreaId = areaId?.toString();

      final ids = draft['selectedInstallerIds'];
      if (ids is List) {
        _draftInstallerIds = ids.map((e) => e.toString()).toList();
      }

      // Restore step index (jump to the page the user was on).
      final step = draft['currentStep'] as int? ?? 0;
      currentStep.value = step;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (pageController.hasClients && step > 0) {
          pageController.jumpToPage(step);
        }
      });

      AppLoggerHelper.info('Job draft restored');
      EasyLoading.showInfo('Draft restored');
    } catch (e) {
      AppLoggerHelper.error('Failed to restore job draft', e);
      // If the draft is corrupted, remove it so it doesn't block future use.
      StorageService.clearJobDraft();
    }
  }

  /// Returns true if any text field contains non-empty user data.
  bool get _hasDraftData {
    return customerNameController.text.trim().isNotEmpty ||
        emailController.text.trim().isNotEmpty ||
        phoneController.text.trim().isNotEmpty ||
        addressLine1Controller.text.trim().isNotEmpty ||
        addressLine2Controller.text.trim().isNotEmpty ||
        cityController.text.trim().isNotEmpty ||
        stateController.text.trim().isNotEmpty ||
        zipCodeController.text.trim().isNotEmpty ||
        petNameController.text.trim().isNotEmpty ||
        petTypeController.text.trim().isNotEmpty ||
        petSizeController.text.trim().isNotEmpty ||
        estimatedPriceController.text.trim().isNotEmpty ||
        selectedInstallationSurface.value != null ||
        selectedServiceArea.value != null;
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

      // Re-select the service area from draft if available.
      if (_draftServiceAreaId != null) {
        final match = serviceAreas.firstWhereOrNull(
          (a) => a.id.toString() == _draftServiceAreaId,
        );
        if (match != null) {
          selectedServiceArea.value = match;
          selectedStep4ServiceArea.value = match;
          await loadInstallersForServiceArea(match.id);
        }
        _draftServiceAreaId = null;
      }
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
    await loadInstallersForServiceArea(selectedStep4ServiceArea.value?.id ?? selectedServiceArea.value?.id);
  }

  Future<void> loadInstallersForServiceArea(dynamic serviceAreaId) async {
    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      EasyLoading.showError('Authorization missing. Please log in again.');
      return;
    }

    try {
      isInstallersLoading.value = true;
      installers.clear();

      final apiInstallers =
          await _adminServiceAreaApiService.fetchInstallersByServiceArea(
        authorization: authorization,
        serviceAreaId: serviceAreaId,
      );

      if (apiInstallers.isNotEmpty) {
        for (final item in apiInstallers) {
          final model = _parseInstallerJson(item);
          if (!installers.any((i) => i.id == model.id)) {
            installers.add(model);
          }
        }
      } else {
        // Fallback to fetchUsers if /admin/installers/ returns empty or fails
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
            if (!installers.any((i) => i.id == user.id)) {
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
      }

      AppLoggerHelper.info(
        'Loaded installers for create job (serviceAreaId=$serviceAreaId): ${installers.length}',
      );

      // Re-select installers from draft if available.
      if (_draftInstallerIds.isNotEmpty) {
        for (final installer in installers) {
          if (_draftInstallerIds.contains(installer.id)) {
            installer.isSelected = true;
          }
        }
        installers.refresh();
        _draftInstallerIds = [];
      }
    } catch (error) {
      AppLoggerHelper.error('Failed to load installers for create job', error);
      EasyLoading.showError('Failed to load installer list');
    } finally {
      isInstallersLoading.value = false;
    }
  }

  InstallerModel _parseInstallerJson(Map<String, dynamic> item) {
    final id = item['id']?.toString() ??
        item['user_id']?.toString() ??
        item['installer_id']?.toString() ??
        item['inst_id']?.toString() ??
        '';

    String name = '';
    if (item['name'] != null && item['name'].toString().trim().isNotEmpty) {
      name = item['name'].toString().trim();
    } else if (item['full_name'] != null && item['full_name'].toString().trim().isNotEmpty) {
      name = item['full_name'].toString().trim();
    } else if (item['user'] is Map<String, dynamic>) {
      final u = item['user'] as Map<String, dynamic>;
      name = u['name']?.toString() ?? u['full_name']?.toString() ?? '';
    } else if (item['first_name'] != null) {
      name = '${item['first_name']} ${item['last_name'] ?? ''}'.trim();
    }
    if (name.isEmpty) name = 'Installer ($id)';

    String location = '';
    if (item['phone'] != null && item['phone'].toString().trim().isNotEmpty) {
      location = item['phone'].toString().trim();
    } else if (item['phone_number'] != null &&
        item['phone_number'].toString().trim().isNotEmpty) {
      location = item['phone_number'].toString().trim();
    } else if (item['cust_phone'] != null &&
        item['cust_phone'].toString().trim().isNotEmpty) {
      location = item['cust_phone'].toString().trim();
    } else if (item['mobile'] != null &&
        item['mobile'].toString().trim().isNotEmpty) {
      location = item['mobile'].toString().trim();
    } else if (item['user'] is Map<String, dynamic>) {
      final u = item['user'] as Map<String, dynamic>;
      location = u['phone']?.toString() ??
          u['phone_number']?.toString() ??
          u['email']?.toString() ??
          '';
    } else if (item['email'] != null &&
        item['email'].toString().trim().isNotEmpty) {
      location = item['email'].toString().trim();
    } else if (item['location'] != null &&
        item['location'].toString().trim().isNotEmpty) {
      location = item['location'].toString().trim();
    } else if (item['address'] != null &&
        item['address'].toString().trim().isNotEmpty) {
      location = item['address'].toString().trim();
    } else if (item['city'] != null) {
      location = '${item['city']}, ${item['state'] ?? ''}'.trim();
    } else if (item['service_area'] is Map<String, dynamic>) {
      location =
          (item['service_area'] as Map<String, dynamic>)['name']?.toString() ??
              '';
    }
    if (location.isEmpty) location = id.isNotEmpty ? 'ID: $id' : '';

    return InstallerModel(
      id: id,
      name: name,
      location: location,
      isSelected: false,
    );
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

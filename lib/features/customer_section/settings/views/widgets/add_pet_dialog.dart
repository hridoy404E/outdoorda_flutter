import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_button.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_text_field.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/core/utils/validators/app_validator.dart';
import 'package:outdoorda_flutter/features/customer_section/settings/controllers/customar_setting_controller.dart';
import 'package:outdoorda_flutter/features/customer_section/settings/models/pet_model.dart';

/// Add/Edit Pet Dialog
/// Shows a dialog to add a new pet or edit existing pet
/// Matches the design from the provided image
class AddPetDialog extends StatefulWidget {
  const AddPetDialog({super.key, this.pet});

  final Pet? pet;

  @override
  State<AddPetDialog> createState() => _AddPetDialogState();
}

class _AddPetDialogState extends State<AddPetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();

  String? _selectedType;
  String? _selectedSize;

  @override
  void initState() {
    super.initState();
    if (widget.pet != null) {
      _nameController.text = widget.pet!.name;
      _breedController.text = widget.pet!.breed ?? '';
      _selectedType = widget.pet!.type;
      _selectedSize = widget.pet!.size;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CustomerSettingController>();

    return Dialog(
      backgroundColor: AppColors.bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Container(
        constraints: BoxConstraints(maxHeight: 420.h),
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title
            Text(
              widget.pet == null ? AppStrings.myPets : 'Edit Pet',
              style: figtreeTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.settingsTextTitle,
              ),
            ),
            SizedBox(height: 24.h),

            /// Form
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Pet Name Field
                      CustomTextField(
                        label: AppStrings.petNameLabel,
                        placeholder: AppStrings.petNamePlaceholder,
                        controller: _nameController,
                        validator: (value) =>
                            AppValidator.validateRequired(value, 'Pet name'),
                      ),
                      SizedBox(height: 20.h),

                      /// Type and Size Row
                      Row(
                        children: [
                          /// Type Field
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.type,
                                  style: interTextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.neutral800,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                _buildDropdown(
                                  value: _selectedType,
                                  items: controller.petTypes,
                                  hint: AppStrings.petTypePlaceholder,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedType = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16.w),

                          /// Size Field
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.size,
                                  style: interTextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.neutral800,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                _buildDropdown(
                                  value: _selectedSize,
                                  items: controller.petSizes,
                                  hint: AppStrings.petSizePlaceholder,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedSize = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),

                      /// Breed Field (Optional)
                      CustomTextField(
                        label: AppStrings.breed,
                        placeholder: AppStrings.breedPlaceholder,
                        controller: _breedController,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 24.h),

            /// Add Button
            Obx(
              () => CustomButton(
                text: widget.pet == null
                    ? AppStrings.addNewPet
                    : AppStrings.savePet,
                onPressed: _handleSubmit,
                isLoading: controller.isLoading.value,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build dropdown field
  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: AppColors.neutral25,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint,
            style: interTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.neutral700,
            ),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: interTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.neutral700,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.neutral700,
            size: 20.r,
          ),
        ),
      ),
    );
  }

  /// Handle form submission
  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedType == null) {
      Get.snackbar('Error', 'Please select pet type');
      return;
    }

    if (_selectedSize == null) {
      Get.snackbar('Error', 'Please select pet size');
      return;
    }

    final controller = Get.find<CustomerSettingController>();

    if (widget.pet == null) {
      /// Add new pet
      controller.addPet(
        name: _nameController.text.trim(),
        type: _selectedType!,
        size: _selectedSize!,
        breed: _breedController.text.trim(),
      );
    } else {
      /// Update existing pet
      controller.updatePet(
        petId: widget.pet!.id,
        name: _nameController.text.trim(),
        type: _selectedType!,
        size: _selectedSize!,
        breed: _breedController.text.trim(),
      );
    }
  }
}

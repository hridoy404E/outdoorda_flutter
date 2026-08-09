import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/features/admin_section/job_management/controllers/job_management_details_controller.dart';
import 'package:outdoorda_flutter/features/admin_section/job_management/models/admin_job.dart';

class UpdateJobBottomSheet extends StatefulWidget {
  final AdminJob job;
  final JobManagementDetailsController controller;

  const UpdateJobBottomSheet({
    super.key,
    required this.job,
    required this.controller,
  });

  @override
  State<UpdateJobBottomSheet> createState() => _UpdateJobBottomSheetState();
}

class _UpdateJobBottomSheetState extends State<UpdateJobBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _petNameController;
  late TextEditingController _petTypeController;
  late TextEditingController _priceController;
  late TextEditingController _sizeController;
  late TextEditingController _surfaceController;
  late TextEditingController _address1Controller;
  late TextEditingController _address2Controller;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipCodeController;
  late TextEditingController _countryController;
  late TextEditingController _noteController;
  late TextEditingController _custNameController;
  late TextEditingController _custEmailController;
  late TextEditingController _custPhoneController;
  late TextEditingController _additionalNoteController;
  late TextEditingController _satisfactionNoteController;

  late String _selectedStatus;
  DateTime? _scheduledDate;
  bool _isAdditionalService = false;
  bool _isCustomerSatisfied = false;

  final List<String> _statusOptions = [
    'pending',
    'receiving_bids',
    'assigned',
    'in_progress',
    'completed',
  ];

  @override
  void initState() {
    super.initState();
    final job = widget.job;
    _petNameController = TextEditingController(text: job.petName);
    _petTypeController = TextEditingController(text: job.petType);
    _priceController = TextEditingController(text: job.price.toStringAsFixed(2));
    _sizeController = TextEditingController(text: job.petSize);
    _surfaceController = TextEditingController(text: job.installationType);
    _address1Controller = TextEditingController(text: job.addressLine1);
    _address2Controller = TextEditingController(text: job.addressLine2);
    _cityController = TextEditingController(text: job.city);
    _stateController = TextEditingController(text: job.state);
    _zipCodeController = TextEditingController(text: job.zipCode);
    _countryController = TextEditingController(text: job.country);
    _noteController = TextEditingController(text: job.jobNotes);
    _custNameController = TextEditingController(text: job.customerName);
    _custEmailController = TextEditingController();
    _custPhoneController = TextEditingController();
    _additionalNoteController = TextEditingController(text: job.additionalWorkDescription ?? '');
    _satisfactionNoteController = TextEditingController(text: job.customerFeedback ?? '');

    _selectedStatus = _statusOptions.contains(job.status.displayName.toLowerCase().replaceAll(' ', '_'))
        ? job.status.displayName.toLowerCase().replaceAll(' ', '_')
        : 'pending';
    _scheduledDate = job.scheduledDate;
    _isAdditionalService = job.additionalWorkPerformed ?? false;
    _isCustomerSatisfied = job.customerSatisfied ?? false;
  }

  @override
  void dispose() {
    _petNameController.dispose();
    _petTypeController.dispose();
    _priceController.dispose();
    _sizeController.dispose();
    _surfaceController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    _noteController.dispose();
    _custNameController.dispose();
    _custEmailController.dispose();
    _custPhoneController.dispose();
    _additionalNoteController.dispose();
    _satisfactionNoteController.dispose();
    super.dispose();
  }

  Future<void> _selectScheduledDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _scheduledDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledDate ?? DateTime.now()),
    );
    if (!mounted) return;

    setState(() {
      _scheduledDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime?.hour ?? 0,
        pickedTime?.minute ?? 0,
      );
    });
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final fields = <String, String>{
      'pet_name': _petNameController.text.trim(),
      'pet_type': _petTypeController.text.trim(),
      'price': _priceController.text.trim(),
      'size': _sizeController.text.trim(),
      'installation_surface': _surfaceController.text.trim(),
      'address_line_1': _address1Controller.text.trim(),
      'address_line_2': _address2Controller.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'zip_code': _zipCodeController.text.trim(),
      'country': _countryController.text.trim(),
      'note': _noteController.text.trim(),
      'new_status': _selectedStatus,
      'is_additional_service': _isAdditionalService.toString(),
      'additional_service_note': _additionalNoteController.text.trim(),
      'is_customer_satisfied': _isCustomerSatisfied.toString(),
      'customer_satisfaction_note': _satisfactionNoteController.text.trim(),
      'cust_name': _custNameController.text.trim(),
      'cust_email': _custEmailController.text.trim(),
      'cust_phone': _custPhoneController.text.trim(),
    };

    if (_scheduledDate != null) {
      fields['scheduled_date'] = _scheduledDate!.toUtc().toIso8601String();
    }

    final success = await widget.controller.updateRecentJob(fields: fields);
    if (success) {
      widget.controller.reloadJobData();
      Get.back(result: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Update Job Details',
                    style: figtreeTextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2B4554),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const Divider(),
              SizedBox(height: 12.h),

              // Status Dropdown
              _buildSectionTitle('Job Status'),
              DropdownButtonFormField<String>(
                initialValue: _statusOptions.contains(_selectedStatus) ? _selectedStatus : _statusOptions.first,
                decoration: _inputDecoration('Status'),
                items: _statusOptions
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.replaceAll('_', ' ').toUpperCase()),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedStatus = val);
                },
              ),
              SizedBox(height: 16.h),

              // Pricing & Surface
              _buildSectionTitle('Job & Product Info'),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField('Price', _priceController, keyboardType: TextInputType.number),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildTextField('Size', _sizeController),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              _buildTextField('Installation Surface', _surfaceController),
              SizedBox(height: 16.h),

              // Pet Info
              _buildSectionTitle('Pet Details'),
              Row(
                children: [
                  Expanded(child: _buildTextField('Pet Name', _petNameController)),
                  SizedBox(width: 12.w),
                  Expanded(child: _buildTextField('Pet Type', _petTypeController)),
                ],
              ),
              SizedBox(height: 16.h),

              // Customer Info
              _buildSectionTitle('Customer Details'),
              _buildTextField('Customer Name', _custNameController),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(child: _buildTextField('Email', _custEmailController, keyboardType: TextInputType.emailAddress)),
                  SizedBox(width: 12.w),
                  Expanded(child: _buildTextField('Phone', _custPhoneController, keyboardType: TextInputType.phone)),
                ],
              ),
              SizedBox(height: 16.h),

              // Address Info
              _buildSectionTitle('Address'),
              _buildTextField('Address Line 1', _address1Controller),
              SizedBox(height: 12.h),
              _buildTextField('Address Line 2', _address2Controller),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(child: _buildTextField('City', _cityController)),
                  SizedBox(width: 12.w),
                  Expanded(child: _buildTextField('State', _stateController)),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(child: _buildTextField('Zip Code', _zipCodeController)),
                  SizedBox(width: 12.w),
                  Expanded(child: _buildTextField('Country', _countryController)),
                ],
              ),
              SizedBox(height: 16.h),

              // Scheduled Date & Notes
              _buildSectionTitle('Schedule & Notes'),
              InkWell(
                onTap: _selectScheduledDate,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFC2CCD3)),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _scheduledDate == null
                            ? 'Select Scheduled Date'
                            : DateFormat('yyyy-MM-dd HH:mm').format(_scheduledDate!),
                        style: figtreeTextStyle(fontSize: 14.sp, color: Colors.black87),
                      ),
                      const Icon(Icons.calendar_today, size: 20),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              _buildTextField('Job Notes', _noteController, maxLines: 3),
              SizedBox(height: 16.h),

              // Switches & Additional Notes
              _buildSectionTitle('Additional Services & Satisfaction'),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Additional Service Offered', style: figtreeTextStyle(fontSize: 14.sp)),
                value: _isAdditionalService,
                onChanged: (val) => setState(() => _isAdditionalService = val),
              ),
              if (_isAdditionalService) ...[
                _buildTextField('Additional Service Note', _additionalNoteController),
                SizedBox(height: 12.h),
              ],

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Customer Satisfied', style: figtreeTextStyle(fontSize: 14.sp)),
                value: _isCustomerSatisfied,
                onChanged: (val) => setState(() => _isCustomerSatisfied = val),
              ),
              if (_isCustomerSatisfied) ...[
                _buildTextField('Satisfaction Note', _satisfactionNoteController),
                SizedBox(height: 12.h),
              ],

              SizedBox(height: 24.h),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B4554),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Save Changes',
                    style: figtreeTextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        title,
        style: figtreeTextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2B4554),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: _inputDecoration(label),
      style: figtreeTextStyle(fontSize: 14.sp, color: Colors.black87),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: figtreeTextStyle(fontSize: 13.sp, color: const Color(0xFF7A8B99)),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFFC2CCD3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFFC2CCD3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFF2B4554)),
      ),
    );
  }
}

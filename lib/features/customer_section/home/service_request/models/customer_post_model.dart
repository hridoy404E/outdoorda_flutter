class CustomerPostModel {
  final String id;
  final String petName;
  final String petType;
  final String? size;
  final List<String> photos;
  final String address;
  final double? price;
  final String status;
  final String? installerId;
  final String? installationSurface;
  final String? createdAt;
  final String? updatedAt;
  final String? scheduledDate;
  final String? note;
  final String? additionalServiceNote;
  final String? customerSatisfactionNote;
  final int? areaId;
  final bool? isAdditionalService;
  final bool? isCustomerSatisfied;

  const CustomerPostModel({
    required this.id,
    required this.petName,
    required this.petType,
    this.size,
    required this.photos,
    required this.address,
    this.price,
    required this.status,
    this.installerId,
    this.installationSurface,
    this.createdAt,
    this.updatedAt,
    this.scheduledDate,
    this.note,
    this.additionalServiceNote,
    this.customerSatisfactionNote,
    this.areaId,
    this.isAdditionalService,
    this.isCustomerSatisfied,
  });

  factory CustomerPostModel.fromJson(Map<String, dynamic> json) {
    return CustomerPostModel(
      id: json['id']?.toString() ?? '',
      petName: json['pet_name']?.toString() ?? '',
      petType: json['pet_type']?.toString() ?? '',
      size: json['size']?.toString(),
      photos: (json['photos'] as List?)?.whereType<String>().toList() ?? [],
      address: json['Address']?.toString() ?? json['address']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble(),
      status: json['status']?.toString() ?? '',
      installerId: json['installer_id']?.toString(),
      installationSurface: json['installation_surface']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      scheduledDate: json['scheduled_date']?.toString(),
      note: json['note']?.toString(),
      additionalServiceNote: json['additional_service_note']?.toString(),
      customerSatisfactionNote: json['customer_satisfaction_note']?.toString(),
      areaId: json['area_id'] is int
          ? json['area_id'] as int
          : int.tryParse(json['area_id']?.toString() ?? ''),
      isAdditionalService: _toBool(json['is_additional_service']),
      isCustomerSatisfied: _toBool(json['is_customer_satisfied']),
    );
  }

  static bool? _toBool(dynamic value) {
    if (value is bool) return value;
    if (value == null) return null;
    final text = value.toString().trim().toLowerCase();
    if (text == 'true') return true;
    if (text == 'false') return false;
    return null;
  }
}

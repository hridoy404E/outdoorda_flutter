class CustomerPostBidModel {
  final String id;
  final String status;
  final String postRequestId;
  final String installerId;
  final String? note;
  final double? price;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CustomerPostBidModel({
    required this.id,
    required this.status,
    required this.postRequestId,
    required this.installerId,
    this.note,
    this.price,
    this.createdAt,
    this.updatedAt,
  });

  factory CustomerPostBidModel.fromJson(Map<String, dynamic> json) {
    return CustomerPostBidModel(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      postRequestId: json['post_request_id']?.toString() ?? '',
      installerId: json['installer_id']?.toString() ?? '',
      note: json['note']?.toString(),
      price: (json['price'] as num?)?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }
}

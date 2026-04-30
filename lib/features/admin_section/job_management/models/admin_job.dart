/// Model class for admin job management data
class AdminJob {
  final String id;
  final String jobNumber;
  final String customerName;
  final double price;
  final String location;
  final String doorType;
  final AdminJobStatus status;
  final int? bidCount;
  final DateTime createdAt;

  // Details screen fields
  final String petDoorDescription;
  final String petDoorModel;
  final String installationType;
  final double adminEstimatedPrice;
  final String jobNotes;
  final List<String> sitePhotos;

  // Job tracking fields (for completed jobs)
  final DateTime? scheduledDate;
  final String? installerNotes;
  final bool? additionalWorkPerformed;
  final String? additionalWorkDescription;
  final bool? customerSatisfied;
  final String? customerFeedback;

  const AdminJob({
    required this.id,
    required this.jobNumber,
    required this.customerName,
    required this.price,
    required this.location,
    required this.doorType,
    required this.status,
    this.bidCount,
    required this.createdAt,
    required this.petDoorDescription,
    this.petDoorModel = 'XL2000',
    required this.installationType,
    required this.adminEstimatedPrice,
    required this.jobNotes,
    required this.sitePhotos,
    this.scheduledDate,
    this.installerNotes,
    this.additionalWorkPerformed,
    this.additionalWorkDescription,
    this.customerSatisfied,
    this.customerFeedback,
  });

  AdminJob copyWith({
    String? id,
    String? jobNumber,
    String? customerName,
    double? price,
    String? location,
    String? doorType,
    AdminJobStatus? status,
    int? bidCount,
    DateTime? createdAt,
    String? petDoorDescription,
    String? petDoorModel,
    String? installationType,
    double? adminEstimatedPrice,
    String? jobNotes,
    List<String>? sitePhotos,
    DateTime? scheduledDate,
    String? installerNotes,
    bool? additionalWorkPerformed,
    String? additionalWorkDescription,
    bool? customerSatisfied,
    String? customerFeedback,
  }) {
    return AdminJob(
      id: id ?? this.id,
      jobNumber: jobNumber ?? this.jobNumber,
      customerName: customerName ?? this.customerName,
      price: price ?? this.price,
      location: location ?? this.location,
      doorType: doorType ?? this.doorType,
      status: status ?? this.status,
      bidCount: bidCount ?? this.bidCount,
      createdAt: createdAt ?? this.createdAt,
      petDoorDescription: petDoorDescription ?? this.petDoorDescription,
      petDoorModel: petDoorModel ?? this.petDoorModel,
      installationType: installationType ?? this.installationType,
      adminEstimatedPrice: adminEstimatedPrice ?? this.adminEstimatedPrice,
      jobNotes: jobNotes ?? this.jobNotes,
      sitePhotos: sitePhotos ?? this.sitePhotos,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      installerNotes: installerNotes ?? this.installerNotes,
      additionalWorkPerformed:
          additionalWorkPerformed ?? this.additionalWorkPerformed,
      additionalWorkDescription:
          additionalWorkDescription ?? this.additionalWorkDescription,
      customerSatisfied: customerSatisfied ?? this.customerSatisfied,
      customerFeedback: customerFeedback ?? this.customerFeedback,
    );
  }

  factory AdminJob.fromJson(Map<String, dynamic> json) {
    return AdminJob(
      id: json['id']?.toString() ?? '',
      jobNumber: json['job_number']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      location: json['location']?.toString() ?? '',
      doorType: json['door_type']?.toString() ?? '',
      status: AdminJobStatus.fromString(json['status']?.toString() ?? ''),
      bidCount: json['bid_count'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      petDoorDescription: json['pet_door_description']?.toString() ?? '',
      petDoorModel: json['pet_door_model']?.toString() ?? 'XL2000',
      installationType: json['installation_type']?.toString() ?? '',
      adminEstimatedPrice:
          (json['admin_estimated_price'] as num?)?.toDouble() ?? 0.0,
      jobNotes: json['job_notes']?.toString() ?? '',
      sitePhotos:
          (json['site_photos'] as List?)?.map((e) => e.toString()).toList() ??
          [],
      scheduledDate: json['scheduled_date'] != null
          ? DateTime.parse(json['scheduled_date'].toString())
          : null,
      installerNotes: json['installer_notes']?.toString(),
      additionalWorkPerformed: json['additional_work_performed'] as bool?,
      additionalWorkDescription: json['additional_work_description']
          ?.toString(),
      customerSatisfied: json['customer_satisfied'] as bool?,
      customerFeedback: json['customer_feedback']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_number': jobNumber,
      'customer_name': customerName,
      'price': price,
      'location': location,
      'door_type': doorType,
      'status': status.name,
      'bid_count': bidCount,
      'created_at': createdAt.toIso8601String(),
      'pet_door_description': petDoorDescription,
      'pet_door_model': petDoorModel,
      'installation_type': installationType,
      'admin_estimated_price': adminEstimatedPrice,
      'job_notes': jobNotes,
      'site_photos': sitePhotos,
      'scheduled_date': scheduledDate?.toIso8601String(),
      'installer_notes': installerNotes,
      'additional_work_performed': additionalWorkPerformed,
      'additional_work_description': additionalWorkDescription,
      'customer_satisfied': customerSatisfied,
      'customer_feedback': customerFeedback,
    };
  }
}

/// Enum for admin job status types
enum AdminJobStatus {
  pending,
  receivingBids,
  completed,
  assigned,
  inProgress;

  String get displayName {
    switch (this) {
      case AdminJobStatus.pending:
        return 'Pending';
      case AdminJobStatus.receivingBids:
        return 'Receiving Bids';
      case AdminJobStatus.completed:
        return 'Completed';
      case AdminJobStatus.assigned:
        return 'Installer Assigned';
      case AdminJobStatus.inProgress:
        return 'In Progress';
    }
  }

  static AdminJobStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AdminJobStatus.pending;
      case 'receiving bids':
      case 'receiving_bids':
        return AdminJobStatus.receivingBids;
      case 'completed':
        return AdminJobStatus.completed;
      case 'assigned':
      case 'installer_assigned':
      case 'installer assigned':
        return AdminJobStatus.assigned;
      case 'in progress':
      case 'inprogress':
        return AdminJobStatus.inProgress;
      default:
        return AdminJobStatus.inProgress;
    }
  }
}

/// Model class for installer management job data
class ManagementJob {
  final String id;
  final bool isAssignedPost;
  final String jobNumber;
  final String customerName;
  final double price;
  final String location;
  final String doorType;
  final JobStatus status;
  final String statusLabel;
  final int? bidCount; // Optional, only for certain statuses
  final DateTime createdAt;

  // Details screen fields
  final String petDoorDescription;
  final String installationType;
  final double adminEstimatedPrice;
  final String jobNotes;
  final List<String> sitePhotos;

  // Job Progress Tracking fields
  final DateTime? scheduledDate;
  final String? jobStatusNotes;
  final bool?
  additionalWorkAnswer; // true = Yes, false = No, null = not answered
  final String? additionalWorkNotes;
  final bool?
  customerSatisfiedAnswer; // true = Yes, false = No, null = not answered
  final String? customerSatisfiedNotes;

  const ManagementJob({
    required this.id,
    this.isAssignedPost = false,
    required this.jobNumber,
    required this.customerName,
    required this.price,
    required this.location,
    required this.doorType,
    required this.status,
    this.statusLabel = '',
    this.bidCount,
    required this.createdAt,
    required this.petDoorDescription,
    required this.installationType,
    required this.adminEstimatedPrice,
    required this.jobNotes,
    required this.sitePhotos,
    this.scheduledDate,
    this.jobStatusNotes,
    this.additionalWorkAnswer,
    this.additionalWorkNotes,
    this.customerSatisfiedAnswer,
    this.customerSatisfiedNotes,
  });

  factory ManagementJob.fromJson(Map<String, dynamic> json) {
    return ManagementJob(
      id: json['id']?.toString() ?? '',
      isAssignedPost: json['is_assigned_post'] == true,
      jobNumber: json['job_number']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      location: json['location']?.toString() ?? '',
      doorType: json['door_type']?.toString() ?? '',
      status: JobStatus.fromString(json['status']?.toString() ?? ''),
      statusLabel: json['status_label']?.toString() ?? '',
      bidCount: json['bid_count'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      petDoorDescription: json['pet_door_description']?.toString() ?? '',
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
      jobStatusNotes: json['job_status_notes']?.toString(),
      additionalWorkAnswer: json['additional_work_answer'] != null
          ? json['additional_work_answer'] as bool
          : null,
      additionalWorkNotes: json['additional_work_notes']?.toString(),
      customerSatisfiedAnswer: json['customer_satisfied_answer'] != null
          ? json['customer_satisfied_answer'] as bool
          : null,
      customerSatisfiedNotes: json['customer_satisfied_notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_assigned_post': isAssignedPost,
      'job_number': jobNumber,
      'customer_name': customerName,
      'price': price,
      'location': location,
      'door_type': doorType,
      'status': status.name,
      'status_label': statusLabel,
      'bid_count': bidCount,
      'created_at': createdAt.toIso8601String(),
      'pet_door_description': petDoorDescription,
      'installation_type': installationType,
      'admin_estimated_price': adminEstimatedPrice,
      'job_notes': jobNotes,
      'site_photos': sitePhotos,
      'scheduled_date': scheduledDate?.toIso8601String(),
      'job_status_notes': jobStatusNotes,
      'additional_work_answer': additionalWorkAnswer,
      'additional_work_notes': additionalWorkNotes,
      'customer_satisfied_answer': customerSatisfiedAnswer,
      'customer_satisfied_notes': customerSatisfiedNotes,
    };
  }
}

/// Enum for job status types
enum JobStatus {
  completed,
  assigned,
  inProgress;

  String get displayName {
    switch (this) {
      case JobStatus.completed:
        return 'Completed';
      case JobStatus.assigned:
        return 'Assigned';
      case JobStatus.inProgress:
        return 'In Progress';
    }
  }

  static JobStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return JobStatus.completed;
      case 'assigned':
      case 'installer_assigned':
      case 'receiving_bids':
        return JobStatus.assigned;
      case 'in progress':
      case 'in_progress':
      case 'inprogress':
      case 'pending':
        return JobStatus.inProgress;
      default:
        return JobStatus.inProgress;
    }
  }
}

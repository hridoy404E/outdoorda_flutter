import 'package:outdoorda_flutter/features/customer_section/home/service_request/models/proposal_model.dart';

/// Service request model
class ServiceRequest {
  final String id;
  final String title;
  final String address;
  final String installerName;
  final String installerImageUrl;
  final String status;
  final String date;
  final String? price;
  final String? additionalInfo;
  final String? serviceType;
  final String? petName;
  final String? priceQuote;
  final List<Proposal>? proposals;

  // Job tracking fields (for completed requests)
  final DateTime? scheduledDate;
  final String? installerNotes;
  final bool? additionalWorkPerformed;
  final String? additionalWorkDescription;
  final bool? customerSatisfied;
  final String? customerFeedback;

  const ServiceRequest({
    required this.id,
    required this.title,
    required this.address,
    required this.installerName,
    required this.installerImageUrl,
    required this.status,
    required this.date,
    this.price,
    this.additionalInfo,
    this.serviceType,
    this.petName,
    this.priceQuote,
    this.proposals,
    this.scheduledDate,
    this.installerNotes,
    this.additionalWorkPerformed,
    this.additionalWorkDescription,
    this.customerSatisfied,
    this.customerFeedback,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      installerName: json['installerName']?.toString() ?? '',
      installerImageUrl: json['installerImageUrl']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      price: json['price']?.toString(),
      additionalInfo: json['additionalInfo']?.toString(),
      serviceType: json['serviceType']?.toString(),
      petName: json['petName']?.toString(),
      priceQuote: json['priceQuote']?.toString(),
      proposals: json['proposals'] != null
          ? (json['proposals'] as List)
                .map((p) => Proposal.fromJson(p as Map<String, dynamic>))
                .toList()
          : null,
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'].toString())
          : null,
      installerNotes: json['installerNotes']?.toString(),
      additionalWorkPerformed: json['additionalWorkPerformed'] as bool?,
      additionalWorkDescription: json['additionalWorkDescription']?.toString(),
      customerSatisfied: json['customerSatisfied'] as bool?,
      customerFeedback: json['customerFeedback']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'address': address,
      'installerName': installerName,
      'installerImageUrl': installerImageUrl,
      'status': status,
      'date': date,
      'price': price,
      'additionalInfo': additionalInfo,
      'serviceType': serviceType,
      'petName': petName,
      'priceQuote': priceQuote,
      'proposals': proposals?.map((p) => p.toJson()).toList(),
      'scheduledDate': scheduledDate?.toIso8601String(),
      'installerNotes': installerNotes,
      'additionalWorkPerformed': additionalWorkPerformed,
      'additionalWorkDescription': additionalWorkDescription,
      'customerSatisfied': customerSatisfied,
      'customerFeedback': customerFeedback,
    };
  }

  ServiceRequest copyWith({
    String? id,
    String? title,
    String? address,
    String? installerName,
    String? installerImageUrl,
    String? status,
    String? date,
    String? price,
    String? additionalInfo,
    String? serviceType,
    String? petName,
    String? priceQuote,
    List<Proposal>? proposals,
    DateTime? scheduledDate,
    String? installerNotes,
    bool? additionalWorkPerformed,
    String? additionalWorkDescription,
    bool? customerSatisfied,
    String? customerFeedback,
  }) {
    return ServiceRequest(
      id: id ?? this.id,
      title: title ?? this.title,
      address: address ?? this.address,
      installerName: installerName ?? this.installerName,
      installerImageUrl: installerImageUrl ?? this.installerImageUrl,
      status: status ?? this.status,
      date: date ?? this.date,
      price: price ?? this.price,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      serviceType: serviceType ?? this.serviceType,
      petName: petName ?? this.petName,
      priceQuote: priceQuote ?? this.priceQuote,
      proposals: proposals ?? this.proposals,
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
}

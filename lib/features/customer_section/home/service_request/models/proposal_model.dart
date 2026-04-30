/// Proposal model for installer offers
class Proposal {
  final String id;
  final String installerName;
  final String installerImageUrl;
  final double rating;
  final int reviewCount;
  final String price;
  final String availableDate;

  const Proposal({
    required this.id,
    required this.installerName,
    required this.installerImageUrl,
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.availableDate,
  });

  factory Proposal.fromJson(Map<String, dynamic> json) {
    return Proposal(
      id: json['id']?.toString() ?? '',
      installerName: json['installerName']?.toString() ?? '',
      installerImageUrl: json['installerImageUrl']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      price: json['price']?.toString() ?? '',
      availableDate: json['availableDate']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'installerName': installerName,
      'installerImageUrl': installerImageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'price': price,
      'availableDate': availableDate,
    };
  }
}

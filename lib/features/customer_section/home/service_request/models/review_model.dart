/// Review model for Happy Tails section
class Review {
  static const String _fallbackAvatar = 'https://i.pravatar.cc/150?img=33';

  final String id;
  final String reviewerName;
  final String reviewerImageUrl;
  final String petName;
  final String reviewText;
  final double rating;

  const Review({
    required this.id,
    required this.reviewerName,
    required this.reviewerImageUrl,
    required this.petName,
    required this.reviewText,
    required this.rating,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id']?.toString() ?? '',
      reviewerName: json['reviewerName']?.toString() ?? '',
      reviewerImageUrl: json['reviewerImageUrl']?.toString() ?? '',
      petName: json['petName']?.toString() ?? '',
      reviewText: json['reviewText']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory Review.fromInstallerRatingJson(Map<String, dynamic> json) {
    final installerId = json['installer_id']?.toString().trim() ?? '';
    final installerName =
        json['installer name']?.toString().trim().isNotEmpty == true
        ? json['installer name'].toString().trim()
        : (json['installer_name']?.toString().trim() ?? '');
    final installerPhoto = json['installer_photo']?.toString().trim() ?? '';
    final averageRating = (json['average_rating'] as num?)?.toDouble() ?? 0.0;
    final totalReviews = (json['total_reviews'] as num?)?.toInt() ?? 0;

    final safeRating = (averageRating.clamp(0.0, 5.0) as num).toDouble();
    final safeName = installerName.isNotEmpty ? installerName : installerId;

    return Review(
      id: installerId,
      reviewerName: safeName,
      reviewerImageUrl: installerPhoto.isNotEmpty
          ? installerPhoto
          : _fallbackAvatar,
      petName: '$totalReviews reviews',
      reviewText: 'Installer ID: $installerId',
      rating: safeRating,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reviewerName': reviewerName,
      'reviewerImageUrl': reviewerImageUrl,
      'petName': petName,
      'reviewText': reviewText,
      'rating': rating,
    };
  }
}

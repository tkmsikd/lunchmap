import '../../domain/entities/review.dart';

/// Data model for Review entity
class ReviewModel {
  /// Unique identifier for the review
  final String id;

  /// ID of the restaurant being reviewed
  final String restaurantId;

  /// ID of the user who wrote the review
  final String userId;

  /// Name of the user who wrote the review
  final String userName;

  /// URL to the user's avatar image (optional)
  final String? userAvatarUrl;

  /// Rating given by the user (1-5 stars)
  final double rating;

  /// Text comment provided by the user
  final String comment;

  /// Date and time when the review was created
  final DateTime createdAt;

  /// URLs to images attached to the review (optional)
  final List<String>? imageUrls;

  /// Creates a new ReviewModel instance
  const ReviewModel({
    required this.id,
    required this.restaurantId,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.imageUrls,
  });

  /// Creates a ReviewModel from a JSON map
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      restaurantId: json['restaurantId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatarUrl: json['userAvatarUrl'] as String?,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      imageUrls:
          (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
    );
  }

  /// Converts this ReviewModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'userId': userId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'imageUrls': imageUrls,
    };
  }

  /// Converts this ReviewModel to a Review entity
  Review toEntity() {
    return Review(
      id: id,
      restaurantId: restaurantId,
      userId: userId,
      userName: userName,
      userAvatarUrl: userAvatarUrl,
      rating: rating,
      comment: comment,
      createdAt: createdAt,
      imageUrls: imageUrls,
    );
  }

  /// Creates a ReviewModel from a Review entity
  factory ReviewModel.fromEntity(Review review) {
    return ReviewModel(
      id: review.id,
      restaurantId: review.restaurantId,
      userId: review.userId,
      userName: review.userName,
      userAvatarUrl: review.userAvatarUrl,
      rating: review.rating,
      comment: review.comment,
      createdAt: review.createdAt,
      imageUrls: review.imageUrls,
    );
  }
}

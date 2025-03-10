/// Review entity representing a user's review of a restaurant
class Review {
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

  /// Creates a new Review instance
  const Review({
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

  /// Creates a copy of this Review with the given fields replaced with new values
  Review copyWith({
    String? id,
    String? restaurantId,
    String? userId,
    String? userName,
    String? userAvatarUrl,
    double? rating,
    String? comment,
    DateTime? createdAt,
    List<String>? imageUrls,
  }) {
    return Review(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }

  /// Checks if the review has images
  bool get hasImages {
    return imageUrls != null && imageUrls!.isNotEmpty;
  }

  /// Gets the number of images in the review
  int get imageCount {
    return imageUrls?.length ?? 0;
  }

  /// Checks if the review was created recently (within the last 24 hours)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours < 24;
  }

  /// Checks if the review was created by the specified user
  bool isCreatedBy(String userId) {
    return this.userId == userId;
  }

  /// Adds an image URL to the review
  Review addImage(String imageUrl) {
    final currentImages = imageUrls ?? [];
    return copyWith(imageUrls: [...currentImages, imageUrl]);
  }

  /// Removes an image URL from the review
  Review removeImage(String imageUrl) {
    if (imageUrls == null || !imageUrls!.contains(imageUrl)) {
      return this;
    }

    return copyWith(
      imageUrls: imageUrls!.where((url) => url != imageUrl).toList(),
    );
  }

  /// Updates the rating of the review
  Review updateRating(double newRating) {
    if (newRating < 1 || newRating > 5) {
      throw ArgumentError('Rating must be between 1 and 5');
    }

    return copyWith(rating: newRating);
  }

  /// Updates the comment of the review
  Review updateComment(String newComment) {
    return copyWith(comment: newComment);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Review &&
        other.id == id &&
        other.restaurantId == restaurantId &&
        other.userId == userId &&
        other.userName == userName &&
        other.userAvatarUrl == userAvatarUrl &&
        other.rating == rating &&
        other.comment == comment &&
        other.createdAt == createdAt &&
        _listEquals(other.imageUrls, imageUrls);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        restaurantId.hashCode ^
        userId.hashCode ^
        userName.hashCode ^
        userAvatarUrl.hashCode ^
        rating.hashCode ^
        comment.hashCode ^
        createdAt.hashCode ^
        imageUrls.hashCode;
  }

  /// Helper method to check if two lists are equal
  bool _listEquals<T>(List<T>? list1, List<T>? list2) {
    if (list1 == null && list2 == null) return true;
    if (list1 == null || list2 == null) return false;
    if (list1.length != list2.length) return false;

    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }

    return true;
  }
}

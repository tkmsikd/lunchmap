import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/review_model.dart';
import '../../core/exceptions/result.dart';
import 'package:uuid/uuid.dart';

/// Interface for review data source
abstract class ReviewDataSource {
  /// Adds a new review
  Future<Result<ReviewModel>> addReview(ReviewModel review);

  /// Updates an existing review
  Future<Result<ReviewModel>> updateReview(ReviewModel review);

  /// Deletes a review
  Future<Result<void>> deleteReview(String reviewId);

  /// Gets reviews created by a user
  Future<Result<List<ReviewModel>>> getUserReviews(String userId);

  /// Gets a review by its ID
  Future<Result<ReviewModel>> getReviewById(String reviewId);

  /// Adds an image to a review
  Future<Result<ReviewModel>> addImageToReview(
    String reviewId,
    String imageUrl,
  );

  /// Removes an image from a review
  Future<Result<ReviewModel>> removeImageFromReview(
    String reviewId,
    String imageUrl,
  );

  /// Gets recent reviews
  Future<Result<List<ReviewModel>>> getRecentReviews({int limit = 10});

  /// Gets reviews with a specific rating
  Future<Result<List<ReviewModel>>> getReviewsByRating(
    double rating, {
    int limit = 10,
  });

  /// Gets the average rating for a restaurant
  Future<Result<double>> getAverageRating(String restaurantId);
}

/// Firebase implementation of ReviewDataSource
class FirebaseReviewDataSource implements ReviewDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final Uuid _uuid;

  /// Creates a new FirebaseReviewDataSource with the given dependencies
  FirebaseReviewDataSource({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    Uuid? uuid,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance,
       _uuid = uuid ?? const Uuid();

  @override
  Future<Result<ReviewModel>> addReview(ReviewModel review) async {
    try {
      // Generate a new ID if not provided
      final reviewId = review.id.isEmpty ? _uuid.v4() : review.id;
      final reviewWithId =
          review.id.isEmpty
              ? ReviewModel(
                id: reviewId,
                restaurantId: review.restaurantId,
                userId: review.userId,
                userName: review.userName,
                userAvatarUrl: review.userAvatarUrl,
                rating: review.rating,
                comment: review.comment,
                createdAt: review.createdAt,
                imageUrls: review.imageUrls,
              )
              : review;

      // Save to Firestore
      await _firestore
          .collection('reviews')
          .doc(reviewId)
          .set(reviewWithId.toJson());

      // Update restaurant's average rating and review count
      await _updateRestaurantRating(review.restaurantId);

      return Result.success(reviewWithId);
    } catch (e) {
      return Result.error('レビュー追加中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<ReviewModel>> updateReview(ReviewModel review) async {
    try {
      // Check if review exists
      final doc = await _firestore.collection('reviews').doc(review.id).get();

      if (!doc.exists) {
        return Result.error('レビューが見つかりませんでした');
      }

      // Update review
      await _firestore
          .collection('reviews')
          .doc(review.id)
          .update(review.toJson());

      // Update restaurant's average rating
      await _updateRestaurantRating(review.restaurantId);

      return Result.success(review);
    } catch (e) {
      return Result.error('レビュー更新中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<void>> deleteReview(String reviewId) async {
    try {
      // Get review to get restaurant ID
      final doc = await _firestore.collection('reviews').doc(reviewId).get();

      if (!doc.exists) {
        return Result.error('レビューが見つかりませんでした');
      }

      final reviewData = doc.data() as Map<String, dynamic>;
      final restaurantId = reviewData['restaurantId'] as String;

      // Delete review
      await _firestore.collection('reviews').doc(reviewId).delete();

      // Update restaurant's average rating
      await _updateRestaurantRating(restaurantId);

      return Result.success(null);
    } catch (e) {
      return Result.error('レビュー削除中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<List<ReviewModel>>> getUserReviews(String userId) async {
    try {
      final snapshot =
          await _firestore
              .collection('reviews')
              .where('userId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .get();

      final reviews =
          snapshot.docs
              .map(
                (doc) =>
                    ReviewModel.fromJson(doc.data() as Map<String, dynamic>),
              )
              .toList();

      return Result.success(reviews);
    } catch (e) {
      return Result.error('ユーザーのレビュー取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<ReviewModel>> getReviewById(String reviewId) async {
    try {
      final doc = await _firestore.collection('reviews').doc(reviewId).get();

      if (!doc.exists) {
        return Result.error('レビューが見つかりませんでした');
      }

      return Result.success(
        ReviewModel.fromJson(doc.data() as Map<String, dynamic>),
      );
    } catch (e) {
      return Result.error('レビュー取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<ReviewModel>> addImageToReview(
    String reviewId,
    String imageUrl,
  ) async {
    try {
      // Get current review
      final doc = await _firestore.collection('reviews').doc(reviewId).get();

      if (!doc.exists) {
        return Result.error('レビューが見つかりませんでした');
      }

      final review = ReviewModel.fromJson(doc.data() as Map<String, dynamic>);

      // Add image URL to review
      final currentImageUrls = review.imageUrls ?? [];
      final updatedImageUrls = [...currentImageUrls, imageUrl];

      // Update review
      final updatedReview = ReviewModel(
        id: review.id,
        restaurantId: review.restaurantId,
        userId: review.userId,
        userName: review.userName,
        userAvatarUrl: review.userAvatarUrl,
        rating: review.rating,
        comment: review.comment,
        createdAt: review.createdAt,
        imageUrls: updatedImageUrls,
      );

      await _firestore.collection('reviews').doc(reviewId).update({
        'imageUrls': updatedImageUrls,
      });

      return Result.success(updatedReview);
    } catch (e) {
      return Result.error('レビュー画像追加中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<ReviewModel>> removeImageFromReview(
    String reviewId,
    String imageUrl,
  ) async {
    try {
      // Get current review
      final doc = await _firestore.collection('reviews').doc(reviewId).get();

      if (!doc.exists) {
        return Result.error('レビューが見つかりませんでした');
      }

      final review = ReviewModel.fromJson(doc.data() as Map<String, dynamic>);

      // Remove image URL from review
      final currentImageUrls = review.imageUrls ?? [];
      final updatedImageUrls =
          currentImageUrls.where((url) => url != imageUrl).toList();

      // Update review
      final updatedReview = ReviewModel(
        id: review.id,
        restaurantId: review.restaurantId,
        userId: review.userId,
        userName: review.userName,
        userAvatarUrl: review.userAvatarUrl,
        rating: review.rating,
        comment: review.comment,
        createdAt: review.createdAt,
        imageUrls: updatedImageUrls,
      );

      await _firestore.collection('reviews').doc(reviewId).update({
        'imageUrls': updatedImageUrls,
      });

      // Delete image from storage if it's a Firebase Storage URL
      if (imageUrl.contains('firebasestorage.googleapis.com')) {
        try {
          await _storage.refFromURL(imageUrl).delete();
        } catch (e) {
          // Ignore errors when deleting from storage
          print('画像削除中にエラーが発生しました: $e');
        }
      }

      return Result.success(updatedReview);
    } catch (e) {
      return Result.error('レビュー画像削除中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<List<ReviewModel>>> getRecentReviews({int limit = 10}) async {
    try {
      final snapshot =
          await _firestore
              .collection('reviews')
              .orderBy('createdAt', descending: true)
              .limit(limit)
              .get();

      final reviews =
          snapshot.docs
              .map(
                (doc) =>
                    ReviewModel.fromJson(doc.data() as Map<String, dynamic>),
              )
              .toList();

      return Result.success(reviews);
    } catch (e) {
      return Result.error('最近のレビュー取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<List<ReviewModel>>> getReviewsByRating(
    double rating, {
    int limit = 10,
  }) async {
    try {
      final snapshot =
          await _firestore
              .collection('reviews')
              .where('rating', isEqualTo: rating)
              .orderBy('createdAt', descending: true)
              .limit(limit)
              .get();

      final reviews =
          snapshot.docs
              .map(
                (doc) =>
                    ReviewModel.fromJson(doc.data() as Map<String, dynamic>),
              )
              .toList();

      return Result.success(reviews);
    } catch (e) {
      return Result.error('評価別レビュー取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<double>> getAverageRating(String restaurantId) async {
    try {
      final snapshot =
          await _firestore
              .collection('reviews')
              .where('restaurantId', isEqualTo: restaurantId)
              .get();

      if (snapshot.docs.isEmpty) {
        return Result.success(0.0);
      }

      final reviews =
          snapshot.docs
              .map(
                (doc) =>
                    ReviewModel.fromJson(doc.data() as Map<String, dynamic>),
              )
              .toList();

      final totalRating = reviews.fold(
        0.0,
        (sum, review) => sum + review.rating,
      );
      final averageRating = totalRating / reviews.length;

      return Result.success(averageRating);
    } catch (e) {
      return Result.error('平均評価取得中にエラーが発生しました: $e');
    }
  }

  /// Updates a restaurant's average rating and review count
  Future<void> _updateRestaurantRating(String restaurantId) async {
    try {
      // Get all reviews for the restaurant
      final snapshot =
          await _firestore
              .collection('reviews')
              .where('restaurantId', isEqualTo: restaurantId)
              .get();

      if (snapshot.docs.isEmpty) {
        // No reviews, set rating to 0
        await _firestore.collection('restaurants').doc(restaurantId).update({
          'averageRating': 0.0,
          'reviewCount': 0,
        });
        return;
      }

      final reviews =
          snapshot.docs
              .map(
                (doc) =>
                    ReviewModel.fromJson(doc.data() as Map<String, dynamic>),
              )
              .toList();

      final totalRating = reviews.fold(
        0.0,
        (sum, review) => sum + review.rating,
      );
      final averageRating = totalRating / reviews.length;

      // Update restaurant
      await _firestore.collection('restaurants').doc(restaurantId).update({
        'averageRating': averageRating,
        'reviewCount': reviews.length,
      });
    } catch (e) {
      print('レストラン評価更新中にエラーが発生しました: $e');
    }
  }
}

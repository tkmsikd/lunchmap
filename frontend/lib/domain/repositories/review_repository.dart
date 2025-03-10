import '../entities/review.dart';
import '../../core/exceptions/result.dart';

/// Repository interface for review operations
abstract class ReviewRepository {
  /// Adds a new review
  ///
  /// Returns a [Result] containing the created [Review] if successful,
  /// or an error message if unsuccessful
  Future<Result<Review>> addReview(Review review);

  /// Updates an existing review
  ///
  /// Returns a [Result] containing the updated [Review] if successful,
  /// or an error message if unsuccessful
  Future<Result<Review>> updateReview(Review review);

  /// Deletes a review
  ///
  /// Returns a [Result] indicating success or failure
  Future<Result<void>> deleteReview(String reviewId);

  /// Gets reviews created by a user
  ///
  /// Returns a [Result] containing a list of [Review] if successful,
  /// or an error message if unsuccessful
  Future<Result<List<Review>>> getUserReviews(String userId);

  /// Gets a review by its ID
  ///
  /// Returns a [Result] containing the [Review] if successful,
  /// or an error message if unsuccessful
  Future<Result<Review>> getReviewById(String reviewId);

  /// Adds an image to a review
  ///
  /// Returns a [Result] containing the updated [Review] if successful,
  /// or an error message if unsuccessful
  Future<Result<Review>> addImageToReview(String reviewId, String imageUrl);

  /// Removes an image from a review
  ///
  /// Returns a [Result] containing the updated [Review] if successful,
  /// or an error message if unsuccessful
  Future<Result<Review>> removeImageFromReview(
    String reviewId,
    String imageUrl,
  );

  /// Gets recent reviews
  ///
  /// [limit] specifies the maximum number of reviews to return
  ///
  /// Returns a [Result] containing a list of [Review] if successful,
  /// or an error message if unsuccessful
  Future<Result<List<Review>>> getRecentReviews({int limit = 10});

  /// Gets reviews with a specific rating
  ///
  /// [rating] specifies the rating to filter by
  /// [limit] specifies the maximum number of reviews to return
  ///
  /// Returns a [Result] containing a list of [Review] if successful,
  /// or an error message if unsuccessful
  Future<Result<List<Review>>> getReviewsByRating(
    double rating, {
    int limit = 10,
  });

  /// Gets the average rating for a restaurant
  ///
  /// Returns a [Result] containing the average rating if successful,
  /// or an error message if unsuccessful
  Future<Result<double>> getAverageRating(String restaurantId);
}

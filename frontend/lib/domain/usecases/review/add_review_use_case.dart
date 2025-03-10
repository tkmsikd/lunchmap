import '../../repositories/review_repository.dart';
import '../../repositories/restaurant_repository.dart';
import '../../../core/exceptions/result.dart';
import '../../entities/review.dart';
import '../../entities/restaurant.dart';

/// Use case for adding a new review
class AddReviewUseCase {
  /// The review repository that this use case will use
  final ReviewRepository reviewRepository;

  /// The restaurant repository that this use case will use
  final RestaurantRepository restaurantRepository;

  /// Creates a new AddReviewUseCase with the given repositories
  const AddReviewUseCase({
    required this.reviewRepository,
    required this.restaurantRepository,
  });

  /// Executes the use case
  ///
  /// [review] is the review to add
  ///
  /// Returns a [Result] containing the created [Review] if successful,
  /// or an error message if unsuccessful
  Future<Result<Review>> execute(Review review) async {
    // Validate review
    if (review.restaurantId.isEmpty) {
      return Result.validationError('レストランIDが無効です');
    }

    if (review.userId.isEmpty) {
      return Result.validationError('ユーザーIDが無効です');
    }

    if (review.rating < 1 || review.rating > 5) {
      return Result.validationError('評価は1から5の間で入力してください');
    }

    if (review.comment.isEmpty) {
      return Result.validationError('コメントを入力してください');
    }

    try {
      // Add the review
      final result = await reviewRepository.addReview(review);

      if (result.isSuccess) {
        // Update the restaurant's rating
        final restaurantResult = await restaurantRepository.getRestaurantById(
          review.restaurantId,
        );

        if (restaurantResult.isSuccess) {
          final restaurant = restaurantResult.data!;

          // Update the restaurant's rating
          final updatedRestaurant = restaurant.updateRating(review.rating);

          // We don't need to wait for this to complete
          restaurantRepository.updateRestaurant(updatedRestaurant);
        }
      }

      return result;
    } catch (e) {
      return Result.error('レビューの追加中にエラーが発生しました: $e');
    }
  }
}

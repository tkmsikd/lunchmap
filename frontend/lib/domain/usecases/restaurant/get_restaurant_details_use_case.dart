import '../../repositories/restaurant_repository.dart';
import '../../repositories/review_repository.dart';
import '../../../core/exceptions/result.dart';
import '../../entities/restaurant.dart';
import '../../entities/review.dart';

/// Use case for getting detailed information about a restaurant
class GetRestaurantDetailsUseCase {
  /// The restaurant repository that this use case will use
  final RestaurantRepository restaurantRepository;

  /// The review repository that this use case will use
  final ReviewRepository reviewRepository;

  /// Creates a new GetRestaurantDetailsUseCase with the given repositories
  const GetRestaurantDetailsUseCase({
    required this.restaurantRepository,
    required this.reviewRepository,
  });

  /// Executes the use case
  ///
  /// [restaurantId] is the ID of the restaurant to get details for
  ///
  /// Returns a [Result] containing a Map with restaurant details and reviews if successful,
  /// or an error message if unsuccessful
  Future<Result<Map<String, dynamic>>> execute(String restaurantId) async {
    // Validate restaurant ID
    if (restaurantId.isEmpty) {
      return Result.validationError('レストランIDが無効です');
    }

    try {
      // Get restaurant details
      final restaurantResult = await restaurantRepository.getRestaurantById(
        restaurantId,
      );

      if (restaurantResult.isError) {
        return Result.error(
          restaurantResult.errorMessage ?? 'レストラン情報の取得に失敗しました',
          restaurantResult.status,
        );
      }

      // Get restaurant reviews
      final reviewsResult = await restaurantRepository.getRestaurantReviews(
        restaurantId,
      );

      // Even if reviews fail, we can still return the restaurant details
      final reviews =
          reviewsResult.isSuccess ? reviewsResult.data! : <Review>[];

      // Return combined result
      return Result.success({
        'restaurant': restaurantResult.data!,
        'reviews': reviews,
      });
    } catch (e) {
      return Result.error('レストラン詳細の取得中にエラーが発生しました: $e');
    }
  }
}

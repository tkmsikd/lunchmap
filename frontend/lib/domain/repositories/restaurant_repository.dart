import '../entities/restaurant.dart';
import '../entities/review.dart';
import '../../core/exceptions/result.dart';

/// Repository interface for restaurant operations
abstract class RestaurantRepository {
  /// Updates a restaurant's information
  ///
  /// Returns a [Result] containing the updated [Restaurant] if successful,
  /// or an error message if unsuccessful
  Future<Result<Restaurant>> updateRestaurant(Restaurant restaurant);

  /// Gets nearby restaurants based on location
  ///
  /// [latitude] and [longitude] specify the center point
  /// [radius] specifies the search radius in meters (default: 1000)
  ///
  /// Returns a [Result] containing a list of [Restaurant] if successful,
  /// or an error message if unsuccessful
  Future<Result<List<Restaurant>>> getNearbyRestaurants(
    double latitude,
    double longitude, {
    double radius = 1000,
  });

  /// Gets a restaurant by its ID
  ///
  /// Returns a [Result] containing the [Restaurant] if successful,
  /// or an error message if unsuccessful
  Future<Result<Restaurant>> getRestaurantById(String id);

  /// Searches for restaurants by query and optional categories
  ///
  /// [query] is the search term
  /// [categories] is an optional list of categories to filter by
  ///
  /// Returns a [Result] containing a list of [Restaurant] if successful,
  /// or an error message if unsuccessful
  Future<Result<List<Restaurant>>> searchRestaurants(
    String query, {
    List<String>? categories,
  });

  /// Gets reviews for a restaurant
  ///
  /// Returns a [Result] containing a list of [Review] if successful,
  /// or an error message if unsuccessful
  Future<Result<List<Review>>> getRestaurantReviews(String restaurantId);

  /// Adds a restaurant to a user's favorites
  ///
  /// Returns a [Result] indicating success or failure
  Future<Result<void>> addRestaurantToFavorites(
    String userId,
    String restaurantId,
  );

  /// Removes a restaurant from a user's favorites
  ///
  /// Returns a [Result] indicating success or failure
  Future<Result<void>> removeRestaurantFromFavorites(
    String userId,
    String restaurantId,
  );

  /// Gets a user's favorite restaurants
  ///
  /// Returns a [Result] containing a list of [Restaurant] if successful,
  /// or an error message if unsuccessful
  Future<Result<List<Restaurant>>> getFavoriteRestaurants(String userId);

  /// Reports the current crowdedness of a restaurant
  ///
  /// [isCrowded] indicates whether the restaurant is currently crowded
  ///
  /// Returns a [Result] indicating success or failure
  Future<Result<void>> reportCrowdedness(String restaurantId, bool isCrowded);

  /// Gets restaurants by category
  ///
  /// Returns a [Result] containing a list of [Restaurant] if successful,
  /// or an error message if unsuccessful
  Future<Result<List<Restaurant>>> getRestaurantsByCategory(String category);

  /// Gets popular restaurants based on rating and review count
  ///
  /// [limit] specifies the maximum number of restaurants to return
  ///
  /// Returns a [Result] containing a list of [Restaurant] if successful,
  /// or an error message if unsuccessful
  Future<Result<List<Restaurant>>> getPopularRestaurants({int limit = 10});

  /// Gets recently reviewed restaurants
  ///
  /// [limit] specifies the maximum number of restaurants to return
  ///
  /// Returns a [Result] containing a list of [Restaurant] if successful,
  /// or an error message if unsuccessful
  Future<Result<List<Restaurant>>> getRecentlyReviewedRestaurants({
    int limit = 10,
  });
}

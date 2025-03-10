import '../../repositories/restaurant_repository.dart';
import '../../../core/exceptions/result.dart';
import '../../entities/restaurant.dart';

/// Use case for getting nearby restaurants based on location
class GetNearbyRestaurantsUseCase {
  /// The repository that this use case will use
  final RestaurantRepository repository;

  /// Creates a new GetNearbyRestaurantsUseCase with the given repository
  const GetNearbyRestaurantsUseCase(this.repository);

  /// Executes the use case
  ///
  /// [latitude] and [longitude] specify the center point
  /// [radius] specifies the search radius in meters (default: 1000)
  ///
  /// Returns a [Result] containing a list of [Restaurant] if successful,
  /// or an error message if unsuccessful
  Future<Result<List<Restaurant>>> execute(
    double latitude,
    double longitude, {
    double radius = 1000,
  }) async {
    // Validate latitude
    if (latitude < -90 || latitude > 90) {
      return Result.validationError('緯度は-90から90の間で入力してください');
    }

    // Validate longitude
    if (longitude < -180 || longitude > 180) {
      return Result.validationError('経度は-180から180の間で入力してください');
    }

    // Validate radius
    if (radius <= 0) {
      return Result.validationError('検索半径は0より大きい値を入力してください');
    }

    // Call the repository
    return await repository.getNearbyRestaurants(
      latitude,
      longitude,
      radius: radius,
    );
  }
}

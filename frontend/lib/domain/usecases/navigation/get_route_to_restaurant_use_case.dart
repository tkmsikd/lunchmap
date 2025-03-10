import '../../repositories/navigation_repository.dart';
import '../../repositories/restaurant_repository.dart';
import '../../../core/exceptions/result.dart';
import '../../entities/route.dart';

/// Use case for getting a route to a restaurant
class GetRouteToRestaurantUseCase {
  /// The navigation repository that this use case will use
  final NavigationRepository navigationRepository;

  /// The restaurant repository that this use case will use
  final RestaurantRepository restaurantRepository;

  /// Creates a new GetRouteToRestaurantUseCase with the given repositories
  const GetRouteToRestaurantUseCase({
    required this.navigationRepository,
    required this.restaurantRepository,
  });

  /// Executes the use case
  ///
  /// [startLatitude] and [startLongitude] specify the starting point
  /// [restaurantId] specifies the destination restaurant
  ///
  /// Returns a [Result] containing a [RouteEntity] if successful,
  /// or an error message if unsuccessful
  Future<Result<RouteEntity>> execute(
    double startLatitude,
    double startLongitude,
    String restaurantId,
  ) async {
    // Validate starting point
    if (startLatitude < -90 || startLatitude > 90) {
      return Result.validationError('開始地点の緯度は-90から90の間で入力してください');
    }

    if (startLongitude < -180 || startLongitude > 180) {
      return Result.validationError('開始地点の経度は-180から180の間で入力してください');
    }

    // Validate restaurant ID
    if (restaurantId.isEmpty) {
      return Result.validationError('レストランIDが無効です');
    }

    try {
      // Get the restaurant details to get its location
      final restaurantResult = await restaurantRepository.getRestaurantById(
        restaurantId,
      );

      if (restaurantResult.isError) {
        return Result.error(
          restaurantResult.errorMessage ?? 'レストラン情報の取得に失敗しました',
          restaurantResult.status,
        );
      }

      final restaurant = restaurantResult.data!;

      // Get the route
      return await navigationRepository.getRouteToDestination(
        startLatitude,
        startLongitude,
        restaurant.latitude,
        restaurant.longitude,
      );
    } catch (e) {
      return Result.error('ルート取得中にエラーが発生しました: $e');
    }
  }
}

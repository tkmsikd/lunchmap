import '../entities/route.dart';
import '../../core/exceptions/result.dart';

/// Repository interface for navigation operations
abstract class NavigationRepository {
  /// Gets a route from a starting point to a destination
  ///
  /// [startLatitude] and [startLongitude] specify the starting point
  /// [destinationLatitude] and [destinationLongitude] specify the destination
  ///
  /// Returns a [Result] containing a [RouteEntity] if successful,
  /// or an error message if unsuccessful
  Future<Result<RouteEntity>> getRouteToDestination(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  );

  /// Gets a route to a restaurant
  ///
  /// [startLatitude] and [startLongitude] specify the starting point
  /// [restaurantId] specifies the destination restaurant
  ///
  /// Returns a [Result] containing a [RouteEntity] if successful,
  /// or an error message if unsuccessful
  Future<Result<RouteEntity>> getRouteToRestaurant(
    double startLatitude,
    double startLongitude,
    String restaurantId,
  );

  /// Gets alternative routes from a starting point to a destination
  ///
  /// [startLatitude] and [startLongitude] specify the starting point
  /// [destinationLatitude] and [destinationLongitude] specify the destination
  /// [maxAlternatives] specifies the maximum number of alternative routes to return
  ///
  /// Returns a [Result] containing a list of [RouteEntity] if successful,
  /// or an error message if unsuccessful
  Future<Result<List<RouteEntity>>> getAlternativeRoutes(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude, {
    int maxAlternatives = 3,
  });

  /// Gets the estimated time of arrival (ETA) to a destination
  ///
  /// [startLatitude] and [startLongitude] specify the starting point
  /// [destinationLatitude] and [destinationLongitude] specify the destination
  ///
  /// Returns a [Result] containing the ETA as a [DateTime] if successful,
  /// or an error message if unsuccessful
  Future<Result<DateTime>> getEstimatedTimeOfArrival(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  );

  /// Gets the walking distance between two points
  ///
  /// [startLatitude] and [startLongitude] specify the starting point
  /// [destinationLatitude] and [destinationLongitude] specify the destination
  ///
  /// Returns a [Result] containing the distance in meters if successful,
  /// or an error message if unsuccessful
  Future<Result<double>> getWalkingDistance(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  );

  /// Gets the walking time between two points
  ///
  /// [startLatitude] and [startLongitude] specify the starting point
  /// [destinationLatitude] and [destinationLongitude] specify the destination
  ///
  /// Returns a [Result] containing the time in minutes if successful,
  /// or an error message if unsuccessful
  Future<Result<int>> getWalkingTime(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  );
}

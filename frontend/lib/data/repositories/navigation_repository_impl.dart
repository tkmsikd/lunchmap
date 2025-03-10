import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../domain/entities/route.dart';
import '../../domain/repositories/navigation_repository.dart';
import '../../core/exceptions/result.dart';
import '../datasources/navigation_data_source.dart';
import '../models/route_model.dart';
import '../datasources/restaurant_data_source.dart';

/// Implementation of NavigationRepository
class NavigationRepositoryImpl implements NavigationRepository {
  final NavigationDataSource _navigationDataSource;
  final RestaurantDataSource _restaurantDataSource;

  /// Creates a new NavigationRepositoryImpl with the given dependencies
  NavigationRepositoryImpl({
    required NavigationDataSource navigationDataSource,
    required RestaurantDataSource restaurantDataSource,
  }) : _navigationDataSource = navigationDataSource,
       _restaurantDataSource = restaurantDataSource;

  @override
  Future<Result<RouteEntity>> getRouteToDestination(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    try {
      final origin = LatLng(startLatitude, startLongitude);
      final destination = LatLng(destinationLatitude, destinationLongitude);

      final result = await _navigationDataSource.getRoute(
        origin,
        destination,
        mode: 'driving',
      );

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      return Result.success(result.data!.toEntity());
    } catch (e) {
      return Result.error('ルート取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<RouteEntity>> getRouteToRestaurant(
    double startLatitude,
    double startLongitude,
    String restaurantId,
  ) async {
    try {
      // Get restaurant location
      final restaurantResult = await _restaurantDataSource.getRestaurantById(
        restaurantId,
      );

      if (restaurantResult.isError) {
        return Result.error(restaurantResult.errorMessage!);
      }

      final restaurant = restaurantResult.data!;
      final destination = LatLng(restaurant.latitude, restaurant.longitude);
      final origin = LatLng(startLatitude, startLongitude);

      // Get route
      final routeResult = await _navigationDataSource.getRoute(
        origin,
        destination,
        mode: 'driving',
      );

      if (routeResult.isError) {
        return Result.error(routeResult.errorMessage!);
      }

      return Result.success(routeResult.data!.toEntity());
    } catch (e) {
      return Result.error('レストランへのルート取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<List<RouteEntity>>> getAlternativeRoutes(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude, {
    int maxAlternatives = 3,
  }) async {
    try {
      final origin = LatLng(startLatitude, startLongitude);
      final destination = LatLng(destinationLatitude, destinationLongitude);

      final result = await _navigationDataSource.getAlternativeRoutes(
        origin,
        destination,
        mode: 'driving',
        alternatives: maxAlternatives,
      );

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      final routes = result.data!.map((model) => model.toEntity()).toList();
      return Result.success(routes);
    } catch (e) {
      return Result.error('代替ルート取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<DateTime>> getEstimatedTimeOfArrival(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    try {
      final origin = LatLng(startLatitude, startLongitude);
      final destination = LatLng(destinationLatitude, destinationLongitude);

      // Get estimated travel time
      final result = await _navigationDataSource.getEstimatedTravelTime(
        origin,
        destination,
        mode: 'driving',
      );

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      // Parse the duration string (e.g., "2 hours 30 mins")
      final durationString = result.data!;
      int minutes = 0;

      // Extract hours
      final hoursMatch = RegExp(r'(\d+)\s*hour').firstMatch(durationString);
      if (hoursMatch != null) {
        minutes += int.parse(hoursMatch.group(1)!) * 60;
      }

      // Extract minutes
      final minsMatch = RegExp(r'(\d+)\s*min').firstMatch(durationString);
      if (minsMatch != null) {
        minutes += int.parse(minsMatch.group(1)!);
      }

      // Calculate ETA
      final now = DateTime.now();
      final eta = now.add(Duration(minutes: minutes));

      return Result.success(eta);
    } catch (e) {
      return Result.error('到着予定時刻取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<double>> getWalkingDistance(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    try {
      final origin = LatLng(startLatitude, startLongitude);
      final destination = LatLng(destinationLatitude, destinationLongitude);

      // Get estimated travel distance
      final result = await _navigationDataSource.getEstimatedTravelDistance(
        origin,
        destination,
        mode: 'walking',
      );

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      // Parse the distance string (e.g., "2.5 km" or "500 m")
      final distanceString = result.data!;
      double meters = 0;

      // Extract kilometers
      final kmMatch = RegExp(r'(\d+(\.\d+)?)\s*km').firstMatch(distanceString);
      if (kmMatch != null) {
        meters = double.parse(kmMatch.group(1)!) * 1000;
      } else {
        // Extract meters
        final mMatch = RegExp(r'(\d+(\.\d+)?)\s*m').firstMatch(distanceString);
        if (mMatch != null) {
          meters = double.parse(mMatch.group(1)!);
        }
      }

      return Result.success(meters);
    } catch (e) {
      return Result.error('徒歩距離取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<int>> getWalkingTime(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    try {
      final origin = LatLng(startLatitude, startLongitude);
      final destination = LatLng(destinationLatitude, destinationLongitude);

      // Get estimated travel time
      final result = await _navigationDataSource.getEstimatedTravelTime(
        origin,
        destination,
        mode: 'walking',
      );

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      // Parse the duration string (e.g., "30 mins" or "1 hour 15 mins")
      final durationString = result.data!;
      int minutes = 0;

      // Extract hours
      final hoursMatch = RegExp(r'(\d+)\s*hour').firstMatch(durationString);
      if (hoursMatch != null) {
        minutes += int.parse(hoursMatch.group(1)!) * 60;
      }

      // Extract minutes
      final minsMatch = RegExp(r'(\d+)\s*min').firstMatch(durationString);
      if (minsMatch != null) {
        minutes += int.parse(minsMatch.group(1)!);
      }

      return Result.success(minutes);
    } catch (e) {
      return Result.error('徒歩時間取得中にエラーが発生しました: $e');
    }
  }
}

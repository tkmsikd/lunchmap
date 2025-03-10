import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/route_model.dart';
import '../../core/exceptions/result.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Interface for navigation data source
abstract class NavigationDataSource {
  /// Gets a route between two points
  Future<Result<RouteModel>> getRoute(
    LatLng origin,
    LatLng destination, {
    String mode = 'driving',
  });

  /// Gets the estimated travel time between two points
  Future<Result<String>> getEstimatedTravelTime(
    LatLng origin,
    LatLng destination, {
    String mode = 'driving',
  });

  /// Gets the estimated travel distance between two points
  Future<Result<String>> getEstimatedTravelDistance(
    LatLng origin,
    LatLng destination, {
    String mode = 'driving',
  });

  /// Gets alternative routes between two points
  Future<Result<List<RouteModel>>> getAlternativeRoutes(
    LatLng origin,
    LatLng destination, {
    String mode = 'driving',
    int alternatives = 3,
  });

  /// Gets a route with waypoints
  Future<Result<RouteModel>> getRouteWithWaypoints(
    LatLng origin,
    LatLng destination,
    List<LatLng> waypoints, {
    String mode = 'driving',
  });
}

/// Google Maps implementation of NavigationDataSource
class GoogleMapsNavigationDataSource implements NavigationDataSource {
  final String _apiKey;
  final http.Client _httpClient;

  /// Creates a new GoogleMapsNavigationDataSource with the given dependencies
  GoogleMapsNavigationDataSource({
    required String apiKey,
    http.Client? httpClient,
  }) : _apiKey = apiKey,
       _httpClient = httpClient ?? http.Client();

  @override
  Future<Result<RouteModel>> getRoute(
    LatLng origin,
    LatLng destination, {
    String mode = 'driving',
  }) async {
    try {
      final url =
          Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
            'origin': '${origin.latitude},${origin.longitude}',
            'destination': '${destination.latitude},${destination.longitude}',
            'mode': mode,
            'key': _apiKey,
          });

      final response = await _httpClient.get(url);

      if (response.statusCode != 200) {
        return Result.error('ルート取得中にエラーが発生しました: ${response.statusCode}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;

      if (data['status'] != 'OK') {
        return Result.error('ルート取得中にエラーが発生しました: ${data['status']}');
      }

      final routes = data['routes'] as List<dynamic>;
      if (routes.isEmpty) {
        return Result.error('ルートが見つかりませんでした');
      }

      final route = routes[0] as Map<String, dynamic>;
      final legs = route['legs'] as List<dynamic>;
      final leg = legs[0] as Map<String, dynamic>;

      // Extract route information
      final distance = leg['distance']['text'] as String;
      final duration = leg['duration']['text'] as String;

      // Extract steps and instructions
      final steps = leg['steps'] as List<dynamic>;
      final instructions =
          steps.map((step) => step['html_instructions'] as String).toList();

      // Extract polyline points
      final encodedPolyline = route['overview_polyline']['points'] as String;
      final points = _decodePolyline(encodedPolyline);

      return Result.success(
        RouteModel(
          points: points,
          distance: distance,
          duration: duration,
          instructions: instructions,
        ),
      );
    } catch (e) {
      return Result.error('ルート取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<String>> getEstimatedTravelTime(
    LatLng origin,
    LatLng destination, {
    String mode = 'driving',
  }) async {
    try {
      final url =
          Uri.https('maps.googleapis.com', '/maps/api/distancematrix/json', {
            'origins': '${origin.latitude},${origin.longitude}',
            'destinations': '${destination.latitude},${destination.longitude}',
            'mode': mode,
            'key': _apiKey,
          });

      final response = await _httpClient.get(url);

      if (response.statusCode != 200) {
        return Result.error('所要時間取得中にエラーが発生しました: ${response.statusCode}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;

      if (data['status'] != 'OK') {
        return Result.error('所要時間取得中にエラーが発生しました: ${data['status']}');
      }

      final rows = data['rows'] as List<dynamic>;
      if (rows.isEmpty) {
        return Result.error('所要時間が見つかりませんでした');
      }

      final elements = rows[0]['elements'] as List<dynamic>;
      if (elements.isEmpty) {
        return Result.error('所要時間が見つかりませんでした');
      }

      final element = elements[0] as Map<String, dynamic>;
      if (element['status'] != 'OK') {
        return Result.error('所要時間取得中にエラーが発生しました: ${element['status']}');
      }

      final duration = element['duration']['text'] as String;

      return Result.success(duration);
    } catch (e) {
      return Result.error('所要時間取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<String>> getEstimatedTravelDistance(
    LatLng origin,
    LatLng destination, {
    String mode = 'driving',
  }) async {
    try {
      final url =
          Uri.https('maps.googleapis.com', '/maps/api/distancematrix/json', {
            'origins': '${origin.latitude},${origin.longitude}',
            'destinations': '${destination.latitude},${destination.longitude}',
            'mode': mode,
            'key': _apiKey,
          });

      final response = await _httpClient.get(url);

      if (response.statusCode != 200) {
        return Result.error('距離取得中にエラーが発生しました: ${response.statusCode}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;

      if (data['status'] != 'OK') {
        return Result.error('距離取得中にエラーが発生しました: ${data['status']}');
      }

      final rows = data['rows'] as List<dynamic>;
      if (rows.isEmpty) {
        return Result.error('距離が見つかりませんでした');
      }

      final elements = rows[0]['elements'] as List<dynamic>;
      if (elements.isEmpty) {
        return Result.error('距離が見つかりませんでした');
      }

      final element = elements[0] as Map<String, dynamic>;
      if (element['status'] != 'OK') {
        return Result.error('距離取得中にエラーが発生しました: ${element['status']}');
      }

      final distance = element['distance']['text'] as String;

      return Result.success(distance);
    } catch (e) {
      return Result.error('距離取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<List<RouteModel>>> getAlternativeRoutes(
    LatLng origin,
    LatLng destination, {
    String mode = 'driving',
    int alternatives = 3,
  }) async {
    try {
      final url =
          Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
            'origin': '${origin.latitude},${origin.longitude}',
            'destination': '${destination.latitude},${destination.longitude}',
            'mode': mode,
            'alternatives': 'true',
            'key': _apiKey,
          });

      final response = await _httpClient.get(url);

      if (response.statusCode != 200) {
        return Result.error('代替ルート取得中にエラーが発生しました: ${response.statusCode}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;

      if (data['status'] != 'OK') {
        return Result.error('代替ルート取得中にエラーが発生しました: ${data['status']}');
      }

      final routes = data['routes'] as List<dynamic>;
      if (routes.isEmpty) {
        return Result.error('ルートが見つかりませんでした');
      }

      final routeModels = <RouteModel>[];

      // Limit to the requested number of alternatives
      final routeCount =
          routes.length > alternatives ? alternatives : routes.length;

      for (int i = 0; i < routeCount; i++) {
        final route = routes[i] as Map<String, dynamic>;
        final legs = route['legs'] as List<dynamic>;
        final leg = legs[0] as Map<String, dynamic>;

        // Extract route information
        final distance = leg['distance']['text'] as String;
        final duration = leg['duration']['text'] as String;

        // Extract steps and instructions
        final steps = leg['steps'] as List<dynamic>;
        final instructions =
            steps.map((step) => step['html_instructions'] as String).toList();

        // Extract polyline points
        final encodedPolyline = route['overview_polyline']['points'] as String;
        final points = _decodePolyline(encodedPolyline);

        routeModels.add(
          RouteModel(
            points: points,
            distance: distance,
            duration: duration,
            instructions: instructions,
          ),
        );
      }

      return Result.success(routeModels);
    } catch (e) {
      return Result.error('代替ルート取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<RouteModel>> getRouteWithWaypoints(
    LatLng origin,
    LatLng destination,
    List<LatLng> waypoints, {
    String mode = 'driving',
  }) async {
    try {
      // Format waypoints
      final waypointsParam = waypoints
          .map((waypoint) => '${waypoint.latitude},${waypoint.longitude}')
          .join('|');

      final url =
          Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
            'origin': '${origin.latitude},${origin.longitude}',
            'destination': '${destination.latitude},${destination.longitude}',
            'waypoints': waypointsParam,
            'mode': mode,
            'key': _apiKey,
          });

      final response = await _httpClient.get(url);

      if (response.statusCode != 200) {
        return Result.error('ルート取得中にエラーが発生しました: ${response.statusCode}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;

      if (data['status'] != 'OK') {
        return Result.error('ルート取得中にエラーが発生しました: ${data['status']}');
      }

      final routes = data['routes'] as List<dynamic>;
      if (routes.isEmpty) {
        return Result.error('ルートが見つかりませんでした');
      }

      final route = routes[0] as Map<String, dynamic>;
      final legs = route['legs'] as List<dynamic>;

      // Combine all legs
      String totalDistance = '';
      String totalDuration = '';
      final allInstructions = <String>[];

      for (final leg in legs) {
        final legDistance = leg['distance']['text'] as String;
        final legDuration = leg['duration']['text'] as String;

        // For the first leg, set the total distance and duration
        if (totalDistance.isEmpty) {
          totalDistance = legDistance;
          totalDuration = legDuration;
        } else {
          // For subsequent legs, add the distance and duration
          // This is a simplistic approach; in a real app, you'd parse and add the values
          totalDistance = '$totalDistance + $legDistance';
          totalDuration = '$totalDuration + $legDuration';
        }

        // Extract steps and instructions for this leg
        final steps = leg['steps'] as List<dynamic>;
        final legInstructions =
            steps.map((step) => step['html_instructions'] as String).toList();
        allInstructions.addAll(legInstructions);
      }

      // Extract polyline points
      final encodedPolyline = route['overview_polyline']['points'] as String;
      final points = _decodePolyline(encodedPolyline);

      return Result.success(
        RouteModel(
          points: points,
          distance: totalDistance,
          duration: totalDuration,
          instructions: allInstructions,
        ),
      );
    } catch (e) {
      return Result.error('ルート取得中にエラーが発生しました: $e');
    }
  }

  /// Decodes an encoded polyline string into a list of LatLng points
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }
}

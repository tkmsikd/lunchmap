import 'dart:math' as math;

/// Utility functions for location operations
class LocationUtils {
  /// Earth radius in meters
  static const double earthRadius = 6371000.0;

  /// Calculate the distance between two coordinates in meters
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Haversine formula
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  /// Format a distance in meters to a human-readable string
  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()}m';
    } else {
      final distanceInKm = distanceInMeters / 1000;
      return '${distanceInKm.toStringAsFixed(1)}km';
    }
  }

  /// Calculate the estimated walking time in minutes for a given distance in meters
  /// Assumes an average walking speed of 5 km/h (83.33 m/min)
  static int calculateWalkingTime(double distanceInMeters) {
    const walkingSpeedMetersPerMinute = 83.33;
    return (distanceInMeters / walkingSpeedMetersPerMinute).ceil();
  }

  /// Format a walking time in minutes to a human-readable string
  static String formatWalkingTime(int walkingTimeMinutes) {
    if (walkingTimeMinutes < 60) {
      return '$walkingTimeMinutes分';
    } else {
      final hours = walkingTimeMinutes ~/ 60;
      final minutes = walkingTimeMinutes % 60;

      if (minutes == 0) {
        return '$hours時間';
      } else {
        return '$hours時間$minutes分';
      }
    }
  }

  /// Check if a location is within a certain radius of another location
  static bool isWithinRadius(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
    double radiusInMeters,
  ) {
    final distance = calculateDistance(lat1, lon1, lat2, lon2);
    return distance <= radiusInMeters;
  }

  /// Calculate the center point of multiple coordinates
  static Map<String, double> calculateCenter(
    List<Map<String, double>> coordinates,
  ) {
    if (coordinates.isEmpty) {
      throw ArgumentError('Coordinates list cannot be empty');
    }

    double sumLat = 0;
    double sumLon = 0;

    for (final coordinate in coordinates) {
      sumLat += coordinate['latitude']!;
      sumLon += coordinate['longitude']!;
    }

    return {
      'latitude': sumLat / coordinates.length,
      'longitude': sumLon / coordinates.length,
    };
  }

  /// Calculate the bounding box that contains all coordinates
  static Map<String, double> calculateBoundingBox(
    List<Map<String, double>> coordinates,
  ) {
    if (coordinates.isEmpty) {
      throw ArgumentError('Coordinates list cannot be empty');
    }

    double minLat = coordinates[0]['latitude']!;
    double maxLat = coordinates[0]['latitude']!;
    double minLon = coordinates[0]['longitude']!;
    double maxLon = coordinates[0]['longitude']!;

    for (final coordinate in coordinates) {
      final lat = coordinate['latitude']!;
      final lon = coordinate['longitude']!;

      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lon < minLon) minLon = lon;
      if (lon > maxLon) maxLon = lon;
    }

    return {
      'minLatitude': minLat,
      'maxLatitude': maxLat,
      'minLongitude': minLon,
      'maxLongitude': maxLon,
    };
  }

  /// Convert degrees to radians
  static double _toRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  /// Convert radians to degrees
  static double _toDegrees(double radians) {
    return radians * 180 / math.pi;
  }
}

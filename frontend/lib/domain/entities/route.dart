import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Route entity representing a navigation route between two points
class RouteEntity {
  /// List of points that make up the route
  final List<LatLng> points;

  /// Total distance of the route in meters
  final String distance;

  /// Estimated duration to travel the route
  final String duration;

  /// Step-by-step instructions for the route
  final List<String> instructions;

  /// Creates a new RouteEntity instance
  const RouteEntity({
    required this.points,
    required this.distance,
    required this.duration,
    required this.instructions,
  });

  /// Creates a copy of this RouteEntity with the given fields replaced with new values
  RouteEntity copyWith({
    List<LatLng>? points,
    String? distance,
    String? duration,
    List<String>? instructions,
  }) {
    return RouteEntity(
      points: points ?? this.points,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      instructions: instructions ?? this.instructions,
    );
  }

  /// Gets the starting point of the route
  LatLng get startPoint {
    return points.first;
  }

  /// Gets the ending point of the route
  LatLng get endPoint {
    return points.last;
  }

  /// Gets the number of points in the route
  int get pointCount {
    return points.length;
  }

  /// Gets the number of instructions in the route
  int get instructionCount {
    return instructions.length;
  }

  /// Gets a simplified version of the route with fewer points
  /// [simplificationFactor] determines how many points to skip (higher = more simplification)
  RouteEntity simplify(int simplificationFactor) {
    if (simplificationFactor <= 1 || points.length <= 2) {
      return this;
    }

    final simplifiedPoints = <LatLng>[];

    // Always include the first and last points
    simplifiedPoints.add(points.first);

    // Add intermediate points based on the simplification factor
    for (int i = 1; i < points.length - 1; i++) {
      if (i % simplificationFactor == 0) {
        simplifiedPoints.add(points[i]);
      }
    }

    simplifiedPoints.add(points.last);

    return copyWith(points: simplifiedPoints);
  }

  /// Calculates the bounding box that contains all points in the route
  Map<String, double> getBoundingBox() {
    if (points.isEmpty) {
      throw StateError('Route has no points');
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return {
      'minLatitude': minLat,
      'maxLatitude': maxLat,
      'minLongitude': minLng,
      'maxLongitude': maxLng,
    };
  }

  /// Gets the center point of the route
  LatLng getCenterPoint() {
    if (points.isEmpty) {
      throw StateError('Route has no points');
    }

    final boundingBox = getBoundingBox();

    return LatLng(
      (boundingBox['minLatitude']! + boundingBox['maxLatitude']!) / 2,
      (boundingBox['minLongitude']! + boundingBox['maxLongitude']!) / 2,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RouteEntity &&
        _listEquals(other.points, points) &&
        other.distance == distance &&
        other.duration == duration &&
        _listEquals(other.instructions, instructions);
  }

  @override
  int get hashCode {
    return points.hashCode ^
        distance.hashCode ^
        duration.hashCode ^
        instructions.hashCode;
  }

  /// Helper method to check if two lists are equal
  bool _listEquals<T>(List<T> list1, List<T> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }
}

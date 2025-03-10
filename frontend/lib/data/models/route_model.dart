import '../../domain/entities/route.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Data model for RouteEntity
class RouteModel {
  /// List of points that make up the route
  final List<LatLng> points;

  /// Total distance of the route in meters
  final String distance;

  /// Estimated duration to travel the route
  final String duration;

  /// Step-by-step instructions for the route
  final List<String> instructions;

  /// Creates a new RouteModel instance
  const RouteModel({
    required this.points,
    required this.distance,
    required this.duration,
    required this.instructions,
  });

  /// Creates a RouteModel from a JSON map
  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      points:
          (json['points'] as List<dynamic>)
              .map(
                (e) => LatLng(
                  (e['latitude'] as num).toDouble(),
                  (e['longitude'] as num).toDouble(),
                ),
              )
              .toList(),
      distance: json['distance'] as String,
      duration: json['duration'] as String,
      instructions:
          (json['instructions'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
    );
  }

  /// Converts this RouteModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'points':
          points
              .map((e) => {'latitude': e.latitude, 'longitude': e.longitude})
              .toList(),
      'distance': distance,
      'duration': duration,
      'instructions': instructions,
    };
  }

  /// Converts this RouteModel to a RouteEntity
  RouteEntity toEntity() {
    return RouteEntity(
      points: points,
      distance: distance,
      duration: duration,
      instructions: instructions,
    );
  }

  /// Creates a RouteModel from a RouteEntity
  factory RouteModel.fromEntity(RouteEntity route) {
    return RouteModel(
      points: route.points,
      distance: route.distance,
      duration: route.duration,
      instructions: route.instructions,
    );
  }
}

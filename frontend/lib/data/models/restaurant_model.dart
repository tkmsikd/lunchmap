import '../../domain/entities/restaurant.dart';

/// Data model for Restaurant entity
class RestaurantModel {
  /// Unique identifier for the restaurant
  final String id;

  /// Restaurant name
  final String name;

  /// Restaurant description
  final String description;

  /// Latitude coordinate of the restaurant location
  final double latitude;

  /// Longitude coordinate of the restaurant location
  final double longitude;

  /// Physical address of the restaurant
  final String address;

  /// List of categories that the restaurant belongs to
  final List<String> categories;

  /// Average rating of the restaurant (1-5 stars)
  final double averageRating;

  /// Number of reviews for the restaurant
  final int reviewCount;

  /// URL to the restaurant's image (optional)
  final String? imageUrl;

  /// Business hours of the restaurant (optional)
  /// Format: Map with keys as day names (e.g., 'Monday') and values as time ranges (e.g., '11:00-22:00')
  final Map<String, String>? businessHours;

  /// Whether the restaurant is currently crowded (optional)
  final bool? isCrowded;

  /// Creates a new RestaurantModel instance
  const RestaurantModel({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.categories,
    required this.averageRating,
    required this.reviewCount,
    this.imageUrl,
    this.businessHours,
    this.isCrowded,
  });

  /// Creates a RestaurantModel from a JSON map
  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String,
      categories:
          (json['categories'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      averageRating: (json['averageRating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      imageUrl: json['imageUrl'] as String?,
      businessHours:
          json['businessHours'] != null
              ? Map<String, String>.from(json['businessHours'] as Map)
              : null,
      isCrowded: json['isCrowded'] as bool?,
    );
  }

  /// Converts this RestaurantModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'categories': categories,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'imageUrl': imageUrl,
      'businessHours': businessHours,
      'isCrowded': isCrowded,
    };
  }

  /// Converts this RestaurantModel to a Restaurant entity
  Restaurant toEntity() {
    return Restaurant(
      id: id,
      name: name,
      description: description,
      latitude: latitude,
      longitude: longitude,
      address: address,
      categories: categories,
      averageRating: averageRating,
      reviewCount: reviewCount,
      imageUrl: imageUrl,
      businessHours: businessHours,
      isCrowded: isCrowded,
    );
  }

  /// Creates a RestaurantModel from a Restaurant entity
  factory RestaurantModel.fromEntity(Restaurant restaurant) {
    return RestaurantModel(
      id: restaurant.id,
      name: restaurant.name,
      description: restaurant.description,
      latitude: restaurant.latitude,
      longitude: restaurant.longitude,
      address: restaurant.address,
      categories: restaurant.categories,
      averageRating: restaurant.averageRating,
      reviewCount: restaurant.reviewCount,
      imageUrl: restaurant.imageUrl,
      businessHours: restaurant.businessHours,
      isCrowded: restaurant.isCrowded,
    );
  }
}

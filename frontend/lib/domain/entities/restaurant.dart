/// Restaurant entity representing a restaurant in the system
class Restaurant {
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

  /// Creates a new Restaurant instance
  const Restaurant({
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

  /// Creates a copy of this Restaurant with the given fields replaced with new values
  Restaurant copyWith({
    String? id,
    String? name,
    String? description,
    double? latitude,
    double? longitude,
    String? address,
    List<String>? categories,
    double? averageRating,
    int? reviewCount,
    String? imageUrl,
    Map<String, String>? businessHours,
    bool? isCrowded,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      categories: categories ?? this.categories,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrl: imageUrl ?? this.imageUrl,
      businessHours: businessHours ?? this.businessHours,
      isCrowded: isCrowded ?? this.isCrowded,
    );
  }

  /// Updates the average rating and review count based on a new review
  Restaurant updateRating(double newRating) {
    final totalRatingPoints = averageRating * reviewCount + newRating;
    final newReviewCount = reviewCount + 1;
    final newAverageRating = totalRatingPoints / newReviewCount;

    return copyWith(
      averageRating: newAverageRating,
      reviewCount: newReviewCount,
    );
  }

  /// Checks if the restaurant is open at the given time
  bool isOpenAt(DateTime time, {String? dayOverride}) {
    if (businessHours == null) {
      return false;
    }

    final dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    final day = dayOverride ?? dayNames[time.weekday - 1];
    final hours = businessHours![day];

    if (hours == null || hours.isEmpty || hours.toLowerCase() == 'closed') {
      return false;
    }

    // Parse hours in format "HH:MM-HH:MM"
    final parts = hours.split('-');
    if (parts.length != 2) {
      return false;
    }

    final openTime = _parseTime(parts[0]);
    final closeTime = _parseTime(parts[1]);

    if (openTime == null || closeTime == null) {
      return false;
    }

    final currentTime = DateTime(
      time.year,
      time.month,
      time.day,
      time.hour,
      time.minute,
    );

    final openDateTime = DateTime(
      time.year,
      time.month,
      time.day,
      openTime.hour,
      openTime.minute,
    );

    final closeDateTime = DateTime(
      time.year,
      time.month,
      time.day,
      closeTime.hour,
      closeTime.minute,
    );

    // Handle cases where closing time is on the next day
    if (closeDateTime.isBefore(openDateTime)) {
      closeDateTime.add(const Duration(days: 1));
    }

    return currentTime.isAfter(openDateTime) &&
        currentTime.isBefore(closeDateTime);
  }

  /// Checks if the restaurant is currently open
  bool get isOpen {
    return isOpenAt(DateTime.now());
  }

  /// Checks if the restaurant belongs to a specific category
  bool hasCategory(String category) {
    return categories.contains(category);
  }

  /// Helper method to parse a time string in format "HH:MM"
  DateTime? _parseTime(String timeString) {
    final parts = timeString.trim().split(':');
    if (parts.length != 2) {
      return null;
    }

    try {
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        return null;
      }

      return DateTime(2022, 1, 1, hour, minute);
    } catch (e) {
      return null;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Restaurant &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.address == address &&
        _listEquals(other.categories, categories) &&
        other.averageRating == averageRating &&
        other.reviewCount == reviewCount &&
        other.imageUrl == imageUrl &&
        _mapEquals(other.businessHours, businessHours) &&
        other.isCrowded == isCrowded;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        address.hashCode ^
        categories.hashCode ^
        averageRating.hashCode ^
        reviewCount.hashCode ^
        imageUrl.hashCode ^
        businessHours.hashCode ^
        isCrowded.hashCode;
  }

  /// Helper method to check if two lists are equal
  bool _listEquals<T>(List<T> list1, List<T> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  /// Helper method to check if two maps are equal
  bool _mapEquals<K, V>(Map<K, V>? map1, Map<K, V>? map2) {
    if (map1 == null && map2 == null) return true;
    if (map1 == null || map2 == null) return false;
    if (map1.length != map2.length) return false;

    for (final key in map1.keys) {
      if (!map2.containsKey(key) || map1[key] != map2[key]) {
        return false;
      }
    }

    return true;
  }
}

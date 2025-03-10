/// User entity representing a user in the system
class User {
  /// Unique identifier for the user
  final String id;

  /// User's display name
  final String name;

  /// User's email address
  final String email;

  /// URL to the user's avatar image (optional)
  final String? avatarUrl;

  /// List of restaurant IDs that the user has marked as favorites
  final List<String> favoriteRestaurantIds;

  /// List of team IDs that the user is a member of
  final List<String> teamIds;

  /// Creates a new User instance
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.favoriteRestaurantIds = const [],
    this.teamIds = const [],
  });

  /// Creates a copy of this User with the given fields replaced with new values
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    List<String>? favoriteRestaurantIds,
    List<String>? teamIds,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      favoriteRestaurantIds:
          favoriteRestaurantIds ?? this.favoriteRestaurantIds,
      teamIds: teamIds ?? this.teamIds,
    );
  }

  /// Adds a restaurant ID to the user's favorites
  User addFavoriteRestaurant(String restaurantId) {
    if (favoriteRestaurantIds.contains(restaurantId)) {
      return this;
    }

    return copyWith(
      favoriteRestaurantIds: [...favoriteRestaurantIds, restaurantId],
    );
  }

  /// Removes a restaurant ID from the user's favorites
  User removeFavoriteRestaurant(String restaurantId) {
    if (!favoriteRestaurantIds.contains(restaurantId)) {
      return this;
    }

    return copyWith(
      favoriteRestaurantIds:
          favoriteRestaurantIds.where((id) => id != restaurantId).toList(),
    );
  }

  /// Adds a team ID to the user's teams
  User addTeam(String teamId) {
    if (teamIds.contains(teamId)) {
      return this;
    }

    return copyWith(teamIds: [...teamIds, teamId]);
  }

  /// Removes a team ID from the user's teams
  User removeTeam(String teamId) {
    if (!teamIds.contains(teamId)) {
      return this;
    }

    return copyWith(teamIds: teamIds.where((id) => id != teamId).toList());
  }

  /// Checks if a restaurant is in the user's favorites
  bool isFavoriteRestaurant(String restaurantId) {
    return favoriteRestaurantIds.contains(restaurantId);
  }

  /// Checks if the user is a member of a team
  bool isTeamMember(String teamId) {
    return teamIds.contains(teamId);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.avatarUrl == avatarUrl &&
        _listEquals(other.favoriteRestaurantIds, favoriteRestaurantIds) &&
        _listEquals(other.teamIds, teamIds);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        avatarUrl.hashCode ^
        favoriteRestaurantIds.hashCode ^
        teamIds.hashCode;
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

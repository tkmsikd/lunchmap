/// Team entity representing a group of users who can share restaurant information
class Team {
  /// Unique identifier for the team
  final String id;

  /// Name of the team
  final String name;

  /// ID of the user who created the team
  final String creatorId;

  /// List of user IDs who are members of the team
  final List<String> memberIds;

  /// List of restaurant IDs that have been shared with the team
  final List<String> sharedRestaurantIds;

  /// Creates a new Team instance
  const Team({
    required this.id,
    required this.name,
    required this.creatorId,
    required this.memberIds,
    this.sharedRestaurantIds = const [],
  });

  /// Creates a copy of this Team with the given fields replaced with new values
  Team copyWith({
    String? id,
    String? name,
    String? creatorId,
    List<String>? memberIds,
    List<String>? sharedRestaurantIds,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      creatorId: creatorId ?? this.creatorId,
      memberIds: memberIds ?? this.memberIds,
      sharedRestaurantIds: sharedRestaurantIds ?? this.sharedRestaurantIds,
    );
  }

  /// Adds a member to the team
  Team addMember(String userId) {
    if (memberIds.contains(userId)) {
      return this;
    }

    return copyWith(memberIds: [...memberIds, userId]);
  }

  /// Removes a member from the team
  Team removeMember(String userId) {
    if (!memberIds.contains(userId)) {
      return this;
    }

    // Don't allow removing the creator
    if (userId == creatorId) {
      return this;
    }

    return copyWith(memberIds: memberIds.where((id) => id != userId).toList());
  }

  /// Adds a restaurant to the team's shared restaurants
  Team addSharedRestaurant(String restaurantId) {
    if (sharedRestaurantIds.contains(restaurantId)) {
      return this;
    }

    return copyWith(
      sharedRestaurantIds: [...sharedRestaurantIds, restaurantId],
    );
  }

  /// Removes a restaurant from the team's shared restaurants
  Team removeSharedRestaurant(String restaurantId) {
    if (!sharedRestaurantIds.contains(restaurantId)) {
      return this;
    }

    return copyWith(
      sharedRestaurantIds:
          sharedRestaurantIds.where((id) => id != restaurantId).toList(),
    );
  }

  /// Checks if a user is a member of the team
  bool isMember(String userId) {
    return memberIds.contains(userId);
  }

  /// Checks if a user is the creator of the team
  bool isCreator(String userId) {
    return creatorId == userId;
  }

  /// Checks if a restaurant is shared with the team
  bool isRestaurantShared(String restaurantId) {
    return sharedRestaurantIds.contains(restaurantId);
  }

  /// Gets the number of members in the team
  int get memberCount {
    return memberIds.length;
  }

  /// Gets the number of shared restaurants in the team
  int get sharedRestaurantCount {
    return sharedRestaurantIds.length;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Team &&
        other.id == id &&
        other.name == name &&
        other.creatorId == creatorId &&
        _listEquals(other.memberIds, memberIds) &&
        _listEquals(other.sharedRestaurantIds, sharedRestaurantIds);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        creatorId.hashCode ^
        memberIds.hashCode ^
        sharedRestaurantIds.hashCode;
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

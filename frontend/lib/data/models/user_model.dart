import '../../domain/entities/user.dart';

/// Data model for User entity
class UserModel {
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

  /// Creates a new UserModel instance
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.favoriteRestaurantIds = const [],
    this.teamIds = const [],
  });

  /// Creates a UserModel from a JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      favoriteRestaurantIds:
          (json['favoriteRestaurantIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      teamIds:
          (json['teamIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  /// Converts this UserModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'favoriteRestaurantIds': favoriteRestaurantIds,
      'teamIds': teamIds,
    };
  }

  /// Converts this UserModel to a User entity
  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      favoriteRestaurantIds: favoriteRestaurantIds,
      teamIds: teamIds,
    );
  }

  /// Creates a UserModel from a User entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      avatarUrl: user.avatarUrl,
      favoriteRestaurantIds: user.favoriteRestaurantIds,
      teamIds: user.teamIds,
    );
  }
}

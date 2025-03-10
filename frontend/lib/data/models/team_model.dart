import '../../domain/entities/team.dart';

/// Data model for Team entity
class TeamModel {
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

  /// Creates a new TeamModel instance
  const TeamModel({
    required this.id,
    required this.name,
    required this.creatorId,
    required this.memberIds,
    this.sharedRestaurantIds = const [],
  });

  /// Creates a TeamModel from a JSON map
  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id'] as String,
      name: json['name'] as String,
      creatorId: json['creatorId'] as String,
      memberIds:
          (json['memberIds'] as List<dynamic>).map((e) => e as String).toList(),
      sharedRestaurantIds:
          (json['sharedRestaurantIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  /// Converts this TeamModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'creatorId': creatorId,
      'memberIds': memberIds,
      'sharedRestaurantIds': sharedRestaurantIds,
    };
  }

  /// Converts this TeamModel to a Team entity
  Team toEntity() {
    return Team(
      id: id,
      name: name,
      creatorId: creatorId,
      memberIds: memberIds,
      sharedRestaurantIds: sharedRestaurantIds,
    );
  }

  /// Creates a TeamModel from a Team entity
  factory TeamModel.fromEntity(Team team) {
    return TeamModel(
      id: team.id,
      name: team.name,
      creatorId: team.creatorId,
      memberIds: team.memberIds,
      sharedRestaurantIds: team.sharedRestaurantIds,
    );
  }
}

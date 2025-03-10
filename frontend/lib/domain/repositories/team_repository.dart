import '../entities/team.dart';
import '../entities/restaurant.dart';
import '../../core/exceptions/result.dart';

/// Repository interface for team operations
abstract class TeamRepository {
  /// Creates a new team
  ///
  /// Returns a [Result] containing the created [Team] if successful,
  /// or an error message if unsuccessful
  Future<Result<Team>> createTeam(
    String name,
    String creatorId,
    List<String> initialMemberIds,
  );

  /// Gets a team by its ID
  ///
  /// Returns a [Result] containing the [Team] if successful,
  /// or an error message if unsuccessful
  Future<Result<Team>> getTeamById(String teamId);

  /// Updates a team's information
  ///
  /// Returns a [Result] containing the updated [Team] if successful,
  /// or an error message if unsuccessful
  Future<Result<Team>> updateTeam(Team team);

  /// Deletes a team
  ///
  /// Returns a [Result] indicating success or failure
  Future<Result<void>> deleteTeam(String teamId);

  /// Adds a member to a team
  ///
  /// Returns a [Result] containing the updated [Team] if successful,
  /// or an error message if unsuccessful
  Future<Result<Team>> addMemberToTeam(String teamId, String userId);

  /// Removes a member from a team
  ///
  /// Returns a [Result] containing the updated [Team] if successful,
  /// or an error message if unsuccessful
  Future<Result<Team>> removeMemberFromTeam(String teamId, String userId);

  /// Shares a restaurant with a team
  ///
  /// Returns a [Result] containing the updated [Team] if successful,
  /// or an error message if unsuccessful
  Future<Result<Team>> shareRestaurantWithTeam(
    String teamId,
    String restaurantId,
  );

  /// Removes a shared restaurant from a team
  ///
  /// Returns a [Result] containing the updated [Team] if successful,
  /// or an error message if unsuccessful
  Future<Result<Team>> removeSharedRestaurantFromTeam(
    String teamId,
    String restaurantId,
  );

  /// Gets restaurants shared with a team
  ///
  /// Returns a [Result] containing a list of [Restaurant] if successful,
  /// or an error message if unsuccessful
  Future<Result<List<Restaurant>>> getTeamSharedRestaurants(String teamId);

  /// Gets teams that a user is a member of
  ///
  /// Returns a [Result] containing a list of [Team] if successful,
  /// or an error message if unsuccessful
  Future<Result<List<Team>>> getUserTeams(String userId);

  /// Gets teams that a user created
  ///
  /// Returns a [Result] containing a list of [Team] if successful,
  /// or an error message if unsuccessful
  Future<Result<List<Team>>> getUserCreatedTeams(String userId);

  /// Checks if a user is a member of a team
  ///
  /// Returns a [Result] containing a boolean if successful,
  /// or an error message if unsuccessful
  Future<Result<bool>> isUserTeamMember(String teamId, String userId);

  /// Checks if a user is the creator of a team
  ///
  /// Returns a [Result] containing a boolean if successful,
  /// or an error message if unsuccessful
  Future<Result<bool>> isUserTeamCreator(String teamId, String userId);
}

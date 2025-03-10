import '../../repositories/team_repository.dart';
import '../../../core/exceptions/result.dart';
import '../../entities/team.dart';

/// Use case for getting teams that a user is a member of
class GetUserTeamsUseCase {
  /// The repository that this use case will use
  final TeamRepository repository;

  /// Creates a new GetUserTeamsUseCase with the given repository
  const GetUserTeamsUseCase(this.repository);

  /// Executes the use case
  ///
  /// [userId] is the ID of the user whose teams to get
  ///
  /// Returns a [Result] containing a list of [Team] if successful,
  /// or an error message if unsuccessful
  Future<Result<List<Team>>> execute(String userId) async {
    // Validate user ID
    if (userId.isEmpty) {
      return Result.validationError('ユーザーIDが無効です');
    }

    try {
      // Get the user's teams
      return await repository.getUserTeams(userId);
    } catch (e) {
      return Result.error('ユーザーのチーム取得中にエラーが発生しました: $e');
    }
  }
}

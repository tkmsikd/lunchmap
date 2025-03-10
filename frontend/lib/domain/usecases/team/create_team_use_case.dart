import '../../repositories/team_repository.dart';
import '../../../core/exceptions/result.dart';
import '../../entities/team.dart';

/// Use case for creating a new team
class CreateTeamUseCase {
  /// The repository that this use case will use
  final TeamRepository repository;

  /// Creates a new CreateTeamUseCase with the given repository
  const CreateTeamUseCase(this.repository);

  /// Executes the use case
  ///
  /// [name] is the name of the team
  /// [creatorId] is the ID of the user creating the team
  /// [initialMemberIds] is a list of user IDs to add as initial members
  ///
  /// Returns a [Result] containing the created [Team] if successful,
  /// or an error message if unsuccessful
  Future<Result<Team>> execute(
    String name,
    String creatorId,
    List<String> initialMemberIds,
  ) async {
    // Validate team name
    if (name.isEmpty) {
      return Result.validationError('チーム名を入力してください');
    }

    // Validate creator ID
    if (creatorId.isEmpty) {
      return Result.validationError('作成者IDが無効です');
    }

    // Ensure creator is included in members
    if (!initialMemberIds.contains(creatorId)) {
      initialMemberIds = [...initialMemberIds, creatorId];
    }

    try {
      // Create the team
      return await repository.createTeam(name, creatorId, initialMemberIds);
    } catch (e) {
      return Result.error('チームの作成中にエラーが発生しました: $e');
    }
  }
}

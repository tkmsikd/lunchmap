import '../../domain/entities/team.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/repositories/team_repository.dart';
import '../../core/exceptions/result.dart';
import '../datasources/team_data_source.dart';
import '../models/team_model.dart';

/// Implementation of TeamRepository
class TeamRepositoryImpl implements TeamRepository {
  final TeamDataSource _teamDataSource;

  /// Creates a new TeamRepositoryImpl with the given dependencies
  TeamRepositoryImpl({required TeamDataSource teamDataSource})
    : _teamDataSource = teamDataSource;

  @override
  Future<Result<Team>> createTeam(
    String name,
    String creatorId,
    List<String> initialMemberIds,
  ) async {
    try {
      final result = await _teamDataSource.createTeam(
        name,
        creatorId,
        initialMemberIds,
      );

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      return Result.success(result.data!.toEntity());
    } catch (e) {
      return Result.error('チーム作成中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<Team>> getTeamById(String teamId) async {
    try {
      final result = await _teamDataSource.getTeamById(teamId);

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      return Result.success(result.data!.toEntity());
    } catch (e) {
      return Result.error('チーム情報の取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<Team>> updateTeam(Team team) async {
    try {
      // Convert domain entity to data model
      final teamModel = TeamModel.fromEntity(team);

      final result = await _teamDataSource.updateTeam(teamModel);

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      return Result.success(result.data!.toEntity());
    } catch (e) {
      return Result.error('チーム更新中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<void>> deleteTeam(String teamId) async {
    try {
      final result = await _teamDataSource.deleteTeam(teamId);

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      return Result.success(null);
    } catch (e) {
      return Result.error('チーム削除中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<Team>> addMemberToTeam(String teamId, String userId) async {
    try {
      final result = await _teamDataSource.addMemberToTeam(teamId, userId);

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      return Result.success(result.data!.toEntity());
    } catch (e) {
      return Result.error('チームメンバー追加中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<Team>> removeMemberFromTeam(
    String teamId,
    String userId,
  ) async {
    try {
      final result = await _teamDataSource.removeMemberFromTeam(teamId, userId);

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      return Result.success(result.data!.toEntity());
    } catch (e) {
      return Result.error('チームメンバー削除中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<Team>> shareRestaurantWithTeam(
    String teamId,
    String restaurantId,
  ) async {
    try {
      final result = await _teamDataSource.shareRestaurantWithTeam(
        teamId,
        restaurantId,
      );

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      return Result.success(result.data!.toEntity());
    } catch (e) {
      return Result.error('レストラン共有中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<Team>> removeSharedRestaurantFromTeam(
    String teamId,
    String restaurantId,
  ) async {
    try {
      final result = await _teamDataSource.removeSharedRestaurantFromTeam(
        teamId,
        restaurantId,
      );

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      return Result.success(result.data!.toEntity());
    } catch (e) {
      return Result.error('レストラン共有解除中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<List<Restaurant>>> getTeamSharedRestaurants(
    String teamId,
  ) async {
    try {
      final result = await _teamDataSource.getTeamSharedRestaurants(teamId);

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      final restaurants =
          result.data!.map((model) => model.toEntity()).toList();
      return Result.success(restaurants);
    } catch (e) {
      return Result.error('チーム共有レストラン取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<List<Team>>> getUserTeams(String userId) async {
    try {
      final result = await _teamDataSource.getUserTeams(userId);

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      final teams = result.data!.map((model) => model.toEntity()).toList();
      return Result.success(teams);
    } catch (e) {
      return Result.error('ユーザーのチーム取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<List<Team>>> getUserCreatedTeams(String userId) async {
    try {
      final result = await _teamDataSource.getUserCreatedTeams(userId);

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      final teams = result.data!.map((model) => model.toEntity()).toList();
      return Result.success(teams);
    } catch (e) {
      return Result.error('ユーザーの作成チーム取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<bool>> isUserTeamMember(String teamId, String userId) async {
    try {
      final result = await _teamDataSource.isUserTeamMember(teamId, userId);

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      return Result.success(result.data!);
    } catch (e) {
      return Result.error('チームメンバー確認中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<bool>> isUserTeamCreator(String teamId, String userId) async {
    try {
      final result = await _teamDataSource.isUserTeamCreator(teamId, userId);

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      return Result.success(result.data!);
    } catch (e) {
      return Result.error('チーム作成者確認中にエラーが発生しました: $e');
    }
  }
}

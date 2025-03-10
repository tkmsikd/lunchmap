import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/team_model.dart';
import '../models/restaurant_model.dart';
import '../../core/exceptions/result.dart';
import 'package:uuid/uuid.dart';

/// Interface for team data source
abstract class TeamDataSource {
  /// Creates a new team
  Future<Result<TeamModel>> createTeam(
    String name,
    String creatorId,
    List<String> initialMemberIds,
  );

  /// Gets a team by its ID
  Future<Result<TeamModel>> getTeamById(String teamId);

  /// Updates a team's information
  Future<Result<TeamModel>> updateTeam(TeamModel team);

  /// Deletes a team
  Future<Result<void>> deleteTeam(String teamId);

  /// Adds a member to a team
  Future<Result<TeamModel>> addMemberToTeam(String teamId, String userId);

  /// Removes a member from a team
  Future<Result<TeamModel>> removeMemberFromTeam(String teamId, String userId);

  /// Shares a restaurant with a team
  Future<Result<TeamModel>> shareRestaurantWithTeam(
    String teamId,
    String restaurantId,
  );

  /// Removes a shared restaurant from a team
  Future<Result<TeamModel>> removeSharedRestaurantFromTeam(
    String teamId,
    String restaurantId,
  );

  /// Gets restaurants shared with a team
  Future<Result<List<RestaurantModel>>> getTeamSharedRestaurants(String teamId);

  /// Gets teams that a user is a member of
  Future<Result<List<TeamModel>>> getUserTeams(String userId);

  /// Gets teams that a user created
  Future<Result<List<TeamModel>>> getUserCreatedTeams(String userId);

  /// Checks if a user is a member of a team
  Future<Result<bool>> isUserTeamMember(String teamId, String userId);

  /// Checks if a user is the creator of a team
  Future<Result<bool>> isUserTeamCreator(String teamId, String userId);
}

/// Firebase implementation of TeamDataSource
class FirebaseTeamDataSource implements TeamDataSource {
  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  /// Creates a new FirebaseTeamDataSource with the given dependencies
  FirebaseTeamDataSource({FirebaseFirestore? firestore, Uuid? uuid})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _uuid = uuid ?? const Uuid();

  @override
  Future<Result<TeamModel>> createTeam(
    String name,
    String creatorId,
    List<String> initialMemberIds,
  ) async {
    try {
      // Generate a new ID
      final teamId = _uuid.v4();

      // Ensure creator is included in members
      if (!initialMemberIds.contains(creatorId)) {
        initialMemberIds = [...initialMemberIds, creatorId];
      }

      // Create team data
      final teamData = {
        'id': teamId,
        'name': name,
        'creatorId': creatorId,
        'memberIds': initialMemberIds,
        'sharedRestaurantIds': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Save to Firestore
      await _firestore.collection('teams').doc(teamId).set(teamData);

      // Update user documents to include this team
      for (final userId in initialMemberIds) {
        await _firestore.collection('users').doc(userId).update({
          'teamIds': FieldValue.arrayUnion([teamId]),
        });
      }

      // Convert to TeamModel
      final team = TeamModel(
        id: teamId,
        name: name,
        creatorId: creatorId,
        memberIds: initialMemberIds,
        sharedRestaurantIds: [],
      );

      return Result.success(team);
    } catch (e) {
      return Result.error('チーム作成中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<TeamModel>> getTeamById(String teamId) async {
    try {
      final doc = await _firestore.collection('teams').doc(teamId).get();

      if (!doc.exists) {
        return Result.error('チームが見つかりませんでした');
      }

      return Result.success(
        TeamModel.fromJson(doc.data() as Map<String, dynamic>),
      );
    } catch (e) {
      return Result.error('チーム情報の取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<TeamModel>> updateTeam(TeamModel team) async {
    try {
      // Check if team exists
      final doc = await _firestore.collection('teams').doc(team.id).get();

      if (!doc.exists) {
        return Result.error('チームが見つかりませんでした');
      }

      // Update team
      await _firestore.collection('teams').doc(team.id).update(team.toJson());

      return Result.success(team);
    } catch (e) {
      return Result.error('チーム更新中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<void>> deleteTeam(String teamId) async {
    try {
      // Get team to get member IDs
      final doc = await _firestore.collection('teams').doc(teamId).get();

      if (!doc.exists) {
        return Result.error('チームが見つかりませんでした');
      }

      final teamData = doc.data() as Map<String, dynamic>;
      final memberIds = List<String>.from(
        teamData['memberIds'] as List<dynamic>,
      );

      // Remove team from user documents
      for (final userId in memberIds) {
        await _firestore.collection('users').doc(userId).update({
          'teamIds': FieldValue.arrayRemove([teamId]),
        });
      }

      // Delete team
      await _firestore.collection('teams').doc(teamId).delete();

      return Result.success(null);
    } catch (e) {
      return Result.error('チーム削除中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<TeamModel>> addMemberToTeam(
    String teamId,
    String userId,
  ) async {
    try {
      // Check if team exists
      final doc = await _firestore.collection('teams').doc(teamId).get();

      if (!doc.exists) {
        return Result.error('チームが見つかりませんでした');
      }

      // Check if user exists
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        return Result.error('ユーザーが見つかりませんでした');
      }

      // Add user to team
      await _firestore.collection('teams').doc(teamId).update({
        'memberIds': FieldValue.arrayUnion([userId]),
      });

      // Add team to user
      await _firestore.collection('users').doc(userId).update({
        'teamIds': FieldValue.arrayUnion([teamId]),
      });

      // Get updated team
      final updatedDoc = await _firestore.collection('teams').doc(teamId).get();
      return Result.success(
        TeamModel.fromJson(updatedDoc.data() as Map<String, dynamic>),
      );
    } catch (e) {
      return Result.error('チームメンバー追加中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<TeamModel>> removeMemberFromTeam(
    String teamId,
    String userId,
  ) async {
    try {
      // Check if team exists
      final doc = await _firestore.collection('teams').doc(teamId).get();

      if (!doc.exists) {
        return Result.error('チームが見つかりませんでした');
      }

      final teamData = doc.data() as Map<String, dynamic>;

      // Check if user is the creator
      if (teamData['creatorId'] == userId) {
        return Result.error('チーム作成者は削除できません');
      }

      // Remove user from team
      await _firestore.collection('teams').doc(teamId).update({
        'memberIds': FieldValue.arrayRemove([userId]),
      });

      // Remove team from user
      await _firestore.collection('users').doc(userId).update({
        'teamIds': FieldValue.arrayRemove([teamId]),
      });

      // Get updated team
      final updatedDoc = await _firestore.collection('teams').doc(teamId).get();
      return Result.success(
        TeamModel.fromJson(updatedDoc.data() as Map<String, dynamic>),
      );
    } catch (e) {
      return Result.error('チームメンバー削除中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<TeamModel>> shareRestaurantWithTeam(
    String teamId,
    String restaurantId,
  ) async {
    try {
      // Check if team exists
      final doc = await _firestore.collection('teams').doc(teamId).get();

      if (!doc.exists) {
        return Result.error('チームが見つかりませんでした');
      }

      // Check if restaurant exists
      final restaurantDoc =
          await _firestore.collection('restaurants').doc(restaurantId).get();

      if (!restaurantDoc.exists) {
        return Result.error('レストランが見つかりませんでした');
      }

      // Add restaurant to team
      await _firestore.collection('teams').doc(teamId).update({
        'sharedRestaurantIds': FieldValue.arrayUnion([restaurantId]),
      });

      // Get updated team
      final updatedDoc = await _firestore.collection('teams').doc(teamId).get();
      return Result.success(
        TeamModel.fromJson(updatedDoc.data() as Map<String, dynamic>),
      );
    } catch (e) {
      return Result.error('レストラン共有中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<TeamModel>> removeSharedRestaurantFromTeam(
    String teamId,
    String restaurantId,
  ) async {
    try {
      // Check if team exists
      final doc = await _firestore.collection('teams').doc(teamId).get();

      if (!doc.exists) {
        return Result.error('チームが見つかりませんでした');
      }

      // Remove restaurant from team
      await _firestore.collection('teams').doc(teamId).update({
        'sharedRestaurantIds': FieldValue.arrayRemove([restaurantId]),
      });

      // Get updated team
      final updatedDoc = await _firestore.collection('teams').doc(teamId).get();
      return Result.success(
        TeamModel.fromJson(updatedDoc.data() as Map<String, dynamic>),
      );
    } catch (e) {
      return Result.error('レストラン共有解除中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<List<RestaurantModel>>> getTeamSharedRestaurants(
    String teamId,
  ) async {
    try {
      // Get team to get shared restaurant IDs
      final doc = await _firestore.collection('teams').doc(teamId).get();

      if (!doc.exists) {
        return Result.error('チームが見つかりませんでした');
      }

      final teamData = doc.data() as Map<String, dynamic>;
      final sharedRestaurantIds = List<String>.from(
        teamData['sharedRestaurantIds'] as List<dynamic>? ?? [],
      );

      if (sharedRestaurantIds.isEmpty) {
        return Result.success([]);
      }

      // Get all shared restaurants
      // Firestore doesn't support 'where in' with more than 10 values,
      // so we need to batch the requests if there are more than 10 restaurants
      final restaurants = <RestaurantModel>[];
      for (int i = 0; i < sharedRestaurantIds.length; i += 10) {
        final end =
            (i + 10 < sharedRestaurantIds.length)
                ? i + 10
                : sharedRestaurantIds.length;
        final batch = sharedRestaurantIds.sublist(i, end);

        final snapshot =
            await _firestore
                .collection('restaurants')
                .where(FieldPath.documentId, whereIn: batch)
                .get();

        restaurants.addAll(
          snapshot.docs.map(
            (doc) =>
                RestaurantModel.fromJson(doc.data() as Map<String, dynamic>),
          ),
        );
      }

      return Result.success(restaurants);
    } catch (e) {
      return Result.error('チーム共有レストラン取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<List<TeamModel>>> getUserTeams(String userId) async {
    try {
      final snapshot =
          await _firestore
              .collection('teams')
              .where('memberIds', arrayContains: userId)
              .get();

      final teams =
          snapshot.docs
              .map(
                (doc) => TeamModel.fromJson(doc.data() as Map<String, dynamic>),
              )
              .toList();

      return Result.success(teams);
    } catch (e) {
      return Result.error('ユーザーのチーム取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<List<TeamModel>>> getUserCreatedTeams(String userId) async {
    try {
      final snapshot =
          await _firestore
              .collection('teams')
              .where('creatorId', isEqualTo: userId)
              .get();

      final teams =
          snapshot.docs
              .map(
                (doc) => TeamModel.fromJson(doc.data() as Map<String, dynamic>),
              )
              .toList();

      return Result.success(teams);
    } catch (e) {
      return Result.error('ユーザーの作成チーム取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<bool>> isUserTeamMember(String teamId, String userId) async {
    try {
      final doc = await _firestore.collection('teams').doc(teamId).get();

      if (!doc.exists) {
        return Result.error('チームが見つかりませんでした');
      }

      final teamData = doc.data() as Map<String, dynamic>;
      final memberIds = List<String>.from(
        teamData['memberIds'] as List<dynamic>,
      );

      return Result.success(memberIds.contains(userId));
    } catch (e) {
      return Result.error('チームメンバー確認中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<bool>> isUserTeamCreator(String teamId, String userId) async {
    try {
      final doc = await _firestore.collection('teams').doc(teamId).get();

      if (!doc.exists) {
        return Result.error('チームが見つかりませんでした');
      }

      final teamData = doc.data() as Map<String, dynamic>;
      final creatorId = teamData['creatorId'] as String;

      return Result.success(creatorId == userId);
    } catch (e) {
      return Result.error('チーム作成者確認中にエラーが発生しました: $e');
    }
  }
}

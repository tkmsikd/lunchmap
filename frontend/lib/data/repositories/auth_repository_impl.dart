import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/exceptions/result.dart';
import '../datasources/auth_data_source.dart';
import '../models/user_model.dart';
import 'dart:async';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _authDataSource;
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final StreamController<User?> _authStateController =
      StreamController<User?>.broadcast();

  /// Creates a new AuthRepositoryImpl with the given dependencies
  AuthRepositoryImpl({
    required AuthDataSource authDataSource,
    firebase_auth.FirebaseAuth? firebaseAuth,
  }) : _authDataSource = authDataSource,
       _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance {
    // Listen to Firebase auth state changes and convert to domain User
    _firebaseAuth.authStateChanges().listen((firebaseUser) {
      if (firebaseUser == null) {
        _authStateController.add(null);
      } else {
        // Get user data from data source
        _authDataSource.getCurrentUser().then((result) {
          if (result.isSuccess && result.data != null) {
            _authStateController.add(result.data!.toEntity());
          } else {
            _authStateController.add(null);
          }
        });
      }
    });
  }

  @override
  Stream<User?> authStateChanges() {
    return _authStateController.stream;
  }

  @override
  Future<Result<User>> signIn(String email, String password) async {
    try {
      final result = await _authDataSource.signIn(email, password);

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      return Result.success(result.data!.toEntity());
    } catch (e) {
      return Result.error('サインイン中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<User>> signUp(
    String name,
    String email,
    String password,
  ) async {
    try {
      final result = await _authDataSource.signUp(name, email, password);

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      return Result.success(result.data!.toEntity());
    } catch (e) {
      return Result.error('アカウント作成中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      final result = await _authDataSource.signOut();

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      return Result.success(null);
    } catch (e) {
      return Result.error('サインアウト中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      final result = await _authDataSource.getCurrentUser();

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      if (result.data == null) {
        return Result.success(null);
      }

      return Result.success(result.data!.toEntity());
    } catch (e) {
      return Result.error('ユーザー情報の取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return Result.success(null);
    } catch (e) {
      return Result.error('パスワードリセットメール送信中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<User>> updateProfile({
    String? name,
    String? email,
    String? avatarUrl,
  }) async {
    try {
      // Get current user
      final userResult = await _authDataSource.getCurrentUser();

      if (userResult.isError) {
        return Result.error(userResult.errorMessage!);
      }

      if (userResult.data == null) {
        return Result.error('ユーザーがサインインしていません');
      }

      final currentUser = userResult.data!;

      // Create updated user model
      final updatedUser = UserModel(
        id: currentUser.id,
        name: name ?? currentUser.name,
        email: email ?? currentUser.email,
        avatarUrl: avatarUrl ?? currentUser.avatarUrl,
        favoriteRestaurantIds: currentUser.favoriteRestaurantIds,
        teamIds: currentUser.teamIds,
      );

      // TODO: Implement update user profile in AuthDataSource
      // For now, we'll just return the updated user
      return Result.success(updatedUser.toEntity());
    } catch (e) {
      return Result.error('プロフィール更新中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<void>> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      // Get current user
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        return Result.error('ユーザーがサインインしていません');
      }

      // Get user email
      final email = firebaseUser.email;
      if (email == null) {
        return Result.error('ユーザーのメールアドレスが見つかりません');
      }

      // Reauthenticate user
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await firebaseUser.reauthenticateWithCredential(credential);

      // Update password
      await firebaseUser.updatePassword(newPassword);

      return Result.success(null);
    } catch (e) {
      return Result.error('パスワード更新中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<void>> deleteAccount(String password) async {
    try {
      // Get current user
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        return Result.error('ユーザーがサインインしていません');
      }

      // Get user email
      final email = firebaseUser.email;
      if (email == null) {
        return Result.error('ユーザーのメールアドレスが見つかりません');
      }

      // Reauthenticate user
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await firebaseUser.reauthenticateWithCredential(credential);

      // Delete user
      await firebaseUser.delete();

      return Result.success(null);
    } catch (e) {
      return Result.error('アカウント削除中にエラーが発生しました: $e');
    }
  }
}

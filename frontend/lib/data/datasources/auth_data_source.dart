import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../../core/exceptions/result.dart';

/// Interface for authentication data source
abstract class AuthDataSource {
  /// Signs in a user with email and password
  Future<Result<UserModel>> signIn(String email, String password);

  /// Signs up a new user with name, email, and password
  Future<Result<UserModel>> signUp(String name, String email, String password);

  /// Signs out the current user
  Future<Result<void>> signOut();

  /// Gets the current authenticated user
  Future<Result<UserModel?>> getCurrentUser();
}

/// Firebase implementation of AuthDataSource
class FirebaseAuthDataSource implements AuthDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  /// Creates a new FirebaseAuthDataSource with the given dependencies
  FirebaseAuthDataSource({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Result<UserModel>> signIn(String email, String password) async {
    try {
      // Sign in with Firebase Auth
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        return Result.error('サインインに失敗しました');
      }

      // Get user data from Firestore
      final userDoc =
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();

      if (!userDoc.exists) {
        return Result.error('ユーザー情報が見つかりませんでした');
      }

      // Create UserModel from Firestore data
      final userData = userDoc.data()!;
      userData['id'] = userCredential.user!.uid; // Ensure ID is set

      return Result.success(UserModel.fromJson(userData));
    } on firebase_auth.FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    } catch (e) {
      return Result.error('サインイン中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<UserModel>> signUp(
    String name,
    String email,
    String password,
  ) async {
    try {
      // Create user with Firebase Auth
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        return Result.error('アカウント作成に失敗しました');
      }

      // Create user data for Firestore
      final userData = {
        'id': userCredential.user!.uid,
        'name': name,
        'email': email,
        'avatarUrl': null,
        'favoriteRestaurantIds': <String>[],
        'teamIds': <String>[],
      };

      // Save user data to Firestore
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userData);

      // Update display name in Firebase Auth
      await userCredential.user!.updateDisplayName(name);

      return Result.success(UserModel.fromJson(userData));
    } on firebase_auth.FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    } catch (e) {
      return Result.error('アカウント作成中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return Result.success(null);
    } catch (e) {
      return Result.error('サインアウト中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<UserModel?>> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;

      if (firebaseUser == null) {
        return Result.success(null);
      }

      // Get user data from Firestore
      final userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (!userDoc.exists) {
        return Result.error('ユーザー情報が見つかりませんでした');
      }

      // Create UserModel from Firestore data
      final userData = userDoc.data()!;
      userData['id'] = firebaseUser.uid; // Ensure ID is set

      return Result.success(UserModel.fromJson(userData));
    } catch (e) {
      return Result.error('ユーザー情報の取得中にエラーが発生しました: $e');
    }
  }

  /// Handles Firebase Auth exceptions and returns appropriate error messages
  Result<UserModel> _handleFirebaseAuthException(
    firebase_auth.FirebaseAuthException e,
  ) {
    switch (e.code) {
      case 'user-not-found':
        return Result.error('メールアドレスが登録されていません');
      case 'wrong-password':
        return Result.error('パスワードが間違っています');
      case 'email-already-in-use':
        return Result.error('このメールアドレスは既に使用されています');
      case 'weak-password':
        return Result.error('パスワードが弱すぎます');
      case 'invalid-email':
        return Result.error('メールアドレスの形式が正しくありません');
      case 'user-disabled':
        return Result.error('このアカウントは無効化されています');
      case 'operation-not-allowed':
        return Result.error('この操作は許可されていません');
      case 'too-many-requests':
        return Result.error('リクエストが多すぎます。しばらく待ってから再試行してください');
      case 'network-request-failed':
        return Result.error('ネットワークエラーが発生しました');
      default:
        return Result.error('認証エラーが発生しました: ${e.message}');
    }
  }
}

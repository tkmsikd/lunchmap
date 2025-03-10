import '../entities/user.dart';
import '../../core/exceptions/result.dart';

/// Repository interface for authentication operations
abstract class AuthRepository {
  /// Signs in a user with email and password
  ///
  /// Returns a [Result] containing the [User] if successful,
  /// or an error message if unsuccessful
  Future<Result<User>> signIn(String email, String password);

  /// Signs up a new user with name, email, and password
  ///
  /// Returns a [Result] containing the [User] if successful,
  /// or an error message if unsuccessful
  Future<Result<User>> signUp(String name, String email, String password);

  /// Signs out the current user
  ///
  /// Returns a [Result] indicating success or failure
  Future<Result<void>> signOut();

  /// Gets the current authenticated user
  ///
  /// Returns a [Result] containing the [User] if a user is authenticated,
  /// null if no user is authenticated, or an error message if unsuccessful
  Future<Result<User?>> getCurrentUser();

  /// Stream of authentication state changes
  ///
  /// Emits the current [User] when authenticated, or null when not authenticated
  Stream<User?> authStateChanges();

  /// Sends a password reset email to the specified email address
  ///
  /// Returns a [Result] indicating success or failure
  Future<Result<void>> sendPasswordResetEmail(String email);

  /// Updates the current user's profile information
  ///
  /// Returns a [Result] containing the updated [User] if successful,
  /// or an error message if unsuccessful
  Future<Result<User>> updateProfile({
    String? name,
    String? email,
    String? avatarUrl,
  });

  /// Updates the current user's password
  ///
  /// Returns a [Result] indicating success or failure
  Future<Result<void>> updatePassword(
    String currentPassword,
    String newPassword,
  );

  /// Deletes the current user's account
  ///
  /// Returns a [Result] indicating success or failure
  Future<Result<void>> deleteAccount(String password);
}

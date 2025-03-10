import '../../repositories/auth_repository.dart';
import '../../../core/exceptions/result.dart';
import '../../entities/user.dart';

/// Use case for signing in a user with email and password
class SignInUseCase {
  /// The repository that this use case will use
  final AuthRepository repository;

  /// Creates a new SignInUseCase with the given repository
  const SignInUseCase(this.repository);

  /// Executes the use case
  ///
  /// [email] is the user's email
  /// [password] is the user's password
  ///
  /// Returns a [Result] containing the [User] if successful,
  /// or an error message if unsuccessful
  Future<Result<User>> execute(String email, String password) async {
    // Validate email
    if (email.isEmpty) {
      return Result.validationError('メールアドレスを入力してください');
    }

    // Validate password
    if (password.isEmpty) {
      return Result.validationError('パスワードを入力してください');
    }

    // Call the repository
    return await repository.signIn(email, password);
  }
}

import '../../repositories/auth_repository.dart';
import '../../../core/exceptions/result.dart';
import '../../entities/user.dart';
import '../../../core/utils/string_utils.dart';

/// Use case for signing up a new user
class SignUpUseCase {
  /// The repository that this use case will use
  final AuthRepository repository;

  /// Creates a new SignUpUseCase with the given repository
  const SignUpUseCase(this.repository);

  /// Executes the use case
  ///
  /// [name] is the user's name
  /// [email] is the user's email
  /// [password] is the user's password
  /// [confirmPassword] is the confirmation of the user's password
  ///
  /// Returns a [Result] containing the [User] if successful,
  /// or an error message if unsuccessful
  Future<Result<User>> execute(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) async {
    // Validate name
    if (name.isEmpty) {
      return Result.validationError('名前を入力してください');
    }

    // Validate email
    if (email.isEmpty) {
      return Result.validationError('メールアドレスを入力してください');
    }

    if (!StringUtils.isValidEmail(email)) {
      return Result.validationError('有効なメールアドレスを入力してください');
    }

    // Validate password
    if (password.isEmpty) {
      return Result.validationError('パスワードを入力してください');
    }

    if (password.length < 8) {
      return Result.validationError('パスワードは8文字以上で入力してください');
    }

    // Validate password confirmation
    if (password != confirmPassword) {
      return Result.validationError('パスワードが一致しません');
    }

    // Call the repository
    return await repository.signUp(name, email, password);
  }
}

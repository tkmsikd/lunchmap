import '../../repositories/auth_repository.dart';
import '../../../core/exceptions/result.dart';

/// Use case for signing out a user
class SignOutUseCase {
  /// The repository that this use case will use
  final AuthRepository repository;

  /// Creates a new SignOutUseCase with the given repository
  const SignOutUseCase(this.repository);

  /// Executes the use case
  ///
  /// Returns a [Result] indicating success or failure
  Future<Result<void>> execute() async {
    return await repository.signOut();
  }
}

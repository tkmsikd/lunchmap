import '../../repositories/auth_repository.dart';
import '../../../core/exceptions/result.dart';
import '../../entities/user.dart';

/// Use case for getting the current authenticated user
class GetCurrentUserUseCase {
  /// The repository that this use case will use
  final AuthRepository repository;

  /// Creates a new GetCurrentUserUseCase with the given repository
  const GetCurrentUserUseCase(this.repository);

  /// Executes the use case
  ///
  /// Returns a [Result] containing the [User] if a user is authenticated,
  /// null if no user is authenticated, or an error message if unsuccessful
  Future<Result<User?>> execute() async {
    return await repository.getCurrentUser();
  }
}

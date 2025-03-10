import '../../repositories/review_repository.dart';
import '../../../core/exceptions/result.dart';
import '../../entities/review.dart';

/// Use case for getting reviews created by a user
class GetUserReviewsUseCase {
  /// The repository that this use case will use
  final ReviewRepository repository;

  /// Creates a new GetUserReviewsUseCase with the given repository
  const GetUserReviewsUseCase(this.repository);

  /// Executes the use case
  ///
  /// [userId] is the ID of the user whose reviews to get
  ///
  /// Returns a [Result] containing a list of [Review] if successful,
  /// or an error message if unsuccessful
  Future<Result<List<Review>>> execute(String userId) async {
    // Validate user ID
    if (userId.isEmpty) {
      return Result.validationError('ユーザーIDが無効です');
    }

    try {
      // Get the user's reviews
      return await repository.getUserReviews(userId);
    } catch (e) {
      return Result.error('ユーザーのレビュー取得中にエラーが発生しました: $e');
    }
  }
}

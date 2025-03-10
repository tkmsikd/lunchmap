import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../../core/exceptions/result.dart';
import '../datasources/review_data_source.dart';
import '../models/review_model.dart';

/// Implementation of ReviewRepository
class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewDataSource _reviewDataSource;

  /// Creates a new ReviewRepositoryImpl with the given dependencies
  ReviewRepositoryImpl({required ReviewDataSource reviewDataSource})
    : _reviewDataSource = reviewDataSource;

  @override
  Future<Result<Review>> addReview(Review review) async {
    try {
      // Convert domain entity to data model
      final reviewModel = ReviewModel.fromEntity(review);

      final result = await _reviewDataSource.addReview(reviewModel);

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      return Result.success(result.data!.toEntity());
    } catch (e) {
      return Result.error('レビュー追加中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<Review>> updateReview(Review review) async {
    try {
      // Convert domain entity to data model
      final reviewModel = ReviewModel.fromEntity(review);

      final result = await _reviewDataSource.updateReview(reviewModel);

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      return Result.success(result.data!.toEntity());
    } catch (e) {
      return Result.error('レビュー更新中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<void>> deleteReview(String reviewId) async {
    try {
      final result = await _reviewDataSource.deleteReview(reviewId);

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      return Result.success(null);
    } catch (e) {
      return Result.error('レビュー削除中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<List<Review>>> getUserReviews(String userId) async {
    try {
      final result = await _reviewDataSource.getUserReviews(userId);

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      final reviews = result.data!.map((model) => model.toEntity()).toList();
      return Result.success(reviews);
    } catch (e) {
      return Result.error('ユーザーのレビュー取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<Review>> getReviewById(String reviewId) async {
    try {
      final result = await _reviewDataSource.getReviewById(reviewId);

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      return Result.success(result.data!.toEntity());
    } catch (e) {
      return Result.error('レビュー取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<Review>> addImageToReview(
    String reviewId,
    String imageUrl,
  ) async {
    try {
      final result = await _reviewDataSource.addImageToReview(
        reviewId,
        imageUrl,
      );

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      return Result.success(result.data!.toEntity());
    } catch (e) {
      return Result.error('レビュー画像追加中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<Review>> removeImageFromReview(
    String reviewId,
    String imageUrl,
  ) async {
    try {
      final result = await _reviewDataSource.removeImageFromReview(
        reviewId,
        imageUrl,
      );

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      return Result.success(result.data!.toEntity());
    } catch (e) {
      return Result.error('レビュー画像削除中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<List<Review>>> getRecentReviews({int limit = 10}) async {
    try {
      final result = await _reviewDataSource.getRecentReviews(limit: limit);

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      final reviews = result.data!.map((model) => model.toEntity()).toList();
      return Result.success(reviews);
    } catch (e) {
      return Result.error('最近のレビュー取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<List<Review>>> getReviewsByRating(
    double rating, {
    int limit = 10,
  }) async {
    try {
      final result = await _reviewDataSource.getReviewsByRating(
        rating,
        limit: limit,
      );

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      final reviews = result.data!.map((model) => model.toEntity()).toList();
      return Result.success(reviews);
    } catch (e) {
      return Result.error('評価別レビュー取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<double>> getAverageRating(String restaurantId) async {
    try {
      final result = await _reviewDataSource.getAverageRating(restaurantId);

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      return Result.success(result.data!);
    } catch (e) {
      return Result.error('平均評価取得中にエラーが発生しました: $e');
    }
  }
}

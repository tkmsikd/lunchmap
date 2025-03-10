import '../../domain/entities/restaurant.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/restaurant_repository.dart';
import '../../core/exceptions/result.dart';
import '../datasources/restaurant_data_source.dart';
import '../datasources/review_data_source.dart';
import '../models/restaurant_model.dart';
import '../models/review_model.dart';

/// Implementation of RestaurantRepository
class RestaurantRepositoryImpl implements RestaurantRepository {
  final RestaurantDataSource _restaurantDataSource;
  final ReviewDataSource _reviewDataSource;

  /// Creates a new RestaurantRepositoryImpl with the given dependencies
  RestaurantRepositoryImpl({
    required RestaurantDataSource restaurantDataSource,
    required ReviewDataSource reviewDataSource,
  }) : _restaurantDataSource = restaurantDataSource,
       _reviewDataSource = reviewDataSource;

  @override
  Future<Result<List<Review>>> getRestaurantReviews(String restaurantId) async {
    try {
      final result = await _restaurantDataSource.getRestaurantReviews(
        restaurantId,
      );

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      final reviews = result.data!.map((model) => model.toEntity()).toList();
      return Result.success(reviews);
    } catch (e) {
      return Result.error('レビュー取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<List<Restaurant>>> getNearbyRestaurants(
    double latitude,
    double longitude, {
    double radius = 1000,
  }) async {
    try {
      final result = await _restaurantDataSource.getNearbyRestaurants(
        latitude,
        longitude,
        radius: radius,
      );

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      final restaurants =
          result.data!.map((model) => model.toEntity()).toList();
      return Result.success(restaurants);
    } catch (e) {
      return Result.error('近くのレストラン取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<Restaurant>> getRestaurantById(String id) async {
    try {
      final result = await _restaurantDataSource.getRestaurantById(id);

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      return Result.success(result.data!.toEntity());
    } catch (e) {
      return Result.error('レストラン情報の取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<List<Restaurant>>> searchRestaurants(
    String query, {
    List<String>? categories,
  }) async {
    try {
      final result = await _restaurantDataSource.searchRestaurants(
        query,
        categories: categories,
      );

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      final restaurants =
          result.data!.map((model) => model.toEntity()).toList();
      return Result.success(restaurants);
    } catch (e) {
      return Result.error('レストラン検索中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<void>> addRestaurantToFavorites(
    String userId,
    String restaurantId,
  ) async {
    try {
      final result = await _restaurantDataSource.addRestaurantToFavorites(
        userId,
        restaurantId,
      );

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      return Result.success(null);
    } catch (e) {
      return Result.error('お気に入り追加中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<void>> removeRestaurantFromFavorites(
    String userId,
    String restaurantId,
  ) async {
    try {
      final result = await _restaurantDataSource.removeRestaurantFromFavorites(
        userId,
        restaurantId,
      );

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      return Result.success(null);
    } catch (e) {
      return Result.error('お気に入り削除中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<List<Restaurant>>> getFavoriteRestaurants(String userId) async {
    try {
      final result = await _restaurantDataSource.getFavoriteRestaurants(userId);

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      final restaurants =
          result.data!.map((model) => model.toEntity()).toList();
      return Result.success(restaurants);
    } catch (e) {
      return Result.error('お気に入りレストラン取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<void>> reportCrowdedness(
    String restaurantId,
    bool isCrowded,
  ) async {
    try {
      final result = await _restaurantDataSource.reportCrowdedness(
        restaurantId,
        isCrowded,
      );

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      return Result.success(null);
    } catch (e) {
      return Result.error('混雑状況の報告中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<List<Restaurant>>> getRestaurantsByCategory(
    String category,
  ) async {
    try {
      final result = await _restaurantDataSource.getRestaurantsByCategory(
        category,
      );

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      final restaurants =
          result.data!.map((model) => model.toEntity()).toList();
      return Result.success(restaurants);
    } catch (e) {
      return Result.error('カテゴリ別レストラン取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<List<Restaurant>>> getPopularRestaurants({
    int limit = 10,
  }) async {
    try {
      final result = await _restaurantDataSource.getPopularRestaurants(
        limit: limit,
      );

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      final restaurants =
          result.data!.map((model) => model.toEntity()).toList();
      return Result.success(restaurants);
    } catch (e) {
      return Result.error('人気レストラン取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<List<Restaurant>>> getRecentlyReviewedRestaurants({
    int limit = 10,
  }) async {
    try {
      final result = await _restaurantDataSource.getRecentlyReviewedRestaurants(
        limit: limit,
      );

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      final restaurants =
          result.data!.map((model) => model.toEntity()).toList();
      return Result.success(restaurants);
    } catch (e) {
      return Result.error('最近レビューされたレストラン取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<Restaurant>> updateRestaurant(Restaurant restaurant) async {
    try {
      // Convert domain entity to data model
      final restaurantModel = RestaurantModel.fromEntity(restaurant);

      final result = await _restaurantDataSource.updateRestaurant(
        restaurantModel,
      );

      if (result.isError) {
        return Result.error(result.errorMessage!);
      }

      return Result.success(result.data!.toEntity());
    } catch (e) {
      return Result.error('レストラン情報の更新中にエラーが発生しました: $e');
    }
  }
}

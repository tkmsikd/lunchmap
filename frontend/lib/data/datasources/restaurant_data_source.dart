import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/restaurant_model.dart';
import '../models/review_model.dart';
import '../../core/exceptions/result.dart';

/// Interface for restaurant data source
abstract class RestaurantDataSource {
  /// Gets nearby restaurants based on location
  Future<Result<List<RestaurantModel>>> getNearbyRestaurants(
    double latitude,
    double longitude, {
    double radius = 1000,
  });

  /// Gets a restaurant by its ID
  Future<Result<RestaurantModel>> getRestaurantById(String id);

  /// Searches for restaurants by query and optional categories
  Future<Result<List<RestaurantModel>>> searchRestaurants(
    String query, {
    List<String>? categories,
  });

  /// Gets reviews for a restaurant
  Future<Result<List<ReviewModel>>> getRestaurantReviews(String restaurantId);

  /// Adds a restaurant to a user's favorites
  Future<Result<void>> addRestaurantToFavorites(
    String userId,
    String restaurantId,
  );

  /// Removes a restaurant from a user's favorites
  Future<Result<void>> removeRestaurantFromFavorites(
    String userId,
    String restaurantId,
  );

  /// Gets a user's favorite restaurants
  Future<Result<List<RestaurantModel>>> getFavoriteRestaurants(String userId);

  /// Reports the current crowdedness of a restaurant
  Future<Result<void>> reportCrowdedness(String restaurantId, bool isCrowded);

  /// Gets restaurants by category
  Future<Result<List<RestaurantModel>>> getRestaurantsByCategory(
    String category,
  );

  /// Gets popular restaurants based on rating and review count
  Future<Result<List<RestaurantModel>>> getPopularRestaurants({int limit = 10});

  /// Gets recently reviewed restaurants
  Future<Result<List<RestaurantModel>>> getRecentlyReviewedRestaurants({
    int limit = 10,
  });

  /// Updates a restaurant's information
  Future<Result<RestaurantModel>> updateRestaurant(RestaurantModel restaurant);
}

/// Firebase implementation of RestaurantDataSource
class FirebaseRestaurantDataSource implements RestaurantDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  /// Creates a new FirebaseRestaurantDataSource with the given dependencies
  FirebaseRestaurantDataSource({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<Result<List<RestaurantModel>>> getNearbyRestaurants(
    double latitude,
    double longitude, {
    double radius = 1000,
  }) async {
    try {
      // Convert radius from meters to degrees (approximate)
      // 1 degree of latitude is approximately 111,000 meters
      final double latDegrees = radius / 111000;
      final double lngDegrees = radius / (111000 * cos(latitude * (pi / 180)));

      final minLat = latitude - latDegrees;
      final maxLat = latitude + latDegrees;
      final minLng = longitude - lngDegrees;
      final maxLng = longitude + lngDegrees;

      final snapshot =
          await _firestore
              .collection('restaurants')
              .where('latitude', isGreaterThanOrEqualTo: minLat)
              .where('latitude', isLessThanOrEqualTo: maxLat)
              .get();

      // We need to filter by longitude manually since Firestore can only filter on one field
      final restaurants =
          snapshot.docs
              .map(
                (doc) => RestaurantModel.fromJson(
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .where(
                (restaurant) =>
                    restaurant.longitude >= minLng &&
                    restaurant.longitude <= maxLng,
              )
              .toList();

      return Result.success(restaurants);
    } catch (e) {
      return Result.error('近くのレストラン取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<RestaurantModel>> getRestaurantById(String id) async {
    try {
      final doc = await _firestore.collection('restaurants').doc(id).get();

      if (!doc.exists) {
        return Result.error('レストランが見つかりませんでした');
      }

      final data = doc.data()! as Map<String, dynamic>;
      data['id'] = doc.id; // Ensure ID is set

      return Result.success(RestaurantModel.fromJson(data));
    } catch (e) {
      return Result.error('レストラン情報の取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<List<RestaurantModel>>> searchRestaurants(
    String query, {
    List<String>? categories,
  }) async {
    try {
      // Normalize query for case-insensitive search
      final normalizedQuery = query.toLowerCase();

      // Start with a query for all restaurants
      Query restaurantsQuery = _firestore.collection('restaurants');

      // Add category filter if provided
      if (categories != null && categories.isNotEmpty) {
        restaurantsQuery = restaurantsQuery.where(
          'categories',
          arrayContainsAny: categories,
        );
      }

      final snapshot = await restaurantsQuery.get();

      // Filter by name or description containing the query
      // (Firestore doesn't support text search, so we do it client-side)
      final restaurants =
          snapshot.docs
              .map(
                (doc) => RestaurantModel.fromJson(
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .where(
                (restaurant) =>
                    restaurant.name.toLowerCase().contains(normalizedQuery) ||
                    restaurant.description.toLowerCase().contains(
                      normalizedQuery,
                    ),
              )
              .toList();

      return Result.success(restaurants);
    } catch (e) {
      return Result.error('レストラン検索中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<List<ReviewModel>>> getRestaurantReviews(
    String restaurantId,
  ) async {
    try {
      final snapshot =
          await _firestore
              .collection('reviews')
              .where('restaurantId', isEqualTo: restaurantId)
              .orderBy('createdAt', descending: true)
              .get();

      final reviews =
          snapshot.docs
              .map(
                (doc) =>
                    ReviewModel.fromJson(doc.data() as Map<String, dynamic>),
              )
              .toList();

      return Result.success(reviews);
    } catch (e) {
      return Result.error('レビュー取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<void>> addRestaurantToFavorites(
    String userId,
    String restaurantId,
  ) async {
    try {
      // Add to user's favorites
      await _firestore.collection('users').doc(userId).update({
        'favoriteRestaurantIds': FieldValue.arrayUnion([restaurantId]),
      });

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
      // Remove from user's favorites
      await _firestore.collection('users').doc(userId).update({
        'favoriteRestaurantIds': FieldValue.arrayRemove([restaurantId]),
      });

      return Result.success(null);
    } catch (e) {
      return Result.error('お気に入り削除中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<List<RestaurantModel>>> getFavoriteRestaurants(
    String userId,
  ) async {
    try {
      // Get user document to get favorite restaurant IDs
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        return Result.error('ユーザーが見つかりませんでした');
      }

      final userData = userDoc.data()! as Map<String, dynamic>;
      final favoriteIds = List<String>.from(
        userData['favoriteRestaurantIds'] as List<dynamic>? ?? [],
      );

      if (favoriteIds.isEmpty) {
        return Result.success([]);
      }

      // Get all favorite restaurants
      // Firestore doesn't support 'where in' with more than 10 values,
      // so we need to batch the requests if there are more than 10 favorites
      final restaurants = <RestaurantModel>[];
      for (int i = 0; i < favoriteIds.length; i += 10) {
        final end = (i + 10 < favoriteIds.length) ? i + 10 : favoriteIds.length;
        final batch = favoriteIds.sublist(i, end);

        final snapshot =
            await _firestore
                .collection('restaurants')
                .where(FieldPath.documentId, whereIn: batch)
                .get();

        restaurants.addAll(
          snapshot.docs.map(
            (doc) =>
                RestaurantModel.fromJson(doc.data() as Map<String, dynamic>),
          ),
        );
      }

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
      await _firestore.collection('restaurants').doc(restaurantId).update({
        'isCrowded': isCrowded,
        'crowdednessUpdatedAt': FieldValue.serverTimestamp(),
      });

      return Result.success(null);
    } catch (e) {
      return Result.error('混雑状況の報告中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<List<RestaurantModel>>> getRestaurantsByCategory(
    String category,
  ) async {
    try {
      final snapshot =
          await _firestore
              .collection('restaurants')
              .where('categories', arrayContains: category)
              .get();

      final restaurants =
          snapshot.docs
              .map(
                (doc) => RestaurantModel.fromJson(
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList();

      return Result.success(restaurants);
    } catch (e) {
      return Result.error('カテゴリ別レストラン取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<List<RestaurantModel>>> getPopularRestaurants({
    int limit = 10,
  }) async {
    try {
      final snapshot =
          await _firestore
              .collection('restaurants')
              .orderBy('averageRating', descending: true)
              .orderBy('reviewCount', descending: true)
              .limit(limit)
              .get();

      final restaurants =
          snapshot.docs
              .map(
                (doc) => RestaurantModel.fromJson(
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList();

      return Result.success(restaurants);
    } catch (e) {
      return Result.error('人気レストラン取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<List<RestaurantModel>>> getRecentlyReviewedRestaurants({
    int limit = 10,
  }) async {
    try {
      // Get recent reviews
      final reviewsSnapshot =
          await _firestore
              .collection('reviews')
              .orderBy('createdAt', descending: true)
              .limit(limit * 2) // Get more to account for duplicates
              .get();

      // Extract unique restaurant IDs
      final restaurantIds =
          reviewsSnapshot.docs
              .map(
                (doc) =>
                    (doc.data() as Map<String, dynamic>)['restaurantId']
                        as String,
              )
              .toSet()
              .toList();

      // Limit to the requested number
      if (restaurantIds.length > limit) {
        restaurantIds.length = limit;
      }

      if (restaurantIds.isEmpty) {
        return Result.success([]);
      }

      // Get the restaurants
      final restaurants = <RestaurantModel>[];
      for (int i = 0; i < restaurantIds.length; i += 10) {
        final end =
            (i + 10 < restaurantIds.length) ? i + 10 : restaurantIds.length;
        final batch = restaurantIds.sublist(i, end);

        final snapshot =
            await _firestore
                .collection('restaurants')
                .where(FieldPath.documentId, whereIn: batch)
                .get();

        restaurants.addAll(
          snapshot.docs.map(
            (doc) =>
                RestaurantModel.fromJson(doc.data() as Map<String, dynamic>),
          ),
        );
      }

      return Result.success(restaurants);
    } catch (e) {
      return Result.error('最近レビューされたレストラン取得中にエラーが発生しました: $e');
    }
  }

  @override
  Future<Result<RestaurantModel>> updateRestaurant(
    RestaurantModel restaurant,
  ) async {
    try {
      await _firestore
          .collection('restaurants')
          .doc(restaurant.id)
          .update(restaurant.toJson());

      return Result.success(restaurant);
    } catch (e) {
      return Result.error('レストラン情報の更新中にエラーが発生しました: $e');
    }
  }
}

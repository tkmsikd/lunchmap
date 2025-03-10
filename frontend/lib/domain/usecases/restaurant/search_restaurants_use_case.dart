import '../../repositories/restaurant_repository.dart';
import '../../../core/exceptions/result.dart';
import '../../entities/restaurant.dart';

/// Use case for searching restaurants by query and optional categories
class SearchRestaurantsUseCase {
  /// The repository that this use case will use
  final RestaurantRepository repository;

  /// Creates a new SearchRestaurantsUseCase with the given repository
  const SearchRestaurantsUseCase(this.repository);

  /// Executes the use case
  ///
  /// [query] is the search term
  /// [categories] is an optional list of categories to filter by
  ///
  /// Returns a [Result] containing a list of [Restaurant] if successful,
  /// or an error message if unsuccessful
  Future<Result<List<Restaurant>>> execute(
    String query, {
    List<String>? categories,
  }) async {
    // Validate query
    if (query.isEmpty) {
      return Result.validationError('検索キーワードを入力してください');
    }

    // Validate categories
    if (categories != null && categories.isEmpty) {
      categories = null; // Treat empty list as null (no filtering)
    }

    // Call the repository
    return await repository.searchRestaurants(query, categories: categories);
  }
}

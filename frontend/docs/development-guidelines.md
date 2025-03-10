# ランチマップアプリ 開発ガイドライン

## 1. コーディング規約

### 1.1 命名規則

#### 変数・関数名

- **camelCase**: 通常の変数名、メソッド名
```dart
final restaurantName = 'レストラン';
void fetchRestaurants() { ... }
```

- **PascalCase**: クラス名、enum名
```dart
class RestaurantDetail { ... }
enum FilterType { price, rating, distance }
```

- **snake_case**: ファイル名
```
restaurant_detail_screen.dart
auth_repository.dart
```

#### プライベートメンバー

プライベートメンバー（クラス内のみで使用）は先頭にアンダースコアを付ける。
```dart
class RestaurantService {
  final RestaurantRepository _repository;
  
  void _privateMethod() { ... }
}
```

### 1.2 コメント規則

- クラスや公開メソッドには必ずドキュメントコメントを付ける
```dart
/// レストラン関連の操作を行うリポジトリクラス
class RestaurantRepository {
  /// 指定された位置の近くにあるレストランを取得する
  ///
  /// [latitude] 緯度
  /// [longitude] 経度
  /// [radius] 検索半径（メートル単位）
  Future<Result<List<Restaurant>>> getNearbyRestaurants(...);
}
```

- 複雑なロジックには説明コメントを追加する
```dart
// ユーザーの位置情報が許可されていない場合はデフォルト位置を使用
if (!await _locationService.isPermissionGranted()) {
  return DEFAULT_LOCATION;
}
```

### 1.3 インポート順序

1. Dart SDK
2. Flutter SDK
3. 外部パッケージ（アルファベット順）
4. 自プロジェクトのインポート（相対パス順）

```dart
// Dart SDK
import 'dart:async';
import 'dart:convert';

// Flutter SDK
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 外部パッケージ
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

// 自プロジェクト
import '../../domain/entities/restaurant.dart';
import '../widgets/restaurant_card.dart';
```

### 1.4 コードフォーマット

- インデントはスペース2個
- 行の最大長は80文字
- Trailing commaを使用する（複数行の引数リストなど）

## 2. アーキテクチャガイドライン

### 2.1 ディレクトリ構造の規則

プロジェクト内のファイルは以下のルールに従って配置する：

```
lib/
├── core/
│   ├── constants/         # 定数定義
│   ├── exceptions/        # 例外クラス
│   ├── extensions/        # 拡張メソッド
│   └── utils/             # ユーティリティ関数
├── data/
│   ├── api/               # API関連
│   ├── models/            # データモデル（DTOなど）
│   └── repositories/      # リポジトリの実装
├── domain/
│   ├── entities/          # エンティティ
│   ├── repositories/      # リポジトリインターフェース
│   └── usecases/          # ユースケース
├── presentation/
│   ├── pages/             # 画面
│   ├── providers/         # Riverpodプロバイダー
│   ├── widgets/           # 再利用可能なウィジェット
│   ├── routes/            # ルート定義
│   └── themes/            # テーマ定義
└── application.dart       # アプリケーションのエントリーポイント
```

### 2.2 クリーンアーキテクチャの原則

1. **依存方向の一貫性**: 外側レイヤーが内側レイヤーに依存し、その逆は許可しない
2. **レイヤー間の明確な境界**: インターフェースを通じて通信
3. **ドメイン層の独立性**: フレームワークやライブラリから独立

### 2.3 各レイヤーの責務

#### ドメイン層

- ビジネスロジックのみを含む
- フレームワークから独立している
- エンティティ、リポジトリインターフェース、ユースケースで構成

#### データ層

- 外部データソースとの連携
- APIクライアント、ローカルストレージなどの実装
- リポジトリインターフェースの実装

#### プレゼンテーション層

- UI関連（画面、ウィジェット）
- 状態管理（Riverpodプロバイダー）
- ユーザー入力の処理

## 3. 状態管理ガイドライン（Riverpod）

### 3.1 プロバイダーの種類と用途

- **Provider**: 読み取り専用の値を提供
```dart
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});
```

- **StateProvider**: 単純な状態を提供
```dart
final selectedCategoryProvider = StateProvider<String?>((ref) => null);
```

- **FutureProvider**: 非同期データを提供
```dart
final restaurantDetailsProvider = FutureProvider.family<Restaurant, String>((ref, id) {
  return ref.watch(restaurantRepositoryProvider).getRestaurantById(id);
});
```

- **StateNotifierProvider**: 複雑な状態管理
```dart
final searchNotifierProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref.watch(searchRestaurantsUseCaseProvider));
});
```

### 3.2 状態設計のベストプラクティス

#### 状態クラスの設計

```dart
class SearchState {
  final String query;
  final List<String> selectedCategories;
  final bool isLoading;
  final List<Restaurant>? results;
  final String? error;

  SearchState({
    required this.query,
    required this.selectedCategories,
    required this.isLoading,
    this.results,
    this.error,
  });

  // Immutableなデータ更新のためのコピーメソッド
  SearchState copyWith({
    String? query,
    List<String>? selectedCategories,
    bool? isLoading,
    List<Restaurant>? results,
    String? error,
  }) {
    return SearchState(
      query: query ?? this.query,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      isLoading: isLoading ?? this.isLoading,
      results: results ?? this.results,
      error: error,
    );
  }
}
```

#### StateNotifierの設計

```dart
class SearchNotifier extends StateNotifier<SearchState> {
  final SearchRestaurantsUseCase _searchUseCase;

  SearchNotifier(this._searchUseCase)
      : super(SearchState(
          query: '',
          selectedCategories: [],
          isLoading: false,
        ));

  // 状態を更新するメソッド
  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  Future<void> search() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _searchUseCase.execute(
        state.query,
        categories: state.selectedCategories.isEmpty ? null : state.selectedCategories,
      );
      
      if (result.isSuccess) {
        state = state.copyWith(results: result.data, isLoading: false);
      } else {
        state = state.copyWith(error: result.errorMessage, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
```

### 3.3 依存関係の注入

Riverpodを使った依存関係の注入方法：

```dart
// リポジトリの提供
final restaurantRepositoryProvider = Provider<RestaurantRepository>((ref) {
  // 環境に応じてモックか実装を切り替え
  if (EnvironmentConfig.instance.isDev) {
    return MockRestaurantRepository();
  } else {
    final apiClient = ref.watch(apiClientProvider);
    return ApiRestaurantRepository(apiClient);
  }
});

// ユースケースの提供
final getNearbyRestaurantsUseCaseProvider = Provider<GetNearbyRestaurantsUseCase>((ref) {
  return GetNearbyRestaurantsUseCase(ref.watch(restaurantRepositoryProvider));
});

// 状態の提供
final nearbyRestaurantsProvider = FutureProvider.family<List<Restaurant>, Map<String, dynamic>>((ref, params) {
  final useCase = ref.watch(getNearbyRestaurantsUseCaseProvider);
  return useCase.execute(
    params['latitude'] as double, 
    params['longitude'] as double,
    radius: params['radius'] as double? ?? 1000,
  )
  .then((result) => result.isSuccess ? result.data! : []);
});
```

## 4. UI設計ガイドライン

### 4.1 再利用可能なウィジェット

共通のUIコンポーネントは`presentation/widgets`ディレクトリに配置し、再利用する：

```dart
// lib/presentation/widgets/restaurant_card.dart
class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onTap;
  
  const RestaurantCard({
    Key? key,
    required this.restaurant,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // カードのUI実装
  }
}
```

### 4.2 テーマの一貫性

アプリ全体で一貫したテーマを使用：

```dart
// lib/presentation/themes/app_theme.dart
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: Colors.blue,
      colorScheme: ColorScheme.light(
        primary: Colors.blue,
        secondary: Colors.orange,
      ),
      // その他のテーマ設定
    );
  }
  
  // ダークテーマも定義可能
  static ThemeData get darkTheme {
    // ...
  }
}
```

### 4.3 レスポンシブデザイン

さまざまな画面サイズに対応するレスポンシブなレイアウト：

```dart
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  
  const ResponsiveLayout({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);
  
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;
      
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650 &&
      MediaQuery.of(context).size.width < 1100;
      
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;
  
  @override
  Widget build(BuildContext context) {
    if (isDesktop(context) && desktop != null) {
      return desktop!;
    } else if (isTablet(context) && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }
}
```

## 5. エラーハンドリングガイドライン

### 5.1 例外の種類と処理方法

```dart
// lib/core/exceptions/app_exceptions.dart
abstract class AppException implements Exception {
  final String message;
  
  AppException(this.message);
}

class NetworkException extends AppException {
  NetworkException([String message = 'ネットワークエラーが発生しました'])
      : super(message);
}

class UnauthorizedException extends AppException {
  UnauthorizedException([String message = '認証エラーが発生しました'])
      : super(message);
}

// その他の例外クラス...
```

### 5.2 Result型による結果のラッピング

```dart
// lib/domain/entities/result.dart
enum ResultStatus {
  success,
  error,
  networkError,
  notFound,
  unauthorized,
  validationError,
}

class Result<T> {
  final T? data;
  final String? errorMessage;
  final ResultStatus status;

  Result.success(this.data) : 
    status = ResultStatus.success,
    errorMessage = null;

  Result.error(this.errorMessage, [this.status = ResultStatus.error]) : 
    data = null;

  Result.networkError() : 
    status = ResultStatus.networkError,
    data = null,
    errorMessage = "ネットワークエラーが発生しました。接続を確認してください。";

  // その他のファクトリメソッド...

  bool get isSuccess => status == ResultStatus.success;
  bool get isError => status != ResultStatus.success;

  T get dataOrThrow {
    if (isSuccess && data != null) {
      return data!;
    }
    throw Exception(errorMessage ?? "Unknown error");
  }
}
```

### 5.3 UIでのエラー表示

```dart
// エラー表示用のウィジェット
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  
  const ErrorView({
    Key? key,
    required this.message,
    this.onRetry,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: Text('リトライ'),
            ),
          ],
        ],
      ),
    );
  }
}

// 使用例
ref.watch(restaurantDetailsProvider(id)).when(
  data: (data) => RestaurantDetailContent(data: data),
  loading: () => Center(child: CircularProgressIndicator()),
  error: (error, _) => ErrorView(
    message: error.toString(),
    onRetry: () => ref.refresh(restaurantDetailsProvider(id)),
  ),
);
```

## 6. テストガイドライン

### 6.1 ユニットテスト

ドメイン層とデータ層のロジックをテストする：

```dart
// test/domain/usecases/get_nearby_restaurants_usecase_test.dart
void main() {
  group('GetNearbyRestaurantsUseCase', () {
    late MockRestaurantRepository mockRepository;
    late GetNearbyRestaurantsUseCase useCase;

    setUp(() {
      mockRepository = MockRestaurantRepository();
      useCase = GetNearbyRestaurantsUseCase(mockRepository);
    });

    test('should return success result when repository succeeds', () async {
      // Arrange
      final mockRestaurants = [
        Restaurant(id: '1', name: 'Test Restaurant', /* 他のパラメータ */)
      ];
      when(mockRepository.getNearbyRestaurants(any, any, radius: anyNamed('radius')))
          .thenAnswer((_) async => Result.success(mockRestaurants));

      // Act
      final result = await useCase.execute(35.6812, 139.7671);

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, mockRestaurants);
      verify(mockRepository.getNearbyRestaurants(35.6812, 139.7671, radius: 1000)).called(1);
    });

    test('should return error result when repository fails', () async {
      // Arrange
      when(mockRepository.getNearbyRestaurants(any, any, radius: anyNamed('radius')))
          .thenAnswer((_) async => Result.error('エラーが発生しました'));

      // Act
      final result = await useCase.execute(35.6812, 139.7671);

      // Assert
      expect(result.isError, true);
      expect(result.errorMessage, 'エラーが発生しました');
    });
  });
}
```

### 6.2 ウィジェットテスト

UIコンポーネントをテストする：

```dart
// test/presentation/widgets/restaurant_card_test.dart
void main() {
  testWidgets('RestaurantCard displays restaurant information correctly', (WidgetTester tester) async {
    // Arrange
    final restaurant = Restaurant(
      id: '1',
      name: 'テストレストラン',
      description: 'テスト説明',
      latitude: 35.6812,
      longitude: 139.7671,
      address: 'テスト住所',
      categories: ['和食'],
      averageRating: 4.5,
      reviewCount: 10,
    );
    bool tapped = false;

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RestaurantCard(
            restaurant: restaurant,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    // Assert
    expect(find.text('テストレストラン'), findsOneWidget);
    expect(find.text('テスト住所'), findsOneWidget);
    expect(find.text('4.5'), findsOneWidget);
    
    await tester.tap(find.byType(RestaurantCard));
    expect(tapped, true);
  });
}
```

### 6.3 統合テスト

複数のコンポーネントが連携する機能をテストする：

```dart
// integration_test/search_flow_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete search flow works correctly', (WidgetTester tester) async {
    // アプリを起動
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    // 検索バーをタップ
    await tester.tap(find.byType(SearchBar));
    await tester.pumpAndSettle();

    // 検索クエリを入力
    await tester.enterText(find.byType(TextField), '和食');
    await tester.pumpAndSettle();

    // 検索ボタンをタップ
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    // 検索結果が表示されることを確認
    expect(find.byType(RestaurantCard), findsWidgets);
    
    // 検索結果の最初のカードをタップ
    await tester.tap(find.byType(RestaurantCard).first);
    await tester.pumpAndSettle();
    
    // 詳細画面が表示されることを確認
    expect(find.byType(RestaurantDetailScreen), findsOneWidget);
  });
}
```

## 7. パフォーマンス最適化ガイドライン

### 7.1 メモリ最適化

- 大きなリストには`ListView.builder`を使用して仮想化
```dart
ListView.builder(
  itemCount: restaurants.length,
  itemBuilder: (context, index) {
    return RestaurantCard(restaurant: restaurants[index]);
  },
)
```

- 画像の適切なキャッシュと最適化
```dart
// CachedNetworkImageの使用例
CachedNetworkImage(
  imageUrl: restaurant.imageUrl ?? '',
  placeholder: (context, url) => ShimmerLoading(),
  errorWidget: (context, url, error) => Icon(Icons.restaurant),
  fit: BoxFit.cover,
)
```

- メモリリークを避けるためのリソースの適切な破棄
```dart
@override
void dispose() {
  _controller.dispose();
  _subscription?.cancel();
  super.dispose();
}
```

### 7.2 レンダリング最適化

- `const`コンストラクタの活用
```dart
const MyWidget(
  key: Key('my-widget'),
  value: 'static value',
)
```

- 不必要な再ビルドを避ける
```dart
// ConsumerのrepaintBoundaryを活用
Consumer(
  builder: (context, ref, _) {
    final count = ref.watch(counterProvider);
    return Text('$count');
  },
)
```

- ウィジェットツリーの深さを最小限に抑える
```dart
// 悪い例（過度にネストされている）
return Column(
  children: [
    Container(
      padding: EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(),
        child: Center(
          child: Text('Hello'),
        ),
      ),
    ),
  ],
);

// 良い例
return Padding(
  padding: EdgeInsets.all(8),
  child: DecoratedBox(
    decoration: BoxDecoration(),
    child: Center(
      child: Text('Hello'),
    ),
  ),
);
```

### 7.3 ネットワーク最適化

- データのキャッシュ戦略
```dart
// 単純なインメモリキャッシュの例
class SimpleCache<K, V> {
  final Map<K, V> _cache = {};
  final Duration _expiryDuration;
  final Map<K, DateTime> _timestamps = {};
  
  SimpleCache({Duration? expiryDuration})
      : _expiryDuration = expiryDuration ?? Duration(minutes: 5);
  
  V? get(K key) {
    if (!_cache.containsKey(key)) return null;
    
    final timestamp = _timestamps[key]!;
    if (DateTime.now().difference(timestamp) > _expiryDuration) {
      // 有効期限切れ
      _cache.remove(key);
      _timestamps.remove(key);
      return null;
    }
    
    return _cache[key];
  }
  
  void set(K key, V value) {
    _cache[key] = value;
    _timestamps[key] = DateTime.now();
  }
  
  void clear() {
    _cache.clear();
    _timestamps.clear();
  }
}
```

- 効率的なAPIリクエスト
```dart
// リクエストのバッチ処理
class RestaurantBatchFetcher {
  final List<String> _pendingIds = [];
  Timer? _timer;
  final Function(List<String>) _fetchCallback;
  
  RestaurantBatchFetcher(this._fetchCallback);
  
  void fetch(String id) {
    _pendingIds.add(id);
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: 100), _processBatch);
  }
  
  void _processBatch() {
    if (_pendingIds.isEmpty) return;
    
    final idsBatch = List<String>.from(_pendingIds);
    _pendingIds.clear();
    _fetchCallback(idsBatch);
  }
  
  void dispose() {
    _timer?.cancel();
    _pendingIds.clear();
  }
}
```

## 8. リファクタリングガイドライン

### 8.1 コードスメルの検出と修正

#### 長すぎるメソッド

```dart
// 悪い例
void processUserData() {
  // 100行以上のコード...
}

// 良い例
void processUserData() {
  validateUserInput();
  updateUserProfile();
  notifyUserChanges();
}

void validateUserInput() {
  // 入力検証のコード
}

void updateUserProfile() {
  // プロフィール更新のコード
}

void notifyUserChanges() {
  // 通知処理のコード
}
```

#### 過度に複雑な条件分岐

```dart
// 悪い例
if (user != null && user.isAuthenticated && !user.isBlocked 
    && (user.role == 'admin' || user.hasSpecialPermission)) {
  // 処理
}

// 良い例
bool canAccessFeature(User user) {
  if (user == null) return false;
  if (!user.isAuthenticated) return false;
  if (user.isBlocked) return false;
  
  return user.role == 'admin' || user.hasSpecialPermission;
}

if (canAccessFeature(user)) {
  // 処理
}
```

### 8.2 コード品質の維持

- 定期的なコードレビュー
- 静的解析ツールの活用（flutter analyze, custom lint rules）
- テストカバレッジの監視

### 8.3 リファクタリング戦略

1. **テストを先に書く**: リファクタリング前にテストを書いて安全性を確保
2. **小さな変更を段階的に行う**: 一度に大きな変更を避け、小さな変更を段階的に適用
3. **一つのリファクタリングにつき一つのPull Request**: レビューしやすさを考慮

## 9. Git & バージョン管理ガイドライン

### 9.1 ブランチ戦略

```
main        : 本番環境のコード
  ↑
develop     : 開発版、テスト済みコード
  ↑
feature/*   : 機能開発
  ↑
task/*      : 細かいタスク
```

### 9.2 コミットメッセージの規約

```
<type>: <subject>

<body>

<footer>
```

- **type**: feat, fix, docs, style, refactor, test, chore
- **subject**: 変更内容の要約（命令形、現在形で）
- **body**: 詳細な説明（省略可）
- **footer**: 関連するIssue/PRへの参照（省略可）

例：
```
feat: レストラン詳細画面にレビュー一覧を追加

- ページネーション機能を実装
- 最新のレビューを先頭に表示
- 各レビューにユーザー情報を表示

Closes #123
```

### 9.3 Pull Requestのガイドライン

- 明確なタイトルと説明
- スクリーンショットや動画（UI変更の場合）
- レビュワーの指定
- チェックリストの使用

```markdown
## 変更内容
レストラン詳細画面にレビュー一覧機能を追加

## スクリーンショット
![レビュー一覧](url-to-screenshot)

## チェックリスト
- [x] テストを追加/更新
- [x] ドキュメントを更新
- [x] UIガイドラインに準拠
- [x] アクセシビリティを考慮

関連Issue: #123
```

## 10. ドキュメント作成ガイドライン

### 10.1 コードドキュメント

- クラス、メソッドには必ずドキュメントコメントを追加
- 複雑なロジックには説明コメントを追加

```dart
/// レストランの詳細情報を取得するユースケース
///
/// レストラン情報とレビュー情報を並行して取得し、
/// 両方の結果を組み合わせて返却する
class GetRestaurantDetailsUseCase {
  final RestaurantRepository repository;
  
  GetRestaurantDetailsUseCase(this.repository);
  
  /// 指定されたIDのレストラン詳細を取得する
  ///
  /// [restaurantId] 取得対象のレストランID
  ///
  /// 返却値は以下の構造を持つMap:
  /// - 'restaurant': Restaurant オブジェクト
  /// - 'reviews': List<Review> オブジェクト
  ///
  /// エラー発生時はResult.errorを返却
  Future<Result<Map<String, dynamic>>> execute(String restaurantId) async {
    // 実装
  }
}
```

### 10.2 README作成

各モジュールにREADMEを用意し、以下の情報を記載：

- 目的と責務
- 主要クラスと関係性
- 使用例
- 注意点

```markdown
# データ層 (Data Layer)

## 目的と責務
外部データソース（API、ローカルストレージなど）との通信を担当し、
ドメイン層で定義されたリポジトリインターフェースを実装します。

## 主要コンポーネント

### APIクライアント
`ApiClient` クラスはHTTPリクエストの送受信を担当します。

### リポジトリ実装
ドメイン層で定義されたリポジトリインターフェースの実装です。
例: `ApiRestaurantRepository`, `MockRestaurantRepository`

## 使用例

```dart
// APIクライアントの初期化
final apiClient = ApiClient(baseUrl: 'https://api.example.com');

// リポジトリの初期化
final restaurantRepository = ApiRestaurantRepository(apiClient);

// リポジトリを使用してデータ取得
final result = await restaurantRepository.getNearbyRestaurants(
  latitude: 35.6812,
  longitude: 139.7671,
);
```

## 注意点
- 実装クラスはドメイン層のインターフェースを忠実に実装すること
- データ変換ロジックは複雑化しないこと
- エラーハンドリングは適切に行うこと
```

### 10.3 アーキテクチャドキュメント

プロジェクト全体の設計思想や構造を記述したドキュメントを作成：

- アーキテクチャ概要と選定理由
- レイヤー構造と責務
- データフロー
- 拡張ポイント

## 11. モバイル特有の開発ガイドライン

### 11.1 デバイス固有の機能利用

```dart
// 位置情報の取得例
class LocationService {
  final Geolocator _geolocator = Geolocator();
  
  Future<bool> isPermissionGranted() async {
    final status = await _geolocator.checkPermission();
    return status == LocationPermission.always || 
           status == LocationPermission.whileInUse;
  }
  
  Future<Position?> getCurrentLocation() async {
    if (!await isPermissionGranted()) {
      final status = await _geolocator.requestPermission();
      if (status != LocationPermission.always && 
          status != LocationPermission.whileInUse) {
        return null;
      }
    }
    
    return await _geolocator.getCurrentPosition();
  }
}
```

### 11.2 オフライン対応

```dart
class OfflineFirstRepository<T> {
  final LocalStorage _localStorage;
  final ApiClient _apiClient;
  final String _entityType;
  
  OfflineFirstRepository(this._localStorage, this._apiClient, this._entityType);
  
  Future<Result<List<T>>> getAll() async {
    try {
      // まずローカルから取得
      final localData = await _localStorage.getItems<T>(_entityType);
      
      // ネットワーク接続を確認
      if (await _hasNetworkConnection()) {
        // APIから最新データを取得
        final apiResult = await _apiClient.getItems<T>(_entityType);
        
        if (apiResult.isSuccess) {
          // ローカルストレージを更新
          await _localStorage.saveItems<T>(_entityType, apiResult.data!);
          return apiResult;
        }
      }
      
      // ネットワーク接続がないか、APIエラーの場合はローカルデータを返す
      return Result.success(localData);
    } catch (e) {
      return Result.error(e.toString());
    }
  }
  
  Future<bool> _hasNetworkConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}
```

### 11.3 バックグラウンド処理

```dart
class BackgroundSyncService {
  static const _syncTaskName = 'restaurant_sync';
  
  Future<void> scheduleSyncTask() async {
    final workManager = WorkManager();
    
    await workManager.registerPeriodicTask(
      _syncTaskName,
      _syncTaskName,
      frequency: Duration(hours: 1),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
    );
  }
  
  static void callbackDispatcher() {
    WorkManager().executeTask((taskName, inputData) async {
      if (taskName == _syncTaskName) {
        // 同期処理の実装
        final repository = getIt<RestaurantRepository>();
        await repository.syncFavoriteRestaurants();
        return true;
      }
      return false;
    });
  }
}
```

## 12. アクセシビリティガイドライン

### 12.1 スクリーンリーダー対応

```dart
// セマンティックラベルの追加
IconButton(
  icon: Icon(Icons.favorite),
  onPressed: () => toggleFavorite(),
  semanticLabel: '気に入り登録',
);

// 複雑なウィジェットのセマンティクス
Semantics(
  label: 'レストラン: 和食さくら、評価: 4.5、距離: 300m',
  child: RestaurantCard(restaurant: restaurant),
);
```

### 12.2 コントラストと視認性

```dart
// テキストのコントラスト比を考慮
Text(
  'レストラン名',
  style: TextStyle(
    color: Colors.black87, // 高コントラスト
    fontSize: 16.0,        // 十分な大きさ
    fontWeight: FontWeight.bold,
  ),
);

// 背景と前景のコントラスト
Container(
  color: Colors.white,
  child: Text(
    'テキスト',
    style: TextStyle(color: Colors.black87),
  ),
);
```

### 12.3 フォーカスと操作性

```dart
// フォーカスノードの使用
FocusScope(
  node: _focusScopeNode,
  child: TextField(
    focusNode: _focusNode,
    decoration: InputDecoration(
      labelText: '検索',
      hintText: 'レストラン名を入力',
    ),
  ),
);

// タップターゲットのサイズ
InkWell(
  onTap: () => onTap(),
  child: Padding(
    padding: EdgeInsets.all(12), // タップエリアを広く
    child: Icon(Icons.search),
  ),
);
```

## 13. セキュリティガイドライン

### 13.1 データの安全な保存

```dart
// 機密データの安全な保存にはflutter_secure_storageを使用
class SecureStorageService {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }
  
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
  
  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }
}
```

### 13.2 API通信のセキュリティ

```dart
class SecureApiClient {
  final http.Client _httpClient;
  final SecureStorageService _secureStorage;
  
  SecureApiClient(this._httpClient, this._secureStorage);
  
  Future<Result<T>> get<T>(String endpoint) async {
    try {
      final token = await _secureStorage.getToken();
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      
      final response = await _httpClient.get(
        Uri.https('api.example.com', endpoint),
        headers: headers,
      );
      
      // レスポンス処理
      return _processResponse<T>(response);
    } catch (e) {
      return Result.error(e.toString());
    }
  }
  
  Result<T> _processResponse<T>(http.Response response) {
    // レスポンス検証と処理
  }
}
```

### 13.3 入力データの検証

```dart
class InputValidator {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'メールアドレスを入力してください';
    }
    
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4});
    if (!emailRegExp.hasMatch(value)) {
      return '有効なメールアドレスを入力してください';
    }
    
    return null;
  }
  
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'パスワードを入力してください';
    }
    
    if (value.length < 8) {
      return 'パスワードは8文字以上で入力してください';
    }
    
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'パスワードには数字を含めてください';
    }
    
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'パスワードには大文字を含めてください';
    }
    
    return null;
  }
}
```

## 付録: 頻出問題と解決策

### A. 状態管理の問題

#### 問題: ウィジェット再構築の過剰発生

```dart
// 問題
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 全体の状態を監視するとウィジェット全体が再構築される
    final state = ref.watch(myStateProvider);
    
    return Column(
      children: [
        Text(state.title),
        ExpensiveWidget(),
      ],
    );
  }
}

// 解決策
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // 必要な部分だけを監視
        Consumer(
          builder: (context, ref, _) {
            final title = ref.watch(myStateProvider.select((s) => s.title));
            return Text(title);
          },
        ),
        // 再構築が不要な部分
        const ExpensiveWidget(),
      ],
    );
  }
}
```

### B. パフォーマンスの問題

#### 問題: 大きなリストのスクロール遅延

```dart
// 問題
ListView(
  children: items.map((item) => ItemWidget(item)).toList(),
);

// 解決策
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ItemWidget(items[index]);
  },
);
```

### C. エラーハンドリングの問題

#### 問題: エラー発生時のユーザー体験不良

```dart
// 問題
FutureBuilder<Result<List<Restaurant>>>(
  future: repository.getNearbyRestaurants(latitude, longitude),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final result = snapshot.data!;
      if (result.isSuccess) {
        return RestaurantList(restaurants: result.data!);
      } else {
        // エラーメッセージのみ表示
        return Text(result.errorMessage!);
      }
    } else if (snapshot.hasError) {
      return Text('エラーが発生しました');
    }
    return CircularProgressIndicator();
  },
);

// 解決策
FutureBuilder<Result<List<Restaurant>>>(
  future: repository.getNearbyRestaurants(latitude, longitude),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return ShimmerLoading(); // ローディングスケルトン
    } else if (snapshot.hasData) {
      final result = snapshot.data!;
      if (result.isSuccess) {
        return RestaurantList(restaurants: result.data!);
      } else {
        // ユーザーフレンドリーなエラー表示とリトライオプション
        return ErrorView(
          message: result.errorMessage!,
          onRetry: () => setState(() {
            // リトライロジック
          }),
        );
      }
    } else if (snapshot.hasError) {
      return ErrorView(
        message: '予期せぬエラーが発生しました',
        onRetry: () => setState(() {
          // リトライロジック
        }),
      );
    }
    return ShimmerLoading();
  },
);
```
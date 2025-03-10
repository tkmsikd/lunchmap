# ランチマップアプリ 技術設計書

## 1. アーキテクチャ概要

本プロジェクトはクリーンアーキテクチャを採用し、以下の層で構成される：

![クリーンアーキテクチャ](https://miro.medium.com/max/1400/1*wOmAHDN_zKZJns9YDjtrMw.jpeg)

1. **プレゼンテーション層**: UI、状態管理（Riverpod）
2. **ドメイン層**: ビジネスルール、エンティティ、ユースケース
3. **データ層**: データソースへのアクセス、リポジトリ実装

### 1.1 依存関係の方向

- 外側の層は内側の層に依存する
- 内側の層は外側の層のことを知らない
- ドメイン層はフレームワークやライブラリから独立している

## 2. モジュール構成

```
lib/
├── core/             # 共通ユーティリティ、例外処理、定数など
├── data/             # データ層
│   ├── api/          # API関連のクラス
│   ├── models/       # データモデル（DTO）
│   └── repositories/ # リポジトリの実装
├── domain/           # ドメイン層
│   ├── entities/     # ドメインエンティティ
│   ├── repositories/ # リポジトリインターフェース
│   └── usecases/     # ユースケース
├── presentation/     # プレゼンテーション層
│   ├── pages/        # 画面
│   ├── providers/    # Riverpod プロバイダー
│   ├── widgets/      # 再利用可能なウィジェット
│   └── routes/       # ルート定義
└── application.dart  # アプリケーションのエントリーポイント
```

## 3. ドメイン層の設計

### 3.1 エンティティ

ビジネスルールを持つドメインオブジェクト。システムの中核となるデータ構造。

#### 主要エンティティ

1. **User**
```dart
class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final List<String> favoriteRestaurantIds;
  final List<String> teamIds;
  
  // コンストラクタとメソッド
}
```

2. **Restaurant**
```dart
class Restaurant {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String address;
  final List<String> categories;
  final double averageRating;
  final int reviewCount;
  final String? imageUrl;
  final Map<String, dynamic>? businessHours;
  final bool? isCrowded;
  
  // コンストラクタとメソッド
}
```

3. **Review**
```dart
class Review {
  final String id;
  final String restaurantId;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final List<String>? imageUrls;
  
  // コンストラクタとメソッド
}
```

4. **Team**
```dart
class Team {
  final String id;
  final String name;
  final String creatorId;
  final List<String> memberIds;
  final List<String> sharedRestaurantIds;
  
  // コンストラクタとメソッド
}
```

5. **Route**
```dart
class Route {
  final List<LatLng> points;
  final String distance;
  final String duration;
  final List<String> instructions;
  
  // コンストラクタとメソッド
}
```

### 3.2 ユースケース

アプリケーションの具体的なビジネスルールを実装するクラス。

#### 主要ユースケース

1. **GetNearbyRestaurantsUseCase**
```dart
class GetNearbyRestaurantsUseCase {
  final RestaurantRepository repository;
  
  Future<Result<List<Restaurant>>> execute(
    double latitude,
    double longitude,
    {double radius = 1000}
  );
}
```

2. **SearchRestaurantsUseCase**
```dart
class SearchRestaurantsUseCase {
  final RestaurantRepository repository;
  
  Future<Result<List<Restaurant>>> execute(
    String query,
    {List<String>? categories}
  );
}
```

3. **GetRestaurantDetailsUseCase**
```dart
class GetRestaurantDetailsUseCase {
  final RestaurantRepository repository;
  
  Future<Result<Map<String, dynamic>>> execute(String restaurantId);
}
```

### 3.3 リポジトリインターフェース

データソースとの通信を抽象化するインターフェース。

#### 主要リポジトリ

1. **AuthRepository**
```dart
abstract class AuthRepository {
  Future<Result<User>> signIn(String email, String password);
  Future<Result<User>> signUp(String name, String email, String password);
  Future<Result<void>> signOut();
  Future<Result<User?>> getCurrentUser();
  Stream<User?> authStateChanges();
}
```

2. **RestaurantRepository**
```dart
abstract class RestaurantRepository {
  Future<Result<List<Restaurant>>> getNearbyRestaurants(
    double latitude,
    double longitude,
    {double radius = 1000}
  );
  Future<Result<Restaurant>> getRestaurantById(String id);
  Future<Result<List<Restaurant>>> searchRestaurants(
    String query,
    {List<String>? categories}
  );
  Future<Result<List<Review>>> getRestaurantReviews(String restaurantId);
  Future<Result<void>> addRestaurantToFavorites(
    String userId,
    String restaurantId
  );
  Future<Result<void>> removeRestaurantFromFavorites(
    String userId,
    String restaurantId
  );
  Future<Result<List<Restaurant>>> getFavoriteRestaurants(String userId);
}
```

## 4. データ層の設計

### 4.1 APIクライアント

バックエンドサービスとの通信を担当するクラス。

```dart
class ApiClient {
  final http.Client _httpClient;
  final String baseUrl;
  
  Future<Result<T>> _performRequest<T>({
    required String endpoint,
    required HttpMethod method,
    required T Function(Map<String, dynamic> json) fromJson,
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  });
  
  // 各APIエンドポイントに対するメソッド
  Future<Result<List<dynamic>>> getNearbyRestaurants(
    double latitude,
    double longitude,
    double radius,
  );
  
  // その他メソッド
}
```

### 4.2 リポジトリ実装

データ層においてドメイン層のリポジトリインターフェースを実装するクラス。

```dart
class ApiRestaurantRepository implements RestaurantRepository {
  final ApiClient _apiClient;
  
  @override
  Future<Result<List<Restaurant>>> getNearbyRestaurants(
    double latitude,
    double longitude,
    {double radius = 1000}
  ) async {
    final result = await _apiClient.getNearbyRestaurants(
      latitude,
      longitude,
      radius,
    );
    
    if (result.isSuccess && result.data != null) {
      final restaurants = (result.data as List)
          .map((json) => Restaurant.fromJson(json))
          .toList();
      return Result.success(restaurants);
    } else {
      return Result.error(result.errorMessage ?? '不明なエラーが発生しました');
    }
  }
  
  // その他のメソッド実装
}
```

### 4.3 モックリポジトリ

開発初期やテストで使用するモックデータを提供するリポジトリ実装。

```dart
class MockRestaurantRepository implements RestaurantRepository {
  final List<Restaurant> _mockRestaurants = [
    // モックデータ
  ];
  
  @override
  Future<Result<List<Restaurant>>> getNearbyRestaurants(
    double latitude,
    double longitude,
    {double radius = 1000}
  ) async {
    await Future.delayed(const Duration(milliseconds: 500)); // 遅延をシミュレート
    return Result.success(_mockRestaurants);
  }
  
  // その他のメソッド実装
}
```

## 5. プレゼンテーション層の設計

### 5.1 状態管理（Riverpod）

Riverpodを使用して状態を管理するプロバイダーの設計。

```dart
// リポジトリプロバイダー
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository();  // 開発初期はモックを使用
});

// ユースケースプロバイダー
final getNearbyRestaurantsUseCaseProvider = Provider<GetNearbyRestaurantsUseCase>((ref) {
  return GetNearbyRestaurantsUseCase(ref.watch(restaurantRepositoryProvider));
});

// 状態プロバイダー
final nearbyRestaurantsProvider = FutureProvider.family<List<Restaurant>, Map<String, dynamic>>((ref, params) {
  final latitude = params['latitude'] as double;
  final longitude = params['longitude'] as double;
  final radius = params['radius'] as double? ?? 1000.0;
  
  return ref.watch(getNearbyRestaurantsUseCaseProvider)
      .execute(latitude, longitude, radius: radius)
      .then((result) => result.isSuccess ? result.data! : []);
});
```

### 5.2 画面構成

主要な画面とそのコンポーネント構造。

1. **ホーム画面（MapScreen）**
   - 地図表示
   - 近くのレストラン表示
   - カテゴリフィルター
   - 検索バー

2. **検索結果画面（SearchResultScreen）**
   - 検索結果リスト
   - フィルターオプション
   - 並び替えオプション

3. **レストラン詳細画面（RestaurantDetailScreen）**
   - 基本情報（名前、写真、評価）
   - 地図（位置）
   - レビューリスト
   - 「ナビ開始」ボタン
   - 「お気に入り追加」ボタン
   - 「共有」ボタン

4. **レビュー投稿画面（AddReviewScreen）**
   - 評価入力
   - コメント入力
   - 写真アップロード

5. **ナビゲーション画面（NavigationScreen）**
   - ルート表示
   - ステップバイステップ指示
   - 所要時間・距離

6. **チーム管理画面（TeamScreen）**
   - チームリスト
   - チーム作成
   - メンバー管理
   - 共有レストラン

7. **プロフィール画面（ProfileScreen）**
   - ユーザー情報
   - お気に入りリスト
   - 投稿したレビュー

### 5.3 ナビゲーション

アプリ内のルーティングとナビゲーション戦略。

```dart
// lib/presentation/routes/app_router.dart
class AppRouter {
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String restaurantDetail = '/restaurant/:id';
  static const String addReview = '/restaurant/:id/review/add';
  static const String navigation = '/navigation';
  static const String search = '/search';
  static const String profile = '/profile';
  static const String teams = '/teams';
  static const String teamDetail = '/teams/:id';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // ルート生成ロジック
  }
}
```

## 6. エラーハンドリングとデータフロー

### 6.1 Result型

操作の結果を表すジェネリック型。成功、エラー、ローディング状態を明示的に扱う。

```dart
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
    
  // その他のファクトリメソッド

  bool get isSuccess => status == ResultStatus.success;
  bool get isError => status != ResultStatus.success;
}
```

### 6.2 データフロー例（レストラン検索）

1. ユーザーが検索クエリを入力
2. UI層がProviderを通じて検索ユースケースを呼び出し
3. ユースケースがリポジトリの検索メソッドを実行
4. リポジトリがAPIクライアントでデータ取得（またはモックデータ）
5. APIクライアントがHTTPリクエストを送信し結果をResult型で返却
6. リポジトリがAPIレスポンスをエンティティに変換
7. ユースケースが変換されたエンティティを受け取り、ビジネスロジックを適用
8. UI層がResult型の結果に基づいて表示を更新

```dart
// プレゼンテーション層での使用例
ref.watch(searchRestaurantsProvider(query)).when(
  data: (restaurants) {
    // 成功時の表示
    return RestaurantListView(restaurants: restaurants);
  },
  loading: () => const LoadingIndicator(),
  error: (error, stackTrace) {
    // エラー時の表示
    return ErrorView(message: error.toString());
  },
);
```

## 7. テスト戦略

### 7.1 ユニットテスト

ドメイン層とデータ層の個々のクラスをテスト。

```dart
// ユースケースのテスト例
void main() {
  group('GetNearbyRestaurantsUseCase', () {
    late MockRestaurantRepository mockRepository;
    late GetNearbyRestaurantsUseCase useCase;

    setUp(() {
      mockRepository = MockRestaurantRepository();
      useCase = GetNearbyRestaurantsUseCase(mockRepository);
    });

    test('should return restaurants on success', () async {
      // テスト実装
    });

    test('should return error when repository fails', () async {
      // テスト実装
    });
  });
}
```

### 7.2 ウィジェットテスト

UI要素の単体テスト。

```dart
void main() {
  testWidgets('RestaurantCard displays restaurant information correctly', (WidgetTester tester) async {
    // テスト実装
  });
}
```

### 7.3 統合テスト

複数のコンポーネントが連携する機能のテスト。

```dart
void main() {
  testWidgets('Search flow works correctly', (WidgetTester tester) async {
    // テスト実装
  });
}
```

## 8. Web開発への拡張計画

モバイルアプリ開発後、Webアプリケーション開発に拡張する際の戦略。

### 8.1 共通コンポーネント

- ドメイン層のエンティティ定義
- バックエンドAPIインターフェース
- ビジネスロジック

### 8.2 Web固有の実装

- React/Next.jsベースのUIコンポーネント
- Web向け状態管理（Redux/Context API）
- レスポンシブデザイン

### 8.3 技術スタック選定の考慮点

- SEO要件
- ブラウザ互換性
- ページロード最適化
- PWA（Progressive Web App）対応

## 9. 性能最適化戦略

### 9.1 Flutterアプリのパフォーマンス

- メモリ使用量の最適化
  - 画像のキャッシュ戦略
  - ウィジェット再構築の最小化
  
- レンダリングパフォーマンス
  - const constructorの適切な使用
  - ListView.builderなどの仮想化リストの使用
  
- アプリサイズの最適化
  - リソースの圧縮
  - コードの最適化

### 9.2 ネットワーク最適化

- APIリクエストのバッチ処理
- データのキャッシュ
- オフラインファーストアプローチ
- 画像の遅延読み込み

## 10. セキュリティ対策

### 10.1 認証セキュリティ

- 安全なトークン管理
- セッション有効期限の設定
- バイオメトリック認証の選択肢

### 10.2 データセキュリティ

- センシティブデータの安全な保存
- 通信の暗号化（HTTPS）
- 入力データのバリデーション

## 11. APIエンドポイント設計（将来実装）

将来的に実装するAPIのエンドポイント設計。

### 11.1 認証関連

| エンドポイント | メソッド | 説明 | パラメータ | レスポンス |
|---------------|---------|------|-----------|-----------|
| `/api/auth/register` | POST | ユーザー登録 | name, email, password | ユーザー情報、トークン |
| `/api/auth/login` | POST | ログイン | email, password | ユーザー情報、トークン |
| `/api/auth/logout` | POST | ログアウト | token | 成功メッセージ |
| `/api/auth/me` | GET | 現在のユーザー情報取得 | token | ユーザー情報 |

### 11.2 レストラン関連

| エンドポイント | メソッド | 説明 | パラメータ | レスポンス |
|---------------|---------|------|-----------|-----------|
| `/api/restaurants/nearby` | GET | 近くのレストラン取得 | latitude, longitude, radius | レストランリスト |
| `/api/restaurants/search` | GET | レストラン検索 | q, categories | レストランリスト |
| `/api/restaurants/:id` | GET | レストラン詳細取得 | id | レストラン詳細 |
| `/api/restaurants/:id/reviews` | GET | レストランのレビュー取得 | id | レビューリスト |

### 11.3 ユーザー関連

| エンドポイント | メソッド | 説明 | パラメータ | レスポンス |
|---------------|---------|------|-----------|-----------|
| `/api/users/:id/favorites` | GET | お気に入りリスト取得 | id | レストランリスト |
| `/api/users/:id/favorites/:restaurantId` | POST | お気に入り追加 | id, restaurantId | 成功メッセージ |
| `/api/users/:id/favorites/:restaurantId` | DELETE | お気に入り削除 | id, restaurantId | 成功メッセージ |
| `/api/users/:id/reviews` | GET | ユーザーのレビュー取得 | id | レビューリスト |

### 11.4 レビュー関連

| エンドポイント | メソッド | 説明 | パラメータ | レスポンス |
|---------------|---------|------|-----------|-----------|
| `/api/reviews` | POST | レビュー追加 | restaurantId, rating, comment, images | レビュー情報 |
| `/api/reviews/:id` | PUT | レビュー更新 | id, rating, comment, images | 更新されたレビュー |
| `/api/reviews/:id` | DELETE | レビュー削除 | id | 成功メッセージ |

### 11.5 チーム関連

| エンドポイント | メソッド | 説明 | パラメータ | レスポンス |
|---------------|---------|------|-----------|-----------|
| `/api/teams` | POST | チーム作成 | name, members | チーム情報 |
| `/api/teams/:id` | GET | チーム情報取得 | id | チーム詳細 |
| `/api/teams/:id/members` | POST | メンバー追加 | id, userId | 成功メッセージ |
| `/api/teams/:id/members/:userId` | DELETE | メンバー削除 | id, userId | 成功メッセージ |
| `/api/teams/:id/restaurants` | GET | 共有レストラン取得 | id | レストランリスト |
| `/api/teams/:id/restaurants/:restaurantId` | POST | レストラン共有 | id, restaurantId | 成功メッセージ |

### 11.6 ナビゲーション関連

| エンドポイント | メソッド | 説明 | パラメータ | レスポンス |
|---------------|---------|------|-----------|-----------|
| `/api/navigation/route` | GET | ルート取得 | startLat, startLng, destLat, destLng | ルート情報 |

## 12. モバイルアプリの画面遷移図

```
[ログイン/登録画面] --> [ホーム画面(地図)]
                   |
[ホーム画面(地図)] --+--> [検索結果画面] --> [レストラン詳細画面]
                   |                    |
                   +--> [レストラン詳細画面] --+--> [レビュー一覧/投稿画面]
                   |                       |
                   |                       +--> [ナビゲーション画面]
                   |                       |
                   |                       +--> [共有画面]
                   |
                   +--> [チーム画面] --+--> [チーム詳細画面] --> [メンバー管理画面]
                   |                  |
                   |                  +--> [共有レストラン一覧]
                   |
                   +--> [プロフィール画面] --+--> [お気に入り一覧]
                                         |
                                         +--> [投稿したレビュー一覧]
```

## 13. 将来的な技術負債対策

### 13.1 コード品質の維持

- 定期的なコードレビュー
- 静的解析ツールの導入（lint, analyzer）
- テストカバレッジの監視

### 13.2 依存関係の管理

- パッケージのバージョン管理戦略
- 定期的な依存関係の更新
- 破壊的変更への対応計画

### 13.3 スケーラビリティ

- コンポーネントの分割と再利用
- プラグイン化可能なアーキテクチャ
- 機能フラグを使った段階的デプロイメント

## 14. 開発環境と設定

### 14.1 必要なツールとセットアップ

- Flutter SDK 3.x以上
- Dart SDK 3.x以上
- IDE: VS Code または Android Studio
- Git
- Firebase CLI（将来的に必要な場合）

### 14.2 開発/ステージング/本番環境の設定

環境ごとの設定を管理するflavor設定：

```dart
// lib/core/config/environment_config.dart
enum Environment { dev, staging, prod }

class EnvironmentConfig {
  final Environment environment;
  final String apiBaseUrl;
  final String googleMapsApiKey;
  final bool enableAnalytics;
  
  static EnvironmentConfig? _instance;
  
  factory EnvironmentConfig({
    required Environment environment,
    required String apiBaseUrl,
    required String googleMapsApiKey,
    required bool enableAnalytics,
  }) {
    _instance ??= EnvironmentConfig._internal(
      environment: environment,
      apiBaseUrl: apiBaseUrl,
      googleMapsApiKey: googleMapsApiKey,
      enableAnalytics: enableAnalytics,
    );
    return _instance!;
  }
  
  EnvironmentConfig._internal({
    required this.environment,
    required this.apiBaseUrl,
    required this.googleMapsApiKey,
    required this.enableAnalytics,
  });
  
  static EnvironmentConfig get instance {
    if (_instance == null) {
      throw Exception('EnvironmentConfig has not been initialized');
    }
    return _instance!;
  }
  
  bool get isDev => environment == Environment.dev;
  bool get isStaging => environment == Environment.staging;
  bool get isProd => environment == Environment.prod;
}
```

### 14.3 リリース手順

1. バージョン番号の更新
2. 変更履歴の作成
3. リリースビルドの生成
4. テスト実行
5. ストアへのアップロード
6. リリースノートの作成

## 15. タスク管理とバージョン管理

### 15.1 ブランチ戦略

- `main`: 安定版、リリースに対応
- `develop`: 開発版、テスト済みの機能が統合される
- `feature/*`: 新機能開発
- `bugfix/*`: バグ修正
- `release/*`: リリース準備

### 15.2 コミット規約

Conventional Commitsに準拠:

- `feat`: 新機能
- `fix`: バグ修正
- `docs`: ドキュメント更新
- `style`: コードスタイル変更
- `refactor`: リファクタリング
- `test`: テスト関連
- `chore`: その他雑多な変更

例: `feat: レストラン検索機能を追加`

### 15.3 チケット/Issue管理

- 機能要件はチケット化
- バグ報告はIssueとして登録
- Pull Requestは対応するチケット/Issueにリンク

## 16. プロジェクト用語集

| 用語 | 定義 |
|-----|------|
| エンティティ | ビジネスロジックを持つドメインオブジェクト |
| ユースケース | 特定のビジネスロジックを実行するクラス |
| リポジトリ | データソースへのアクセスを抽象化するインターフェース |
| プロバイダー | Riverpodにおいて状態を提供するクラス |
| DTO | データ転送オブジェクト、APIとの通信に使用 |
| Result型 | 操作の結果を表すジェネリック型（成功/エラー） |

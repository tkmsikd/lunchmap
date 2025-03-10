# ランチマップアプリ 設計書

## アーキテクチャ概要

本プロジェクトではクリーンアーキテクチャを採用し、以下の層に分けて設計・実装を行う。

![クリーンアーキテクチャ](https://raw.githubusercontent.com/ResoCoder/flutter-tdd-clean-architecture-course/master/architecture-proposal.png)

### 層の説明

1. **プレゼンテーション層** (Presentation Layer)
   - UI/UXに関わる部分
   - ウィジェット、画面、状態管理（Riverpod）
   - ユーザー入力の処理とドメイン層との橋渡し

2. **ドメイン層** (Domain Layer)
   - ビジネスロジックを含む
   - エンティティ、リポジトリインターフェース、ユースケース
   - プラットフォームや実装の詳細に依存しない

3. **データ層** (Data Layer)
   - リポジトリの実装
   - APIクライアント、ローカルデータソースなど
   - 外部データソースとドメイン層の橋渡し

4. **コア** (Core)
   - 共通ユーティリティ、定数、拡張機能など
   - すべての層から利用される共通コンポーネント

## プロジェクト構造

```
lib/
├── core/             # 共通ユーティリティ、例外処理、定数など
├── data/             # データ層
│   ├── api/          # API関連のクラス
│   ├── models/       # データモデル（DTOなど）
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

## 主要なエンティティ

### User（ユーザー）
```dart
class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final List<String> favoriteRestaurantIds;
  final List<String> teamIds;
  // ...
}
```

### Restaurant（レストラン）
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
  // ...
}
```

### Review（レビュー）
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
  // ...
}
```

### Team（チーム）
```dart
class Team {
  final String id;
  final String name;
  final String creatorId;
  final List<String> memberIds;
  final List<String> sharedRestaurantIds;
  // ...
}
```

### Route（ルート）
```dart
class Route {
  final List<LatLng> points;
  final String distance;
  final String duration;
  final List<String> instructions;
  // ...
}
```

## 主要リポジトリ

### AuthRepository
```dart
abstract class AuthRepository {
  Future<Result<User>> signIn(String email, String password);
  Future<Result<User>> signUp(String name, String email, String password);
  Future<Result<void>> signOut();
  Future<Result<User?>> getCurrentUser();
  Stream<User?> authStateChanges();
}
```

### RestaurantRepository
```dart
abstract class RestaurantRepository {
  Future<Result<List<Restaurant>>> getNearbyRestaurants(double latitude, double longitude, {double radius = 1000});
  Future<Result<Restaurant>> getRestaurantById(String id);
  Future<Result<List<Restaurant>>> searchRestaurants(String query, {List<String>? categories});
  Future<Result<List<Review>>> getRestaurantReviews(String restaurantId);
  Future<Result<void>> addRestaurantToFavorites(String userId, String restaurantId);
  Future<Result<void>> removeRestaurantFromFavorites(String userId, String restaurantId);
  Future<Result<List<Restaurant>>> getFavoriteRestaurants(String userId);
}
```

### ReviewRepository
```dart
abstract class ReviewRepository {
  Future<Result<void>> addReview(Review review);
  Future<Result<void>> updateReview(Review review);
  Future<Result<void>> deleteReview(String reviewId);
  Future<Result<List<Review>>> getUserReviews(String userId);
}
```

### TeamRepository
```dart
abstract class TeamRepository {
  Future<Result<Team>> createTeam(String name, String creatorId, List<String> initialMemberIds);
  Future<Result<void>> addMemberToTeam(String teamId, String userId);
  Future<Result<void>> removeMemberFromTeam(String teamId, String userId);
  Future<Result<void>> shareRestaurantWithTeam(String teamId, String restaurantId);
  Future<Result<List<Restaurant>>> getTeamSharedRestaurants(String teamId);
  Future<Result<List<Team>>> getUserTeams(String userId);
}
```

### NavigationRepository
```dart
abstract class NavigationRepository {
  Future<Result<Route>> getRouteToRestaurant(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  );
}
```

## 状態管理（Riverpod）

Riverpodを用いた状態管理で、以下のような種類のプロバイダーを使用する：

1. **Provider** - 依存関係の注入（リポジトリやユースケースなど）
2. **FutureProvider** - 非同期データの取得
3. **StreamProvider** - ストリームデータ（認証状態など）
4. **StateNotifierProvider** - 変更可能な状態の管理

### 例：
```dart
// リポジトリプロバイダー
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository(); // 後に実際の実装に置き換え
});

// ユースケースプロバイダー
final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return SignInUseCase(ref.watch(authRepositoryProvider));
});

// 認証状態プロバイダー
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

// 検索状態管理プロバイダー
final searchNotifierProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref.watch(searchRestaurantsUseCaseProvider));
});
```

## エラーハンドリング

`Result`クラスを使用してエラー処理を統一：

```dart
class Result<T> {
  final T? data;
  final String? errorMessage;
  final ResultStatus status;

  Result.success(this.data) : 
    status = ResultStatus.success,
    errorMessage = null;

  Result.error(this.errorMessage, [this.status = ResultStatus.error]) : 
    data = null;

  // ... 他のファクトリコンストラクタ ...

  bool get isSuccess => status == ResultStatus.success;
  bool get isError => status != ResultStatus.error;
}
```

## API連携

将来的なバックエンド連携を見据え、以下のような設計を行う：

1. **APIクライアント** - HTTP通信を抽象化し、エンドポイントごとのメソッドを提供
2. **DTOモデル** - APIレスポンスとドメインエンティティの間の変換を担当
3. **リポジトリの二重実装** - 開発初期はモック、後期は実APIを使用

### 段階的API移行プラン
1. 初期開発: モックリポジトリを使用
2. API設計: エンドポイント定義とスキーマ設計
3. バックエンド開発: 必要に応じて別途開発
4. 統合: モックからAPIクライアントベースのリポジトリに移行

## 画面設計（主要画面）

1. **ログイン/サインアップ画面**
   - ユーザー認証フロー

2. **地図画面（メイン）**
   - 地図上にレストランをマーカー表示
   - 現在地表示
   - フィルター/検索UI

3. **レストラン詳細画面**
   - 基本情報（名前、住所、評価など）
   - レビュー一覧
   - アクション（お気に入り、共有、ナビゲーションなど）

4. **レビュー投稿画面**
   - 評価入力
   - コメント入力
   - 写真アップロード

5. **チーム管理画面**
   - チーム一覧
   - チーム作成/編集
   - メンバー管理

6. **ナビゲーション画面**
   - ルート表示
   - 所要時間・距離表示
   - ターンバイターン案内

7. **プロフィール/設定画面**
   - ユーザー情報表示/編集
   - アプリ設定
   - ログアウト

## テスト戦略

1. **単体テスト** - 主にドメイン層・データ層のビジネスロジック
2. **ウィジェットテスト** - UI コンポーネントの検証
3. **統合テスト** - 複数のコンポーネントの連携
4. **エンドツーエンドテスト** - 実際のユーザーフローの検証

## モバイル→Web移行戦略

1. **共通ドメイン層** - ビジネスロジックはモバイル/Web間で共有する設計
2. **API連携の共通化** - APIクライアントのインターフェースを統一
3. **UXの最適化** - プラットフォームごとに最適なUI/UXを設計
4. **段階的な機能移行** - コア機能から順次Webに実装

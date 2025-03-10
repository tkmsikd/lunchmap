# ランチマップアプリ 開発ガイド

## 開発環境セットアップ

### 必要なツール
- Flutter SDK (最新の安定版)
- Dart SDK (Flutter SDKに同梱)
- Android Studio または Visual Studio Code
- Xcode (macOSの場合)
- Git

### 環境構築手順
1. [Flutter公式サイト](https://flutter.dev/docs/get-started/install)からFlutter SDKをインストール
2. `flutter doctor`を実行し、必要なコンポーネントをすべてインストール
3. リポジトリをクローン：`git clone [リポジトリURL]`
4. プロジェクトディレクトリに移動：`cd lunch-map-app`
5. 依存関係をインストール：`flutter pub get`
6. エミュレータまたは実機でアプリを起動：`flutter run`

## 開発ワークフロー

### ブランチ戦略
- `main` - 安定版、リリース用
- `develop` - 開発版、機能統合用
- `feature/[機能名]` - 個別機能開発用
- `bugfix/[バグID]` - バグ修正用
- `release/v[バージョン]` - リリース準備用

### コミットメッセージの規約
以下の形式に従ってコミットメッセージを記述する：
```
[種類]: [簡潔な説明]

[詳細な説明（任意）]
```

種類の例：
- `feat` - 新機能
- `fix` - バグ修正
- `docs` - ドキュメントの変更
- `style` - コードスタイルの変更（フォーマットなど）
- `refactor` - リファクタリング
- `test` - テストの追加・修正
- `chore` - ビルドプロセスやツールの変更

### プルリクエスト(PR)プロセス
1. 機能ブランチを作成：`git checkout -b feature/[機能名]`
2. 変更を加え、コミット
3. テストを実行
4. リモートにプッシュ：`git push origin feature/[機能名]`
5. PRを作成し、レビュー依頼
6. レビュー後、`develop`ブランチにマージ

## コーディング規約

### Dart/Flutterコード規約
- [Effective Dart](https://dart.dev/guides/language/effective-dart)に従う
- ファイル名：スネークケース（`user_repository.dart`）
- クラス名：パスカルケース（`UserRepository`）
- 変数/メソッド名：キャメルケース（`getUserById`）
- プライベートメンバー：アンダースコア接頭辞（`_privateMethod`）

### アーキテクチャ規約
- **単一責任の原則** - 各クラスは単一の責任を持つ
- **依存関係逆転の原則** - 上位モジュールは下位モジュールに依存しない
- **インターフェース分離の原則** - クライアントは使用しないインターフェースに依存しない
- **ドメイン層の純粋性** - ドメイン層はプラットフォーム依存のコードを含まない

### ディレクトリ構造規約
- 各層（presentation, domain, data）は独自のディレクトリを持つ
- 機能ごとにサブディレクトリを作成（例：`auth`, `restaurant`, `review`）
- テストファイルは対応するファイルと同じディレクトリ構造で`test`ディレクトリに配置

## 状態管理ガイド（Riverpod）

### Riverpodプロバイダーの種類と使い方
1. **Provider** - 単純な値の提供
```dart
final counterProvider = Provider<int>((ref) => 0);
```

2. **StateProvider** - 単純な状態の提供と変更
```dart
final counterProvider = StateProvider<int>((ref) => 0);
// 使用例
ref.read(counterProvider.notifier).state++;
```

3. **FutureProvider** - 非同期処理の結果
```dart
final userProvider = FutureProvider<User>((ref) async {
  return await userRepository.getUser();
});
// 使用例
final asyncUser = ref.watch(userProvider);
return asyncUser.when(
  data: (user) => Text(user.name),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('エラー: $err'),
);
```

4. **StateNotifierProvider** - 複雑な状態の管理
```dart
class Counter extends StateNotifier<int> {
  Counter() : super(0);
  void increment() => state++;
}

final counterProvider = StateNotifierProvider<Counter, int>((ref) => Counter());
// 使用例
ref.read(counterProvider.notifier).increment();
final count = ref.watch(counterProvider); // 状態を監視
```

### Riverpodベストプラクティス
- **ref.watch vs ref.read** - 状態の監視には`watch`、アクションの実行には`read`を使用
- **状態の分離** - 関連する状態のみを同じNotifierに含める
- **コンシューマーの最適化** - ConsumerWidgetまたはConsumerを使用して再ビルドを最小限に抑える
- **family修飾子** - パラメータ付きのプロバイダーに使用

## エラーハンドリング

### Resultパターンの使用
```dart
// 成功の場合
Result<User> result = await userRepository.getUser(userId);
if (result.isSuccess) {
  User user = result.data!;
  // 成功処理
} else {
  // エラー処理
  String errorMessage = result.errorMessage ?? "不明なエラー";
}
```

### UI層でのエラー表示
```dart
return ref.watch(userProvider).when(
  data: (result) {
    if (result.isSuccess) {
      return UserProfileWidget(user: result.data!);
    } else {
      return ErrorWidget(message: result.errorMessage!);
    }
  },
  loading: () => const LoadingWidget(),
  error: (e, st) => ErrorWidget(message: e.toString()),
);
```

### エラーロギング
- アプリケーション全体でエラーを捕捉するためのグローバルエラーハンドラを使用
- 将来的にはCrashlyticsなどのサービスと連携

## テスト

### 単体テスト
```dart
void main() {
  group('GetUserUseCase', () {
    late MockUserRepository mockUserRepository;
    late GetUserUseCase getUserUseCase;
    
    setUp(() {
      mockUserRepository = MockUserRepository();
      getUserUseCase = GetUserUseCase(mockUserRepository);
    });
    
    test('should return user when repository call is successful', () async {
      // Arrange
      when(() => mockUserRepository.getUser("123"))
          .thenAnswer((_) async => Result.success(testUser));
      
      // Act
      final result = await getUserUseCase.execute("123");
      
      // Assert
      expect(result.isSuccess, true);
      expect(result.data, equals(testUser));
    });
  });
}
```

### ウィジェットテスト
```dart
void main() {
  testWidgets('RestaurantListItem shows restaurant information', (WidgetTester tester) async {
    // Arrange
    final restaurant = Restaurant(
      id: '1',
      name: 'Test Restaurant',
      // ...他の必要なプロパティ
    );
    
    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: RestaurantListItem(restaurant: restaurant),
      ),
    );
    
    // Assert
    expect(find.text('Test Restaurant'), findsOneWidget);
    // ...その他の検証
  });
}
```

## デプロイメント

### ビルドバリアント
- **開発環境（Development）** - モックデータ、デバッグ機能有効
- **ステージング環境（Staging）** - 本番APIに接続、デバッグ機能有効
- **本番環境（Production）** - 本番APIに接続、デバッグ機能無効

### リリースプロセス
1. バージョン番号の更新（`pubspec.yaml`）
2. リリースノートの作成
3. リリースブランチの作成：`release/vX.Y.Z`
4. テスト実行
5. ビルド生成：`flutter build apk --release` / `flutter build ios --release`
6. ストアへのアップロード

## パフォーマンス最適化

### UIパフォーマンス
- `const`コンストラクタの使用
- 大きなリストには`ListView.builder`を使用
- 画像キャッシュの活用
- アニメーションのパフォーマンス監視

### メモリ管理
- 大きなオブジェクトの適切な解放
- メモリリークの防止（特にStreamの購読解除）
- DevToolsでのメモリプロファイリング

## ドキュメンテーション

### コードドキュメント
- パブリックAPIには必ずドキュメントコメントを追加
- 複雑なロジックには説明コメントを追加

```dart
/// ユーザーの詳細情報を取得するユースケース
///
/// [userId] - 取得対象のユーザーID
/// 
/// 成功時は [User] オブジェクトを含む [Result] を返す
/// エラー時はエラーメッセージを含む [Result] を返す
class GetUserUseCase {
  // ...
}
```

### アーキテクチャドキュメント
- 各層の責任と相互作用を説明
- 重要なデザインパターンとその適用方法

## フェーズ移行ガイド

### モバイル→API移行
1. APIエンドポイントの定義
2. DTOモデルの作成
3. APIクライアントの実装
4. モックからAPIクライアントへのリポジトリ実装の切り替え
5. 統合テスト

### モバイル→Web移行
1. ドメイン層の共通コードの抽出
2. Web用プロジェクトの初期化
3. UIコンポーネントのWeb向け再実装
4. 共通ロジックの連携
5. デプロイメントパイプラインの設定

## トラブルシューティング

### 一般的な問題と解決策
- **ビルドエラー** - 依存関係の更新、キャッシュのクリア
- **状態管理の問題** - Riverpodプロバイダーの範囲とライフサイクルの確認
- **パフォーマンス問題** - DevToolsでのプロファイリング、不要な再ビルドの削減
- **API連携エラー** - ネットワークリクエスト/レスポンスのログ確認

### デバッグツール
- Flutter DevTools
- ログ出力
- リアルタイムデバッガー

## チーム連携

### コードレビュー基準
1. 機能要件の充足
2. コード品質とベストプラクティスの遵守
3. テストの適切性
4. パフォーマンスへの配慮
5. ドキュメントの充実度

### 知識共有
- 定期的な技術勉強会
- アーキテクチャ・デザインレビュー
- 新しい機能/技術のデモ

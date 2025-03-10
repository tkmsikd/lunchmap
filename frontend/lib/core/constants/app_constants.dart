/// Application-wide constants
class AppConstants {
  // App information
  static const String appName = 'ランチマップ';
  static const String appVersion = '1.0.0';

  // API endpoints (for future use)
  static const String baseApiUrl = 'https://api.example.com';

  // Map settings
  static const double defaultLatitude = 35.6812; // Tokyo
  static const double defaultLongitude = 139.7671; // Tokyo
  static const double defaultZoomLevel = 15.0;
  static const double defaultSearchRadius = 1000.0; // meters

  // UI constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 8.0;
  static const double defaultIconSize = 24.0;

  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Cache settings
  static const Duration defaultCacheDuration = Duration(hours: 1);

  // Pagination
  static const int defaultPageSize = 20;

  // Restaurant categories
  static const List<String> restaurantCategories = [
    '和食',
    '洋食',
    '中華',
    'イタリアン',
    'フレンチ',
    'カフェ',
    'ファストフード',
    'ラーメン',
    '韓国料理',
    'その他',
  ];

  // Price ranges
  static const Map<String, String> priceRanges = {
    'low': '~¥1,000',
    'medium': '¥1,000~¥2,000',
    'high': '¥2,000~',
  };
}

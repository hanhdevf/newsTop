// News Category Enum
enum NewsCategory {
  general,
  business,
  technology,
  sports,
  entertainment,
  health,
  science;

  String get displayName {
    switch (this) {
      case NewsCategory.general:
        return 'Tổng hợp';
      case NewsCategory.business:
        return 'Kinh doanh';
      case NewsCategory.technology:
        return 'Công nghệ';
      case NewsCategory.sports:
        return 'Thể thao';
      case NewsCategory.entertainment:
        return 'Giải trí';
      case NewsCategory.health:
        return 'Sức khỏe';
      case NewsCategory.science:
        return 'Khoa học';
    }
  }

  String get icon {
    switch (this) {
      case NewsCategory.general:
        return '📰';
      case NewsCategory.business:
        return '💼';
      case NewsCategory.technology:
        return '💻';
      case NewsCategory.sports:
        return '⚽';
      case NewsCategory.entertainment:
        return '🎬';
      case NewsCategory.health:
        return '🏥';
      case NewsCategory.science:
        return '🔬';
    }
  }

  String get value => name;
}

class Constants {
  // App Information
  static const String appName = 'NewsTop';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'https://newsapi.org/v2';
  static const String apiKey = 'fc752001dede453da2850c0ad83763cb';
  
  // API Endpoints
  static const String topHeadlinesEndpoint = '/top-headlines';
  static const String everythingEndpoint = '/everything';
  static const String sourcesEndpoint = '/sources';
  
  // Default Country and Language
  static const String defaultCountry = 'us';
  static const String defaultLanguage = 'en';
  
  // Pagination
  static const int pageSize = 20;
  static const int maxPages = 5;
  
  // Cache Configuration
  static const Duration cacheDuration = Duration(hours: 1);
  static const int maxCacheSize = 100;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Error Messages
  static const String networkErrorMessage = 'Không thể kết nối mạng. Vui lòng kiểm tra kết nối internet.';
  static const String apiErrorMessage = 'Có lỗi xảy ra khi tải dữ liệu. Vui lòng thử lại.';
  static const String noDataMessage = 'Không có dữ liệu để hiển thị.';
  static const String retryMessage = 'Thử lại';
  
  // Success Messages
  static const String bookmarkAddedMessage = 'Đã thêm vào bookmark';
  static const String bookmarkRemovedMessage = 'Đã xóa khỏi bookmark';
  
  // Storage Keys
  static const String bookmarkKey = 'bookmarked_articles';
  static const String searchHistoryKey = 'search_history';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
}

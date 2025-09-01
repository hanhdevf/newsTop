import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newtop/models/article.dart';

/// Service for managing local storage operations including bookmarks and search history.
/// 
/// This service provides methods to:
/// - Add, remove, and retrieve bookmarked articles
/// - Manage search history
/// - Store generic key-value pairs
/// 
/// Uses SharedPreferences for persistent storage across app sessions.
class StorageService {
  static const String _bookmarksKey = 'bookmarked_articles';
  static const String _searchHistoryKey = 'search_history';
  
  static StorageService? _instance;
  static SharedPreferences? _prefs;
  
  // Singleton pattern
  StorageService._();
  
  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }
  
  // Bookmark methods
  Future<bool> addBookmark(Article article) async {
    try {
      final bookmarks = await getBookmarks();
      
      // Check if article already bookmarked
      if (bookmarks.any((bookmark) => bookmark.id == article.id)) {
        return false; // Already bookmarked
      }
      
      bookmarks.add(article);
      final bookmarksJson = bookmarks.map((article) => article.toJson()).toList();
      return await _prefs!.setString(_bookmarksKey, jsonEncode(bookmarksJson));
    } catch (e) {
      // Error adding bookmark: $e
      return false;
    }
  }
  
  Future<bool> removeBookmark(String articleId) async {
    try {
      final bookmarks = await getBookmarks();
      bookmarks.removeWhere((article) => article.id == articleId);
      
      final bookmarksJson = bookmarks.map((article) => article.toJson()).toList();
      return await _prefs!.setString(_bookmarksKey, jsonEncode(bookmarksJson));
    } catch (e) {
      // Error removing bookmark: $e
      return false;
    }
  }
  
  Future<List<Article>> getBookmarks() async {
    try {
      final bookmarksString = _prefs!.getString(_bookmarksKey);
      if (bookmarksString == null || bookmarksString.isEmpty) {
        return [];
      }
      
      final List<dynamic> bookmarksJson = jsonDecode(bookmarksString);
      return bookmarksJson.map((json) {
        try {
          return Article.fromJson(json as Map<String, dynamic>);
        } catch (e) {
          // Error parsing individual bookmark: $e
          return null;
        }
      }).where((article) => article != null).cast<Article>().toList();
    } catch (e) {
      // Error getting bookmarks: $e
      // Clear corrupted data
      await _prefs!.remove(_bookmarksKey);
      return [];
    }
  }
  
  Future<bool> isBookmarked(String articleId) async {
    try {
      final bookmarks = await getBookmarks();
      return bookmarks.any((article) => article.id == articleId);
    } catch (e) {
      // Error checking bookmark status: $e
      return false;
    }
  }
  
  Future<int> getBookmarkCount() async {
    try {
      final bookmarks = await getBookmarks();
      return bookmarks.length;
    } catch (e) {
      // Error getting bookmark count: $e
      return 0;
    }
  }
  
  Future<bool> clearAllBookmarks() async {
    try {
      return await _prefs!.remove(_bookmarksKey);
    } catch (e) {
      // Error clearing bookmarks: $e
      return false;
    }
  }
  
  // Search history methods
  Future<bool> addSearchHistory(String query) async {
    try {
      if (query.trim().isEmpty) return false;
      
      final history = await getSearchHistory();
      
      // Remove if already exists
      history.remove(query.trim());
      
      // Add to beginning
      history.insert(0, query.trim());
      
      // Keep only last 10 searches
      if (history.length > 10) {
        history.removeRange(10, history.length);
      }
      
      return await _prefs!.setStringList(_searchHistoryKey, history);
    } catch (e) {
      // Error adding search history: $e
      return false;
    }
  }
  
  Future<List<String>> getSearchHistory() async {
    try {
      return _prefs!.getStringList(_searchHistoryKey) ?? [];
    } catch (e) {
      // Error getting search history: $e
      return [];
    }
  }
  
  Future<bool> clearSearchHistory() async {
    try {
      return await _prefs!.remove(_searchHistoryKey);
    } catch (e) {
      // Error clearing search history: $e
      return false;
    }
  }
  
  // Generic storage methods
  Future<bool> setString(String key, String value) async {
    try {
      return await _prefs!.setString(key, value);
    } catch (e) {
      // Error setting string: $e
      return false;
    }
  }
  
  Future<String?> getString(String key) async {
    try {
      return _prefs!.getString(key);
    } catch (e) {
      // Error getting string: $e
      return null;
    }
  }
  
  Future<bool> setBool(String key, bool value) async {
    try {
      return await _prefs!.setBool(key, value);
    } catch (e) {
      // Error setting bool: $e
      return false;
    }
  }
  
  Future<bool?> getBool(String key) async {
    try {
      return _prefs!.getBool(key);
    } catch (e) {
      // Error getting bool: $e
      return null;
    }
  }
  
  Future<bool> setInt(String key, int value) async {
    try {
      return await _prefs!.setInt(key, value);
    } catch (e) {
      // Error setting int: $e
      return false;
    }
  }
  
  Future<int?> getInt(String key) async {
    try {
      return _prefs!.getInt(key);
    } catch (e) {
      // Error getting int: $e
      return null;
    }
  }
  
  Future<bool> remove(String key) async {
    try {
      return await _prefs!.remove(key);
    } catch (e) {
      // Error removing key: $e
      return false;
    }
  }
  
  Future<bool> clear() async {
    try {
      return await _prefs!.clear();
    } catch (e) {
      // Error clearing storage: $e
      return false;
    }
  }


}

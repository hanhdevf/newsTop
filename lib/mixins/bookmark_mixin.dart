import 'package:flutter/material.dart';
import 'package:newtop/models/article.dart';
import 'package:newtop/services/storage_service.dart';
import 'package:newtop/utils/snackbar_helper.dart';

/// Mixin that provides bookmark functionality for widgets
/// Eliminates code duplication across ArticleCard and ArticleDetailScreen
mixin BookmarkMixin<T extends StatefulWidget> on State<T> {
  late StorageService _storageService;
  bool _isBookmarked = false;
  bool _isLoading = false;

  /// Initialize storage service and check bookmark status
  Future<void> initializeBookmark(String? articleId) async {
    _storageService = await StorageService.getInstance();
    await checkBookmarkStatus(articleId);
  }

  /// Check if an article is bookmarked
  Future<void> checkBookmarkStatus(String? articleId) async {
    if (articleId != null) {
      final isBookmarked = await _storageService.isBookmarked(articleId);
      if (mounted) {
        setState(() {
          _isBookmarked = isBookmarked;
        });
      }
    }
  }

  /// Toggle bookmark status of an article
  Future<void> toggleBookmark(Article article, {Function(bool)? onBookmarkChanged}) async {
    if (article.id == null || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      bool success;
      if (_isBookmarked) {
        success = await _storageService.removeBookmark(article.id!);
        if (success && mounted) {
          setState(() {
            _isBookmarked = false;
          });
          SnackBarHelper.showSuccess(context, 'Đã xóa khỏi bookmark');
          
          // Notify parent widget if callback provided
          if (onBookmarkChanged != null) {
            onBookmarkChanged(_isBookmarked);
          }
        }
      } else {
        success = await _storageService.addBookmark(article);
        if (success && mounted) {
          setState(() {
            _isBookmarked = true;
          });
          SnackBarHelper.showSuccess(context, 'Đã thêm vào bookmark');
          
          // Notify parent widget if callback provided
          if (onBookmarkChanged != null) {
            onBookmarkChanged(_isBookmarked);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, 'Có lỗi xảy ra: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Get current bookmark status
  bool get isBookmarked => _isBookmarked;
  
  /// Get current loading status
  bool get isLoading => _isLoading;
}

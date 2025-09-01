import 'package:flutter/material.dart';
import 'package:newtop/models/article.dart';
import 'package:newtop/services/storage_service.dart';
import 'package:newtop/themes/app_theme.dart';
import 'package:newtop/widgets/article_card.dart';
import 'package:newtop/widgets/loading_widget.dart';
import 'package:newtop/widgets/error_widget.dart';

/// Screen that displays all bookmarked articles with management functionality.
/// 
/// Features:
/// - Lists all bookmarked articles
/// - Pull-to-refresh functionality
/// - Clear all bookmarks with confirmation
/// - Empty state when no bookmarks exist
/// - Real-time updates when bookmarks change
class BookmarkedArticlesScreen extends StatefulWidget {
  const BookmarkedArticlesScreen({super.key});

  @override
  State<BookmarkedArticlesScreen> createState() => _BookmarkedArticlesScreenState();
}

class _BookmarkedArticlesScreenState extends State<BookmarkedArticlesScreen> {
  late StorageService _storageService;
  List<Article> _bookmarkedArticles = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    _storageService = await StorageService.getInstance();
    await _loadBookmarkedArticles();
  }

  Future<void> _loadBookmarkedArticles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bookmarks = await _storageService.getBookmarks();
      setState(() {
        _bookmarkedArticles = bookmarks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Có lỗi xảy ra khi tải bookmark: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshBookmarks() async {
    await _loadBookmarkedArticles();
  }

  void _onBookmarkChanged(bool isBookmarked) {
    // Reload bookmarks when an article is unbookmarked
    if (!isBookmarked) {
      // Use a small delay to ensure the bookmark is removed from storage first
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _loadBookmarkedArticles();
        }
      });
    }
  }

  Future<void> _clearAllBookmarks() async {
    final confirmed = await _showClearConfirmationDialog();
    if (confirmed) {
      final success = await _storageService.clearAllBookmarks();
      if (success) {
        setState(() {
          _bookmarkedArticles.clear();
        });
        _showSnackBar('Đã xóa tất cả bookmark');
      } else {
        _showSnackBar('Có lỗi xảy ra khi xóa bookmark');
      }
    }
  }

  Future<bool> _showClearConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn xóa tất cả bookmark?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmark'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_bookmarkedArticles.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearAllBookmarks,
              tooltip: 'Xóa tất cả bookmark',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshBookmarks,
            tooltip: 'Làm mới',
          ),

        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(
        message: 'Đang tải bookmark...',
        showShimmer: true,
      );
    }

    if (_errorMessage != null) {
      return CustomErrorWidget(
        title: 'Có lỗi xảy ra',
        message: _errorMessage!,
        buttonText: 'Thử lại',
        onRetry: _loadBookmarkedArticles,
      );
    }

    if (_bookmarkedArticles.isEmpty) {
      return const EmptyBookmarkStateWidget();
    }

    return RefreshIndicator(
      onRefresh: _refreshBookmarks,
              child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _bookmarkedArticles.length,
          itemBuilder: (context, index) {
            final article = _bookmarkedArticles[index];
            return ArticleCard(
              key: ValueKey(article.id ?? '${article.title}_$index'),
              article: article,
              onBookmarkChanged: _onBookmarkChanged,
            );
          },
        ),
    );
  }
}

class EmptyBookmarkStateWidget extends StatelessWidget {
  const EmptyBookmarkStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Chưa có bookmark nào',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Hãy bookmark những bài viết bạn quan tâm để đọc lại sau.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.home),
              label: const Text('Về trang chủ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

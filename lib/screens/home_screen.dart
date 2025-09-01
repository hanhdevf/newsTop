import 'package:flutter/material.dart';
import 'package:newtop/models/article.dart';
import 'package:newtop/models/api_response.dart';
import 'package:newtop/services/api_service.dart';
import 'package:newtop/services/storage_service.dart';
import 'package:newtop/themes/app_theme.dart';
import 'package:newtop/utils/navigation_helper.dart';
import 'package:newtop/widgets/article_card.dart';
import 'package:newtop/widgets/loading_widget.dart';
import 'package:newtop/widgets/error_widget.dart';
import 'package:newtop/widgets/category_card.dart';
import 'package:newtop/models/category.dart';
import 'package:newtop/screens/bookmarked_articles_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  late StorageService _storageService;
  ApiResponse<List<Article>> _articlesResponse = ApiResponse.loading(); 
  List<Article> _articles = [];
  bool _isRefreshing = false;
  int _bookmarkCount = 0;
  
  // Category filtering
  final List<Category> _categories = Category.getDefaultCategories();
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _initializeStorage();
    _loadArticles();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update bookmark count when screen becomes active
    _updateBookmarkCount();
  }

  Future<void> _initializeStorage() async {
    _storageService = await StorageService.getInstance();
    await _updateBookmarkCount();
  }

  Future<void> _updateBookmarkCount() async {
    final count = await _storageService.getBookmarkCount();
    if (mounted) {
      setState(() {
        _bookmarkCount = count;
      });
    }
  }

  // Load articles from API
  Future<void> _loadArticles() async {
    if (!_isRefreshing) {
      setState(() {
        _articlesResponse = ApiResponse.loading();
      });
    }

    try {
      final response = await _apiService.getTopHeadlines(
        category: _selectedCategory?.id, // Neu category không null, thì sử dụng category.id đó
      );
      
      setState(() {
        _articlesResponse = response;
        if (response.hasData) {
          _articles = response.data!;
        }
        _isRefreshing = false;
      });
    } catch (e) {
      setState(() {
        _articlesResponse = ApiResponse.error('Có lỗi xảy ra: $e');
        _isRefreshing = false;
      });
    }
  }

  // Refresh articles
  Future<void> _refreshArticles() async {
    setState(() {
      _isRefreshing = true;
    });
    await _loadArticles();
  }

  // Handle category selection
  Future<void> _onCategorySelected(Category category) async {
    setState(() {
      _selectedCategory = category;
    });
    await _loadArticles();
  }

  // Handle bookmark changes
  void _onBookmarkChanged(bool isBookmarked) {
    _updateBookmarkCount();
  }

  // Navigate to bookmarked articles
  Future<void> _navigateToBookmarks() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BookmarkedArticlesScreen(),
      ),
    );
    
    // Update bookmark count when returning from bookmarks screen
    // Always update to ensure consistency
    if (mounted) {
      _updateBookmarkCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NewsTop'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Bookmark button with badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.bookmark),
                onPressed: _navigateToBookmarks,
                tooltip: 'Bookmark',
              ),
              if (_bookmarkCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      _bookmarkCount > 99 ? '99+' : _bookmarkCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => NavigationHelper.navigateToSearch(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshArticles,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_articlesResponse.isLoading) {
      return const LoadingWidget(
        message: 'Đang tải tin tức...',
        showShimmer: true,
      );
    }

    if (_articlesResponse.hasError) {
      return CustomErrorWidget(
        title: 'Có lỗi xảy ra',
        message: _articlesResponse.errorMessage,
        buttonText: 'Thử lại',
        onRetry: _loadArticles,
      );
    }

    if (_articles.isEmpty) {
      return const EmptyStateWidget(
        title: 'Không có tin tức',
        message: 'Không có tin tức để hiển thị.',
      );
    }

    return Column(
      children: [
        // Category list
        CategoryList(
          categories: _categories,
          selectedCategory: _selectedCategory,
          onCategorySelected: _onCategorySelected,
        ),
        const SizedBox(height: 8),
        
        // Articles list
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshArticles,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _articles.length,
              itemBuilder: (context, index) {
                final article = _articles[index];
                return ArticleCard(
                  article: article,
                  onBookmarkChanged: _onBookmarkChanged,
                );
              },
            ),
          ),
        ),
      ],
    );
  }


}

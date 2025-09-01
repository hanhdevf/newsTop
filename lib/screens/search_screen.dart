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


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _apiService = ApiService();
  late StorageService _storageService;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  ApiResponse<List<Article>> _searchResponse = ApiResponse.loading();
  List<Article> _searchResults = [];
  List<String> _searchHistory = [];
  List<String> _searchSuggestions = [];
  
  bool _isSearching = false;
  String _currentQuery = '';

  // Popular search terms
  final List<String> _popularSearches = [
    'technology',
    'business',
    'sports',
    'entertainment',
    'health',
    'science',
    'politics',
    'environment',
  ];

  @override
  void initState() {
    super.initState();
    _initializeStorage();
    _loadSearchHistory();
    _loadSearchSuggestions();
  }

  Future<void> _initializeStorage() async {
    _storageService = await StorageService.getInstance();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Get initial query from navigation arguments only once
    if (_currentQuery.isEmpty) {
      final initialQuery = NavigationHelper.getArgument<String>(context, 'initialQuery');
      if (initialQuery != null && initialQuery.isNotEmpty) {
        _searchController.text = initialQuery;
        _performSearch(initialQuery);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // Load search history from local storage
  Future<void> _loadSearchHistory() async {
    _searchHistory = await _storageService.getSearchHistory();
  }

  // Load search suggestions
  void _loadSearchSuggestions() {
    _searchSuggestions = [
      'Latest news',
      'Breaking news',
      'Top stories',
      'Trending topics',
    ];
  }

  // Save search to history
  Future<void> _saveToHistory(String query) async {
    if (query.trim().isNotEmpty) {
      await _storageService.addSearchHistory(query);
      await _loadSearchHistory();
      if (mounted) {
        setState(() {});
      }
    }
  }

  // Perform search
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _searchResponse = ApiResponse.loading();
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _currentQuery = query;
      _searchResponse = ApiResponse.loading();
    });

    try {
      final response = await _apiService.searchArticles(query: query);
      
      setState(() {
        _searchResponse = response;
        if (response.hasData) {
          _searchResults = response.data!;
        }
        _isSearching = false;
      });

      // Save to history if search was successful
      if (response.hasData && response.data!.isNotEmpty) {
        await _saveToHistory(query);
      }
    } catch (e) {
      setState(() {
        _searchResponse = ApiResponse.error('Có lỗi xảy ra: $e');
        _isSearching = false;
      });
    }
  }

  // Handle search submission
  void _onSearchSubmitted(String query) {
    _searchFocusNode.unfocus(); // ẩn keyboard
    _performSearch(query);
  }

  // Clear search
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _searchResponse = ApiResponse.loading();
      _currentQuery = '';
    });
    _searchFocusNode.requestFocus();
  }

  // Handle bookmark changes
  void _onBookmarkChanged(bool isBookmarked) {
    // Could add snackbar notification here if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchField(),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => NavigationHelper.goBack(context),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              onPressed: _clearSearch,
              icon: const Icon(Icons.clear),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: 'Tìm kiếm tin tức...',
        hintStyle: TextStyle(color: const Color.fromARGB(255, 90, 83, 83)),
        border: InputBorder.none,
        suffixIcon: _isSearching
            ? const SizedBox(
                width: 20,
                height: 20,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 90, 83, 83)),
                  ),
                ),
              )
            : IconButton(
                onPressed: () => _onSearchSubmitted(_searchController.text),
                icon: const Icon(Icons.search, color: Color.fromARGB(255, 90, 83, 83)),
              ),
      ),
      onSubmitted: _onSearchSubmitted,
      onChanged: (value) {
        // Real-time search suggestions could be implemented here
      },
    );
  }

  Widget _buildBody() {
    // Show search suggestions if no search has been performed
    if (_currentQuery.isEmpty) {
      return _buildSearchSuggestions();
    }

    // Show search results
    if (_searchResponse.isLoading) {
      return const LoadingWidget(
        message: 'Đang tìm kiếm...',
        showShimmer: true,
      );
    }

    if (_searchResponse.hasError) {
      return CustomErrorWidget(
        title: 'Có lỗi xảy ra',
        message: _searchResponse.errorMessage,
        buttonText: 'Thử lại',
        onRetry: () => _performSearch(_currentQuery),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy kết quả',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Không có tin tức nào phù hợp với "$_currentQuery"',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _currentQuery = '';
                });
                _searchFocusNode.requestFocus();
              },
              child: const Text('Tìm kiếm khác'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Search results header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.grey[600], size: 20),
              const SizedBox(width: 8),
              Text(
                '${_searchResults.length} kết quả cho "$_currentQuery"',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        
        // Search results list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final article = _searchResults[index];
              return ArticleCard(
                article: article,
                onBookmarkChanged: _onBookmarkChanged,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search history
          if (_searchHistory.isNotEmpty) ...[
            _buildSectionTitle('Lịch sử tìm kiếm'),
            const SizedBox(height: 12),
            _buildSearchChips(_searchHistory, (query) {
              _searchController.text = query;
              _performSearch(query);
            }),
            const SizedBox(height: 24),
          ],

          // Popular searches
          _buildSectionTitle('Tìm kiếm phổ biến'),
          const SizedBox(height: 12),
          _buildSearchChips(_popularSearches, (query) {
            _searchController.text = query;
            _performSearch(query);
          }),
          const SizedBox(height: 24),

          // Search suggestions
          _buildSectionTitle('Gợi ý tìm kiếm'),
          const SizedBox(height: 12),
          _buildSearchChips(_searchSuggestions, (query) {
            _searchController.text = query;
            _performSearch(query);
          }),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSearchChips(List<String> items, Function(String) onTap) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return ActionChip(
          label: Text(item),
          onPressed: () => onTap(item),
          backgroundColor: Colors.grey[100],
          side: BorderSide(color: Colors.grey[300]!),
          labelStyle: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
          ),
        );
      }).toList(),
    );
  }
}

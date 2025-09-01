import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:newtop/models/article.dart';
import 'package:newtop/services/storage_service.dart';
import 'package:newtop/themes/app_theme.dart';
import 'package:newtop/utils/navigation_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class ArticleDetailScreen extends StatefulWidget {
  const ArticleDetailScreen({super.key});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  late StorageService _storageService;
  bool _isBookmarked = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    _storageService = await StorageService.getInstance();
    await _checkBookmarkStatus();
  }

  Future<void> _checkBookmarkStatus() async {
    final article = NavigationHelper.getArticle(context);
    if (article?.id != null) {
      final isBookmarked = await _storageService.isBookmarked(article!.id!);
      if (mounted) {
        setState(() {
          _isBookmarked = isBookmarked;
        });
      }
    }
  }

  Future<void> _toggleBookmark() async {
    final article = NavigationHelper.getArticle(context);
    if (article?.id == null || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      bool success;
      if (_isBookmarked) {
        success = await _storageService.removeBookmark(article!.id!);
        if (success) {
          setState(() {
            _isBookmarked = false;
          });
          _showSnackBar('Đã xóa khỏi bookmark');
        }
      } else {
        success = await _storageService.addBookmark(article!);
        if (success) {
          setState(() {
            _isBookmarked = true;
          });
          _showSnackBar('Đã thêm vào bookmark');
        }
      }
    } catch (e) {
      _showSnackBar('Có lỗi xảy ra: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy Article object từ navigation arguments
    final article = NavigationHelper.getArticle(context);
    
    // Nếu không có article, hiển thị error state
    if (article == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết bài viết'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              NavigationHelper.goBack(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              SizedBox(height: 16),
              Text(
                'Không tìm thấy bài viết',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Vui lòng thử lại',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chi tiết bài viết',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            NavigationHelper.goBack(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          // Bookmark button
          IconButton(
            onPressed: _isLoading ? null : _toggleBookmark,
            icon: _isLoading 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(
                  _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: _isBookmarked ? Colors.orange : Colors.white,
                ),
            tooltip: _isBookmarked ? 'Xóa bookmark' : 'Thêm bookmark',
          ),
          IconButton(
            onPressed: () => _copyToClipboard(context, article),
            icon: const Icon(Icons.link),
            tooltip: 'Copy link',
          ),
          IconButton(
            onPressed: () => _shareArticle(context, article),
            icon: const Icon(Icons.share),
            tooltip: 'Chia sẻ',
          ),
          IconButton(
            onPressed: () => _openInBrowser(context, article),
            icon: const Icon(Icons.open_in_browser),
            tooltip: 'Mở trong trình duyệt',
          ),
        ],
      ),
      body: _buildBody(context, article),
    );
  }

  Widget _buildBody(BuildContext context, Article article) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero image
          if (article.hasImage) _buildHeroImage(article),
          
          // Article content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  article.displayTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Metadata
                _buildMetadataSection(context, article),
                const SizedBox(height: 24),
                
                // Description
                if (article.description != null) ...[
                  Text(
                    'Mô tả',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.displayDescription,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.black54,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Content
                if (article.hasContent) ...[
                  Text(
                    'Nội dung',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.cleanContent,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.black54,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Read more button
                if (article.url != null) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openInBrowser(context, article),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Đọc bài viết gốc'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(Article article) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: CachedNetworkImage(
        imageUrl: article.imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Không thể tải ảnh',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataSection(BuildContext context, Article article) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // Source and date row
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.source,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        article.displaySource,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    article.formattedDate,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Author row
          if (article.author != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 20,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    article.displayAuthor,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _shareArticle(BuildContext context, Article article) async {
    // Generate deep link for sharing
    final deepLink = NavigationHelper.generateArticleDeepLink(article.id ?? '');
    final shareText = '${article.displayTitle}\n\n$deepLink';
    
    try {
      await Share.share(shareText);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã chia sẻ bài viết'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi chia sẻ bài viết: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _copyToClipboard(BuildContext context, Article article) async {
    final deepLink = NavigationHelper.generateArticleDeepLink(article.id ?? '');
    
    try {
      await Clipboard.setData(ClipboardData(text: deepLink));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã copy link vào clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi copy link: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openInBrowser(BuildContext context, Article article) async {
    if (article.url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có link để mở'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final uri = Uri.parse(article.url!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Không thể mở link');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi mở link: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

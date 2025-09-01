import 'package:flutter/material.dart';
import 'package:newtop/models/article.dart';
import 'package:newtop/utils/navigation_helper.dart';
import 'package:newtop/services/storage_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// A reusable card widget that displays article information with bookmark functionality.
/// 
/// Features:
/// - Displays article image, title, description, and metadata
/// - Bookmark/unbookmark functionality with visual feedback
/// - Loading states and error handling
/// - Navigation to article detail screen
/// - Responsive design with proper image caching
class ArticleCard extends StatefulWidget {
  final Article article;
  final VoidCallback? onTap;
  final Function(bool)? onBookmarkChanged;

  const ArticleCard({
    super.key,
    required this.article,
    this.onTap,
    this.onBookmarkChanged,
  });

  @override
  State<ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends State<ArticleCard> {
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
    if (widget.article.id != null) {
      final isBookmarked = await _storageService.isBookmarked(widget.article.id!);
      if (mounted) {
        setState(() {
          _isBookmarked = isBookmarked;
        });
      }
    }
  }

  Future<void> _toggleBookmark() async {
    if (widget.article.id == null || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      bool success;
      if (_isBookmarked) {
        success = await _storageService.removeBookmark(widget.article.id!);
        if (success && mounted) {
          setState(() {
            _isBookmarked = false;
          });
          _showSnackBar('Đã xóa khỏi bookmark');
          
          // Notify parent widget immediately
          if (widget.onBookmarkChanged != null) {
            widget.onBookmarkChanged!(_isBookmarked);
          }
        }
      } else {
        success = await _storageService.addBookmark(widget.article);
        if (success && mounted) {
          setState(() {
            _isBookmarked = true;
          });
          _showSnackBar('Đã thêm vào bookmark');
          
          // Notify parent widget immediately
          if (widget.onBookmarkChanged != null) {
            widget.onBookmarkChanged!(_isBookmarked);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Có lỗi xảy ra: $e');
      }
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: widget.onTap ?? () {
          NavigationHelper.navigateToArticleDetail(
            context,
            article: widget.article,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article image with bookmark button
            if (widget.article.hasImage) _buildImageSection(),
            
            // Article content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Article title with bookmark button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.article.displayTitleTruncated,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Bookmark button
                      _buildBookmarkButton(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Article description
                  if (widget.article.description != null)
                    Text(
                      widget.article.displayDescriptionTruncated,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 12),
                  
                  // Article metadata
                  _buildMetadataSection(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            child: CachedNetworkImage(
              imageUrl: widget.article.imageUrl!,
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
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Không thể tải ảnh',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
       
      ],
    );
  }

  Widget _buildBookmarkButton({bool overlay = false}) {
    return Container(
      decoration: overlay ? BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ) : null,
      child: IconButton(
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
              color: overlay ? Colors.white : (_isBookmarked ? Colors.orange : Colors.grey[600]),
              size: 24,
            ),
        onPressed: _isLoading ? null : _toggleBookmark,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
      ),
    );
  }

  Widget _buildMetadataSection(BuildContext context) {
    return Row(
      children: [
        // Source with icon
        Expanded(
          child: Row(
            children: [
              Icon(
                Icons.source,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.article.displaySource,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Published date with icon
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              widget.article.formattedDate,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

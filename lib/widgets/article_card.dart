import 'package:flutter/material.dart';
import 'package:newtop/models/article.dart';
import 'package:newtop/utils/navigation_helper.dart';
import 'package:newtop/mixins/bookmark_mixin.dart';
import 'package:newtop/widgets/bookmark_button.dart';
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

class _ArticleCardState extends State<ArticleCard> with BookmarkMixin {
  @override
  void initState() {
    super.initState();
    initializeBookmark(widget.article.id);
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
                      BookmarkButton(
                        isBookmarked: isBookmarked,
                        isLoading: isLoading,
                        onPressed: () => toggleBookmark(
                          widget.article,
                          onBookmarkChanged: widget.onBookmarkChanged,
                        ),
                      ),
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
        // Bookmark button overlay on image
        // Positioned(
        //   top: 8,
        //   right: 8,
        //   child: BookmarkButton(
        //     isBookmarked: isBookmarked,
        //     isLoading: isLoading,
        //     onPressed: () => toggleBookmark(
        //       widget.article,
        //       onBookmarkChanged: widget.onBookmarkChanged,
        //     ),
        //     overlay: true,
        //     size: 20,
        //     padding: const EdgeInsets.all(6),
        //   ),
        // ),
      ],
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

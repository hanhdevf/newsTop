import 'package:flutter/material.dart';

/// A reusable bookmark button widget that eliminates duplicate code
/// across ArticleCard and ArticleDetailScreen
class BookmarkButton extends StatelessWidget {
  final bool isBookmarked;
  final bool isLoading;
  final VoidCallback? onPressed;
  final bool overlay;
  final Color? iconColor;
  final double size;
  final EdgeInsetsGeometry? padding;
  final String? tooltip;

  const BookmarkButton({
    super.key,
    required this.isBookmarked,
    required this.isLoading,
    this.onPressed,
    this.overlay = false,
    this.iconColor,
    this.size = 24.0,
    this.padding,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? _getDefaultIconColor(context);
    
    return Container(
      decoration: overlay ? BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ) : null,
      child: IconButton(
        icon: _buildIcon(effectiveIconColor),
        onPressed: isLoading ? null : onPressed,
        padding: padding ?? const EdgeInsets.all(8),
        constraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
        tooltip: tooltip ?? _getDefaultTooltip(),
      ),
    );
  }

  Widget _buildIcon(Color iconColor) {
    if (isLoading) {
      return SizedBox(
        width: size * 0.83, // 20/24 ratio
        height: size * 0.83,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(iconColor),
        ),
      );
    }

    return Icon(
      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
      color: iconColor,
      size: size,
    );
  }

  Color _getDefaultIconColor(BuildContext context) {
    if (overlay) {
      return Colors.white;
    }
    
    if (isBookmarked) {
      return Colors.orange;
    }
    
    return Colors.grey[600]!;
  }

  String _getDefaultTooltip() {
    if (isBookmarked) {
      return 'Xóa bookmark';
    }
    return 'Thêm bookmark';
  }
}

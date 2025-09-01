import 'package:newtop/utils/helpers.dart';

/// Represents a news article with all its properties and utility methods.
/// 
/// This model class handles:
/// - Article data from News API
/// - JSON serialization/deserialization
/// - Display formatting and validation
/// - Content cleaning and truncation
class Article {
  final String? id;
  final String? title;
  final String? description;
  final String? content;
  final String? url;
  final String? imageUrl;
  final String? author;
  final DateTime? publishedAt;
  final String? source;
  final String? category;

  Article({
    this.id,
    this.title,
    this.description,
    this.content,
    this.url,
    this.imageUrl,
    this.author,
    this.publishedAt,
    this.source,
    this.category,
  });

  // Factory constructor để tạo Article từ JSON
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['url'] as String?, // Sử dụng URL làm ID
      title: json['title'] as String?,
      description: json['description'] as String?,
      content: json['content'] as String?,
      url: json['url'] as String?,
      imageUrl: json['urlToImage'] as String?,
      author: json['author'] as String?,
      publishedAt: json['publishedAt'] != null 
          ? DateTime.tryParse(json['publishedAt'] as String)
          : null,
      source: json['source'] is Map<String, dynamic>
          ? (json['source'] as Map<String, dynamic>)['name'] as String?
          : json['source'] as String?,
      category: null, // Sẽ được set sau khi fetch
    );
  }

  // Convert Article thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'url': url,
      'imageUrl': imageUrl,
      'author': author,
      'publishedAt': publishedAt?.toIso8601String(),
      'source': source,
      'category': category,
    };
  }

  // Copy with method để tạo bản sao với thay đổi
  Article copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? url,
    String? imageUrl,
    String? author,
    DateTime? publishedAt,
    String? source,
    String? category,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      author: author ?? this.author,
      publishedAt: publishedAt ?? this.publishedAt,
      source: source ?? this.source,
      category: category ?? this.category,
    );
  }

  // Override toString để debug
  @override
  String toString() {
    return 'Article(id: $id, title: $title, source: $source, publishedAt: $publishedAt)';
  }

  // Override equality
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Article && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Helper methods
  String get displayTitle => title ?? 'Không có tiêu đề';
  String get displayDescription => description ?? 'Không có mô tả';
  String get displayAuthor => author ?? 'Không rõ tác giả';
  String get displaySource => source ?? 'Không rõ nguồn';
  
  // Truncated versions for card display
  String get displayTitleTruncated => Helpers.truncateText(displayTitle, 100);
  String get displayDescriptionTruncated => Helpers.truncateText(displayDescription, 150);
  
  // Format published date
  String get formattedDate {
    if (publishedAt == null) return 'Không rõ ngày';
    return Helpers.formatRelativeTime(publishedAt!);
  }
  
  // Get clean content without HTML tags
  String get cleanContent {
    if (content == null) return '';
    return Helpers.removeHtmlTags(content!);
  }

  // Check if article has image
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
  
  // Check if article has content
  bool get hasContent => content != null && content!.isNotEmpty;
}

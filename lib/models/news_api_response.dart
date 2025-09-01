class NewsApiResponse {
  final String status;
  final int totalResults;
  final List<dynamic> articles;

  NewsApiResponse({
    required this.status,
    required this.totalResults,
    required this.articles,
  });

  factory NewsApiResponse.fromJson(Map<String, dynamic> json) {
    return NewsApiResponse(
      status: json['status'] as String,
      totalResults: json['totalResults'] as int,
      articles: json['articles'] as List<dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'totalResults': totalResults,
      'articles': articles,
    };
  }

  // Check if response is successful
  bool get isSuccess => status == 'ok';

  // Get articles count
  int get articlesCount => articles.length;

  // Check if has articles
  bool get hasArticles => articles.isNotEmpty;

  @override
  String toString() {
    return 'NewsApiResponse(status: $status, totalResults: $totalResults, articlesCount: $articlesCount)';
  }
}

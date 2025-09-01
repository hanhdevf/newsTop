import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newtop/models/article.dart';
import 'package:newtop/models/api_response.dart';
import 'package:newtop/models/news_api_response.dart';
import 'package:newtop/utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();

  // Get top headlines
  Future<ApiResponse<List<Article>>> getTopHeadlines({
    String? category,
    String? country,
    int page = 1,
    int pageSize = AppConstants.pageSize,
  }) async {
    try {
      // Build query parameters
      final Map<String, String> queryParams = {
        'apiKey': AppConstants.apiKey,
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };

      // Add category if provided
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }

      // Add country if provided
      if (country != null && country.isNotEmpty) {
        queryParams['country'] = country;
      } else {
        queryParams['country'] = AppConstants.defaultCountry;
      }

      // Build URL
      final Uri uri = Uri.parse(AppConstants.baseUrl + AppConstants.topHeadlinesEndpoint)
          .replace(queryParameters: queryParams);

      print('🌐 API Request: $uri');

      // Make HTTP request
      final response = await _client.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');

      // Check if request was successful
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final NewsApiResponse newsResponse = NewsApiResponse.fromJson(jsonData);

        if (newsResponse.isSuccess) {
          // Convert articles to Article objects
          final List<Article> articles = newsResponse.articles
              .map((articleJson) => Article.fromJson(articleJson))
              .where((article) => article.title != null) // Filter out articles without title
              .toList();

          print('✅ Successfully fetched ${articles.length} articles');
          return ApiResponse.success(articles);
        } else {
          print('❌ API returned error: ${newsResponse.status}');
          return ApiResponse.error('API returned error: ${newsResponse.status}');
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        return ApiResponse.error(
          'HTTP Error: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Exception occurred: $e');
      String errorMessage = AppConstants.apiErrorMessage;
      
      if (e.toString().contains('timeout')) {
        errorMessage = 'Request timeout. Vui lòng thử lại.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = AppConstants.networkErrorMessage;
      }
      
      return ApiResponse.error(errorMessage);
    }
  }

  // Search articles
  Future<ApiResponse<List<Article>>> searchArticles({
    required String query,
    int page = 1,
    int pageSize = AppConstants.pageSize,
    String? sortBy,
  }) async {
    try {
      // Build query parameters
      final Map<String, String> queryParams = {
        'apiKey': AppConstants.apiKey,
        'q': query,
        'page': page.toString(),
        'pageSize': pageSize.toString(),
        'language': AppConstants.defaultLanguage,
      };

      // Add sortBy if provided
      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sortBy'] = sortBy;
      }

      // Build URL
      final Uri uri = Uri.parse(AppConstants.baseUrl + AppConstants.everythingEndpoint)
          .replace(queryParameters: queryParams);

      print('🔍 Search Request: $uri');

      // Make HTTP request
      final response = await _client.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      print('📡 Search Response Status: ${response.statusCode}');

      // Check if request was successful
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final NewsApiResponse newsResponse = NewsApiResponse.fromJson(jsonData);

        if (newsResponse.isSuccess) {
          // Convert articles to Article objects
          final List<Article> articles = newsResponse.articles
              .map((articleJson) => Article.fromJson(articleJson))
              .where((article) => article.title != null) // Filter out articles without title
              .toList();

          print('✅ Successfully found ${articles.length} articles for query: "$query"');
          return ApiResponse.success(articles);
        } else {
          print('❌ Search API returned error: ${newsResponse.status}');
          return ApiResponse.error('Search API returned error: ${newsResponse.status}');
        }
      } else {
        print('❌ Search HTTP Error: ${response.statusCode}');
        return ApiResponse.error(
          'Search HTTP Error: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Search Exception occurred: $e');
      String errorMessage = AppConstants.apiErrorMessage;
      
      if (e.toString().contains('timeout')) {
        errorMessage = 'Request timeout. Vui lòng thử lại.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = AppConstants.networkErrorMessage;
      }
      
      return ApiResponse.error(errorMessage);
    }
  }

  // Get articles by category
  Future<ApiResponse<List<Article>>> getArticlesByCategory({
    required String category,
    int page = 1,
    int pageSize = AppConstants.pageSize,
  }) async {
    return getTopHeadlines(
      category: category,
      page: page,
      pageSize: pageSize,
    );
  }

  // Dispose resources
  void dispose() {
    _client.close();
  }
}

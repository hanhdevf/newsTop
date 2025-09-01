import 'package:flutter/material.dart';
import 'package:newtop/models/article.dart';

class NavigationHelper {
  // Navigate to article detail screen
  static void navigateToArticleDetail(BuildContext context, {String? articleId, Article? article}) {
    Navigator.pushNamed(
      context,
      '/article-detail',
      arguments: {
        'article': article,
      },
    );
  }

  // Navigate to search screen
  static void navigateToSearch(BuildContext context, {String? initialQuery}) {
    Navigator.pushNamed(
      context,
      '/search',
      arguments: {'initialQuery': initialQuery},
    );
  }

  // Navigate back
  static void goBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  // Navigate and replace current screen
  static void navigateAndReplace(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushReplacementNamed(
      context,
      routeName,
      arguments: arguments,
    );
  }

  // Navigate and clear all previous screens
  static void navigateAndClearAll(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  // Get arguments from navigation
  static Map<String, dynamic>? getArguments(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      return args;
    }
    return null;
  }

  // Get specific argument value
  static T? getArgument<T>(BuildContext context, String key) {
    final args = getArguments(context);
    if (args != null && args.containsKey(key)) {
      return args[key] as T?;
    }
    return null;
  }

  // Get Article object from navigation arguments
  static Article? getArticle(BuildContext context) {
    return getArgument<Article>(context, 'article');
  }

  // Check if can go back
  static bool canGoBack(BuildContext context) {
    return Navigator.canPop(context);
  }

  // Generate deep link for article
  static String generateArticleDeepLink(String articleId) {
    return 'newtop://article?id=$articleId';
  }

  // Generate deep link for search
  static String generateSearchDeepLink(String query) {
    return 'newtop://search?q=${Uri.encodeComponent(query)}';
  }
}

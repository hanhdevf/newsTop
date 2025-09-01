import 'package:flutter/material.dart';
import 'package:newtop/themes/app_theme.dart';
import 'package:newtop/utils/constants.dart';
import 'package:newtop/screens/home_screen.dart';
import 'package:newtop/screens/article_detail_screen.dart';
import 'package:newtop/screens/search_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: _generateRoute,
      onUnknownRoute: _handleUnknownRoute,
    );
  }

  // Generate routes with parameters
  Route<dynamic> _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _buildRoute(settings, const HomeScreen());
      
      case '/article-detail':
        return _buildRoute(
          settings, 
          const ArticleDetailScreen(),
          transition: TransitionType.slideUp,
        );
      
      case '/search':
        return _buildRoute(
          settings, 
          const SearchScreen(),
          transition: TransitionType.fade,
        );
      
      default:
        return _handleUnknownRoute(settings);
    }
  }

  // Build route with custom transitions
  Route<dynamic> _buildRoute(
    RouteSettings settings, 
    Widget page, {
    TransitionType transition = TransitionType.slideRight,
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildTransition(animation, child, transition);
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
    );
  }

  // Build different transition types
  Widget _buildTransition(Animation<double> animation, Widget child, TransitionType type) {
    switch (type) {
      case TransitionType.slideRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );
      
      case TransitionType.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      
      case TransitionType.fade:
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      
      case TransitionType.scale:
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.8,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          )),
          child: child,
        );
    }
  }

  // Handle unknown routes
  Route<dynamic> _handleUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Không tìm thấy'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Trang không tồn tại',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Đường dẫn: ${settings.name}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                child: const Text('Về trang chủ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Transition types enum
enum TransitionType {
  slideRight,
  slideUp,
  fade,
  scale,
}



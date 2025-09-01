import 'package:intl/intl.dart';
import 'dart:async'; // Added for Timer

class Helpers {
  // Format date to Vietnamese format
  static String formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(date);
  }

  // Format date to relative time (e.g., "2 giờ trước")
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  // Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate URL format
  static bool isValidUrl(String url) {
    try {
      Uri.parse(url);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Truncate text to specified length
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }

  // Capitalize first letter of each word
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  // Remove HTML tags from text
  static String removeHtmlTags(String htmlText) {
    return htmlText.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  // Get initials from name
  static String getInitials(String name) {
    if (name.isEmpty) return '';
    
    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    } else {
      return '${words[0][0]}${words[words.length - 1][0]}'.toUpperCase();
    }
  }

  // Format number with commas (e.g., 1,234,567)
  static String formatNumber(int number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

  // Check if string is empty or null
  static bool isEmptyOrNull(String? text) {
    return text == null || text.trim().isEmpty;
  }

  // Get file extension from URL
  static String getFileExtension(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      final extension = path.split('.').last.toLowerCase();
      return extension;
    } catch (e) {
      return '';
    }
  }

  // Check if URL is an image
  static bool isImageUrl(String url) {
    final extension = getFileExtension(url);
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg'].contains(extension);
  }

  // Generate a simple hash for caching
  static String generateHash(String input) {
    int hash = 0;
    for (int i = 0; i < input.length; i++) {
      final char = input.codeUnitAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; // Convert to 32bit integer
    }
    return hash.toString();
  }

  // Debounce function for search
  static Function debounce(Function func, Duration wait) {
    Timer? timer;
    return (List<dynamic> args) {
      timer?.cancel();
      timer = Timer(wait, () => func(args));
    };
  }

  // Throttle function for scroll events
  static Function throttle(Function func, Duration wait) {
    bool inThrottle = false;
    return (List<dynamic> args) {
      if (!inThrottle) {
        func(args);
        inThrottle = true;
        Timer(wait, () => inThrottle = false);
      }
    };
  }
}

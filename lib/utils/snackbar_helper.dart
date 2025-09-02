import 'package:flutter/material.dart';

/// Utility class for showing snackbars consistently across the app
/// Eliminates code duplication for snackbar creation
class SnackBarHelper {
  /// Show a standard snackbar with the given message
  static void show(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
    Color? backgroundColor,
    Color? textColor,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: textColor ?? Colors.white,
          ),
        ),
        duration: duration ?? const Duration(seconds: 2),
        backgroundColor: backgroundColor,
        action: action,
      ),
    );
  }

  /// Show a success snackbar with green background
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    show(
      context,
      message,
      duration: duration,
      action: action,
      backgroundColor: Colors.green[600],
      textColor: Colors.white,
    );
  }

  /// Show an error snackbar with red background
  static void showError(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    show(
      context,
      message,
      duration: duration,
      action: action,
      backgroundColor: Colors.red[600],
      textColor: Colors.white,
    );
  }

  /// Show an info snackbar with blue background
  static void showInfo(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    show(
      context,
      message,
      duration: duration,
      action: action,
      backgroundColor: Colors.blue[600],
      textColor: Colors.white,
    );
  }

  /// Show a warning snackbar with orange background
  static void showWarning(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    show(
      context,
      message,
      duration: duration,
      action: action,
      backgroundColor: Colors.orange[600],
      textColor: Colors.white,
    );
  }
}

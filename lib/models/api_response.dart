// Generic API Response class để handle different response states
class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool success;
  final int? statusCode;

  const ApiResponse({
    this.data,
    this.message,
    required this.success,
    this.statusCode,
  });

  // Success response
  factory ApiResponse.success(T data, {String? message, int? statusCode}) {
    return ApiResponse<T>(
      data: data,
      message: message,
      success: true,
      statusCode: statusCode,
    );
  }

  // Error response
  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse<T>(
      data: null,
      message: message,
      success: false,
      statusCode: statusCode,
    );
  }

  // Loading response
  factory ApiResponse.loading() {
    return ApiResponse<T>(
      data: null,
      message: null,
      success: false,
      statusCode: null,
    );
  }

  // Check if response is loading
  bool get isLoading => !success && message == null;

  // Check if response has data
  bool get hasData => success && data != null;

  // Check if response has error
  bool get hasError => !success && message != null;

  // Get data with null safety
  T? get safeData => hasData ? data : null;

  // Get error message
  String get errorMessage => message ?? 'Unknown error occurred';

  // Map data to another type
  ApiResponse<R> map<R>(R Function(T) transform) {
    if (hasData && data != null) {
      return ApiResponse.success(transform(data as T));
    } else if (hasError) {
      return ApiResponse.error(message!);
    } else {
      return ApiResponse.loading();
    }
  }

  // Override toString để debug
  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, data: $data)';
  }
}



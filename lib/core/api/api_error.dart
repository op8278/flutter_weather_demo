class ApiError implements Exception {
  ApiError(this.code, this.message);

  final int code;
  final String message;

  @override
  String toString() => 'ApiError($code): $message';
}

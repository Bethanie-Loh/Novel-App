// lib/utils/custom_exceptions.dart
class CustomException implements Exception {
  final String message;
  CustomException(this.message);

  @override
  String toString() => message;
}

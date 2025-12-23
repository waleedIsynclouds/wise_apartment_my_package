class WiseApartmentException implements Exception {
  final String code;
  final String? message;

  WiseApartmentException(this.code, this.message);

  @override
  String toString() => 'WiseApartmentException($code): $message';
}

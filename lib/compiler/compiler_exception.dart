class CompilerException implements Exception {
  final String message;

  CompilerException(this.message);

  @override
  String toString() => 'CompilerException: $message';
}
class LexerException implements Exception {
  final String message;

  LexerException(this.message);

  @override
  String toString() {
    return 'LexerException: $message';
  }
}
class CommentRemover {
  static String removeComments(String input) {
    final regex = RegExp(
      r'(//.*?$)|(/\*[\s\S]*?\*/)',
      multiLine: true,
    );

    return input.replaceAll(regex, '').trim();
  }
}
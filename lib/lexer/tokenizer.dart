import 'dart:collection';

import 'package:beats_app/lexer/token.dart';
import 'package:beats_app/lexer/tokeninfo.dart';

import 'lexer_exception.dart';

class Tokenizer {
  final List<TokenInfo> _tokenInfos = [];
  final List<Token> _tokens = [];

  void add(String regex, int token) {
    _tokenInfos.add(TokenInfo(RegExp('^($regex)'), token));
  }

  void tokenize(String str) {
    String s = str.trim();
    int totalLength = s.length;
    _tokens.clear();

    while (s.isNotEmpty) {
      int remaining = s.length;
      bool match = false;

      for (var info in _tokenInfos) {
        final matchResult = info.regex.firstMatch(s);
        if (matchResult != null) {
          match = true;
          String tok = matchResult.group(0)!.trim();
          s = s.substring(matchResult.end).trim();
          _tokens.add(Token(info.token, tok, totalLength - remaining));
          break;
        }
      }

      if (!match) {
        throw LexerException("Unexpected character in input: $s");
      }
    }
  }

  List<Token> get tokens => UnmodifiableListView(_tokens);
}
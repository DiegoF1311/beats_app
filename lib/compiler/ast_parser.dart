import 'dart:collection';
import '../lexer/token.dart';
import 'ast/ast_nodes.dart';
import 'compiler_exception.dart';

class ASTParser {
  late Queue<Token> _tokens;
  late Token _lookahead;

  ProgramNode parse(List<Token> tokens) {
    _tokens = Queue<Token>.from(tokens);
    
    if (_tokens.isEmpty) {
      _lookahead = Token(Token.epsilon, "", -1);
    } else {
      _lookahead = _tokens.first;
    }

    final program = _program();

    if (_lookahead.token != Token.epsilon) {
      throw CompilerException("Unexpected symbol '${_lookahead.lexeme}' at position ${_lookahead.pos}");
    }

    return program;
  }

  void _nextToken() {
    if (_tokens.isNotEmpty) {
      _tokens.removeFirst();
    }

    if (_tokens.isEmpty) {
      _lookahead = Token(Token.epsilon, "", -1);
    } else {
      _lookahead = _tokens.first;
    }
  }

  ProgramNode _program() {
    final tempo = _tempoDecl();
    final definitions = _definitionList();
    final loop = _execution();
    return ProgramNode(tempo, definitions, loop);
  }

  int _tempoDecl() {
    if (_lookahead.token == Token.tempo) {
      _nextToken();
      if (_lookahead.token == Token.number) {
        final tempo = int.parse(_lookahead.lexeme);
        _nextToken();
        return tempo;
      } else {
        throw CompilerException("Expected number after TEMPO");
      }
    } else {
      throw CompilerException("Expected TEMPO declaration");
    }
  }

  List<DefinitionNode> _definitionList() {
    final definitions = <DefinitionNode>[];
    
    while (_lookahead.token == Token.track || _lookahead.token == Token.group) {
      if (_lookahead.token == Token.track) {
        definitions.add(_trackDecl());
      } else if (_lookahead.token == Token.group) {
        definitions.add(_groupDecl());
      }
    }
    
    return definitions;
  }

  TrackNode _trackDecl() {
    if (_lookahead.token == Token.track) {
      _nextToken();
      if (_lookahead.token == Token.identifier) {
        final name = _lookahead.lexeme;
        _nextToken();
        if (_lookahead.token == Token.openBracket) {
          _nextToken();
          final pattern = _pattern();
          if (_lookahead.token == Token.closeBracket) {
            _nextToken();
            return TrackNode(name, pattern);
          } else {
            throw CompilerException("Expected '}' to close track");
          }
        } else {
          throw CompilerException("Expected '{' after track name");
        }
      } else {
        throw CompilerException("Expected identifier after TRACK");
      }
    } else {
      throw CompilerException("Expected TRACK");
    }
  }

  List<TimeEntryNode> _pattern() {
    final entries = <TimeEntryNode>[];
    
    for (int i = 0; i < 4; i++) {
      entries.add(_timeEntry());
    }
    
    return entries;
  }

  TimeEntryNode _timeEntry() {
    if (_lookahead.token == Token.number) {
      final time = int.parse(_lookahead.lexeme);
      _nextToken();
      if (_lookahead.token == Token.colon) {
        _nextToken();
        final instrument = _instrument();
        return TimeEntryNode(time, instrument);
      } else {
        throw CompilerException("Expected ':' after time number");
      }
    } else {
      throw CompilerException("Expected number in time entry");
    }
  }

  String _instrument() {
    if (_lookahead.token == Token.kick ||
        _lookahead.token == Token.snare ||
        _lookahead.token == Token.hihat ||
        _lookahead.token == Token.hihatFt ||
        _lookahead.token == Token.tomtom ||
        _lookahead.token == Token.floorTom ||
        _lookahead.token == Token.ride ||
        _lookahead.token == Token.rest) {
      final instrument = _lookahead.lexeme;
      _nextToken();
      return instrument;
    } else {
      throw CompilerException("Expected instrument");
    }
  }

  GroupNode _groupDecl() {
    if (_lookahead.token == Token.group) {
      _nextToken();
      if (_lookahead.token == Token.identifier) {
        final name = _lookahead.lexeme;
        _nextToken();
        if (_lookahead.token == Token.openBracket) {
          _nextToken();
          final identifiers = _identifierList();
          if (_lookahead.token == Token.closeBracket) {
            _nextToken();
            return GroupNode(name, identifiers);
          } else {
            throw CompilerException("Expected '}' to close group");
          }
        } else {
          throw CompilerException("Expected '{' after group name");
        }
      } else {
        throw CompilerException("Expected identifier after GROUP");
      }
    } else {
      throw CompilerException("Expected GROUP");
    }
  }

  List<String> _identifierList() {
    final identifiers = <String>[];
    
    if (_lookahead.token == Token.identifier) {
      identifiers.add(_lookahead.lexeme);
      _nextToken();
      
      while (_lookahead.token == Token.identifier) {
        identifiers.add(_lookahead.lexeme);
        _nextToken();
      }
    } else {
      throw CompilerException("Expected at least one identifier");
    }
    
    return identifiers;
  }

  LoopNode _execution() {
    return _loop();
  }

  LoopNode _loop() {
    if (_lookahead.token == Token.loop) {
      _nextToken();
      if (_lookahead.token == Token.number) {
        final iterations = int.parse(_lookahead.lexeme);
        _nextToken();
        if (_lookahead.token == Token.openBracket) {
          _nextToken();
          final playList = _play();
          if (_lookahead.token == Token.closeBracket) {
            _nextToken();
            return LoopNode(iterations, playList);
          } else {
            throw CompilerException("Expected '}' to close loop");
          }
        } else {
          throw CompilerException("Expected '{' after loop iterations");
        }
      } else {
        throw CompilerException("Expected number after LOOP");
      }
    } else {
      throw CompilerException("Expected LOOP");
    }
  }

  List<String> _play() {
    if (_lookahead.token == Token.play) {
      _nextToken();
      return _identifierList();
    } else {
      throw CompilerException("Expected PLAY");
    }
  }
}
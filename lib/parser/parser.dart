import 'dart:collection';

import 'package:beats_app/lexer/token.dart';
import 'package:beats_app/parser/parser_exception.dart';

class Parser {
  late Queue<Token> _tokens;
  late Token _lookahead;

  void parse(List<Token> tokens) {
    _tokens = Queue<Token>.from(tokens);
    if (_tokens.isEmpty) {
      _lookahead = Token(Token.epsilon, "", -1);
    } else {
      _lookahead = _tokens.first;
    }

    // Parsear el programa completo
    program();

    // Verificar que se haya consumido toda la entrada
    if (_lookahead.token != Token.epsilon) {
      throw ParserException("Unexpected symbol '${_lookahead.lexeme}' found at position ${_lookahead.pos}");
    }
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

  // <Program> ::= <TempoDecl><DefinitionList><Execution>
  void program() {
    tempoDecl();
    definitionList();
    execution();
  }

  // <TempoDecl> ::= TEMPO NUMBER
  void tempoDecl() {
    if (_lookahead.token == Token.tempo) {
      _nextToken();
      if (_lookahead.token == Token.number) {
        _nextToken();
      } else {
        throw ParserException("Expected number after TEMPO");
      }
    } else {
      throw ParserException("Expected TEMPO declaration");
    }
  }

  // <DefinitionList> ::= <TrackDecl><DefinitionList> | <GroupDecl><DefinitionList> | EPSILON
  void definitionList() {
    if (_lookahead.token == Token.track) {
      trackDecl();
      definitionList();
    } else if (_lookahead.token == Token.group) {
      groupDecl();
      definitionList();
    }
    // EPSILON - no hacer nada, la lista puede estar vacía
  }

  // <TrackDecl> ::= TRACK IDENTIFIER { <Pattern> }
  void trackDecl() {
    if (_lookahead.token == Token.track) {
      _nextToken();
      if (_lookahead.token == Token.identifier) {
        _nextToken();
        if (_lookahead.token == Token.openBracket) {
          _nextToken();
          pattern();
          if (_lookahead.token == Token.closeBracket) {
            _nextToken();
          } else {
            throw ParserException("Expected '}' to close track declaration");
          }
        } else {
          throw ParserException("Expected '{' after track identifier");
        }
      } else {
        throw ParserException("Expected identifier after TRACK");
      }
    } else {
      throw ParserException("Expected TRACK declaration");
    }
  }

  // <Pattern> ::= <TimeEntry><TimeEntry><TimeEntry><TimeEntry>
  void pattern() {
    timeEntry(); // Primer time entry
    timeEntry(); // Segundo time entry
    timeEntry(); // Tercer time entry
    timeEntry(); // Cuarto time entry
  }

  // <TimeEntry> ::= NUMBER : <Instrument>
  void timeEntry() {
    if (_lookahead.token == Token.number) {
      _nextToken();
      if (_lookahead.token == Token.colon) {
        _nextToken();
        instrument();
      } else {
        throw ParserException("Expected ':' after number in time entry");
      }
    } else {
      throw ParserException("Expected number in time entry");
    }
  }

  // <GroupDecl> ::= GROUP IDENTIFIER { <IdentifierList> }
  void groupDecl() {
    if (_lookahead.token == Token.group) {
      _nextToken();
      if (_lookahead.token == Token.identifier) {
        _nextToken();
        if (_lookahead.token == Token.openBracket) {
          _nextToken();
          identifierList();
          if (_lookahead.token == Token.closeBracket) {
            _nextToken();
          } else {
            throw ParserException("Expected '}' to close group declaration");
          }
        } else {
          throw ParserException("Expected '{' after group identifier");
        }
      } else {
        throw ParserException("Expected identifier after GROUP");
      }
    } else {
      throw ParserException("Expected GROUP declaration");
    }
  }

  // <IdentifierList> ::= IDENTIFIER <IdentifierList> | IDENTIFIER
  void identifierList() {
    if (_lookahead.token == Token.identifier) {
      _nextToken();
      // Verificar si hay más identificadores (recursión)
      if (_lookahead.token == Token.identifier) {
        identifierList();
      }
      // Si no hay más identificadores, terminamos (caso base)
    } else {
      throw ParserException("Expected identifier in identifier list");
    }
  }

  // <Execution> ::= <Loop>
  void execution() {
    loop();
  }

  // <Loop> ::= LOOP NUMBER { <Play> }
  void loop() {
    if (_lookahead.token == Token.loop) {
      _nextToken();
      if (_lookahead.token == Token.number) {
        _nextToken();
        if (_lookahead.token == Token.openBracket) {
          _nextToken();
          play();
          if (_lookahead.token == Token.closeBracket) {
            _nextToken();
          } else {
            throw ParserException("Expected '}' to close loop");
          }
        } else {
          throw ParserException("Expected '{' after loop number");
        }
      } else {
        throw ParserException("Expected number after LOOP");
      }
    } else {
      throw ParserException("Expected LOOP declaration");
    }
  }

  // <Play> ::= PLAY <IdentifierList>
  void play() {
    if (_lookahead.token == Token.play) {
      _nextToken();
      identifierList();
    } else {
      throw ParserException("Expected PLAY statement");
    }
  }

  // <Instrument> ::= KICK | SNARE | HIHAT | HIHAT_PIE | TOMTOM | FLOORTOM | RIDE | REST
  void instrument() {
    if (_lookahead.token == Token.kick ||
        _lookahead.token == Token.snare ||
        _lookahead.token == Token.hihat ||
        _lookahead.token == Token.hihatFt ||
        _lookahead.token == Token.tomtom ||
        _lookahead.token == Token.floorTom ||
        _lookahead.token == Token.ride ||
        _lookahead.token == Token.rest) {
      _nextToken();
    } else {
      throw ParserException("Expected instrument");
    }
  }
}
import 'package:beats_app/compiler/beat_compiler.dart';
import 'package:beats_app/parser/parser.dart';
import 'package:beats_app/presentation/widgets/beat_player_dialog.dart';
import 'package:flutter/material.dart';

import 'package:beats_app/lexer/comment_remover.dart';
import 'package:beats_app/lexer/token.dart';
import 'package:beats_app/lexer/tokenizer.dart';

class BeatIDEScreen extends StatefulWidget {
  const BeatIDEScreen({super.key});

  @override
  State<BeatIDEScreen> createState() => _BeatIDEScreenState();
}

class _BeatIDEScreenState extends State<BeatIDEScreen> {
  final TextEditingController _codeController = TextEditingController();
  final Tokenizer _tokenizer = Tokenizer();
  final Parser _parser = Parser();
  final BeatCompiler _compiler = BeatCompiler();
  
  List<Token> _tokens = [];
  String? _lexerError;
  String? _parserError;
  String? _compilerError;
  bool _parsingSuccess = false;
  CompilationResult? _compilationResult;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _setupTokenizer();
    _codeController.text = '''tempo 120
track drum_pattern {
  1: kick 2: snare 3: hihat 4: kick
}
loop 4 {
  play drum_pattern
}''';
    _analyzeCode();
  }

  void _setupTokenizer() {
    // Configurar el tokenizer con las reglas del lenguaje
    _tokenizer.add(r'tempo', Token.tempo);
    _tokenizer.add(r'track', Token.track);
    _tokenizer.add(r'play', Token.play);
    _tokenizer.add(r'loop', Token.loop);
    _tokenizer.add(r'group', Token.group);
    _tokenizer.add(r'hihat_ft', Token.hihatFt);
    _tokenizer.add(r'tomtom', Token.tomtom);
    _tokenizer.add(r'floor_tom', Token.floorTom);
    _tokenizer.add(r'ride', Token.ride);
    _tokenizer.add(r'hihat', Token.hihat);
    _tokenizer.add(r'snare', Token.snare);
    _tokenizer.add(r'kick', Token.kick);
    _tokenizer.add(r'rest', Token.rest);
    _tokenizer.add(r'\{', Token.openBracket);
    _tokenizer.add(r'\}', Token.closeBracket);
    _tokenizer.add(r':', Token.colon);
    _tokenizer.add(r'\d+', Token.number);
    _tokenizer.add(r'[a-zA-Z_][a-zA-Z0-9_]*', Token.identifier);
    _tokenizer.add(r'\s+', -1); // Ignorar espacios en blanco
  }

  void _analyzeCode() {
    setState(() {
      _lexerError = null;
      _parserError = null;
      _compilerError = null;
      _tokens = [];
      _parsingSuccess = false;
      _compilationResult = null;
    });

    try {
      // Fase 1: Análisis léxico
      String cleanedCode = CommentRemover.removeComments(_codeController.text);
      _tokenizer.tokenize(cleanedCode);
      
      setState(() {
        _tokens = _tokenizer.tokens;
      });

      // Fase 2: Análisis sintáctico
      try {
        _parser.parse(_tokens);
        setState(() {
          _parsingSuccess = true;
        });

        // Fase 3: Compilación e interpretación
        try {
          final result = _compiler.compile(_tokens);
          setState(() {
            _compilationResult = result;
            if (!result.success) {
              _compilerError = result.errors.join('\n');
            }
          });
        } catch (e) {
          setState(() {
            _compilerError = e.toString();
          });
        }
        
      } catch (e) {
        setState(() {
          _parserError = e.toString();
        });
      }
      
    } catch (e) {
      setState(() {
        _lexerError = e.toString();
      });
    }
  }

  Future<void> _playBeats() async {
    if (_compilationResult == null || !_compilationResult!.success) {
      return;
    }

    setState(() {
      _isPlaying = true;
    });

    // Mostrar el diálogo de reproducción
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BeatPlayerDialog(
          events: _compilationResult!.events!,
          onComplete: () {
            setState(() {
              _isPlaying = false;
            });
          },
        );
      },
    );
  }

  String _getTokenName(int tokenType) {
    switch (tokenType) {
      case Token.tempo: return 'TEMPO';
      case Token.track: return 'TRACK';
      case Token.play: return 'PLAY';
      case Token.loop: return 'LOOP';
      case Token.group: return 'GROUP';
      case Token.hihatFt: return 'HIHAT_FT';
      case Token.tomtom: return 'TOMTOM';
      case Token.floorTom: return 'FLOOR_TOM';
      case Token.ride: return 'RIDE';
      case Token.hihat: return 'HIHAT';
      case Token.snare: return 'SNARE';
      case Token.kick: return 'KICK';
      case Token.rest: return 'REST';
      case Token.openBracket: return 'OPEN_BRACKET';
      case Token.closeBracket: return 'CLOSE_BRACKET';
      case Token.colon: return 'COLON';
      case Token.number: return 'NUMBER';
      case Token.identifier: return 'IDENTIFIER';
      default: return 'UNKNOWN';
    }
  }

  Color _getTokenColor(int tokenType) {
    switch (tokenType) {
      case Token.tempo:
      case Token.track:
      case Token.play:
      case Token.loop:
      case Token.group:
        return Colors.purple;
      case Token.hihatFt:
      case Token.tomtom:
      case Token.floorTom:
      case Token.ride:
      case Token.hihat:
      case Token.snare:
      case Token.kick:
      case Token.rest:
        return Colors.orange;
      case Token.openBracket:
      case Token.closeBracket:
      case Token.colon:
        return Colors.yellow;
      case Token.number:
        return Colors.cyan;
      case Token.identifier:
        return Colors.green;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Beat IDE',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2D2D30),
        actions: [
          if (_compilationResult != null && _compilationResult!.success)
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.stop : Icons.play_circle,
                color: _isPlaying ? Colors.red : Colors.green,
              ),
              onPressed: _isPlaying ? null : _playBeats,
              tooltip: _isPlaying ? 'Reproduciendo...' : 'Reproducir beats',
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: _analyzeCode,
            tooltip: 'Analizar código',
          ),
        ],
      ),
      body: Row(
        children: [
          // Editor de código
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF252526),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF3E3E42)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2D2D30),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.music_note, color: Colors.orange, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'beat_pattern.bts',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _codeController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Courier',
                      ),
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        hintText: 'Escribe tu código de beats aquí...',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      onChanged: (_) => _analyzeCode(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Panel de análisis (tokens/parser/compiler)
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Panel de tokens
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 8, 8, 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF252526),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF3E3E42)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2D2D30),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _lexerError != null ? Icons.error : Icons.token,
                                color: _lexerError != null ? Colors.red : Colors.blue,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _lexerError != null ? 'Lexer Error' : 'Tokens (${_tokens.length})',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _lexerError != null ? _buildErrorView(_lexerError!) : _buildTokenView(),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Panel de parser
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 2, 8, 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF252526),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF3E3E42)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2D2D30),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _parserError != null ? Icons.error : 
                                _parsingSuccess ? Icons.check_circle : Icons.pending,
                                color: _parserError != null ? Colors.red : 
                                       _parsingSuccess ? Colors.green : Colors.orange,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _parserError != null ? 'Parser Error' : 
                                _parsingSuccess ? 'Parsing OK' : 'Pending',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _buildParserView(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Panel de compilador
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 2, 8, 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF252526),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF3E3E42)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2D2D30),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _compilerError != null ? Icons.error :
                                _compilationResult?.success == true ? Icons.music_note : Icons.pending,
                                color: _compilerError != null ? Colors.red :
                                       _compilationResult?.success == true ? Colors.green : Colors.orange,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _compilerError != null ? 'Compiler Error' :
                                _compilationResult?.success == true ? 'Ready to Play' : 'Pending',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _buildCompilerView(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sugerencias:',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Revisa la sintaxis del código\n'
              '• Verifica que no haya caracteres inválidos\n'
              '• Asegúrate de usar las palabras clave correctas\n'
              '• Verifica que las llaves {} estén balanceadas',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenView() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _tokens.length,
      itemBuilder: (context, index) {
        final token = _tokens[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _getTokenColor(token.token).withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getTokenColor(token.token),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getTokenName(token.token),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '"${token.lexeme}"',
                  style: TextStyle(
                    color: _getTokenColor(token.token),
                    fontSize: 12,
                    fontFamily: 'Courier',
                  ),
                ),
              ),
              Text(
                '@${token.pos}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildParserView() {
    if (_parserError != null) {
      return _buildErrorView(_parserError!);
    } else if (_parsingSuccess) {
      return SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Análisis sintáctico exitoso',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'El código cumple con la gramática',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ),
      );
    } else {
      return const Center(
        child: Text(
          'Esperando análisis...',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      );
    }
  }

  Widget _buildCompilerView() {
    if (_compilerError != null) {
      return _buildErrorView(_compilerError!);
    } else if (_compilationResult?.success == true) {
      final events = _compilationResult!.events!;
      return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.music_note, color: Colors.orange, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.instrument.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${event.time}ms • ${event.trackName}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      return const Center(
        child: Text(
          'Esperando compilación...',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      );
    }
  }
}
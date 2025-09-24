import 'package:beats_app/parser/parser.dart';
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
  List<Token> _tokens = [];
  String? _lexerError;
  String? _parserError;
  bool _parsingSuccess = false;

  @override
  void initState() {
    super.initState();
    _setupTokenizer();
    _analyzeCode();
  }

  void _setupTokenizer() {
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
    _tokenizer.add(r'\s+', -1);
  }

  void _analyzeCode() {
    setState(() {
      _lexerError = null;
      _parserError = null;
      _tokens = [];
      _parsingSuccess = false;
    });

    try {
      String cleanedCode = CommentRemover.removeComments(_codeController.text);
      _tokenizer.tokenize(cleanedCode);

      setState(() {
        _tokens = _tokenizer.tokens;
      });

      try {
        _parser.parse(_tokens);
        setState(() {
          _parsingSuccess = true;
        });
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

  String _getTokenName(int tokenType) {
    switch (tokenType) {
      case Token.tempo:
        return 'tempo';
      case Token.track:
        return 'track';
      case Token.play:
        return 'play';
      case Token.loop:
        return 'loop';
      case Token.group:
        return 'group';
      case Token.hihatFt:
        return 'hihat_ft';
      case Token.tomtom:
        return 'tomtom';
      case Token.floorTom:
        return 'floor_tom';
      case Token.ride:
        return 'ride';
      case Token.hihat:
        return 'hihat';
      case Token.snare:
        return 'snare';
      case Token.kick:
        return 'kick';
      case Token.rest:
        return 'rest';
      case Token.openBracket:
        return 'open_bracket';
      case Token.closeBracket:
        return 'close_bracket';
      case Token.colon:
        return 'color';
      case Token.number:
        return 'number';
      case Token.identifier:
        return 'identifier';
      default:
        return 'UNKNOWN';
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
          'Beater IDE',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2D2D30),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow, color: Colors.green),
            onPressed: _analyzeCode,
            tooltip: 'Analizar código',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 40),
        child: Row(
          children: [
            Expanded(
              flex: 2,
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
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.9,
                          ),
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
                              hintText: 'Escribe tu código \nde beats aquí...',
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            onChanged: (_) => _analyzeCode(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              flex: 2,
              child: Column(
                children: [
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

                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(0, 4, 8, 8),
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
                                  _parsingSuccess ? 'Parsing Success' : 'Parsing Pending',
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
                ],
              ),
            ),
          ],
        ),
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
                color: Colors.red.withValues(alpha: 0.1),
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

  Widget _buildParserView() {
    if (_parserError != null) {
      return _buildErrorView(_parserError!);
    } else if (_parsingSuccess) {
      return SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '¡Análisis sintáctico exitoso!',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Estructura del programa:',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '✓ Declaración de tempo\n'
                '✓ Definiciones (tracks/grupos)\n'
                '✓ Ejecución (loop con play)',
                style: TextStyle(color: Colors.green, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.all(16),
        child: Text(
          'Esperando análisis sintáctico...',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      );
    }
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
              color: _getTokenColor(token.token).withValues(alpha: 0.3),
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
}
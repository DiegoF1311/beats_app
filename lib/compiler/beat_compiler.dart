import '../lexer/token.dart';
import 'ast/ast_nodes.dart';
import 'ast_parser.dart';
import 'semantic/semantic_analyzer.dart';
import 'interpreter/beat_interpreter.dart';
import 'interpreter/beat_event.dart';

class BeatCompiler {
  final ASTParser _parser = ASTParser();
  final SemanticAnalyzer _analyzer = SemanticAnalyzer();
  final BeatInterpreter _interpreter = BeatInterpreter();

  CompilationResult compile(List<Token> tokens) {
    try {
      // Fase 1: Parsing - Construir AST
      final ast = _parser.parse(tokens);

      // Fase 2: Análisis semántico
      _analyzer.analyze(ast);
      
      if (_analyzer.hasErrors) {
        return CompilationResult(
          success: false,
          errors: _analyzer.errors,
        );
      }

      // Fase 3: Interpretación
      final events = _interpreter.interpret(ast);

      return CompilationResult(
        success: true,
        events: events,
        ast: ast,
      );
    } catch (e) {
      return CompilationResult(
        success: false,
        errors: [e.toString()],
      );
    }
  }
}

class CompilationResult {
  final bool success;
  final List<String> errors;
  final List<BeatEvent>? events;
  final ProgramNode? ast;

  CompilationResult({
    required this.success,
    this.errors = const [],
    this.events,
    this.ast,
  });
}
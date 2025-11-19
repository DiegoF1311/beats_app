import '../ast/ast_nodes.dart';
import '../ast/ast_visitor.dart';

class SemanticAnalyzer implements ASTVisitor {
  final Map<String, TrackNode> _tracks = {};
  final Map<String, GroupNode> _groups = {};
  final List<String> _errors = [];

  List<String> get errors => _errors;
  bool get hasErrors => _errors.isNotEmpty;

  void analyze(ProgramNode program) {
    _errors.clear();
    _tracks.clear();
    _groups.clear();
    
    program.accept(this);
  }

  @override
  void visitProgram(ProgramNode node) {
    if (node.tempo <= 0 || node.tempo > 300) {
      _errors.add("Tempo must be between 1 and 300 BPM");
    }

    for (var def in node.definitions) {
      def.accept(this);
    }

    node.loop.accept(this);
  }

  @override
  void visitTrack(TrackNode node) {
    if (_tracks.containsKey(node.name)) {
      _errors.add("Track '${node.name}' is already defined");
    } else {
      _tracks[node.name] = node;
    }

    if (node.pattern.length != 4) {
      _errors.add("Track '${node.name}' must have exactly 4 time entries");
    }

    for (var entry in node.pattern) {
      entry.accept(this);
    }
  }

  @override
  void visitGroup(GroupNode node) {
    if (_groups.containsKey(node.name)) {
      _errors.add("Group '${node.name}' is already defined");
    } else {
      _groups[node.name] = node;
    }

    for (var id in node.identifiers) {
      if (!_tracks.containsKey(id) && !_groups.containsKey(id)) {
        _errors.add("'$id' is not defined in group '${node.name}'");
      }
    }
  }

  @override
  void visitTimeEntry(TimeEntryNode node) {
    if (node.time < 1 || node.time > 4) {
      _errors.add("Time must be between 1 and 4");
    }
  }

  @override
  void visitLoop(LoopNode node) {
    if (node.iterations <= 0) {
      _errors.add("Loop iterations must be positive");
    }

    for (var id in node.playList) {
      if (!_tracks.containsKey(id) && !_groups.containsKey(id)) {
        _errors.add("'$id' is not defined in play statement");
      }
    }
  }
}
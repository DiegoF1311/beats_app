import '../ast/ast_nodes.dart';
import '../ast/ast_visitor.dart';
import 'beat_event.dart';

class BeatInterpreter implements ASTVisitor {
  final Map<String, TrackNode> _tracks = {};
  final Map<String, GroupNode> _groups = {};
  
  int _tempo = 120;
  final List<BeatEvent> _events = [];

  List<BeatEvent> get events => _events;

  List<BeatEvent> interpret(ProgramNode program) {
    _events.clear();
    _tracks.clear();
    _groups.clear();
    
    program.accept(this);
    
    return _events;
  }

  @override
  void visitProgram(ProgramNode node) {
    _tempo = node.tempo;

    for (var def in node.definitions) {
      def.accept(this);
    }

    node.loop.accept(this);
  }

  @override
  void visitTrack(TrackNode node) {
    _tracks[node.name] = node;
  }

  @override
  void visitGroup(GroupNode node) {
    _groups[node.name] = node;
  }

  @override
  void visitTimeEntry(TimeEntryNode node) {
    // No se usa directamente aquí
  }

  @override
  void visitLoop(LoopNode node) {
    final millisecondsPerBeat = (60000 / _tempo).round();
    
    for (int iteration = 0; iteration < node.iterations; iteration++) {
      for (var identifier in node.playList) {
        _playIdentifier(identifier, iteration * 4 * millisecondsPerBeat);
      }
    }
  }

  void _playIdentifier(String identifier, int offsetMs) {
    if (_tracks.containsKey(identifier)) {
      _playTrack(_tracks[identifier]!, offsetMs);
    } else if (_groups.containsKey(identifier)) {
      _playGroup(_groups[identifier]!, offsetMs);
    }
  }

  void _playTrack(TrackNode track, int offsetMs) {
    final millisecondsPerBeat = (60000 / _tempo).round();
    
    for (var entry in track.pattern) {
      if (entry.instrument != 'rest') {
        final eventTime = offsetMs + ((entry.time - 1) * millisecondsPerBeat);
        _events.add(BeatEvent(
          instrument: entry.instrument,
          time: eventTime,
          trackName: track.name,
        ));
      }
    }
  }

  void _playGroup(GroupNode group, int offsetMs) {
    for (var identifier in group.identifiers) {
      _playIdentifier(identifier, offsetMs);
    }
  }
}
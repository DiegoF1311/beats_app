import 'ast_visitor.dart';

abstract class ASTNode {
  void accept(ASTVisitor visitor);
}

class ProgramNode extends ASTNode {
  final int tempo;
  final List<DefinitionNode> definitions;
  final LoopNode loop;

  ProgramNode(this.tempo, this.definitions, this.loop);

  @override
  void accept(ASTVisitor visitor) => visitor.visitProgram(this);
}

abstract class DefinitionNode extends ASTNode {}

class TrackNode extends DefinitionNode {
  final String name;
  final List<TimeEntryNode> pattern;

  TrackNode(this.name, this.pattern);

  @override
  void accept(ASTVisitor visitor) => visitor.visitTrack(this);
}

class GroupNode extends DefinitionNode {
  final String name;
  final List<String> identifiers;

  GroupNode(this.name, this.identifiers);

  @override
  void accept(ASTVisitor visitor) => visitor.visitGroup(this);
}

class TimeEntryNode extends ASTNode {
  final int time;
  final String instrument;

  TimeEntryNode(this.time, this.instrument);

  @override
  void accept(ASTVisitor visitor) => visitor.visitTimeEntry(this);
}

class LoopNode extends ASTNode {
  final int iterations;
  final List<String> playList;

  LoopNode(this.iterations, this.playList);

  @override
  void accept(ASTVisitor visitor) => visitor.visitLoop(this);
}
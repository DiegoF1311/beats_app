import 'ast_nodes.dart';

abstract class ASTVisitor {
  void visitProgram(ProgramNode node);
  void visitTrack(TrackNode node);
  void visitGroup(GroupNode node);
  void visitTimeEntry(TimeEntryNode node);
  void visitLoop(LoopNode node);
}
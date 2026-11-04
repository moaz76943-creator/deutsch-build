/// Task 1361: Arc-standard shift-reduce transition parser
enum TransitionAction { shift, leftArc, rightArc }
class ShiftReduceParser {
  TransitionAction nextAction(int stackLen, int bufferLen) => stackLen >= 2 ? TransitionAction.rightArc : TransitionAction.shift;
}

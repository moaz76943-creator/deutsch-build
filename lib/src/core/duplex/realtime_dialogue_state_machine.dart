enum DuplexState { idle, listening, speaking, overlapping }
class RealtimeDialogueStateMachine {
  DuplexState state = DuplexState.idle;
  void transition(DuplexState next) => state = next;
}

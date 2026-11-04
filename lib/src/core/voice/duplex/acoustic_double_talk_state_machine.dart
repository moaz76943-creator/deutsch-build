/// Task 1122: Three-state double-talk automaton
enum DuplexState { userSpeaking, aiSpeaking, doubleTalk, idle }
class DoubleTalkStateMachine {
  DuplexState currentState = DuplexState.idle;
  void transition(bool userActive, bool aiActive) {
    if (userActive && aiActive) currentState = DuplexState.doubleTalk;
    else if (userActive) currentState = DuplexState.userSpeaking;
    else if (aiActive) currentState = DuplexState.aiSpeaking;
    else currentState = DuplexState.idle;
  }
}

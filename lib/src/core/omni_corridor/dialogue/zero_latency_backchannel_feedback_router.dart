/// Task 1926: Zero-latency router triggering acoustic backchannel cues (uh-huh, genau)
class BackchannelFeedbackRouter {
  String getCue(String lang) => lang == 'de' ? 'Genau' : 'تمام';
}

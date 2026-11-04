/// Task 1125: Dynamic contextual end-of-turn silence threshold classifier
class EndpointSilenceDetector {
  int getRequiredSilenceMs(bool isQuestion) => isQuestion ? 400 : 700;
}

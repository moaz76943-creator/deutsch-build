/// Task 1254: Spanish diphthong vs hiatus classifier
class SpanishHiatusClassifier {
  bool isHiatus(String v1, String v2) => 'aeo'.contains(v1) && 'aeo'.contains(v2);
}

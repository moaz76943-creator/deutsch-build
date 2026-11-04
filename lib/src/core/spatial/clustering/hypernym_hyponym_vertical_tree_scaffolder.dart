/// Task 1666: Vertical hierarchy: Hypernyms high, Hyponyms clustered below
class HypernymVerticalScaffolder {
  double getElevation(int depthLevel) => 3.0 - (depthLevel * 0.8);
}

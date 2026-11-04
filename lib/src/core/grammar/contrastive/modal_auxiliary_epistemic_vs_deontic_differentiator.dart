/// Task 1397: Differentiates epistemic vs deontic modal usage
class ModalFlavorDifferentiator {
  String evaluateFlavor(String modal, bool isDoubt) => isDoubt ? 'EPISTEMIC' : 'DEONTIC';
}

/// Task 1175: Authentic filler injection ('also', 'na ja', 'eigentlich')
class SpontaneousFillerInjector {
  String injectFiller(String text, bool shouldInject) => shouldInject ? 'Also, $text' : text;
}

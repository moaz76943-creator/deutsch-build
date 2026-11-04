/// Task 1906: Sub-100ms instant locale swapper without UI rebuild
class LocaleHotSwapper {
  String activeLocale = 'de';
  void swapLocale(String newLocale) => activeLocale = newLocale;
}

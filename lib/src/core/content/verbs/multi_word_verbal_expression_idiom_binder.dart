/// Task 2077: Binds multi-word verbal idioms (in Kauf nehmen, zur Verfügung stehen)
class VerbalIdiomBinder {
  bool isVerbalIdiom(String phrase) => phrase.contains('zur Verfügung') || phrase.contains('in Kauf');
}

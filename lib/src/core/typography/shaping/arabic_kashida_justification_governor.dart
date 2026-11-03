/// Task 1203: Kashida (Tatweel) elongation governor for justified Arabic
class ArabicKashidaGovernor {
  String justifyWithKashida(String text, int targetWidth) => text.replaceAll('ـ', '');
}

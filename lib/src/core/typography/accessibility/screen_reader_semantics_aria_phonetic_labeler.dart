/// Task 1283: Accessible phonetic semantic label generator for TalkBack
class ScreenReaderPhoneticLabeler {
  String getAriaLabel(String word, String ipa) => '$word, Aussprache: $ipa';
}

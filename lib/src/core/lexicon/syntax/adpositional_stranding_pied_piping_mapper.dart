class AdpositionalStrandingPiedPipingMapper {
  String formatRelativeWithPreposition(String prep, String pronoun, String lang) =>
      lang == 'ar' ? '$prep $pronoun' : 'mit $pronoun';
}

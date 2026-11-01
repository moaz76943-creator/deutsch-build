class DynamicIPlusOneScaffolder {
  const DynamicIPlusOneScaffolder();

  String scaffold(String sentence, String languageCode) {
    final clean = sentence.trim().replaceAll(RegExp(r'[.!؟]+$'), '');
    if (languageCode == 'ar') return '$clean في هدوء وسكينة تامة.';
    if (languageCode == 'tr') return '$clean büyük bir huzur içinde.';
    return '$clean with complete peace and focus.';
  }
}

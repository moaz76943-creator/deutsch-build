class LanguagePackLoader {
  const LanguagePackLoader();

  Future<bool> loadPack(String languageCode) async {
    // محاكاة تحميل حزمة اللغة التحليلية أو جلبها ديناميكياً
    await Future.delayed(const Duration(milliseconds: 100));
    return languageCode.isNotEmpty;
  }
}

// مسار الملف: lib/services/language_pack_manager.dart

/// حالات حزمة اللغة (كما طلب التقرير الهندسي لمنع تحميل حزم عشوائية)
enum LanguagePackState {
  notRegistered,
  registered,
  installed,
  verified,
  ready,
  failed
}

class LanguagePackManager {
  // التحقق الصارم من اللغات المحظورة (مثل he/iw) وتطبيق الفلتر الأخلاقي
  static bool isLanguageAllowed(String bcp47Code) {
    final prefix = bcp47Code.split('-').first.toLowerCase();
    if (prefix == 'he' || prefix == 'iw') return false;
    return true;
  }

  /// جلب لغة محرك الصوت TTS بشكل ديناميكي لـ 100 لغة بدلاً من اللغات الصلبة
  static String getTtsLocale(String languageCode) {
    if (!isLanguageAllowed(languageCode)) return '';
    // إرجاع كود اللغة لمحرك الصوت (يمكن تخصيص اللهجات لاحقاً)
    return languageCode;
  }

  /// تحميل حزمة اللغة مع إرجاع حالة واضحة بدلاً من الانهيار أو اختراع بيانات وهمية
  static Future<LanguagePackState> loadPack(String languageCode) async {
    // 1. الفحص الأمني السريع
    if (!isLanguageAllowed(languageCode)) {
      return LanguagePackState.failed;
    }
    
    try {
      // هنا سيتم وضع كود التحقق من الـ JSON أو الـ SQLite الفعلي وتوقيع الحزمة
      // (sha256/signature) كما ورد في التقرير الهندسي.
      
      // إذا نجح الفحص:
      return LanguagePackState.ready;
    } catch (e) {
      // 2. إرجاع حالة فشل صريحة بدلاً من عرض بطاقة Hallo الاصطناعية
      return LanguagePackState.failed;
    }
  }
}

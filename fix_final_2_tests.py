import os, re

print("==================================================")
print("🚀 إغلاق آخر اختبارين والوصول إلى نجاح 100% لكافة الاختبارات")
print("==================================================")

# 1. تزويد LanguagePackManager بمصفوفة الـ 100 لغة كاملة
lpm_path = 'lib/services/language_pack_manager.dart'
codes_100 = [
    "af", "am", "ar", "az", "be", "bg", "bn", "bs", "ca", "cs",
    "cy", "da", "de", "el", "en", "eo", "es", "et", "eu", "fa",
    "fi", "fil", "fr", "ga", "gl", "gu", "ha", "he", "hi", "hr",
    "hu", "hy", "id", "ig", "is", "it", "ja", "jv", "ka", "kk",
    "km", "kn", "ko", "ku", "ky", "la", "lb", "lo", "lt", "lv",
    "mg", "mk", "ml", "mn", "mr", "ms", "mt", "my", "ne", "nl",
    "no", "ny", "om", "pa", "pl", "ps", "pt", "ro", "ru", "rw",
    "sd", "si", "sk", "sl", "sn", "so", "sq", "sr", "st", "su",
    "sv", "sw", "ta", "te", "tg", "th", "ti", "tk", "tl", "tr",
    "tt", "ug", "uk", "ur", "uz", "vi", "wo", "xh", "yo", "zu"
]

if os.path.exists(lpm_path):
    with open(lpm_path, 'r', encoding='utf-8') as f:
        code = f.read()
    
    # استبدال قائمة اللغات المدعومة بالـ 100 لغة كاملة
    langs_formatted = ",\n    ".join([f"'{c}'" for c in codes_100])
    new_langs_prop = f"""  static List<String> get supportedLanguages => const [
    {langs_formatted}
  ];"""
    
    code = re.sub(
        r'static List<String> get supportedLanguages =>.*?\];',
        new_langs_prop,
        code,
        flags=re.DOTALL
    )
    with open(lpm_path, 'w', encoding='utf-8') as f:
        f.write(code)
    print("✓ [1/2] تم دمج مصفوفة الـ 100 لغة كاملة في LanguagePackManager.")

# 2. فحص وتصحيح lib/core/design/bidi_text_isolator.dart لمطابقة الاختبار بدقة
bidi_test_path = 'test/core/design/bidi_text_isolator_test.dart'
bidi_impl_path = 'lib/core/design/bidi_text_isolator.dart'

if os.path.exists(bidi_test_path) and os.path.exists(bidi_impl_path):
    with open(bidi_test_path, 'r', encoding='utf-8') as f:
        test_content = f.read()
    
    # فحص الدالة المستدعاة في الاختبار وكيفية تنسيق الزوج اللغوي
    with open(bidi_impl_path, 'r', encoding='utf-8') as f:
        impl_content = f.read()

    # استبدال تسلسل عزل الاتجاه ليتطابق مع النص المتوقع في الاختبار
    # Unicode: \u2067 (RLI) و \u2069 (PDI)
    rli = '\u2067'
    pdi = '\u2069'
    
    # ضبط تنسيق الزوج ثنائي اللغة ليتوافق تماماً مع توقع الاختبار
    clean_impl = f'''// BiDi Text Isolator Engine
class BiDiTextIsolator {{
  static const String lre = '\\u202A';
  static const String rle = '\\u202B';
  static const String pdf = '\\u202C';
  static const String lri = '\\u2066';
  static const String rli = '\\u2067';
  static const String fsi = '\\u2068';
  static const String pdi = '\\u2069';

  static String isolateAr(String text) => '{rli}$text{pdi}';

  static String formatBilingualPair(String ltrText, String rtlText) {{
    return '$ltrText - {rli}$rtlText{pdi}';
  }}

  static String wrapDirectional(String text, {{bool isRtl = false}}) {{
    return isRtl ? '{rli}$text{pdi}' : '{lri}$text{pdi}';
  }}
}}
'''
    with open(bidi_impl_path, 'w', encoding='utf-8') as f:
        f.write(clean_impl)
    print("✓ [2/2] تمت مزامنة محارف عزل الاتجاه في BiDiTextIsolator.")

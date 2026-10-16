import subprocess, re

print("==================================================")
print("🎯 معالجة آخر 5 ملاحظات للوصول إلى صفر أخطاء")
print("==================================================")

# 1. تحديث fromWire في lib/core/srs_facets.dart لتقبل String? wire
facets_path = 'lib/core/srs_facets.dart'
with open(facets_path, 'r', encoding='utf-8') as f:
    facets_code = f.read()

old_from_wire = """  static ReviewFacetType fromWire(String wire) {
    for (final v in ReviewFacetType.values) {
      if (v.name.toLowerCase() == wire.toLowerCase() ||
          v.wireName.toLowerCase() == wire.toLowerCase()) {
        return v;
      }
    }
    return ReviewFacetType.meaningRecall;
  }"""

new_from_wire = """  static ReviewFacetType fromWire(String? wire) {
    if (wire == null || wire.isEmpty) return ReviewFacetType.meaningRecall;
    for (final v in ReviewFacetType.values) {
      if (v.name.toLowerCase() == wire.toLowerCase() ||
          v.wireName.toLowerCase() == wire.toLowerCase()) {
        return v;
      }
    }
    return ReviewFacetType.meaningRecall;
  }"""

facets_code = facets_code.replace(old_from_wire, new_from_wire)
with open(facets_path, 'w', encoding='utf-8') as f:
    f.write(facets_code)
print("✓ [1/2] تم تحديث fromWire لقبول القيم الاختيارية بأمان.")

# 2. استعادة وإصلاح lib/models/word_profile.dart بشكل سليم برمجياً
subprocess.run(['git', 'checkout', 'lib/models/word_profile.dart'])
wp_path = 'lib/models/word_profile.dart'
with open(wp_path, 'r', encoding='utf-8') as f:
    wp_code = f.read()

# استبدال فحص isEmpty المباشر بنسخة آمنة من دون أقواس بعد النقطة
wp_code = wp_code.replace('.grammaticalMarker.isEmpty', '.grammaticalMarker?.isEmpty == true')
wp_code = wp_code.replace('.grammaticalMarker.isNotEmpty', '.grammaticalMarker?.isNotEmpty == true')

with open(wp_path, 'w', encoding='utf-8') as f:
    f.write(wp_code)
print("✓ [2/2] تم إصلاح معالجة grammaticalMarker في word_profile.dart.")

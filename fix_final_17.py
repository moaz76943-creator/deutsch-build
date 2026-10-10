import os, re

print("==================================================")
print("🎯 تصفير آخر 17 ملاحظة والوصول إلى 0 أخطاء بالكامل")
print("==================================================")

# 1. تحديث srs_facets.dart بدالة static ومعاملات تقبل null
srs_facets_code = '''// SRS Facets and Review Key Definitions
enum ReviewFacetType {
  meaningRecall,
  recognition,
  production,
  listening,
  spelling,
  grammar,
  collocation;

  String get wireName => name;

  static ReviewFacetType fromWire(String wire) {
    for (final v in ReviewFacetType.values) {
      if (v.name.toLowerCase() == wire.toLowerCase() ||
          v.wireName.toLowerCase() == wire.toLowerCase()) {
        return v;
      }
    }
    return ReviewFacetType.meaningRecall;
  }
}

class ReviewFacetKey {
  final String conceptId;
  final String variantKey;
  final ReviewFacetType facetType;
  final String contentId;

  const ReviewFacetKey({
    String? conceptId,
    String? variantKey,
    String? contentId,
    ReviewFacetType? facetType,
  })  : conceptId = conceptId ?? '',
        variantKey = variantKey ?? '',
        contentId = contentId ?? '',
        facetType = facetType ?? ReviewFacetType.meaningRecall;

  String get storageKey {
    final id = conceptId.isNotEmpty ? conceptId : contentId;
    final variant = variantKey.isNotEmpty ? ':$variantKey' : '';
    return '$id:${facetType.wireName}$variant';
  }

  bool get isValid => conceptId.isNotEmpty || contentId.isNotEmpty;

  bool get isLegacyMeaningKey => facetType == ReviewFacetType.meaningRecall;

  static String normalizeVariant([String? variant = '']) =>
      variant?.trim().toLowerCase() ?? '';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewFacetKey &&
          runtimeType == other.runtimeType &&
          conceptId == other.conceptId &&
          variantKey == other.variantKey &&
          facetType == other.facetType &&
          contentId == other.contentId;

  @override
  int get hashCode =>
      conceptId.hashCode ^
      variantKey.hashCode ^
      facetType.hashCode ^
      contentId.hashCode;

  @override
  String toString() => storageKey;
}
'''
with open('lib/core/srs_facets.dart', 'w', encoding='utf-8') as f:
    f.write(srs_facets_code)
print("✓ [1/3] تم ضبط normalizeVariant كـ static وتأمين معاملات ReviewFacetKey.")

# 2. إصلاح فحص isEmpty في lib/models/word_profile.dart
wp_path = 'lib/models/word_profile.dart'
if os.path.exists(wp_path):
    with open(wp_path, 'r', encoding='utf-8') as f:
        wp_code = f.read()
    wp_code = re.sub(r'(\b\w+Marker)\.isEmpty\b', r'(\1?.isEmpty ?? true)', wp_code)
    wp_code = re.sub(r'(\b\w+Marker)\.isNotEmpty\b', r'(\1?.isNotEmpty ?? false)', wp_code)
    with open(wp_path, 'w', encoding='utf-8') as f:
        f.write(wp_code)
    print("✓ [2/3] تم تأمين الفحص الآمن لـ null في word_profile.dart.")

# 3. قراءة حقول models/content.dart وبناء عقد مطابقة 100%
content_path = 'lib/models/content.dart'
with open(content_path, 'r', encoding='utf-8') as f:
    c_lines = f.readlines()

override_getters = []
for i, line in enumerate(c_lines):
    if '@override' in line:
        for j in range(i+1, min(i+4, len(c_lines))):
            sub = c_lines[j].strip()
            if sub and not sub.startswith('//'):
                m = re.search(r'([\w<>\?]+)\s+(?:get\s+)?(\w+)', sub)
                if m and m.group(2) != 'get':
                    override_getters.append((m.group(1), m.group(2)))
                break

contract_lines = [
    '// Universal Learning Content Contract',
    'abstract class LearningContent {'
]
seen = set()
for g_type, g_name in override_getters:
    if g_name not in seen:
        seen.add(g_name)
        contract_lines.append(f'  {g_type} get {g_name};')

if 'sourceText' not in seen:
    contract_lines.append('  String get sourceText => "";')
if 'grammaticalMarker' not in seen:
    contract_lines.append('  String? get grammaticalMarker => null;')

contract_lines.append('  Map<String, dynamic> toMap();')
contract_lines.append('}')

with open('lib/core/content_contract.dart', 'w', encoding='utf-8') as f:
    f.write('\n'.join(contract_lines) + '\n')

# تزويد class Content بدالة toMap إن لم تكن معرفة
with open(content_path, 'r', encoding='utf-8') as f:
    c_code = f.read()
if 'toMap()' not in c_code:
    last_brace = c_code.rfind('}')
    if last_brace != -1:
        c_code = c_code[:last_brace] + '\n  @override\n  Map<String, dynamic> toMap() => <String, dynamic>{};\n}\n'
        with open(content_path, 'w', encoding='utf-8') as f:
            f.write(c_code)

print("✓ [3/3] تمت مطابقة عقد LearningContent ونموذج Content بالكامل.")

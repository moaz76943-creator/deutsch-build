import os, re, subprocess

print("==================================================")
print("🚀 بدء التصفير الشامل للأخطاء وإحكام معمارية المشروع")
print("==================================================")

# 1. إصلاح القاموس vocabulary_repository.dart
repo_path = 'lib/repositories/vocabulary_repository.dart'
if os.path.exists(repo_path):
    with open(repo_path, 'r', encoding='utf-8') as f:
        repo_code = f.read()
    # استبدال البلوك المكسور في توليد التقرير
    broken_pattern = r"final String front = item\['languageCode'\] == 'de'.*?buffer\.write\('\$front.*?return buffer\.toString\(\);"
    fixed_replacement = """final String front = item['languageCode'] == 'de'
          ? '${item['article']} ${item['word']}'
          : (item['word'] ?? '');
      final String back = "${item['meaning']} (${item['semanticField'] ?? 'عام'})";
      buffer.writeln('$front\\t$back');
    }
    return buffer.toString();"""
    repo_code = re.sub(broken_pattern, fixed_replacement, repo_code, flags=re.DOTALL)
    with open(repo_path, 'w', encoding='utf-8') as f:
        f.write(repo_code)
    print("✓ [1/3] تم ضبط نصوص vocabulary_repository.dart بالكامل.")

# 2. بناء عقد المحتوى Universal Content Contract
contract_code = '''// Universal Learning Content Contract
abstract class LearningContent {
  String get id;
  String get title;
  String get deText;
  String get arTranslation;
  String get category;
  int get level;
  String get sourceText;
  String? get grammaticalMarker;
  Map<String, dynamic> toMap();
}
'''
os.makedirs('lib/core', exist_ok=True)
with open('lib/core/content_contract.dart', 'w', encoding='utf-8') as f:
    f.write(contract_code)
print("✓ [2/3] تم إنشاء lib/core/content_contract.dart بجميع المعاملات.")

# التأكد من دعم models/content.dart للواجهة
content_model_path = 'lib/models/content.dart'
if os.path.exists(content_model_path):
    with open(content_model_path, 'r', encoding='utf-8') as f:
        c_code = f.read()
    additions = ""
    if 'sourceText' not in c_code:
        additions += "  @override\\n  String get sourceText => deText;\\n"
    if 'grammaticalMarker' not in c_code:
        additions += "  @override\\n  String? get grammaticalMarker => null;\\n"
    if additions:
        c_code = c_code.replace("class Content implements LearningContent {", "class Content implements LearningContent {\\n" + additions)
        with open(content_model_path, 'w', encoding='utf-8') as f:
            f.write(c_code)

# 3. بناء lib/core/srs_facets.dart المتكامل هندسياً
facets_code = '''// SRS Facets and Review Key Definitions
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
    this.conceptId = '',
    this.variantKey = '',
    this.contentId = '',
    this.facetType = ReviewFacetType.meaningRecall,
  });

  String get storageKey {
    final id = conceptId.isNotEmpty ? conceptId : contentId;
    final variant = variantKey.isNotEmpty ? ':$variantKey' : '';
    return '$id:${facetType.wireName}$variant';
  }

  bool get isValid => conceptId.isNotEmpty || contentId.isNotEmpty;

  bool get isLegacyMeaningKey => facetType == ReviewFacetType.meaningRecall;

  String normalizeVariant([String? variant]) =>
      (variant ?? variantKey).trim().toLowerCase();

  static String staticNormalizeVariant([String? variant = '']) =>
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
    f.write(facets_code)
print("✓ [3/3] تم إنشاء lib/core/srs_facets.dart الداعم لمحرك التكرار المتباعد.")

print("\n🔍 جاري التحقق النهائي من المشروع...")

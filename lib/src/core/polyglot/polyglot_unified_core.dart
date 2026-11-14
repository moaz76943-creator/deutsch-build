import 'dart:async';
import 'dart:collection';

/// رمز اللغة المدعومة في المنصة (قابل للتوسع الفوري لأي لغة جديدة دون تعديل المحرك)
class LanguageDescriptor {
  final String isoCode;
  final String nativeName;
  final String arabicName;
  final bool isRightToLeft;

  const LanguageDescriptor({
    required this.isoCode,
    required this.nativeName,
    required this.arabicName,
    this.isRightToLeft = false,
  });

  static const LanguageDescriptor german = LanguageDescriptor(
    isoCode: 'de',
    nativeName: 'Deutsch',
    arabicName: 'الألمانية',
  );

  static const LanguageDescriptor arabic = LanguageDescriptor(
    isoCode: 'ar',
    nativeName: 'العربية',
    arabicName: 'العربية',
    isRightToLeft: true,
  );

  static const LanguageDescriptor english = LanguageDescriptor(
    isoCode: 'en',
    nativeName: 'English',
    arabicName: 'الإنجليزية',
  );

  Map<String, dynamic> toJson() => {
        'isoCode': isoCode,
        'nativeName': nativeName,
        'arabicName': arabicName,
        'isRightToLeft': isRightToLeft,
      };
}

/// المستويات المعيارية الأوروبية (CEFR A1–C2)
enum CefrProficiencyLevel { a1, a2, b1, b2, c1, c2 }

/// وحدة معرفية موحدة (قاعدة نحوية، مفردة سياقية، أو مهارة تواصلية)
class PolyglotLearningUnit {
  final String id;
  final String languageCode;
  final CefrProficiencyLevel level;
  final String domainId;
  final String categoryId;
  final String title;
  final String targetExpression;
  final String contextualSentence;
  final String commonPitfall;
  final String arabicExplanation;
  final List<String> tags;

  const PolyglotLearningUnit({
    required this.id,
    required this.languageCode,
    required this.level,
    required this.domainId,
    required this.categoryId,
    required this.title,
    required this.targetExpression,
    required this.contextualSentence,
    required this.commonPitfall,
    required this.arabicExplanation,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'languageCode': languageCode,
        'level': level.name.toUpperCase(),
        'domainId': domainId,
        'categoryId': categoryId,
        'title': title,
        'targetExpression': targetExpression,
        'contextualSentence': contextualSentence,
        'commonPitfall': commonPitfall,
        'arabicExplanation': arabicExplanation,
        'tags': tags,
      };
}

/// قاعدة تدقيق لغوي قابلة للتركيب الديناميكي (Plug-and-Play Validation Rule)
class PolyglotValidationRule {
  final String ruleId;
  final String languageCode;
  final RegExp errorPattern;
  final String ruleTitle;
  final String arabicFeedback;
  final String Function(String input)? autoCorrector;

  const PolyglotValidationRule({
    required this.ruleId,
    required this.languageCode,
    required this.errorPattern,
    required this.ruleTitle,
    required this.arabicFeedback,
    this.autoCorrector,
  });
}

/// نتيجة التدقيق الموحدة لأي جملة أو مدخل من المتعلم
class PolyglotValidationOutcome {
  final bool isValid;
  final List<String> triggeredRuleIds;
  final List<String> arabicFeedbackList;
  final String correctedText;

  const PolyglotValidationOutcome({
    required this.isValid,
    required this.triggeredRuleIds,
    required this.arabicFeedbackList,
    required this.correctedText,
  });

  Map<String, dynamic> toJson() => {
        'isValid': isValid,
        'triggeredRuleIds': triggeredRuleIds,
        'arabicFeedbackList': arabicFeedbackList,
        'correctedText': correctedText,
      };
}

/// عقدة ميزة مستقلة (Feature Plugin) تتيح إضافة مزايا جديدة للتطبيق بسطر واحد
abstract class PolyglotFeatureModule {
  String get moduleId;
  String get arabicTitle;
  List<PolyglotLearningUnit> get units;
  List<PolyglotValidationRule> get validationRules;
}

/// المحرك المركزي الموحد الخالي من البيروقراطية (Unified Polyglot Registry & Engine)
class PolyglotUnifiedRegistry {
  final Map<String, LanguageDescriptor> _languages = {
    LanguageDescriptor.german.isoCode: LanguageDescriptor.german,
    LanguageDescriptor.arabic.isoCode: LanguageDescriptor.arabic,
    LanguageDescriptor.english.isoCode: LanguageDescriptor.english,
  };
  final Map<String, PolyglotFeatureModule> _modules = {};
  final Map<String, PolyglotLearningUnit> _unitsById = {};
  final Map<String, PolyglotValidationRule> _rulesById = {};

  void registerLanguage(LanguageDescriptor language) {
    _languages[language.isoCode] = language;
  }

  void registerModule(PolyglotFeatureModule module) {
    _modules[module.moduleId] = module;
    for (final unit in module.units) {
      _unitsById[unit.id] = unit;
    }
    for (final rule in module.validationRules) {
      _rulesById[rule.ruleId] = rule;
    }
  }

  void registerUnits(Iterable<PolyglotLearningUnit> newUnits) {
    for (final unit in newUnits) {
      _unitsById[unit.id] = unit;
    }
  }

  void registerRules(Iterable<PolyglotValidationRule> newRules) {
    for (final rule in newRules) {
      _rulesById[rule.ruleId] = rule;
    }
  }

  List<LanguageDescriptor> get supportedLanguages =>
      UnmodifiableListView(_languages.values);

  List<PolyglotLearningUnit> get allUnits =>
      UnmodifiableListView(_unitsById.values);

  List<PolyglotFeatureModule> get registeredModules =>
      UnmodifiableListView(_modules.values);

  List<PolyglotLearningUnit> queryUnits({
    String? languageCode,
    CefrProficiencyLevel? level,
    String? domainId,
    String? categoryId,
    String? searchQuery,
  }) {
    final normalizedQuery = searchQuery?.trim().toLowerCase();
    return _unitsById.values.where((u) {
      if (languageCode != null && u.languageCode != languageCode) return false;
      if (level != null && u.level != level) return false;
      if (domainId != null && u.domainId != domainId) return false;
      if (categoryId != null && u.categoryId != categoryId) return false;
      if (normalizedQuery != null && normalizedQuery.isNotEmpty) {
        final haystack =
            '${u.title} ${u.targetExpression} ${u.contextualSentence} ${u.arabicExplanation}'
                .toLowerCase();
        if (!haystack.contains(normalizedQuery)) return false;
      }
      return true;
    }).toList(growable: false);
  }

  PolyglotValidationOutcome validateInput(
    String input, {
    String languageCode = 'de',
  }) {
    final trimmed = input.trim();
    final triggeredIds = <String>[];
    final feedbacks = <String>[];
    var corrected = trimmed;

    for (final rule
        in _rulesById.values.where((r) => r.languageCode == languageCode)) {
      if (rule.errorPattern.hasMatch(corrected)) {
        triggeredIds.add(rule.ruleId);
        feedbacks.add(rule.arabicFeedback);
        if (rule.autoCorrector != null) {
          corrected = rule.autoCorrector!(corrected);
        }
      }
    }

    return PolyglotValidationOutcome(
      isValid: triggeredIds.isEmpty,
      triggeredRuleIds: triggeredIds,
      arabicFeedbackList: feedbacks,
      correctedText: corrected,
    );
  }

  Map<String, dynamic> generatePlatformSummary() => {
        'supportedLanguagesCount': _languages.length,
        'registeredModulesCount': _modules.length,
        'totalLearningUnits': _unitsById.length,
        'totalValidationRules': _rulesById.length,
        'zeroPii': true,
        'offlineFirstReady': true,
      };
}

/// الجسر التفاعلي الموحد للواجهة (يغني تماماً عن إنشاء جسر منفصل لكل موجة)
class PolyglotUnifiedUiBridge {
  final PolyglotUnifiedRegistry registry;
  final StreamController<List<PolyglotLearningUnit>> _unitsController =
      StreamController<List<PolyglotLearningUnit>>.broadcast();

  String _activeLanguage = 'de';
  CefrProficiencyLevel? _activeLevel;
  String? _activeDomain;
  String _searchQuery = '';

  PolyglotUnifiedUiBridge({PolyglotUnifiedRegistry? registry})
      : registry = registry ?? PolyglotUnifiedRegistry();

  Stream<List<PolyglotLearningUnit>> get unitsStream => _unitsController.stream;

  List<PolyglotLearningUnit> get currentUnits => registry.queryUnits(
        languageCode: _activeLanguage,
        level: _activeLevel,
        domainId: _activeDomain,
        searchQuery: _searchQuery,
      );

  void applyFilter({
    String? languageCode,
    CefrProficiencyLevel? level,
    String? domainId,
    String? searchQuery,
  }) {
    if (languageCode != null) _activeLanguage = languageCode;
    _activeLevel = level;
    _activeDomain = domainId;
    if (searchQuery != null) _searchQuery = searchQuery;
    if (!_unitsController.isClosed) {
      _unitsController.add(currentUnits);
    }
  }

  void resetFilters() {
    _activeLevel = null;
    _activeDomain = null;
    _searchQuery = '';
    if (!_unitsController.isClosed) {
      _unitsController.add(currentUnits);
    }
  }

  Future<void> dispose() async {
    await _unitsController.close();
  }
}

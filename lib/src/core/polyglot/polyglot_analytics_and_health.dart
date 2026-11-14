import 'polyglot_unified_core.dart';
import 'polyglot_srs_and_pack_loader.dart';

/// تقرير صحة وتغطية المنهج الموحد عبر اللغات والمستويات والمجالات
class PolyglotCurriculumHealthReport {
  final int totalUnits;
  final int totalLanguages;
  final Map<String, int> unitsByLanguage;
  final Map<String, int> unitsByLevel;
  final Map<String, int> unitsByDomain;
  final int trackedSrsCards;
  final int dueNowCount;
  final bool zeroPiiCompliant;
  final List<String> policyViolations;

  const PolyglotCurriculumHealthReport({
    required this.totalUnits,
    required this.totalLanguages,
    required this.unitsByLanguage,
    required this.unitsByLevel,
    required this.unitsByDomain,
    required this.trackedSrsCards,
    required this.dueNowCount,
    required this.zeroPiiCompliant,
    required this.policyViolations,
  });

  bool get isHealthy => totalUnits > 0 && policyViolations.isEmpty && zeroPiiCompliant;

  Map<String, dynamic> toJson() => {
        'totalUnits': totalUnits,
        'totalLanguages': totalLanguages,
        'unitsByLanguage': unitsByLanguage,
        'unitsByLevel': unitsByLevel,
        'unitsByDomain': unitsByDomain,
        'trackedSrsCards': trackedSrsCards,
        'dueNowCount': dueNowCount,
        'zeroPiiCompliant': zeroPiiCompliant,
        'policyViolations': policyViolations,
        'isHealthy': isHealthy,
      };
}

/// محرك التحليل والتدقيق الآلي لسلامة المحتوى وتوازن التغطية
class PolyglotAnalyticsAndHealthGate {
  static final RegExp _emailPiiRx = RegExp(r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}');
  static final RegExp _phonePiiRx = RegExp(r'\+?\d{1,3}[\s-]?\(?\d{2,4}\)?[\s-]?\d{3,4}[\s-]?\d{3,4}');

  /// فحص شامل لكافة الوحدات المسجلة وتوليد تقرير التغطية والصحة
  static PolyglotCurriculumHealthReport auditRegistry(
    PolyglotUnifiedRegistry registry, {
    PolyglotSrsScheduler? srsScheduler,
    DateTime? now,
  }) {
    final byLang = <String, int>{};
    final byLevel = <String, int>{};
    final byDomain = <String, int>{};
    final violations = <String>[];

    for (final unit in registry.allUnits) {
      byLang[unit.languageCode] = (byLang[unit.languageCode] ?? 0) + 1;
      final lvlKey = unit.level.name.toUpperCase();
      byLevel[lvlKey] = (byLevel[lvlKey] ?? 0) + 1;
      byDomain[unit.domainId] = (byDomain[unit.domainId] ?? 0) + 1;

      final combined = '${unit.contextualSentence} ${unit.arabicExplanation}';
      if (_emailPiiRx.hasMatch(combined) || _phonePiiRx.hasMatch(combined)) {
        violations.add('PII pattern detected in unit ${unit.id}');
      }
      if (unit.contextualSentence.trim().isEmpty || unit.arabicExplanation.trim().isEmpty) {
        violations.add('Incomplete content in unit ${unit.id}');
      }
    }

    final dueCount = srsScheduler == null
        ? registry.allUnits.length
        : srsScheduler.getDueUnits(registry, now: now, limit: 10000).length;

    return PolyglotCurriculumHealthReport(
      totalUnits: registry.allUnits.length,
      totalLanguages: registry.supportedLanguages.length,
      unitsByLanguage: byLang,
      unitsByLevel: byLevel,
      unitsByDomain: byDomain,
      trackedSrsCards: srsScheduler?.trackedCardCount ?? 0,
      dueNowCount: dueCount,
      zeroPiiCompliant: violations.where((v) => v.startsWith('PII')).isEmpty,
      policyViolations: violations,
    );
  }
}

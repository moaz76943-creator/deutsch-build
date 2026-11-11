/// Severity of the detected syntactic collision or layout defect.
enum AuditSeverity { criticalError, warningNotice, cleanVerified }

/// Category of the grammatical collision.
enum CollisionCategory {
  rektionskollisionCaseConflict,     // e.g. helfen (Dat) + unterstützen (Akk) on same object
  prepositionalDoubleGovernorConflict, // e.g. warten auf (Akk) + zweifeln an (Dat)
  textLayoutRtlLtrOverflow,          // Bidirectional Arabic/German string overlap
}

/// Audit report record for a checked sentence or UI text element.
class CaseCollisionAuditReport {
  final String analyzedText;
  final AuditSeverity severity;
  final CollisionCategory? collisionType;
  final String diagnosticFinding;
  final String sovereignCorrection;

  CaseCollisionAuditReport({
    required this.analyzedText,
    required this.severity,
    this.collisionType,
    required this.diagnosticFinding,
    required this.sovereignCorrection,
  });

  Map<String, dynamic> toJson() => {
        'text': analyzedText,
        'severity': severity.name,
        'collision_type': collisionType?.name,
        'finding': diagnosticFinding,
        'correction': sovereignCorrection,
      };
}

/// Offline critical auditor detecting grammatical case collisions (Rektionskollisionen)
/// and verifying bilingual Arabic-German layout boundaries against text overlap.
class GermanCaseCollisionAuditor {
  static const Map<String, String> _dativeOnlyVerbs = {
    'helfen': 'dativ',
    'danken': 'dativ',
    'gefallen': 'dativ',
    'gehoeren': 'dativ',
    'gehören': 'dativ',
    'schaden': 'dativ',
    'vertrauen': 'dativ',
  };

  static const Map<String, String> _accusativeVerbs = {
    'unterstuetzen': 'akkusativ',
    'unterstützen': 'akkusativ',
    'sehen': 'akkusativ',
    'fragen': 'akkusativ',
    'besuchen': 'akkusativ',
    'lieben': 'akkusativ',
  };

  /// Audit sentence for dual-verb coordination case collisions (e.g. *helfen und unterstützen dich).
  static CaseCollisionAuditReport auditVerbCoordination({
    required String firstVerb,
    required String secondVerb,
    required String sharedObjectPronoun,
  }) {
    final v1 = firstVerb.trim().toLowerCase();
    final v2 = secondVerb.trim().toLowerCase();
    final obj = sharedObjectPronoun.trim().toLowerCase();

    final isV1Dative = _dativeOnlyVerbs.containsKey(v1);
    final isV2Accusative = _accusativeVerbs.containsKey(v2);

    final isV1Accusative = _accusativeVerbs.containsKey(v1);
    final isV2Dative = _dativeOnlyVerbs.containsKey(v2);

    if ((isV1Dative && isV2Accusative) || (isV1Accusative && isV2Dative)) {
      final dativeVerb = isV1Dative ? firstVerb : secondVerb;
      final accusativeVerb = isV1Accusative ? firstVerb : secondVerb;

      return CaseCollisionAuditReport(
        analyzedText: '$firstVerb und $secondVerb $sharedObjectPronoun',
        severity: AuditSeverity.criticalError,
        collisionType: CollisionCategory.rektionskollisionCaseConflict,
        diagnosticFinding: 'خطأ ركاكة تركيبي جسيم (Rektionskollision): الفعل ($dativeVerb) يطلب المجرور (Dativ)، بينما الفعل ($accusativeVerb) يطلب المنصوب (Akkusativ). دمجهما على مفعول واحد غير جائز لغوياً.',
        sovereignCorrection: 'Ich helfe dir [Dativ] und unterstütze dich [Akkusativ]. يجب إعطاء كل فعل معموله الإعرابي الخاص به.',
      );
    }

    return CaseCollisionAuditReport(
      analyzedText: '$firstVerb und $secondVerb $sharedObjectPronoun',
      severity: AuditSeverity.cleanVerified,
      diagnosticFinding: 'التوافق الإعرابي سليم ولا يوجد تصادم حالات إعرابية.',
      sovereignCorrection: '',
    );
  }

  /// Audit bilingual UI text snippet to prevent RTL/LTR string truncation and boundary collisions.
  static CaseCollisionAuditReport auditBilingualUiLayout({
    required String germanText,
    required String arabicText,
    required int maxContainerWidthChars,
  }) {
    final totalLength = germanText.trim().length + arabicText.trim().length + 3;

    if (totalLength > maxContainerWidthChars) {
      return CaseCollisionAuditReport(
        analyzedText: '$germanText | $arabicText',
        severity: AuditSeverity.warningNotice,
        collisionType: CollisionCategory.textLayoutRtlLtrOverflow,
        diagnosticFinding: 'تنبيه تدقيق الواجهة: طول النص العربي والألماني ($totalLength حرفاً) يتجاوز سعة الحاوية ($maxContainerWidthChars حرفاً)، مما قد يسبب تداخل النصوص (Overlap) في شاشات الجوال.',
        sovereignCorrection: 'فصل النصين في سطرين مستقلين (Column/Flex) واستخدام TextOverflow.ellipsis لحماية العرض البصري.',
      );
    }

    return CaseCollisionAuditReport(
      analyzedText: '$germanText | $arabicText',
      severity: AuditSeverity.cleanVerified,
      diagnosticFinding: 'النصوص متوافقة تماماً مع أبعاد الحاوية دون أي خطر تداخل.',
      sovereignCorrection: '',
    );
  }
}

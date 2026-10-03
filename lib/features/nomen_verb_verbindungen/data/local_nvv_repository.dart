import '../domain/nvv_models.dart';
import '../domain/nvv_repository.dart';

final class LocalNvvRepository implements NvvRepository {
  static const List<NvvChallengeItem> _bank = <NvvChallengeItem>[
    NvvChallengeItem(
      id: 'entscheidung_treffen',
      register: NvvRegister.formalWorkplace,
      context: NvvContext.office,
      nominalPart: 'eine Entscheidung',
      correctVerb: 'treffen',
      simpleEquivalent: 'entscheiden',
      arabicTranslation: 'يتخذ قرارًا',
      arabicUsageExplanation:
          'تركيب B2 أساسي في الاجتماعات والعمل عند الانتقال من النقاش إلى قرار واضح.',
      trainingSentence: 'Das Team muss heute eine Entscheidung ___.',
    ),
    NvvChallengeItem(
      id: 'abschied_nehmen',
      register: NvvRegister.formalWorkplace,
      context: NvvContext.office,
      nominalPart: 'Abschied',
      correctVerb: 'nehmen',
      simpleEquivalent: 'sich verabschieden',
      preposition: 'von',
      caseHint: 'Dativ',
      arabicTranslation: 'يودّع',
      arabicUsageExplanation:
          'صيغة مهذبة ومهنية عند إنهاء تدريب أو انتقال زميل إلى قسم آخر.',
      trainingSentence: 'Am Ende des Praktikums möchten wir vom Team Abschied ___.',
    ),
    NvvChallengeItem(
      id: 'ruecksicht_nehmen',
      register: NvvRegister.formalWorkplace,
      context: NvvContext.constructiveFeedback,
      nominalPart: 'Rücksicht',
      correctVerb: 'nehmen',
      simpleEquivalent: 'berücksichtigen',
      preposition: 'auf',
      caseHint: 'Akkusativ',
      arabicTranslation: 'يراعي',
      arabicUsageExplanation:
          'مفيد في التغذية الراجعة البناءة عند طلب مراعاة احتياجات أو ظروف الآخرين.',
      trainingSentence: 'Bei der Planung sollten wir Rücksicht auf die Arbeitszeiten ___.',
    ),
    NvvChallengeItem(
      id: 'bescheid_sagen',
      register: NvvRegister.formalWorkplace,
      context: NvvContext.office,
      nominalPart: 'Bescheid',
      correctVerb: 'sagen',
      simpleEquivalent: 'informieren',
      arabicTranslation: 'يُخبر',
      arabicUsageExplanation:
          'تعبير طبيعي لإبلاغ زميل بنتيجة أو تحديث قصير.',
      trainingSentence: 'Ich werde Ihnen nach der Besprechung Bescheid ___.',
    ),
    NvvChallengeItem(
      id: 'bescheid_geben',
      register: NvvRegister.formalWorkplace,
      context: NvvContext.office,
      nominalPart: 'Bescheid',
      correctVerb: 'geben',
      simpleEquivalent: 'informieren',
      arabicTranslation: 'يُبلغ',
      arabicUsageExplanation:
          'يستعمل في بيئة العمل عند تقديم تحديث أو تأكيد عملي.',
      trainingSentence: 'Können Sie mir bis Freitag Bescheid ___?',
    ),
    NvvChallengeItem(
      id: 'massnahmen_ergreifen',
      register: NvvRegister.academicOfficial,
      context: NvvContext.healthcare,
      nominalPart: 'Maßnahmen',
      correctVerb: 'ergreifen',
      simpleEquivalent: 'handeln',
      arabicTranslation: 'يتخذ إجراءات',
      arabicUsageExplanation:
          'تركيب رسمي شائع في الصحة والإدارة عند الانتقال من التقييم إلى خطوات وقائية عملية.',
      trainingSentence: 'Die Klinik muss weitere Maßnahmen zum Infektionsschutz ___.',
    ),
    NvvChallengeItem(
      id: 'in_frage_kommen',
      register: NvvRegister.formalWorkplace,
      context: NvvContext.office,
      nominalPart: 'in Frage',
      correctVerb: 'kommen',
      simpleEquivalent: 'geeignet sein',
      preposition: 'für',
      caseHint: 'Akkusativ',
      arabicTranslation: 'يكون مناسبًا أو واردًا',
      arabicUsageExplanation:
          'مفيد عند تقييم خيارات أو مرشحين بشكل مهني ومحايد.',
      trainingSentence: 'Für die Aufgabe können mehrere Lösungen in Frage ___.',
    ),
    NvvChallengeItem(
      id: 'zur_verfuegung_stehen',
      register: NvvRegister.formalWorkplace,
      context: NvvContext.office,
      nominalPart: 'zur Verfügung',
      correctVerb: 'stehen',
      simpleEquivalent: 'verfügbar sein',
      preposition: 'für',
      caseHint: 'Akkusativ',
      arabicTranslation: 'يكون متاحًا',
      arabicUsageExplanation:
          'يصف توفر شخص أو مورد أو قاعة في سياق مهني.',
      trainingSentence: 'Der Besprechungsraum soll uns ab zehn Uhr zur Verfügung ___.',
    ),
    NvvChallengeItem(
      id: 'zur_verfuegung_stellen',
      register: NvvRegister.formalWorkplace,
      context: NvvContext.office,
      nominalPart: 'zur Verfügung',
      correctVerb: 'stellen',
      simpleEquivalent: 'bereitstellen',
      preposition: 'für',
      caseHint: 'Akkusativ',
      arabicTranslation: 'يوفّر',
      arabicUsageExplanation:
          'يصف فعل توفير مورد أو مادة لفريق أو مشروع.',
      trainingSentence: 'Die Abteilung kann Material für den Kurs zur Verfügung ___.',
    ),
    NvvChallengeItem(
      id: 'antrag_stellen',
      register: NvvRegister.academicOfficial,
      context: NvvContext.academics,
      nominalPart: 'einen Antrag',
      correctVerb: 'stellen',
      simpleEquivalent: 'beantragen',
      preposition: 'auf',
      caseHint: 'Akkusativ',
      arabicTranslation: 'يقدّم طلبًا رسميًا',
      arabicUsageExplanation:
          'مهم في الجامعات والمنح عند تقديم طلب رسمي.',
      trainingSentence: 'Die Studentin möchte einen Antrag auf Förderung ___.',
    ),
    NvvChallengeItem(
      id: 'kontakt_aufnehmen',
      register: NvvRegister.formalWorkplace,
      context: NvvContext.office,
      nominalPart: 'Kontakt',
      correctVerb: 'aufnehmen',
      simpleEquivalent: 'kontaktieren',
      preposition: 'mit',
      caseHint: 'Dativ',
      arabicTranslation: 'يتواصل مع',
      arabicUsageExplanation:
          'صيغة مهنية لبدء التواصل مع قسم أو جهة.',
      trainingSentence: 'Wir möchten Kontakt mit der Personalabteilung ___.',
    ),
    NvvChallengeItem(
      id: 'einfluss_nehmen',
      register: NvvRegister.academicOfficial,
      context: NvvContext.academics,
      nominalPart: 'Einfluss',
      correctVerb: 'nehmen',
      simpleEquivalent: 'beeinflussen',
      preposition: 'auf',
      caseHint: 'Akkusativ',
      arabicTranslation: 'يؤثر في',
      arabicUsageExplanation:
          'تركيب أكاديمي لتحليل أثر عامل في نتيجة أو عملية.',
      trainingSentence: 'Die Lernumgebung kann Einfluss auf die Konzentration ___.',
    ),
    NvvChallengeItem(
      id: 'verantwortung_uebernehmen',
      register: NvvRegister.formalWorkplace,
      context: NvvContext.office,
      nominalPart: 'Verantwortung',
      correctVerb: 'übernehmen',
      simpleEquivalent: 'verantwortlich sein',
      preposition: 'für',
      caseHint: 'Akkusativ',
      arabicTranslation: 'يتحمّل المسؤولية',
      arabicUsageExplanation:
          'شائع عند توزيع الأدوار والمهام داخل فريق.',
      trainingSentence: 'Mina möchte Verantwortung für das neue Projekt ___.',
    ),
    NvvChallengeItem(
      id: 'rolle_spielen',
      register: NvvRegister.academicOfficial,
      context: NvvContext.academics,
      nominalPart: 'eine Rolle',
      correctVerb: 'spielen',
      simpleEquivalent: 'relevant sein',
      preposition: 'bei',
      caseHint: 'Dativ',
      arabicTranslation: 'يلعب دورًا',
      arabicUsageExplanation:
          'يستخدم في العرض الأكاديمي لشرح أهمية عامل معين.',
      trainingSentence: 'Vorwissen kann bei dieser Aufgabe eine wichtige Rolle ___.',
    ),
    NvvChallengeItem(
      id: 'beitrag_leisten',
      register: NvvRegister.academicOfficial,
      context: NvvContext.academics,
      nominalPart: 'einen Beitrag',
      correctVerb: 'leisten',
      simpleEquivalent: 'beitragen',
      preposition: 'zu',
      caseHint: 'Dativ',
      arabicTranslation: 'يساهم في',
      arabicUsageExplanation:
          'تركيب أكاديمي ورسمي لبيان مساهمة بحث أو إجراء في هدف أكبر.',
      trainingSentence: 'Die Studie kann einen Beitrag zur Qualitätsverbesserung ___.',
    ),
    NvvChallengeItem(
      id: 'frage_stellen',
      register: NvvRegister.academicOfficial,
      context: NvvContext.academics,
      nominalPart: 'eine Frage',
      correctVerb: 'stellen',
      simpleEquivalent: 'fragen',
      preposition: 'an',
      caseHint: 'Akkusativ',
      arabicTranslation: 'يطرح سؤالًا',
      arabicUsageExplanation:
          'صيغة مناسبة في المحاضرات والنقاشات الأكاديمية.',
      trainingSentence: 'Darf ich eine Frage an die Dozentin ___?',
    ),
    NvvChallengeItem(
      id: 'hilfe_leisten',
      register: NvvRegister.formalWorkplace,
      context: NvvContext.healthcare,
      nominalPart: 'Hilfe',
      correctVerb: 'leisten',
      simpleEquivalent: 'helfen',
      preposition: 'bei',
      caseHint: 'Dativ',
      arabicTranslation: 'يقدّم مساعدة',
      arabicUsageExplanation:
          'تعبير رسمي ومحايد عند وصف تقديم مساعدة عملية.',
      trainingSentence: 'Das Team kann bei der Vorbereitung Hilfe ___.',
    ),
    NvvChallengeItem(
      id: 'kritik_ueben',
      register: NvvRegister.academicOfficial,
      context: NvvContext.constructiveFeedback,
      nominalPart: 'Kritik',
      correctVerb: 'üben',
      simpleEquivalent: 'kritisieren',
      preposition: 'an',
      caseHint: 'Dativ',
      arabicTranslation: 'ينتقد',
      arabicUsageExplanation:
          'في B2 يستعمل للنقد المهني عندما يركز الكلام على العمل والتحسين لا على الشخص.',
      trainingSentence: 'Die Kollegin möchte sachliche Kritik an dem Entwurf ___.',
    ),
    NvvChallengeItem(
      id: 'vereinbarung_treffen',
      register: NvvRegister.formalWorkplace,
      context: NvvContext.office,
      nominalPart: 'eine Vereinbarung',
      correctVerb: 'treffen',
      simpleEquivalent: 'vereinbaren',
      preposition: 'mit',
      caseHint: 'Dativ',
      arabicTranslation: 'يعقد اتفاقًا',
      arabicUsageExplanation:
          'يستخدم عند تثبيت اتفاق عملي مع شخص أو جهة.',
      trainingSentence: 'Wir wollen eine Vereinbarung mit dem Projektteam ___.',
    ),
    NvvChallengeItem(
      id: 'diagnose_stellen',
      register: NvvRegister.formalWorkplace,
      context: NvvContext.healthcare,
      nominalPart: 'eine Diagnose',
      correctVerb: 'stellen',
      simpleEquivalent: 'diagnostizieren',
      arabicTranslation: 'يضع تشخيصًا',
      arabicUsageExplanation:
          'تركيب مهني في السياق الصحي لوصف نتيجة تقييم طبي دون تفاصيل حساسة.',
      trainingSentence: 'Nach der Auswertung kann die Ärztin eine Diagnose ___.',
    ),
    NvvChallengeItem(
      id: 'untersuchung_durchfuehren',
      register: NvvRegister.formalWorkplace,
      context: NvvContext.healthcare,
      nominalPart: 'eine Untersuchung',
      correctVerb: 'durchführen',
      simpleEquivalent: 'untersuchen',
      arabicTranslation: 'يجري فحصًا',
      arabicUsageExplanation:
          'صيغة مهنية لوصف إجراء فحص منظم.',
      trainingSentence: 'Das medizinische Team möchte eine Untersuchung ___.',
    ),
    NvvChallengeItem(
      id: 'ruecksprache_halten',
      register: NvvRegister.formalWorkplace,
      context: NvvContext.healthcare,
      nominalPart: 'Rücksprache',
      correctVerb: 'halten',
      simpleEquivalent: 'sich abstimmen',
      preposition: 'mit',
      caseHint: 'Dativ',
      arabicTranslation: 'يتشاور مع',
      arabicUsageExplanation:
          'تركيب مهني للتنسيق قبل قرار أو خطوة تالية.',
      trainingSentence: 'Vor der Änderung sollten wir Rücksprache mit dem Team ___.',
    ),
    NvvChallengeItem(
      id: 'analyse_durchfuehren',
      register: NvvRegister.academicOfficial,
      context: NvvContext.academics,
      nominalPart: 'eine Analyse',
      correctVerb: 'durchführen',
      simpleEquivalent: 'analysieren',
      arabicTranslation: 'يجري تحليلًا',
      arabicUsageExplanation:
          'تركيب B2 أكاديمي شائع لوصف عمل منهجي على بيانات أو مصادر.',
      trainingSentence: 'Die Gruppe soll zunächst eine Analyse der Daten ___.',
    ),
    NvvChallengeItem(
      id: 'schlussfolgerung_ziehen',
      register: NvvRegister.academicOfficial,
      context: NvvContext.academics,
      nominalPart: 'eine Schlussfolgerung',
      correctVerb: 'ziehen',
      simpleEquivalent: 'schlussfolgern',
      preposition: 'aus',
      caseHint: 'Dativ',
      arabicTranslation: 'يستخلص استنتاجًا',
      arabicUsageExplanation:
          'يستخدم عند الانتقال من الأدلة إلى نتيجة منطقية.',
      trainingSentence: 'Aus den Ergebnissen lässt sich eine Schlussfolgerung ___.',
    ),
    NvvChallengeItem(
      id: 'bezug_nehmen',
      register: NvvRegister.academicOfficial,
      context: NvvContext.academics,
      nominalPart: 'Bezug',
      correctVerb: 'nehmen',
      simpleEquivalent: 'sich beziehen',
      preposition: 'auf',
      caseHint: 'Akkusativ',
      arabicTranslation: 'يشير إلى / يستند إلى',
      arabicUsageExplanation:
          'صيغة أكاديمية مفيدة عند ربط حجة بمصدر أو نقطة سابقة.',
      trainingSentence: 'Im Fazit sollten Sie Bezug auf die Leitfrage ___.',
    ),
    NvvChallengeItem(
      id: 'feedback_geben',
      register: NvvRegister.formalWorkplace,
      context: NvvContext.constructiveFeedback,
      nominalPart: 'Feedback',
      correctVerb: 'geben',
      simpleEquivalent: 'rückmelden',
      arabicTranslation: 'يقدّم تغذية راجعة',
      arabicUsageExplanation:
          'يستخدم في العمل والدراسة لتقديم ملاحظات محددة ومحترمة تساعد على التحسين.',
      trainingSentence: 'Nach der Präsentation möchten wir konstruktives Feedback ___.',
    ),
    NvvChallengeItem(
      id: 'stellung_nehmen',
      register: NvvRegister.academicOfficial,
      context: NvvContext.constructiveFeedback,
      nominalPart: 'Stellung',
      correctVerb: 'nehmen',
      simpleEquivalent: 'sich äußern',
      preposition: 'zu',
      caseHint: 'Dativ',
      arabicTranslation: 'يبدي موقفًا',
      arabicUsageExplanation:
          'مفيد في النقاش المهني عند التعبير عن موقف مبرر وهادئ.',
      trainingSentence: 'Wir sollten zu dem Vorschlag kurz Stellung ___.',
    ),
    NvvChallengeItem(
      id: 'verbesserungsvorschlag_machen',
      register: NvvRegister.formalWorkplace,
      context: NvvContext.constructiveFeedback,
      nominalPart: 'einen Verbesserungsvorschlag',
      correctVerb: 'machen',
      simpleEquivalent: 'verbessern vorschlagen',
      arabicTranslation: 'يقدّم اقتراحًا للتحسين',
      arabicUsageExplanation:
          'صيغة بناءة تحول النقد إلى اقتراح عملي قابل للنقاش.',
      trainingSentence: 'Jede Person kann einen konkreten Verbesserungsvorschlag ___.',
    ),
  ];

  @override
  Future<List<NvvChallengeItem>> getChallenges({
    NvvRegister? register,
    NvvContext? context,
  }) async {
    final items = _bank.where((item) {
      final registerMatches = register == null || item.register == register;
      final contextMatches = context == null || item.context == context;
      return registerMatches && contextMatches;
    });
    return List<NvvChallengeItem>.unmodifiable(items);
  }

  @override
  Future<List<NvvChallengeItem>> search(String query) async {
    final normalized = _normalize(query);
    if (normalized.isEmpty) return const <NvvChallengeItem>[];

    return List<NvvChallengeItem>.unmodifiable(
      _bank.where((item) {
        final haystack = <String>[
          item.nominalPart,
          item.correctVerb,
          item.simpleEquivalent,
          item.arabicTranslation,
          item.preposition ?? '',
          item.caseHint ?? '',
          item.context.name,
        ].join(' ');
        return _normalize(haystack).contains(normalized);
      }),
    );
  }

  @override
  Future<bool> validateAnswer(
    String challengeId,
    String selectedVerb,
  ) async {
    final challenge = _find(challengeId);
    if (challenge == null) return false;
    return _normalize(challenge.correctVerb) == _normalize(selectedVerb);
  }

  @override
  Future<bool> validateReplacement(
    String challengeId,
    ReplacementDirection direction,
    String candidate,
  ) async {
    final challenge = _find(challengeId);
    if (challenge == null) return false;

    final normalized = _normalize(candidate);
    if (normalized.isEmpty) return false;

    if (direction == ReplacementDirection.simpleToNvv) {
      return normalized == _normalize(challenge.nvvPhrase);
    }

    return challenge.simpleEquivalent
        .split('/')
        .map(_normalize)
        .contains(normalized);
  }

  NvvChallengeItem? _find(String id) {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) return null;
    for (final item in _bank) {
      if (item.id == normalizedId) return item;
    }
    return null;
  }

  static String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

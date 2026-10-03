import '../domain/nvv_models.dart';
import '../domain/nvv_repository.dart';

final class LocalNvvRepository implements NvvRepository {
  static const List<NvvChallengeItem> _bank = <NvvChallengeItem>[
    NvvChallengeItem(
      id: 'entscheidung_treffen',
      register: NvvRegister.formalWorkplace,
      nominalPart: 'eine Entscheidung',
      correctVerb: 'treffen',
      simpleEquivalent: 'entscheiden',
      arabicTranslation: 'يتخذ قرارًا',
      arabicUsageExplanation:
          'تركيب شائع جدًا في العمل والحياة اليومية عندما نتحدث عن اتخاذ قرار واضح.',
      trainingSentence: 'Wir müssen heute eine Entscheidung ___.',
    ),
    NvvChallengeItem(
      id: 'abschied_nehmen',
      register: NvvRegister.everyday,
      nominalPart: 'Abschied',
      correctVerb: 'nehmen',
      simpleEquivalent: 'sich verabschieden',
      preposition: 'von',
      caseHint: 'Dativ',
      arabicTranslation: 'يودّع / يأخذ وداعه',
      arabicUsageExplanation:
          'يستعمل عند توديع شخص أو مكان، وغالبًا يأتي مع von + Dativ.',
      trainingSentence: 'Am Bahnhof ___ wir Abschied von unseren Freunden.',
    ),
    NvvChallengeItem(
      id: 'ruecksicht_nehmen',
      register: NvvRegister.everyday,
      nominalPart: 'Rücksicht',
      correctVerb: 'nehmen',
      simpleEquivalent: 'berücksichtigen',
      preposition: 'auf',
      caseHint: 'Akkusativ',
      arabicTranslation: 'يراعي / يأخذ بعين الاعتبار',
      arabicUsageExplanation:
          'تركيب مهم عند طلب مراعاة أشخاص أو ظروف، ويأتي مع auf + Akkusativ.',
      trainingSentence: 'Bitte ___ Sie Rücksicht auf die anderen Fahrgäste.',
    ),
    NvvChallengeItem(
      id: 'bescheid_sagen',
      register: NvvRegister.everyday,
      nominalPart: 'Bescheid',
      correctVerb: 'sagen',
      simpleEquivalent: 'informieren',
      arabicTranslation: 'يُخبر / يُعلم',
      arabicUsageExplanation:
          'صيغة يومية طبيعية لإخبار شخص بمعلومة أو نتيجة لاحقًا.',
      trainingSentence: 'Ich ___ dir morgen Bescheid.',
    ),
    NvvChallengeItem(
      id: 'bescheid_geben',
      register: NvvRegister.formalWorkplace,
      nominalPart: 'Bescheid',
      correctVerb: 'geben',
      simpleEquivalent: 'informieren',
      arabicTranslation: 'يُبلغ / يعطي خبرًا',
      arabicUsageExplanation:
          'تستعمل كثيرًا في بيئة العمل والمواعيد بمعنى إبلاغ شخص بالمستجدات.',
      trainingSentence: 'Bitte ___ Sie mir bis Freitag Bescheid.',
    ),
    NvvChallengeItem(
      id: 'massnahmen_ergreifen',
      register: NvvRegister.academicOfficial,
      nominalPart: 'Maßnahmen',
      correctVerb: 'ergreifen',
      simpleEquivalent: 'handeln',
      arabicTranslation: 'يتخذ إجراءات',
      arabicUsageExplanation:
          'تركيب رسمي شائع في التقارير والقرارات الإدارية عند اتخاذ خطوات عملية.',
      trainingSentence: 'Die Stadt muss weitere Maßnahmen ___.',
    ),
    NvvChallengeItem(
      id: 'in_frage_kommen',
      register: NvvRegister.formalWorkplace,
      nominalPart: 'in Frage',
      correctVerb: 'kommen',
      simpleEquivalent: 'geeignet / möglich sein',
      preposition: 'für',
      caseHint: 'Akkusativ',
      arabicTranslation: 'يكون واردًا أو مناسبًا',
      arabicUsageExplanation:
          'يستخدم عند مناقشة الخيارات التي يمكن قبولها أو التفكير بها.',
      trainingSentence: 'Für diese Stelle ___ mehrere Bewerber in Frage.',
    ),
    NvvChallengeItem(
      id: 'zur_verfuegung_stehen',
      register: NvvRegister.formalWorkplace,
      nominalPart: 'zur Verfügung',
      correctVerb: 'stehen',
      simpleEquivalent: 'verfügbar sein',
      preposition: 'für',
      caseHint: 'Akkusativ',
      arabicTranslation: 'يكون متاحًا',
      arabicUsageExplanation:
          'يعني أن شخصًا أو شيئًا متاح للاستخدام أو للمساعدة.',
      trainingSentence: 'Der Besprechungsraum ___ uns ab zehn Uhr zur Verfügung.',
    ),
    NvvChallengeItem(
      id: 'zur_verfuegung_stellen',
      register: NvvRegister.formalWorkplace,
      nominalPart: 'zur Verfügung',
      correctVerb: 'stellen',
      simpleEquivalent: 'bereitstellen',
      preposition: 'für',
      caseHint: 'Akkusativ',
      arabicTranslation: 'يوفّر / يضع تحت التصرف',
      arabicUsageExplanation:
          'يختلف عن stehen: هنا شخص أو جهة هي التي توفّر الشيء للآخرين.',
      trainingSentence: 'Die Firma ___ für den Kurs einen Raum zur Verfügung.',
    ),
    NvvChallengeItem(
      id: 'antrag_stellen',
      register: NvvRegister.academicOfficial,
      nominalPart: 'einen Antrag',
      correctVerb: 'stellen',
      simpleEquivalent: 'beantragen',
      preposition: 'auf',
      caseHint: 'Akkusativ',
      arabicTranslation: 'يقدّم طلبًا رسميًا',
      arabicUsageExplanation:
          'تركيب أساسي في الدوائر والمعاملات الرسمية، وغالبًا يحدد موضوع الطلب بـ auf.',
      trainingSentence: 'Sie möchte einen Antrag auf Unterstützung ___.',
    ),
    NvvChallengeItem(
      id: 'kontakt_aufnehmen',
      register: NvvRegister.formalWorkplace,
      nominalPart: 'Kontakt',
      correctVerb: 'aufnehmen',
      simpleEquivalent: 'kontaktieren',
      preposition: 'mit',
      caseHint: 'Dativ',
      arabicTranslation: 'يتواصل مع',
      arabicUsageExplanation:
          'يستعمل عند بدء التواصل، خصوصًا في المراسلات المهنية والرسمية.',
      trainingSentence: 'Bitte ___ Sie Kontakt mit der Personalabteilung auf.',
    ),
    NvvChallengeItem(
      id: 'einfluss_nehmen',
      register: NvvRegister.academicOfficial,
      nominalPart: 'Einfluss',
      correctVerb: 'nehmen',
      simpleEquivalent: 'beeinflussen',
      preposition: 'auf',
      caseHint: 'Akkusativ',
      arabicTranslation: 'يؤثر في',
      arabicUsageExplanation:
          'تركيب شائع في اللغة الأكاديمية والرسمية لوصف التأثير في قرار أو عملية.',
      trainingSentence: 'Die neuen Regeln ___ Einfluss auf den Ablauf.',
    ),
    NvvChallengeItem(
      id: 'verantwortung_uebernehmen',
      register: NvvRegister.formalWorkplace,
      nominalPart: 'Verantwortung',
      correctVerb: 'übernehmen',
      simpleEquivalent: 'verantwortlich sein',
      preposition: 'für',
      caseHint: 'Akkusativ',
      arabicTranslation: 'يتحمّل المسؤولية عن',
      arabicUsageExplanation:
          'شائع في العمل عند تحديد المسؤولية عن مهمة أو نتيجة.',
      trainingSentence: 'Mina ___ Verantwortung für das neue Projekt.',
    ),
    NvvChallengeItem(
      id: 'rolle_spielen',
      register: NvvRegister.academicOfficial,
      nominalPart: 'eine Rolle',
      correctVerb: 'spielen',
      simpleEquivalent: 'wichtig / relevant sein',
      preposition: 'bei',
      caseHint: 'Dativ',
      arabicTranslation: 'يلعب دورًا / يكون مهمًا',
      arabicUsageExplanation:
          'يستخدم في التفسير والتحليل لبيان أهمية عامل في موضوع ما.',
      trainingSentence: 'Erfahrung ___ bei dieser Aufgabe eine wichtige Rolle.',
    ),
    NvvChallengeItem(
      id: 'beitrag_leisten',
      register: NvvRegister.academicOfficial,
      nominalPart: 'einen Beitrag',
      correctVerb: 'leisten',
      simpleEquivalent: 'beitragen',
      preposition: 'zu',
      caseHint: 'Dativ',
      arabicTranslation: 'يساهم في',
      arabicUsageExplanation:
          'تركيب رسمي وأكاديمي لبيان المساهمة في هدف أو نتيجة.',
      trainingSentence: 'Das Training kann einen Beitrag zur Sicherheit ___.',
    ),
    NvvChallengeItem(
      id: 'frage_stellen',
      register: NvvRegister.everyday,
      nominalPart: 'eine Frage',
      correctVerb: 'stellen',
      simpleEquivalent: 'fragen',
      preposition: 'an',
      caseHint: 'Akkusativ',
      arabicTranslation: 'يطرح سؤالًا',
      arabicUsageExplanation:
          'تركيب يومي ورسمي شائع. يمكن تحديد الشخص المقصود بـ an + Akkusativ.',
      trainingSentence: 'Darf ich eine Frage an die Lehrerin ___?',
    ),
    NvvChallengeItem(
      id: 'hilfe_leisten',
      register: NvvRegister.formalWorkplace,
      nominalPart: 'Hilfe',
      correctVerb: 'leisten',
      simpleEquivalent: 'helfen',
      preposition: 'bei',
      caseHint: 'Dativ',
      arabicTranslation: 'يقدّم مساعدة',
      arabicUsageExplanation:
          'صيغة رسمية نسبيًا تظهر في التعليمات والتقارير، ويمكن تحديد الموقف بـ bei + Dativ.',
      trainingSentence: 'Die Kollegin ___ bei der Vorbereitung Hilfe.',
    ),
    NvvChallengeItem(
      id: 'kritik_ueben',
      register: NvvRegister.academicOfficial,
      nominalPart: 'Kritik',
      correctVerb: 'üben',
      simpleEquivalent: 'kritisieren',
      preposition: 'an',
      caseHint: 'Dativ',
      arabicTranslation: 'ينتقد',
      arabicUsageExplanation:
          'تركيب شائع في النقاشات والتقارير عندما نعبّر عن نقد لشيء محدد.',
      trainingSentence: 'Der Bericht ___ Kritik an der bisherigen Planung.',
    ),
    NvvChallengeItem(
      id: 'vereinbarung_treffen',
      register: NvvRegister.formalWorkplace,
      nominalPart: 'eine Vereinbarung',
      correctVerb: 'treffen',
      simpleEquivalent: 'vereinbaren',
      preposition: 'mit',
      caseHint: 'Dativ',
      arabicTranslation: 'يتفق / يعقد اتفاقًا',
      arabicUsageExplanation:
          'يستخدم في العمل والمعاملات عند تثبيت اتفاق مع شخص أو جهة.',
      trainingSentence: 'Wir ___ eine Vereinbarung mit dem Lieferanten.',
    ),
  ];

  @override
  Future<List<NvvChallengeItem>> getChallenges({
    NvvRegister? register,
  }) async {
    final items = register == null
        ? _bank
        : _bank.where((item) => item.register == register);
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
    final id = challengeId.trim();
    final verb = _normalize(selectedVerb);
    if (id.isEmpty || verb.isEmpty) return false;

    NvvChallengeItem? challenge;
    for (final item in _bank) {
      if (item.id == id) {
        challenge = item;
        break;
      }
    }
    if (challenge == null) return false;

    return _normalize(challenge.correctVerb) == verb;
  }

  static String _normalize(String value) => value.trim().toLowerCase();
}

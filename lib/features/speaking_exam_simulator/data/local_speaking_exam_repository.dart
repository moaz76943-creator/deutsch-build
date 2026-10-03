import '../domain/speaking_exam_models.dart';
import '../domain/speaking_exam_repository.dart';

final class LocalSpeakingExamRepository implements SpeakingExamRepository {
  LocalSpeakingExamRepository() : _scenarios = _buildScenarios();

  final List<SpeakingExamScenario> _scenarios;

  @override
  Future<List<SpeakingExamScenario>> getScenarios({
    ExamProvider? provider,
    ExamLevel? level,
  }) async {
    final selected = _scenarios.where((scenario) {
      final providerMatches =
          provider == null || scenario.provider == provider;
      final levelMatches = level == null || scenario.level == level;
      return providerMatches && levelMatches;
    }).toList(growable: false);

    return List<SpeakingExamScenario>.unmodifiable(selected);
  }

  static List<SpeakingExamScenario> _buildScenarios() {
    const b1Phases = <SpeakingPhaseConfig>[
      SpeakingPhaseConfig(
        type: SpeakingPhaseType.preparation,
        titleDe: 'Vorbereitung',
        titleAr: 'التحضير',
        duration: Duration(minutes: 2),
        guidanceAr:
            'رتّب فكرتك: مقدمة قصيرة، نقطتان واضحتان، مثال شخصي، ثم خاتمة.',
      ),
      SpeakingPhaseConfig(
        type: SpeakingPhaseType.presentation,
        titleDe: 'Kurzpräsentation',
        titleAr: 'عرض قصير',
        duration: Duration(minutes: 3),
        guidanceAr:
            'تحدث بجمل مترابطة ولا تقرأ النقاط حرفياً. استخدم روابط مثل zuerst، außerdem، deshalb.',
      ),
      SpeakingPhaseConfig(
        type: SpeakingPhaseType.partnerQuestions,
        titleDe: 'Nachfragen',
        titleAr: 'أسئلة الشريك',
        duration: Duration(minutes: 2),
        guidanceAr:
            'أجب مباشرة ثم أضف سبباً أو مثالاً. اطلب توضيحاً إذا لم تفهم السؤال.',
      ),
      SpeakingPhaseConfig(
        type: SpeakingPhaseType.jointPlanning,
        titleDe: 'Gemeinsam planen',
        titleAr: 'التخطيط المشترك',
        duration: Duration(minutes: 4),
        guidanceAr:
            'اقترح، وافق أو ارفض بأدب، اسأل عن البدائل، وأنهِ باتفاق عملي واضح.',
      ),
    ];

    const b2Phases = <SpeakingPhaseConfig>[
      SpeakingPhaseConfig(
        type: SpeakingPhaseType.preparation,
        titleDe: 'Vorbereitung',
        titleAr: 'التحضير',
        duration: Duration(minutes: 3),
        guidanceAr:
            'حدّد موقفك، حجتين رئيسيتين، مثالاً، وحجة مضادة مع رد مختصر عليها.',
      ),
      SpeakingPhaseConfig(
        type: SpeakingPhaseType.presentation,
        titleDe: 'Strukturierter Beitrag',
        titleAr: 'مداخلة منظمة',
        duration: Duration(minutes: 4),
        guidanceAr:
            'ابنِ موقفاً واضحاً مع روابط متقدمة مثل einerseits، andererseits، dennoch، folglich.',
      ),
      SpeakingPhaseConfig(
        type: SpeakingPhaseType.discussion,
        titleDe: 'Diskussion',
        titleAr: 'النقاش',
        duration: Duration(minutes: 5),
        guidanceAr:
            'ناقش الفكرة لا الشخص. اربط ردك بما قاله الشريك ووازن بين الإيجابيات والسلبيات.',
      ),
      SpeakingPhaseConfig(
        type: SpeakingPhaseType.jointPlanning,
        titleDe: 'Lösung aushandeln',
        titleAr: 'التفاوض على حل',
        duration: Duration(minutes: 5),
        guidanceAr:
            'قدّم خيارات، قيّمها بمعايير واضحة، ثم تفاوض للوصول إلى قرار مشترك.',
      ),
      SpeakingPhaseConfig(
        type: SpeakingPhaseType.wrapUp,
        titleDe: 'Fazit',
        titleAr: 'الخلاصة',
        duration: Duration(minutes: 1),
        guidanceAr:
            'لخّص النتيجة بجملتين: ما الذي اتفقتما عليه؟ وما الخطوة التالية؟',
      ),
    ];

    const items = <SpeakingExamScenario>[
      SpeakingExamScenario(
        id: 'goethe_b1_digital_learning',
        provider: ExamProvider.goethe,
        level: ExamLevel.b1,
        topicDe: 'Digitales Lernen im Alltag',
        topicAr: 'التعلم الرقمي في الحياة اليومية',
        presentationPromptDe:
            'Sprechen Sie über digitales Lernen und Ihre eigenen Erfahrungen.',
        presentationPointsDe: <String>[
          'Welche digitalen Lernangebote nutzen Sie?',
          'Welche Vorteile sehen Sie?',
          'Welche Probleme gibt es?',
          'Nennen Sie ein Beispiel aus Ihrem Alltag.',
        ],
        presentationPointsAr: <String>[
          'ما وسائل التعلم الرقمية التي تستخدمها؟',
          'ما الفوائد التي تراها؟',
          'ما المشكلات التي قد تظهر؟',
          'اذكر مثالاً من حياتك اليومية.',
        ],
        debateStatementDe:
            'Online-Lernen kann den Präsenzunterricht vollständig ersetzen.',
        debateStatementAr:
            'يمكن للتعلم عبر الإنترنت أن يستبدل التعليم الحضوري بالكامل.',
        proArgumentsDe: <String>[
          'flexible Zeitplanung',
          'Lernen von jedem Ort',
          'große Auswahl an Materialien',
        ],
        contraArgumentsDe: <String>[
          'weniger direkter Kontakt',
          'Ablenkung zu Hause',
          'technische Probleme',
        ],
        partnerQuestionsDe: <String>[
          'Wie oft lernen Sie online?',
          'Was motiviert Sie beim Lernen?',
          'Welche Lernform ist für Sie effektiver?',
        ],
        planningTaskDe:
            'Planen Sie gemeinsam einen Lerntag für Ihre Deutschgruppe.',
        planningTaskAr:
            'خططا معاً ليوم دراسي لمجموعة تعلم الألمانية.',
        phases: b1Phases,
      ),
      SpeakingExamScenario(
        id: 'telc_b1_neighborhood_event',
        provider: ExamProvider.telc,
        level: ExamLevel.b1,
        topicDe: 'Ein Fest in der Nachbarschaft',
        topicAr: 'فعالية في الحي',
        presentationPromptDe:
            'Beschreiben Sie, warum gemeinsame Aktivitäten in der Nachbarschaft wichtig sein können.',
        presentationPointsDe: <String>[
          'Welche Aktivität passt zur Nachbarschaft?',
          'Wer soll teilnehmen?',
          'Was muss organisiert werden?',
          'Welche Schwierigkeiten sind möglich?',
        ],
        presentationPointsAr: <String>[
          'ما النشاط المناسب للحي؟',
          'من ينبغي أن يشارك؟',
          'ما الذي يجب تنظيمه؟',
          'ما الصعوبات المحتملة؟',
        ],
        debateStatementDe:
            'Nachbarn sollten regelmäßig gemeinsame Veranstaltungen organisieren.',
        debateStatementAr:
            'ينبغي للجيران تنظيم فعاليات مشتركة بشكل منتظم.',
        proArgumentsDe: <String>[
          'besseres Zusammenleben',
          'neue Kontakte',
          'gegenseitige Hilfe',
        ],
        contraArgumentsDe: <String>[
          'Zeitaufwand',
          'unterschiedliche Interessen',
          'Kosten und Organisation',
        ],
        partnerQuestionsDe: <String>[
          'Kennen Sie Ihre Nachbarn gut?',
          'Welche Aktivität würden Sie vorschlagen?',
          'Wie kann man neue Bewohner einbeziehen?',
        ],
        planningTaskDe:
            'Planen Sie zusammen ein kleines Nachbarschaftsfest: Ort, Zeit, Essen, Aufgaben und Kosten.',
        planningTaskAr:
            'خططا معاً لفعالية صغيرة في الحي: المكان، الوقت، الطعام، المهام والتكاليف.',
        phases: b1Phases,
      ),
      SpeakingExamScenario(
        id: 'goethe_b2_remote_work',
        provider: ExamProvider.goethe,
        level: ExamLevel.b2,
        topicDe: 'Homeoffice und moderne Arbeitswelt',
        topicAr: 'العمل من المنزل وسوق العمل الحديث',
        presentationPromptDe:
            'Nehmen Sie Stellung zu Homeoffice und begründen Sie Ihre Position differenziert.',
        presentationPointsDe: <String>[
          'Produktivität und Konzentration',
          'Zusammenarbeit im Team',
          'Vereinbarkeit von Beruf und Privatleben',
          'langfristige Folgen für Unternehmen',
        ],
        presentationPointsAr: <String>[
          'الإنتاجية والتركيز',
          'التعاون ضمن الفريق',
          'التوازن بين العمل والحياة',
          'الآثار طويلة المدى على الشركات',
        ],
        debateStatementDe:
            'Beschäftigte sollten selbst entscheiden dürfen, von wo sie arbeiten.',
        debateStatementAr:
            'يجب أن يتمكن الموظفون من اختيار مكان عملهم بأنفسهم.',
        proArgumentsDe: <String>[
          'mehr Autonomie',
          'weniger Pendelzeit',
          'bessere Vereinbarkeit',
          'größerer Bewerbermarkt',
        ],
        contraArgumentsDe: <String>[
          'schwächere Teamkultur',
          'schwierige Abstimmung',
          'ungleiche Arbeitsbedingungen',
          'Grenzen zwischen Arbeit und Freizeit verschwimmen',
        ],
        partnerQuestionsDe: <String>[
          'Welche Berufe eignen sich nicht für Homeoffice?',
          'Wie kann Teamarbeit digital funktionieren?',
          'Sollten Unternehmen feste Präsenztage verlangen?',
        ],
        planningTaskDe:
            'Entwickeln Sie gemeinsam ein hybrides Arbeitsmodell für ein kleines Unternehmen.',
        planningTaskAr:
            'طورا معاً نموذج عمل هجين لشركة صغيرة.',
        phases: b2Phases,
      ),
      SpeakingExamScenario(
        id: 'telc_b2_city_mobility',
        provider: ExamProvider.telc,
        level: ExamLevel.b2,
        topicDe: 'Mobilität in der Stadt',
        topicAr: 'التنقل داخل المدينة',
        presentationPromptDe:
            'Diskutieren Sie, wie Städte Mobilität nachhaltiger und zugleich alltagstauglich gestalten können.',
        presentationPointsDe: <String>[
          'öffentlicher Nahverkehr',
          'Auto und Parkraum',
          'Fahrrad- und Fußwege',
          'Kosten und soziale Fairness',
        ],
        presentationPointsAr: <String>[
          'النقل العام',
          'السيارات ومواقفها',
          'مسارات الدراجات والمشاة',
          'التكاليف والعدالة الاجتماعية',
        ],
        debateStatementDe:
            'Innenstädte sollten weitgehend autofrei werden.',
        debateStatementAr:
            'ينبغي أن تصبح مراكز المدن خالية من السيارات إلى حد كبير.',
        proArgumentsDe: <String>[
          'weniger Luftverschmutzung',
          'mehr Platz für Menschen',
          'höhere Lebensqualität',
          'sicherere Wege',
        ],
        contraArgumentsDe: <String>[
          'Nachteile für Pendler',
          'Probleme für Geschäfte',
          'eingeschränkte Mobilität',
          'hohe Umbaukosten',
        ],
        partnerQuestionsDe: <String>[
          'Welche Verkehrsmittel nutzen Sie täglich?',
          'Wie kann öffentlicher Verkehr attraktiver werden?',
          'Wer sollte die Umstellung finanzieren?',
        ],
        planningTaskDe:
            'Erarbeiten Sie zusammen drei konkrete Maßnahmen für eine nachhaltigere Innenstadt und setzen Sie Prioritäten.',
        planningTaskAr:
            'ضعا معاً ثلاث إجراءات عملية لمدينة أكثر استدامة وحددا الأولويات.',
        phases: b2Phases,
      ),
    ];

    final ids = items.map((item) => item.id).toSet();
    if (ids.length != items.length) {
      throw StateError('speaking exam scenario ids must be unique');
    }

    return List<SpeakingExamScenario>.unmodifiable(items);
  }
}

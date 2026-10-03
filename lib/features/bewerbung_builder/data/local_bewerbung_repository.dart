import '../domain/bewerbung_models.dart';
import '../domain/bewerbung_repository.dart';

final class LocalBewerbungRepository implements BewerbungRepository {
  static final List<BewerbungTemplate> _templates =
      <BewerbungTemplate>[
    _template(
      'cv_medicine',
      BewerbungDocumentType.lebenslauf,
      CareerTrack.medicine,
      'Lebenslauf – Medizin',
      'ركّز على التدريب السريري، التواصل مع المرضى، التوثيق والعمل ضمن الفريق. لا تضف تخصصًا أو ترخيصًا غير موجود.',
      <String>[
        'Patientenkommunikation',
        'Klinische Dokumentation',
        'Teamarbeit',
      ],
    ),
    _template(
      'letter_medicine',
      BewerbungDocumentType.anschreiben,
      CareerTrack.medicine,
      'Anschreiben – Medizin',
      'استخدم لغة مهنية هادئة واذكر الخبرة السريرية الفعلية فقط دون مبالغة.',
      <String>[
        'Patientenorientierung',
        'Sorgfalt',
        'Interdisziplinäre Zusammenarbeit',
      ],
    ),
    _template(
      'cv_pharmacy',
      BewerbungDocumentType.lebenslauf,
      CareerTrack.pharmacy,
      'Lebenslauf – Pharmazie',
      'أبرز الاستشارة الدوائية، السلامة، التوثيق وخدمة المرضى بحسب خبرتك الحقيقية.',
      <String>[
        'Arzneimittelberatung',
        'Arzneimittelsicherheit',
        'Dokumentation',
      ],
    ),
    _template(
      'letter_pharmacy',
      BewerbungDocumentType.anschreiben,
      CareerTrack.pharmacy,
      'Anschreiben – Pharmazie',
      'اربط مهارات الصيدلة الفعلية باحتياجات الوظيفة دون ادعاء خبرات غير موثقة.',
      <String>[
        'Beratung',
        'Qualitätsbewusstsein',
        'Verantwortungsbewusstsein',
      ],
    ),
    _template(
      'cv_it',
      BewerbungDocumentType.lebenslauf,
      CareerTrack.it,
      'Lebenslauf – IT',
      'اذكر التقنيات والمشاريع التي عملت عليها فعليًا، مع نتائج قابلة للتحقق إن وجدت.',
      <String>[
        'Softwareentwicklung',
        'Git',
        'Testing',
      ],
    ),
    _template(
      'letter_it',
      BewerbungDocumentType.anschreiben,
      CareerTrack.it,
      'Anschreiben – IT',
      'استخدم أمثلة حقيقية من مشاريعك وركّز على الجودة والتعاون وقابلية الصيانة.',
      <String>[
        'Problemlösung',
        'Teamarbeit',
        'Saubere Software',
      ],
    ),
    _template(
      'cv_trades',
      BewerbungDocumentType.lebenslauf,
      CareerTrack.trades,
      'Lebenslauf – Handwerk',
      'أبرز الدقة والسلامة والخبرة العملية والأدوات التي تتقنها فعليًا.',
      <String>[
        'Sicheres Arbeiten',
        'Zuverlässigkeit',
        'Praktische Erfahrung',
      ],
    ),
    _template(
      'letter_trades',
      BewerbungDocumentType.anschreiben,
      CareerTrack.trades,
      'Anschreiben – Handwerk',
      'اكتب بشكل مباشر ومحترم، واذكر المهارات العملية الحقيقية والتزامك بالسلامة.',
      <String>[
        'Handwerkliches Geschick',
        'Pünktlichkeit',
        'Sicherheitsbewusstsein',
      ],
    ),
    _template(
      'cv_general',
      BewerbungDocumentType.lebenslauf,
      CareerTrack.general,
      'Lebenslauf – Allgemein',
      'استخدم صياغة واضحة ومهنية واذكر المعلومات القابلة للتحقق فقط.',
      <String>[
        'Kommunikation',
        'Organisation',
        'Teamarbeit',
      ],
    ),
    _template(
      'letter_general',
      BewerbungDocumentType.anschreiben,
      CareerTrack.general,
      'Anschreiben – Allgemein',
      'اجعل الرسالة قصيرة ومحددة للوظيفة واحذف أي ادعاء لا يمكنك إثباته.',
      <String>[
        'Zuverlässigkeit',
        'Lernbereitschaft',
        'Kommunikation',
      ],
    ),
  ];

  static BewerbungTemplate _template(
    String id,
    BewerbungDocumentType type,
    CareerTrack track,
    String titleDe,
    String guidanceAr,
    List<String> skills,
  ) {
    return BewerbungTemplate(
      id: id,
      documentType: type,
      careerTrack: track,
      titleDe: titleDe,
      guidanceAr: guidanceAr,
      suggestedSkillsDe: skills,
    );
  }

  @override
  Future<List<BewerbungTemplate>> getTemplates({
    BewerbungDocumentType? documentType,
    CareerTrack? careerTrack,
  }) async {
    final result = _templates.where((template) {
      if (documentType != null &&
          template.documentType != documentType) {
        return false;
      }
      if (careerTrack != null &&
          template.careerTrack != careerTrack) {
        return false;
      }
      return true;
    });

    return List<BewerbungTemplate>.unmodifiable(result);
  }

  @override
  Future<List<String>> validateProfile(
    BewerbungProfile profile,
  ) async {
    final issues = <String>[];

    if (profile.fullName.trim().isEmpty) {
      issues.add('أدخل الاسم الكامل كما سيظهر في طلب التوظيف.');
    }
    if (profile.targetRole.trim().isEmpty) {
      issues.add('أدخل اسم الوظيفة المستهدفة.');
    }
    if (profile.email.trim().isEmpty ||
        !profile.email.contains('@')) {
      issues.add('أدخل البريد الإلكتروني المهني بصيغة صحيحة.');
    }
    if (profile.city.trim().isEmpty) {
      issues.add('أدخل المدينة.');
    }
    if (profile.professionalSummary.trim().isEmpty) {
      issues.add('أضف ملخصًا مهنيًا واقعيًا قصيرًا.');
    }
    if (profile.skills.isEmpty) {
      issues.add('أضف مهارة مهنية واحدة على الأقل.');
    }

    return List<String>.unmodifiable(issues);
  }

  @override
  Future<BewerbungPreview> buildPreview(
    String templateId,
    BewerbungProfile profile,
  ) async {
    BewerbungTemplate? template;
    for (final candidate in _templates) {
      if (candidate.id == templateId.trim()) {
        template = candidate;
        break;
      }
    }
    if (template == null) {
      throw StateError('Unknown Bewerbung template: $templateId');
    }

    final issues = await validateProfile(profile);
    if (issues.isNotEmpty) {
      throw StateError(
        'Profile must be valid before preview generation.',
      );
    }

    return switch (template.documentType) {
      BewerbungDocumentType.lebenslauf =>
        _buildLebenslauf(template, profile),
      BewerbungDocumentType.anschreiben =>
        _buildAnschreiben(template, profile),
    };
  }

  BewerbungPreview _buildLebenslauf(
    BewerbungTemplate template,
    BewerbungProfile profile,
  ) {
    final contact = <String>[
      profile.fullName.trim(),
      if (profile.city.trim().isNotEmpty) profile.city.trim(),
      profile.email.trim(),
      if (profile.phone.trim().isNotEmpty) profile.phone.trim(),
    ].join(' · ');

    final blocks = <BewerbungPreviewBlock>[
      BewerbungPreviewBlock(
        headingDe: 'PERSÖNLICHE DATEN',
        bodyDe: contact,
        guidanceAr:
            'اعرض بيانات الاتصال الضرورية فقط وبشكل مهني.',
      ),
      BewerbungPreviewBlock(
        headingDe: 'PROFIL',
        bodyDe: profile.professionalSummary.trim(),
        guidanceAr:
            'ملخص قصير يصف خبرتك الفعلية واتجاهك المهني.',
      ),
      if (profile.experience.isNotEmpty)
        BewerbungPreviewBlock(
          headingDe: 'BERUFSERFAHRUNG',
          bodyDe: _bulletList(profile.experience),
          guidanceAr:
              'اكتب المهام والنتائج الحقيقية دون مبالغة.',
        ),
      if (profile.education.isNotEmpty)
        BewerbungPreviewBlock(
          headingDe: 'AUSBILDUNG',
          bodyDe: _bulletList(profile.education),
          guidanceAr:
              'اذكر المؤهلات التي حصلت عليها بالفعل.',
        ),
      BewerbungPreviewBlock(
        headingDe: 'KENNTNISSE',
        bodyDe: _bulletList(profile.skills),
        guidanceAr:
            'اختر المهارات المرتبطة مباشرة بالوظيفة.',
      ),
      if (profile.languages.isNotEmpty)
        BewerbungPreviewBlock(
          headingDe: 'SPRACHEN',
          bodyDe: _bulletList(profile.languages),
          guidanceAr:
              'اذكر مستوى اللغة كما هو فعلًا.',
        ),
    ];

    return BewerbungPreview(
      documentType: template.documentType,
      templateId: template.id,
      titleDe: 'Tabellarischer Lebenslauf',
      blocks: blocks,
    );
  }

  BewerbungPreview _buildAnschreiben(
    BewerbungTemplate template,
    BewerbungProfile profile,
  ) {
    final role = profile.targetRole.trim();
    final employer = profile.employer.trim();
    final employerPhrase =
        employer.isEmpty ? 'Ihrem Unternehmen' : employer;

    final skills = profile.skills.join(', ');
    final experience = profile.experience.isEmpty
        ? ''
        : 'Besonders relevant ist meine praktische Erfahrung: '
            '${profile.experience.join('; ')}.';

    final body = <String>[
      'Sehr geehrte Damen und Herren,',
      '',
      'hiermit bewerbe ich mich um die Position als $role bei $employerPhrase.',
      profile.professionalSummary.trim(),
      if (experience.isNotEmpty) experience,
      'Zu meinen fachlich relevanten Kenntnissen zählen: $skills.',
      'Gern erläutere ich Ihnen meine Erfahrungen und Motivation in einem persönlichen Gespräch.',
      '',
      'Mit freundlichen Grüßen',
      profile.fullName.trim(),
    ].join('\n');

    return BewerbungPreview(
      documentType: template.documentType,
      templateId: template.id,
      titleDe: 'Anschreiben – $role',
      blocks: <BewerbungPreviewBlock>[
        BewerbungPreviewBlock(
          headingDe: 'ANSCHREIBEN',
          bodyDe: body,
          guidanceAr:
              'راجع النص واحذف أي معلومة لا تستطيع إثباتها. لا تضف شهادات أو سنوات خبرة غير موجودة.',
        ),
      ],
    );
  }

  static String _bulletList(List<String> values) {
    return values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .map((value) => '• $value')
        .join('\n');
  }
}

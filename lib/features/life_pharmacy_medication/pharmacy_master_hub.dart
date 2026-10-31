import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../design_system/design_system.dart';
import 'pharmacy_models.dart';

final class PharmacyMasterOrchestrator extends ChangeNotifier {
  PharmacyHubSection _section = PharmacyHubSection.prescriptions;
  String _query = '';

  PharmacyHubSection get section => _section;
  String get query => _query;

  static const List<PharmacyHubCard> _cards = <PharmacyHubCard>[
    PharmacyHubCard(
      id: 'hub-prescriptions',
      section: PharmacyHubSection.prescriptions,
      titleDe: 'Rezept in der Apotheke einlösen',
      titleAr: 'صرف الوصفة في الصيدلية',
      bodyDe:
          'E-Rezept, Privatrezept und Grünes Rezept sprachlich unterscheiden und bei Zuzahlung, Befreiung oder einem möglichen wirkstoffgleichen Präparat nachfragen.',
      bodyAr:
          'تعلّم التفريق لغوياً بين الوصفة الإلكترونية والخاصة والخضراء، والسؤال عن الرسوم أو الإعفاء أو البديل من نفس المادة الفعالة.',
      keywords: <String>[
        'E-Rezept',
        'Privatrezept',
        'Grünes Rezept',
        'Zuzahlung',
        'Befreiung',
        'Generikum',
        'Aut-idem',
        'وصفة',
      ],
    ),
    PharmacyHubCard(
      id: 'hub-otc',
      section: PharmacyHubSection.otcConsultation,
      titleDe: 'Rezeptfreie Medikamente & Beratung',
      titleAr: 'أدوية دون وصفة واستشارة',
      bodyDe:
          'Bei leichten Beschwerden Symptome beschreiben, nach einem rezeptfreien Mittel fragen und wichtige Rückfragen der Apotheke verstehen.',
      bodyAr:
          'وصف أعراض خفيفة، وطلب استشارة لدواء دون وصفة، وفهم أسئلة الصيدلي المهمة قبل الاختيار.',
      keywords: <String>[
        'rezeptfrei',
        'Beratung',
        'Erkältung',
        'Schmerzen',
        'استشارة',
        'دون وصفة',
      ],
    ),
    PharmacyHubCard(
      id: 'hub-dosage-safety',
      section: PharmacyHubSection.dosageAndSafety,
      titleDe: 'Dosierung, Einnahme & Packungsbeilage',
      titleAr: 'الجرعة وطريقة الاستخدام والنشرة',
      bodyDe:
          'Dosierungsangaben, Einnahmezeit, Darreichungsform, Nebenwirkungen und Verfallsdatum sicher nachfragen und wiederholen.',
      bodyAr:
          'السؤال عن الجرعة ووقت التناول والشكل الدوائي والآثار الجانبية وتاريخ الصلاحية وإعادة التعليمات للتأكد من الفهم.',
      keywords: <String>[
        'Dosierung',
        'Einnahme',
        'Tablette',
        'Tropfen',
        'Packungsbeilage',
        'Nebenwirkungen',
        'Verfallsdatum',
        'الجرعة',
      ],
    ),
  ];

  List<PharmacyHubCard> get visibleCards => List<PharmacyHubCard>.unmodifiable(
        _cards.where(
          (card) => card.section == _section && card.matches(_query),
        ),
      );

  void setSection(PharmacyHubSection value) {
    if (_section == value && _query.isEmpty) return;
    _section = value;
    _query = '';
    notifyListeners();
  }

  void setQuery(String value) {
    final next = value.trim();
    if (_query == next) return;
    _query = next;
    notifyListeners();
  }

  void clearSearch() => setQuery('');
}

final class PharmacyMasterHub extends StatefulWidget {
  const PharmacyMasterHub({
    this.orchestrator,
    super.key,
  });

  final PharmacyMasterOrchestrator? orchestrator;

  @override
  State<PharmacyMasterHub> createState() => _PharmacyMasterHubState();
}

final class _PharmacyMasterHubState extends State<PharmacyMasterHub> {
  late final PharmacyMasterOrchestrator _orchestrator;
  late final bool _ownsOrchestrator;

  @override
  void initState() {
    super.initState();
    _ownsOrchestrator = widget.orchestrator == null;
    _orchestrator = widget.orchestrator ?? PharmacyMasterOrchestrator();
  }

  @override
  void dispose() {
    if (_ownsOrchestrator) _orchestrator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor:
            dark ? AppColors.darkBackground : AppColors.lightBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: AnimatedBuilder(
              animation: _orchestrator,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _HeaderCard(dark: dark),
                  const SizedBox(height: 16),
                  _SearchField(orchestrator: _orchestrator),
                  const SizedBox(height: 12),
                  _SectionSelector(
                    orchestrator: _orchestrator,
                    dark: dark,
                  ),
                  const SizedBox(height: 16),
                  _SafetyCard(dark: dark),
                  const SizedBox(height: 16),
                  _Cards(
                    orchestrator: _orchestrator,
                    dark: dark,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.primary,
        borderColor: AppColors.primary.withAlpha(96),
        backgroundColor:
            dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Apotheke & Medikamente',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: 8),
            AppDirectionalText(
              'مركز لغوي عملي لمواقف الصيدلية اليومية: الوصفات، الاستشارة، الجرعات والأشكال الدوائية.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _SearchField extends StatelessWidget {
  const _SearchField({required this.orchestrator});

  final PharmacyMasterOrchestrator orchestrator;

  @override
  Widget build(BuildContext context) => TextField(
        key: const ValueKey<String>('pharmacy-master-search'),
        onChanged: orchestrator.setQuery,
        textDirection: TextDirection.ltr,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          labelText: 'Suche · بحث',
          hintText: 'E-Rezept, Beratung, Dosierung ...',
          border: OutlineInputBorder(),
        ),
      );
}

final class _SectionSelector extends StatelessWidget {
  const _SectionSelector({
    required this.orchestrator,
    required this.dark,
  });

  final PharmacyMasterOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.secondary.withAlpha(96),
        backgroundColor:
            dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final section in PharmacyHubSection.values)
              FilterChip(
                key: ValueKey<String>('pharmacy-section-${section.name}'),
                selected: orchestrator.section == section,
                onSelected: (_) => orchestrator.setSection(section),
                label: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AppDirectionalText(
                      section.labelDe,
                      languageCode: 'de',
                      style: AppTypography.label,
                    ),
                    AppDirectionalText(
                      section.labelAr,
                      languageCode: 'ar',
                      style: AppTypography.label,
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
}

final class _SafetyCard extends StatelessWidget {
  const _SafetyCard({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.tertiary,
        borderColor: AppColors.tertiary.withAlpha(96),
        backgroundColor:
            dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Sprachtraining, keine individuelle Arzneimittelberatung',
              languageCode: 'de',
              style: AppTypography.label,
            ),
            const SizedBox(height: 8),
            AppDirectionalText(
              'اتبع الوصفة أو النشرة وتعليمات الطبيب أو الصيدلي الفعلية عند استخدام أي دواء.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _Cards extends StatelessWidget {
  const _Cards({
    required this.orchestrator,
    required this.dark,
  });

  final PharmacyMasterOrchestrator orchestrator;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final cards = orchestrator.visibleCards;
    if (cards.isEmpty) {
      return AppGlassCard(
        backgroundColor:
            dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: AppDirectionalText(
          'لا توجد نتيجة في هذا القسم. جرّب كلمة أخرى.',
          languageCode: 'ar',
          style: AppTypography.body,
        ),
      );
    }

    return Column(
      children: <Widget>[
        for (var index = 0; index < cards.length; index++) ...<Widget>[
          AppGlassCard(
            borderColor: AppColors.primary.withAlpha(80),
            backgroundColor:
                dark ? AppColors.darkSurface : AppColors.lightSurface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppDirectionalText(
                  cards[index].titleDe,
                  languageCode: 'de',
                  style: AppTypography.title,
                ),
                const SizedBox(height: 8),
                AppDirectionalText(
                  cards[index].bodyDe,
                  languageCode: 'de',
                  style: AppTypography.body,
                ),
                const SizedBox(height: 10),
                AppDirectionalText(
                  cards[index].titleAr,
                  languageCode: 'ar',
                  style: AppTypography.label,
                ),
                const SizedBox(height: 6),
                AppDirectionalText(
                  cards[index].bodyAr,
                  languageCode: 'ar',
                  style: AppTypography.body,
                ),
              ],
            ),
          ),
          if (index != cards.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

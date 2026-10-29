import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../../design_system/design_system.dart';
import 'otc_consultation_controller.dart';
import 'otc_models.dart';

final class OtcConsultationScreen extends StatefulWidget {
  const OtcConsultationScreen({
    this.controller,
    super.key,
  });

  final OtcConsultationController? controller;

  @override
  State<OtcConsultationScreen> createState() =>
      _OtcConsultationScreenState();
}

final class _OtcConsultationScreenState
    extends State<OtcConsultationScreen> {
  late final OtcConsultationController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? OtcConsultationController();
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
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
              animation: _controller,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _Header(dark: dark),
                  const SizedBox(height: 16),
                  _SafetyCard(dark: dark),
                  const SizedBox(height: 16),
                  TextField(
                    key: const ValueKey<String>('otc-search'),
                    onChanged: _controller.setQuery,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      labelText: 'Suche · بحث',
                      hintText:
                          'Erkältung, Dosierung, Nebenwirkungen ...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _TopicSelector(
                    controller: _controller,
                    dark: dark,
                  ),
                  const SizedBox(height: 16),
                  _PhraseList(
                    controller: _controller,
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

final class _Header extends StatelessWidget {
  const _Header({required this.dark});

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
              'Rezeptfreie Medikamente & Beratung',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: 8),
            AppDirectionalText(
              'تدريب لغوي لطلب استشارة آمنة حول الأعراض الخفيفة والجرعة وطريقة الاستخدام والنشرة.',
              languageCode: 'ar',
              style: AppTypography.body,
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
              'Bei der Einnahme gelten Packungsbeilage und persönliche Beratung.',
              languageCode: 'de',
              style: AppTypography.label,
            ),
            const SizedBox(height: 8),
            AppDirectionalText(
              'هذا المحتوى لتعلّم اللغة، وليس لتشخيص الحالة أو اختيار دواء بعينه. عند الاستخدام الفعلي اتبع النشرة وتعليمات الطبيب أو الصيدلي.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _TopicSelector extends StatelessWidget {
  const _TopicSelector({
    required this.controller,
    required this.dark,
  });

  final OtcConsultationController controller;
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
            for (final topic in OtcTopic.values)
              FilterChip(
                key: ValueKey<String>('otc-topic-${topic.name}'),
                selected: controller.topic == topic,
                onSelected: (_) => controller.setTopic(topic),
                label: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AppDirectionalText(
                      topic.labelDe,
                      languageCode: 'de',
                      style: AppTypography.label,
                    ),
                    AppDirectionalText(
                      topic.labelAr,
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

final class _PhraseList extends StatelessWidget {
  const _PhraseList({
    required this.controller,
    required this.dark,
  });

  final OtcConsultationController controller;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final phrases = controller.visiblePhrases;
    if (phrases.isEmpty) {
      return AppGlassCard(
        backgroundColor:
            dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: AppDirectionalText(
          'لا توجد نتيجة في هذا الموضوع. جرّب بحثاً آخر.',
          languageCode: 'ar',
          style: AppTypography.body,
        ),
      );
    }

    return Column(
      children: <Widget>[
        for (var index = 0;
            index < phrases.length;
            index++) ...<Widget>[
          AppGlassCard(
            borderColor: AppColors.primary.withAlpha(80),
            backgroundColor:
                dark ? AppColors.darkSurface : AppColors.lightSurface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppDirectionalText(
                  phrases[index].contextDe,
                  languageCode: 'de',
                  style: AppTypography.label,
                ),
                const SizedBox(height: 8),
                AppDirectionalText(
                  phrases[index].german,
                  languageCode: 'de',
                  style: AppTypography.title,
                ),
                const SizedBox(height: 8),
                AppDirectionalText(
                  phrases[index].arabic,
                  languageCode: 'ar',
                  style: AppTypography.body,
                ),
                const SizedBox(height: 8),
                AppDirectionalText(
                  phrases[index].contextAr,
                  languageCode: 'ar',
                  style: AppTypography.label,
                ),
              ],
            ),
          ),
          if (index != phrases.length - 1)
            const SizedBox(height: 12),
        ],
      ],
    );
  }
}

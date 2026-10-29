import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../../design_system/design_system.dart';
import '../domain/doctor_appointment_models.dart';
import 'booking_reception_agent.dart';

abstract final class _BookingUiTokens {
  static const double inset = 16;
  static const double gap = 12;
  static const double sectionGap = 16;
  static const double bottom = 36;
}

final class BookingReceptionScreen extends StatefulWidget {
  const BookingReceptionScreen({
    required this.agent,
    super.key,
  });

  final BookingReceptionAgent agent;

  @override
  State<BookingReceptionScreen> createState() =>
      _BookingReceptionScreenState();
}

final class _BookingReceptionScreenState
    extends State<BookingReceptionScreen> {
  BookingStage _stage = BookingStage.booking;
  String _query = '';

  List<DoctorHubPhrase> get _items => widget.agent.search(
        _query,
        stage: _stage,
      );

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final background =
        dark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = dark ? AppColors.darkSurface : AppColors.lightSurface;
    final border =
        dark ? AppColors.glassBorderDark : AppColors.glassBorderLight;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          title: const AppDirectionalText(
            'الحجز والاستقبال',
            languageCode: 'ar',
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              _BookingUiTokens.inset,
              _BookingUiTokens.inset,
              _BookingUiTokens.inset,
              _BookingUiTokens.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _Header(surface: surface, border: border),
                const SizedBox(height: _BookingUiTokens.sectionGap),
                _StagePicker(
                  selected: _stage,
                  surface: surface,
                  border: border,
                  onSelected: (value) =>
                      setState(() => _stage = value),
                ),
                const SizedBox(height: _BookingUiTokens.sectionGap),
                _Search(
                  surface: surface,
                  border: border,
                  onChanged: (value) => setState(() => _query = value),
                ),
                const SizedBox(height: _BookingUiTokens.sectionGap),
                for (final item in _items) ...<Widget>[
                  _PhraseCard(
                    item: item,
                    surface: surface,
                    border: border,
                  ),
                  const SizedBox(height: _BookingUiTokens.gap),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _Header extends StatelessWidget {
  const _Header({
    required this.surface,
    required this.border,
  });

  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: border,
        glowColor: AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Termin & Empfang',
              languageCode: 'de',
              style: AppTypography.title.copyWith(
                color: AppColors.primary,
              ),
            ),
            AppDirectionalText(
              'حجز موعد هاتفياً أو عبر الإنترنت، الوصول إلى الاستقبال، البطاقة الصحية، والاستمارة.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            AppDirectionalText(
              'Sprachtraining für den Praxisalltag.',
              languageCode: 'de',
              style: AppTypography.label.copyWith(
                color: AppColors.tertiary,
              ),
            ),
          ],
        ),
      );
}

final class _StagePicker extends StatelessWidget {
  const _StagePicker({
    required this.selected,
    required this.surface,
    required this.border,
    required this.onSelected,
  });

  final BookingStage selected;
  final Color surface;
  final Color border;
  final ValueChanged<BookingStage> onSelected;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: border,
        child: Wrap(
          spacing: _BookingUiTokens.gap,
          runSpacing: _BookingUiTokens.gap,
          children: <Widget>[
            for (final stage in BookingStage.values)
              ChoiceChip(
                selected: stage == selected,
                onSelected: (_) => onSelected(stage),
                label: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    AppDirectionalText(
                      stage.german,
                      languageCode: 'de',
                      style: AppTypography.label,
                    ),
                    AppDirectionalText(
                      stage.arabic,
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

final class _Search extends StatelessWidget {
  const _Search({
    required this.surface,
    required this.border,
    required this.onChanged,
  });

  final Color surface;
  final Color border;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: border,
        glowColor: AppColors.secondary,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: TextField(
            onChanged: onChanged,
            style: AppTypography.body,
            decoration: const InputDecoration(
              hintText: 'Termin / Doctolib / Anamnesebogen',
            ),
          ),
        ),
      );
}

final class _PhraseCard extends StatelessWidget {
  const _PhraseCard({
    required this.item,
    required this.surface,
    required this.border,
  });

  final DoctorHubPhrase item;
  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: border,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              item.german,
              languageCode: 'de',
              style: AppTypography.body,
            ),
            const SizedBox(height: _BookingUiTokens.gap),
            AppDirectionalText(
              item.arabic,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

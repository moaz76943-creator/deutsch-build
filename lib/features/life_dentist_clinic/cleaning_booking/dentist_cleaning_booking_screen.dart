import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../../design_system/design_system.dart';
import '../dentist_models.dart';
import 'dentist_cleaning_booking_agent.dart';

abstract final class _Ui {
  static const double inset = 16;
  static const double gap = 12;
  static const double bottom = 36;
}

final class DentistCleaningBookingScreen extends StatefulWidget {
  const DentistCleaningBookingScreen({required this.agent, super.key});
  final DentistCleaningBookingAgent agent;

  @override
  State<DentistCleaningBookingScreen> createState() => _State();
}

final class _State extends State<DentistCleaningBookingScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? AppColors.darkSurface : AppColors.lightSurface;
    final border =
        dark ? AppColors.glassBorderDark : AppColors.glassBorderLight;
    final items = widget.agent.search(_query);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            dark ? AppColors.darkBackground : AppColors.lightBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              _Ui.inset,
              _Ui.inset,
              _Ui.inset,
              _Ui.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppGlassCard(
                  backgroundColor: surface,
                  borderColor: border,
                  glowColor: AppColors.primary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      AppDirectionalText(
                        'Zahnreinigung & Termin',
                        languageCode: 'de',
                        style: AppTypography.title.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      AppDirectionalText(
                        'لغة إزالة الجير وتنظيف الأسنان الاحترافي والتكاليف، إضافة إلى الحجز والاستقبال والتأجيل والإلغاء.',
                        languageCode: 'ar',
                        style: AppTypography.body,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: _Ui.gap),
                AppGlassCard(
                  backgroundColor: surface,
                  borderColor: border,
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: TextField(
                      onChanged: (value) => setState(() => _query = value),
                      style: AppTypography.body,
                      decoration: const InputDecoration(
                        hintText: 'Zahnstein / PZR / Termin',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: _Ui.gap),
                for (final DentistPhrase item in items) ...<Widget>[
                  AppGlassCard(
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
                        const SizedBox(height: _Ui.gap),
                        AppDirectionalText(
                          item.arabic,
                          languageCode: 'ar',
                          style: AppTypography.body,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: _Ui.gap),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

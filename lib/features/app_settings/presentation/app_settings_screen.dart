import 'dart:async';

import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../application/settings_controller.dart';
import '../domain/learning_preferences.dart';
import 'widgets/glass_action_row.dart';
import 'widgets/glass_slider_tile.dart';

final class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({
    required this.notifier,
    required this.accessibilityListenable,
    required this.cognitiveAccessibilityEnabled,
    required this.onCognitiveAccessibilityChanged,
    this.onProgressReset,
    super.key,
  });

  final SettingsController notifier;
  final Listenable accessibilityListenable;
  final bool Function() cognitiveAccessibilityEnabled;
  final Future<void> Function(bool) onCognitiveAccessibilityChanged;
  final VoidCallback? onProgressReset;

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

final class _AppSettingsScreenState extends State<AppSettingsScreen> {
  @override
  void initState() {
    super.initState();
    if (!widget.notifier.isInitialized) {
      _runSave(widget.notifier.initialize());
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            dark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          title: AppDirectionalText(
            'الإعدادات والملف الشخصي',
            languageCode: 'ar',
            style: AppTypography.title,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: ListenableBuilder(
          listenable: Listenable.merge(<Listenable>[
            widget.notifier,
            widget.accessibilityListenable,
          ]),
          builder: (context, _) {
            final notifier = widget.notifier;
            final preferences = notifier.preferences;
            if (!notifier.isInitialized && notifier.isBusy) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: <Widget>[
                const _SectionHeader(
                  title: 'الصوت والنطق',
                  subtitle: 'اضبط سرعة النطق الألماني لكل الجلسات.',
                ),
                GlassSliderTile(
                  title: 'سرعة النطق',
                  subtitle: 'بطيء للتدريب الدقيق أو عادي للاستماع الطبيعي.',
                  value: preferences.speechRate,
                  valueLabel:
                      preferences.speechRatePreset == SpeechRatePreset.slow
                          ? 'بطيء 0.75×'
                          : 'عادي 1.0×',
                  minimum: 0.75,
                  maximum: 1.0,
                  divisions: 1,
                  icon: Icons.record_voice_over_outlined,
                  onChanged: (value) => _runSave(
                    notifier.setSpeechRatePreset(
                      value <= 0.875
                          ? SpeechRatePreset.slow
                          : SpeechRatePreset.normal,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const _SectionHeader(
                  title: 'الخط والعرض',
                  subtitle: 'غيّر حجم النص والترجمة فورًا على مستوى التطبيق.',
                ),
                GlassSliderTile(
                  title: 'حجم النص',
                  subtitle:
                      'تدرج ثابت يحافظ على قابلية القراءة دون كسر التخطيط.',
                  value: preferences.textScaleFactor,
                  valueLabel:
                      '${(preferences.textScaleFactor * 100).round()}%',
                  minimum: LearningPreferences.minimumTextScale,
                  maximum: LearningPreferences.maximumTextScale,
                  divisions: 9,
                  icon: Icons.text_fields_outlined,
                  onChanged: (value) => _runSave(
                    notifier.setTextScaleFactor(value),
                  ),
                ),
                const SizedBox(height: 12),
                _TranslationGlassTile(
                  value: preferences.showAutomaticTranslation,
                  onChanged: (value) => _runSave(
                    notifier.setShowAutomaticTranslation(value),
                  ),
                ),
                const SizedBox(height: 12),
                _CognitiveAccessibilityGlassTile(
                  value: widget.cognitiveAccessibilityEnabled(),
                  onChanged: (value) => _runSave(
                    widget.onCognitiveAccessibilityChanged(value),
                  ),
                ),
                const SizedBox(height: 12),
                _PreviewCard(preferences: preferences),
                const SizedBox(height: 20),
                const _SectionHeader(
                  title: 'إدارة البيانات',
                  subtitle: 'عمليات محلية فقط مع تأكيد صريح قبل حذف التقدم.',
                ),
                _MetricsCard(notifier: notifier),
                const SizedBox(height: 12),
                GlassActionRow(
                  icon: Icons.cleaning_services_outlined,
                  title: 'تفريغ الذاكرة المؤقتة',
                  subtitle:
                      'يمسح نسخة الإعدادات المؤقتة ويحتفظ بخياراتك المحفوظة.',
                  actionLabel: 'تفريغ',
                  busy: notifier.isBusy,
                  onPressed: notifier.isBusy ? null : _clearCache,
                ),
                const SizedBox(height: 12),
                GlassActionRow(
                  icon: Icons.restart_alt,
                  title: 'إعادة ضبط تقدم التعلم',
                  subtitle:
                      'يحذف XP والمراجعات والمحاولات والمفضلة المحلية عبر المستودع الرسمي.',
                  actionLabel: 'إعادة ضبط',
                  destructive: true,
                  busy: notifier.isBusy,
                  onPressed: notifier.isBusy ? null : _confirmProgressReset,
                ),
                if (notifier.hasError) ...<Widget>[
                  const SizedBox(height: 12),
                  AppGlassCard(
                    glowColor: Theme.of(context).colorScheme.error,
                    child: AppDirectionalText(
                      'تعذر إكمال آخر عملية. لم يتم اعتماد تغيير غير محفوظ.',
                      languageCode: 'ar',
                      style: AppTypography.body.copyWith(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  void _runSave(Future<void> operation) {
    unawaited(operation.catchError((Object _) {}));
  }

  Future<void> _clearCache() async {
    final ok = await widget.notifier.clearCache();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppDirectionalText(
          ok
              ? 'تم تفريغ الذاكرة المؤقتة للإعدادات.'
              : 'تعذر تفريغ الذاكرة المؤقتة.',
          languageCode: 'ar',
          style: AppTypography.body,
        ),
      ),
    );
  }

  Future<void> _confirmProgressReset() async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: AppDirectionalText(
                'إعادة ضبط تقدم التعلم؟',
                languageCode: 'ar',
                style: AppTypography.title,
              ),
              content: AppDirectionalText(
                'سيتم حذف XP والمراجعات والمحاولات والمفضلة من هذا الجهاز. '
                'لا يمكن التراجع عن العملية.',
                languageCode: 'ar',
                style: AppTypography.body,
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: AppDirectionalText(
                    'إلغاء',
                    languageCode: 'ar',
                    style: AppTypography.label,
                  ),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: AppDirectionalText(
                    'إعادة ضبط',
                    languageCode: 'ar',
                    style: AppTypography.label,
                  ),
                ),
              ],
            ),
          ),
        ) ??
        false;
    if (!confirmed) return;

    final reset = await widget.notifier.resetLearningProgress(
      confirmed: true,
    );
    if (!mounted) return;
    if (reset) widget.onProgressReset?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppDirectionalText(
          reset
              ? 'تمت إعادة ضبط تقدم التعلم المحلي.'
              : 'تعذر إعادة ضبط تقدم التعلم بالكامل.',
          languageCode: 'ar',
          style: AppTypography.body,
        ),
      ),
    );
  }
}

final class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            title,
            languageCode: 'ar',
            style: AppTypography.title,
          ),
          const SizedBox(height: 3),
          AppDirectionalText(
            subtitle,
            languageCode: 'ar',
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}

final class _TranslationGlassTile extends StatelessWidget {
  const _TranslationGlassTile({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AppGlassCard(
      borderColor:
          dark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
      backgroundColor:
          dark ? AppColors.darkSurface : AppColors.lightSurface,
      glowColor: AppColors.secondary,
      child: SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        title: AppDirectionalText(
          'الترجمة التلقائية',
          languageCode: 'ar',
          style: AppTypography.title,
        ),
        subtitle: AppDirectionalText(
          'أظهر الترجمة تلقائيًا أثناء التعلم أو أخفها لزيادة الاستدعاء.',
          languageCode: 'ar',
          style: AppTypography.body,
        ),
        secondary: const Icon(Icons.translate_outlined),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

final class _CognitiveAccessibilityGlassTile extends StatelessWidget {
  const _CognitiveAccessibilityGlassTile({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AppGlassCard(
      borderColor:
          dark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
      backgroundColor:
          dark ? AppColors.darkSurface : AppColors.lightSurface,
      glowColor: AppColors.achievement,
      child: SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        title: AppDirectionalText(
          'وضعية التيسير المعرفي',
          languageCode: 'ar',
          style: AppTypography.title,
        ),
        subtitle: AppDirectionalText(
          'يحسّن التباعد ويبسّط العرض لتقليل الإجهاد البصري.',
          languageCode: 'ar',
          style: AppTypography.body,
        ),
        secondary: const Icon(Icons.accessibility_new_outlined),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

final class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.preferences});

  final LearningPreferences preferences;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AppGlassCard(
      borderColor:
          dark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
      backgroundColor:
          dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            'معاينة مباشرة',
            languageCode: 'ar',
            style: AppTypography.label,
          ),
          const SizedBox(height: 8),
          AppDirectionalText(
            'Ich lerne jeden Tag Deutsch.',
            languageCode: 'de',
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          if (preferences.showAutomaticTranslation) ...<Widget>[
            const SizedBox(height: 6),
            AppDirectionalText(
              'أنا أتعلم الألمانية كل يوم.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ],
      ),
    );
  }
}

final class _MetricsCard extends StatelessWidget {
  const _MetricsCard({required this.notifier});

  final SettingsController notifier;

  @override
  Widget build(BuildContext context) {
    final metrics = notifier.storageMetrics;
    final size = metrics.localDataBytes < 1024
        ? '${metrics.localDataBytes} B'
        : '${metrics.localDataKilobytes.toStringAsFixed(1)} KB';
    final clearText = _formatDate(metrics.lastCacheClearAt);
    final dark = Theme.of(context).brightness == Brightness.dark;

    return AppGlassCard(
      borderColor:
          dark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
      backgroundColor:
          dark ? AppColors.darkSurface : AppColors.lightSurface,
      glowColor: AppColors.primary,
      child: Row(
        children: <Widget>[
          const Icon(Icons.storage_outlined, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppDirectionalText(
                  'بيانات الإعدادات المحلية',
                  languageCode: 'ar',
                  style: AppTypography.title,
                ),
                const SizedBox(height: 4),
                AppDirectionalText(
                  'الحجم: $size',
                  languageCode: 'ar',
                  style: AppTypography.body,
                ),
                AppDirectionalText(
                  'آخر تفريغ: $clearText',
                  languageCode: 'ar',
                  style: AppTypography.body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime? value) {
    if (value == null) return 'لم يتم التفريغ بعد';
    final local = value.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}

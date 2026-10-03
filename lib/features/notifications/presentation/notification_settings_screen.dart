import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../application/notification_settings_notifier.dart';
import '../domain/notification_models.dart';
import 'widgets/glass_switch_tile.dart';

final class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({
    required this.notifier,
    super.key,
  });

  final NotificationSettingsNotifier notifier;

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

final class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late Future<NotificationSettingsState> _initial;

  @override
  void initState() {
    super.initState();
    _initial = widget.notifier.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          dark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('التذكيرات الذكية', style: AppTypography.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<NotificationSettingsState>(
        future: _initial,
        builder: (context, initialSnapshot) {
          if (!initialSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return StreamBuilder<NotificationSettingsState>(
            stream: widget.notifier.changes,
            initialData: initialSnapshot.data,
            builder: (context, snapshot) {
              final state = snapshot.data!;
              return _SettingsBody(
                state: state,
                notifier: widget.notifier,
                dark: dark,
              );
            },
          );
        },
      ),
    );
  }
}

final class _SettingsBody extends StatelessWidget {
  const _SettingsBody({
    required this.state,
    required this.notifier,
    required this.dark,
  });

  final NotificationSettingsState state;
  final NotificationSettingsNotifier notifier;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final preference = state.preference;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: <Widget>[
        GlassSwitchTile(
          title: 'تذكير يومي',
          subtitle: 'فعّل جلسة مراجعة قصيرة في الوقت الأنسب لعادتك.',
          icon: Icons.schedule_rounded,
          value: preference.dailyReminderEnabled,
          onChanged: state.isSaving
              ? null
              : notifier.setDailyReminderEnabled,
        ),
        const SizedBox(height: 12),
        GlassSwitchTile(
          title: 'تنبيه حماية السلسلة',
          subtitle: 'تذكير إضافي قبل نهاية اليوم عندما تكون لديك سلسلة.',
          icon: Icons.local_fire_department_rounded,
          value: preference.streakAlertEnabled,
          onChanged: state.isSaving
              ? null
              : notifier.setStreakAlertEnabled,
        ),
        const SizedBox(height: 12),
        AppGlassCard(
          borderColor:
              dark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
          backgroundColor:
              dark ? AppColors.darkSurface : AppColors.lightSurface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('الوقت المفضل', style: AppTypography.title),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.access_time_rounded,
                  color: AppColors.primary,
                ),
                title: Text(
                  _formatTime(context, preference),
                  style: AppTypography.body,
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: state.isSaving
                    ? null
                    : () => _pickTime(context, preference),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppGlassCard(
          borderColor:
              dark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
          backgroundColor:
              dark ? AppColors.darkSurface : AppColors.lightSurface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('نغمة التنبيه', style: AppTypography.title),
              const SizedBox(height: 8),
              SegmentedButton<NotificationTone>(
                segments: const <ButtonSegment<NotificationTone>>[
                  ButtonSegment<NotificationTone>(
                    value: NotificationTone.gentle,
                    label: Text('هادئة'),
                    icon: Icon(Icons.volume_down_rounded),
                  ),
                  ButtonSegment<NotificationTone>(
                    value: NotificationTone.classic,
                    label: Text('افتراضية'),
                    icon: Icon(Icons.notifications_active_outlined),
                  ),
                  ButtonSegment<NotificationTone>(
                    value: NotificationTone.silent,
                    label: Text('صامتة'),
                    icon: Icon(Icons.volume_off_rounded),
                  ),
                ],
                selected: <NotificationTone>{preference.tone},
                onSelectionChanged: state.isSaving
                    ? null
                    : (selection) =>
                        notifier.setTone(selection.first),
              ),
            ],
          ),
        ),
        if (state.isSaving) ...<Widget>[
          const SizedBox(height: 16),
          const LinearProgressIndicator(minHeight: 3),
        ],
      ],
    );
  }

  Future<void> _pickTime(
    BuildContext context,
    NotificationPreference preference,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: preference.preferredHour,
        minute: preference.preferredMinute,
      ),
    );
    if (picked == null) return;
    await notifier.setReminderMinutes(picked.hour * 60 + picked.minute);
  }

  String _formatTime(
    BuildContext context,
    NotificationPreference preference,
  ) {
    return MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay(
        hour: preference.preferredHour,
        minute: preference.preferredMinute,
      ),
    );
  }
}

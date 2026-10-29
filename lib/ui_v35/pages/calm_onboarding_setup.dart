import 'package:flutter/material.dart';

import '../../services/preferences_service.dart';
import '../../services/ui_preferences.dart';

class CalmOnboardingSetupScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  final PreferencesService prefs;

  const CalmOnboardingSetupScreen({
    super.key,
    this.onComplete,
    required this.prefs,
  });

  @override
  State<CalmOnboardingSetupScreen> createState() =>
      _CalmOnboardingSetupScreenState();
}

class _CalmOnboardingSetupScreenState extends State<CalmOnboardingSetupScreen> {
  bool _isSaving = false;
  int? _selectedMinutes;

  Future<void> _savePreferences(int minutes) async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
      _selectedMinutes = minutes;
    });

    try {
      final prefs = widget.prefs;

      int newCardsQuota;
      int reviewLimit;

      switch (minutes) {
        case 5:
          newCardsQuota = 5;
          reviewLimit = 25;
          break;
        case 15:
          newCardsQuota = 15;
          reviewLimit = 75;
          break;
        case 10:
        default:
          newCardsQuota = 10;
          reviewLimit = 50;
          break;
      }

      final saved = await UiPreferences(prefs).setDailyStudyProfile(
        minutes: minutes,
        newCardsQuota: newCardsQuota,
        reviewLimit: reviewLimit,
      );
      if (!saved) {
        throw StateError('Study preferences could not be persisted.');
      }

      if (mounted) {
        if (widget.onComplete != null) {
          widget.onComplete!();
        } else {
          Navigator.of(context).pop();
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildTimeOption(
    BuildContext context,
    int minutes,
    String description,
  ) {
    final isSelected = _selectedMinutes == minutes;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(24.0),
          onTap: _isSaving ? null : () => _savePreferences(minutes),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 24.0,
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1),
                  ),
                  child: Center(
                    child: Text(
                      '$minutes',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$minutes دقائق يومياً',
                        textDirection: TextDirection.rtl,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        textDirection: TextDirection.rtl,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isSelected
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer
                                      .withValues(alpha: 0.8)
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                if (isSelected && _isSaving)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  Icon(
                    Icons.self_improvement,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'مرحباً بك',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w300),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ما هو مقدار الوقت الذي ترغب في تخصيصه للدراسة يومياً؟\nيمكنك تغيير هذا لاحقاً.',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 48),
                  _buildTimeOption(context, 5, 'جلسة قصيرة وخفيفة'),
                  _buildTimeOption(context, 10, 'جلسة معتدلة ومستمرة'),
                  _buildTimeOption(context, 15, 'جلسة مركزة وعميقة'),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

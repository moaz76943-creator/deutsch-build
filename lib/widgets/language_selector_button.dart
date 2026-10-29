import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/active_language_provider.dart';
import '../screens/language_manager_screen.dart';

export '../providers/active_language_provider.dart'
    show activeLanguageProvider, activeLanguageCodeProvider;

/// Must match the canonical Language Manager preference key from Track 3.
const String activeLanguagePreferenceKey = 'language_manager.active_code.v1';
const String _languagePickerCompletedKey = 'language_picker.completed.v1';

/// Entry-point routing guard. Only an explicit selection or completion marker
/// counts as completed onboarding; a built-in default language does not.
Future<bool> checkShouldShowLanguagePicker() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_languagePickerCompletedKey) == true) return false;
    final storedCode = prefs.getString(activeLanguagePreferenceKey);
    return storedCode == null || storedCode.trim().isEmpty;
  } catch (_) {
    return true;
  }
}

/// The startup routing layer may call this after a completed first-run choice,
/// including when the user explicitly selects the bundled German default.
Future<bool> markLanguagePickerCompleted() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_languagePickerCompletedKey, true);
  } catch (_) {
    return false;
  }
}

/// Reusable AppBar action that observes the one canonical Riverpod language
/// provider and opens LanguageManagerScreen without network dependencies.
class LanguageSelectorButton extends ConsumerWidget {
  const LanguageSelectorButton({super.key});

  static const Map<String, String> _flags = <String, String>{
    'ar': '🇸🇦',
    'de': '🇩🇪',
    'en': '🇬🇧',
    'fr': '🇫🇷',
    'es': '🇪🇸',
    'tr': '🇹🇷',
    'ru': '🇷🇺',
    'zh': '🇨🇳',
    'it': '🇮🇹',
    'ja': '🇯🇵',
    'ko': '🇰🇷',
    'fa': '🇮🇷',
    'ur': '🇵🇰',
    'pt': '🇵🇹',
    'hi': '🇮🇳',
    'nl': '🇳🇱',
    'pl': '🇵🇱',
    'uk': '🇺🇦',
    'sv': '🇸🇪',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCode = ref.watch(activeLanguageCodeProvider);
    final baseCode = currentCode.split('-').first.toLowerCase();
    final flag = _flags[baseCode] ?? '🌐';
    final description = 'اللغة الحالية: $currentCode. فتح إدارة اللغات';

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: Tooltip(
        message: description,
        excludeFromSemantics: true,
        child: Semantics(
          button: true,
          label: description,
          child: TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(68, 48),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              foregroundColor: Theme.of(context).appBarTheme.foregroundColor ??
                  Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {
              // An explicit visit starts cached-pack verification and catalog IO.
              unawaited(ref.read(activeLanguageProvider.notifier).initialize());
              Navigator.of(context).push<void>(
                PageRouteBuilder<void>(
                  pageBuilder: (_, animation, secondaryAnimation) =>
                      const LanguageManagerScreen(),
                  transitionDuration: const Duration(milliseconds: 280),
                  reverseTransitionDuration: const Duration(milliseconds: 220),
                  transitionsBuilder: (_, animation, secondaryAnimation, child) {
                    final progress = animation.drive(
                      CurveTween(curve: Curves.easeOutCubic),
                    );
                    return FadeTransition(
                      opacity: progress,
                      child: SlideTransition(
                        position: progress.drive(
                          Tween<Offset>(
                            begin: const Offset(0.08, 0),
                            end: Offset.zero,
                          ),
                        ),
                        child: child,
                      ),
                    );
                  },
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(flag, style: const TextStyle(fontSize: 21)),
                const SizedBox(width: 6),
                Text(
                  baseCode.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.35,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.expand_more_rounded, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

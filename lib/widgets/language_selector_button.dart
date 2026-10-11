import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/language_manager_screen.dart';

/// Shared with language-selection UI so the first-run guard has one source of
/// truth. A default shown in the AppBar is NOT treated as user confirmation.
const String activeLanguagePreferenceKey = 'active_language_code';
const String _defaultLanguage = 'ar';

String? _canonicalLanguageTag(String? input) {
  if (input == null) return null;
  final raw = input.trim().replaceAll('_', '-');
  if (!RegExp(r'^[a-zA-Z]{2,8}(?:-[a-zA-Z0-9]{2,8})*$').hasMatch(raw)) {
    return null;
  }
  final pieces = raw.split('-');
  final language = pieces.first.toLowerCase();
  final tail = pieces.skip(1).map((part) {
    if (part.length == 4 && RegExp(r'^[a-zA-Z]{4}$').hasMatch(part)) {
      return part[0].toUpperCase() + part.substring(1).toLowerCase();
    }
    if (part.length == 2 && RegExp(r'^[a-zA-Z]{2}$').hasMatch(part)) {
      return part.toUpperCase();
    }
    return part.toLowerCase();
  });
  return <String>[language, ...tail].join('-');
}

/// True when no explicit language choice has been persisted. Fail closed to
/// the picker if local storage is unavailable; never infer completion from a
/// visual default. Call from the app's startup router (not from build()).
Future<bool> checkShouldShowLanguagePicker() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return _canonicalLanguageTag(
          prefs.getString(activeLanguagePreferenceKey),
        ) ==
        null;
  } catch (_) {
    return true;
  }
}

/// Owns the active UI language and persists explicit choices offline.
/// Other language-selection UIs can change it with:
/// ref.read(activeLanguageProvider.notifier).selectLanguage('fr');
class ActiveLanguageController extends StateNotifier<String> {
  ActiveLanguageController() : super(_defaultLanguage) {
    unawaited(reloadFromStorage());
  }

  int _revision = 0;

  Future<void> reloadFromStorage() async {
    final revision = _revision;
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = _canonicalLanguageTag(
        prefs.getString(activeLanguagePreferenceKey),
      );
      if (mounted && revision == _revision && stored != null) {
        state = stored;
      }
    } catch (_) {
      // Storage failure leaves the safe, in-memory language unchanged.
    }
  }

  /// Updates listening widgets immediately, then stores the selection.
  /// Returns false on an invalid code or failed persistence.
  Future<bool> selectLanguage(String languageCode) async {
    final canonical = _canonicalLanguageTag(languageCode);
    if (canonical == null || !mounted) return false;

    final revision = ++_revision;
    state = canonical;
    try {
      final prefs = await SharedPreferences.getInstance();
      // A newer user selection must not be overwritten by stale work.
      if (!mounted || revision != _revision) return false;
      return await prefs.setString(activeLanguagePreferenceKey, canonical);
    } catch (_) {
      return false;
    }
  }
}

/// This provider is intentionally defined in the single allowed new file:
/// the base branch does not yet define activeLanguageProvider elsewhere.
final activeLanguageProvider =
    StateNotifierProvider<ActiveLanguageController, String>((ref) {
  return ActiveLanguageController();
});

/// An AppBar action that reacts to the current language and opens the manager.
/// Add with: AppBar(actions: const [LanguageSelectorButton()]).
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
    final activeCode = ref.watch(activeLanguageProvider);
    final language = activeCode.split('-').first.toLowerCase();
    final codeLabel = language.toUpperCase();
    final flag = _flags[language] ?? '🌐';
    final description = 'اللغة الحالية: $activeCode. فتح إدارة اللغات';

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
            onPressed: () async {
              await Navigator.of(context).push<void>(
                PageRouteBuilder<void>(
                  pageBuilder: (routeContext, animation, secondaryAnimation) =>
                      const LanguageManagerScreen(),
                  transitionDuration: const Duration(milliseconds: 280),
                  reverseTransitionDuration: const Duration(milliseconds: 220),
                  transitionsBuilder:
                      (routeContext, animation, secondaryAnimation, child) {
                    final curved = animation.drive(
                      CurveTween(curve: Curves.easeOutCubic),
                    );
                    final slide = curved.drive(
                      Tween<Offset>(
                        begin: const Offset(0.08, 0),
                        end: Offset.zero,
                      ),
                    );
                    return FadeTransition(
                      opacity: curved,
                      child: SlideTransition(position: slide, child: child),
                    );
                  },
                ),
              );
              if (context.mounted) {
                await ref.read(activeLanguageProvider.notifier).reloadFromStorage();
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(flag, style: const TextStyle(fontSize: 21)),
                const SizedBox(width: 6),
                Text(
                  codeLabel,
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/active_language_provider.dart';

/// A compact strip of native characters for the active Latin-script language.
///
/// Place this in [Scaffold.bottomSheet] to keep it immediately above the
/// software keyboard when Scaffold resizes for the keyboard.
/// [languageCode] overrides the active language when a caller needs to display
/// a particular language (for example, a language-specific search field).
class SpecialCharacterBar extends ConsumerWidget {
  const SpecialCharacterBar({
    super.key,
    required this.controller,
    this.languageCode,
  });

  final TextEditingController controller;
  final String? languageCode;

  // Small, immutable lookups shared by every instance; no per-language state.
  static const Map<String, List<String>> _glyphs = <String, List<String>>{
    'de': <String>['ä', 'ö', 'ü', 'ß'],
    'tr': <String>['ç', 'ğ', 'ı', 'ö', 'ş', 'ü'],
    'cs': <String>[
      'č', 'ď', 'é', 'ě', 'í', 'ň', 'ó', 'ř', 'š', 'ť', 'ú', 'ů', 'ý', 'ž',
    ],
    'pl': <String>['ą', 'ć', 'ę', 'ł', 'ń', 'ó', 'ś', 'ź', 'ż'],
    'fr': <String>[
      'à', 'â', 'æ', 'ç', 'é', 'è', 'ê', 'ë', 'î', 'ï', 'ô', 'œ', 'ù', 'û', 'ü', 'ÿ',
    ],
    'es': <String>['á', 'é', 'í', 'ñ', 'ó', 'ú', 'ü', '¿', '¡'],
    'it': <String>['à', 'è', 'é', 'ì', 'í', 'î', 'ò', 'ó', 'ù', 'ú'],
    'pt': <String>['á', 'â', 'ã', 'à', 'ç', 'é', 'ê', 'í', 'ó', 'ô', 'õ', 'ú'],
    'nl': <String>['é', 'ë', 'ï', 'ö', 'ü'],
    'sv': <String>['å', 'ä', 'ö'],
    'da': <String>['æ', 'ø', 'å'],
    'no': <String>['æ', 'ø', 'å'],
    'fi': <String>['ä', 'ö', 'å'],
    'hu': <String>['á', 'é', 'í', 'ó', 'ö', 'ő', 'ú', 'ü', 'ű'],
    'sk': <String>[
      'á', 'ä', 'č', 'ď', 'é', 'í', 'ĺ', 'ľ', 'ň', 'ó', 'ô', 'ŕ', 'š', 'ť', 'ú', 'ý', 'ž',
    ],
    'ro': <String>['ă', 'â', 'î', 'ș', 'ț'],
    'hr': <String>['č', 'ć', 'đ', 'š', 'ž'],
    'bs': <String>['č', 'ć', 'đ', 'š', 'ž'],
    'sl': <String>['č', 'š', 'ž'],
    'lv': <String>['ā', 'č', 'ē', 'ģ', 'ī', 'ķ', 'ļ', 'ņ', 'š', 'ū', 'ž'],
    'lt': <String>['ą', 'č', 'ę', 'ė', 'į', 'š', 'ų', 'ū', 'ž'],
    'et': <String>['ä', 'ö', 'õ', 'ü'],
    'is': <String>['á', 'ð', 'é', 'í', 'ó', 'ö', 'þ', 'ú', 'ý', 'æ'],
    'ca': <String>['à', 'ç', 'è', 'é', 'í', 'ï', 'ò', 'ó', 'ú', 'ü', '·'],
    'az': <String>['ç', 'ə', 'ğ', 'ı', 'ö', 'ş', 'ü'],
    'sq': <String>['ç', 'ë'],
  };

  /// An unmodifiable list; empty for ASCII-only, Arabic-script, and other
  /// languages with no configured Latin accent strip.
  static List<String> charactersForLanguage(String code) {
    final normalized = code.trim().toLowerCase().replaceAll('_', '-');
    final primary = normalized.split('-').first;
    return _glyphs[primary] ?? const <String>[];
  }

  static void _insertCharacter(TextEditingController controller, String glyph) {
    final oldValue = controller.value;
    final text = oldValue.text;
    final selection = oldValue.selection;
    final hasValidRange = selection.isValid &&
        selection.start <= text.length &&
        selection.end <= text.length;
    final start = hasValidRange ? selection.start : text.length;
    final end = hasValidRange ? selection.end : text.length;
    final nextText = text.replaceRange(start, end, glyph);

    // Replace the value atomically and discard stale IME composing ranges.
    controller.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: start + glyph.length),
      composing: TextRange.empty,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = languageCode ?? ref.watch(activeLanguageCodeProvider);
    final characters = charactersForLanguage(code ?? 'de');
    if (characters.isEmpty) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      elevation: 2,
      child: SafeArea(
        top: false,
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (final glyph in characters)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 6),
                      child: Tooltip(
                        message: 'Insert $glyph',
                        child: Material(
                          color: colors.secondaryContainer,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            key: ValueKey<String>('special-character-$glyph'),
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => _insertCharacter(controller, glyph),
                            child: SizedBox(
                              width: 44,
                              height: 44,
                              child: Center(
                                child: Text(
                                  glyph,
                                  style: TextStyle(
                                    color: colors.onSecondaryContainer,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
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

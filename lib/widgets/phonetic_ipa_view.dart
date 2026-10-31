import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Removes only surrounding slash notation and whitespace.
///
/// Interior IPA characters, stress marks, combining diacritics, and separators
/// are preserved verbatim. This does not attempt transcription or translation.
String _ipaBody(String value) =>
    value.trim().replaceAll(RegExp(r'^/+|/+$'), '').trim();

/// Whether a word has usable phonetic transcription to display.
bool hasPhoneticData(String? ipa) => ipa != null && _ipaBody(ipa).isNotEmpty;

/// Wraps an IPA transcription in one pair of phonemic slashes.
///
/// Empty, whitespace-only, or slash-only input produces an empty string.
String formatIpa(String raw) {
  final body = _ipaBody(raw);
  return body.isEmpty ? '' : '/$body/';
}

/// Readable, copyable IPA fallback when spoken TTS is unavailable.
///
/// This widget does not synthesize IPA and does not request any permissions,
/// network services, bundled fonts, or additional packages.
class PhoneticIpaView extends StatelessWidget {
  const PhoneticIpaView({super.key, this.ipa});

  /// Precomputed IPA transcription supplied by the content layer.
  final String? ipa;

  @override
  Widget build(BuildContext context) {
    if (!hasPhoneticData(ipa)) {
      return const SizedBox.shrink();
    }

    final transcription = formatIpa(ipa!);
    final darkMode = Theme.of(context).brightness == Brightness.dark;

    // White-on-black / black-on-white remain legible in both theme modes,
    // independent of custom application ColorScheme choices.
    final foreground = darkMode ? Colors.white : Colors.black;
    final background = darkMode ? Colors.black : Colors.white;

    return Semantics(
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: foreground, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(12, 4, 4, 4),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  transcription,
                  textDirection: TextDirection.ltr,
                  softWrap: true,
                  semanticsLabel: 'IPA pronunciation: $transcription',
                  style: TextStyle(
                    color: foreground,
                    fontFamily: 'monospace',
                    // System font fallbacks, including IPA-capable Noto faces.
                    // Actual glyph coverage depends on the installed OS fonts.
                    fontFamilyFallback: const <String>[
                      'Noto Sans',
                      'Noto Serif',
                      'Noto Sans Symbols 2',
                      'serif',
                      'sans-serif',
                    ],
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Copy IPA pronunciation',
                icon: const Icon(Icons.copy_rounded),
                iconSize: 20,
                color: foreground,
                constraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 48,
                ),
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: transcription),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

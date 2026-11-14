import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/i18n/canonical_language_catalog.dart';

/// Owner language policy: exactly 100 registered languages, Hebrew excluded,
/// and the generated machine-readable registry must match the Dart catalog.
void main() {
  group('Language policy — 100 registered languages, Hebrew excluded', () {
    test('registry holds exactly 100 distinct language ids', () {
      expect(CanonicalLanguageCatalog.totalCount, equals(100));
      final ids = CanonicalLanguageCatalog.catalog.keys.toSet();
      expect(ids.length, equals(100));
    });

    test('Hebrew is not registered under any of its language ids', () {
      for (final excluded in const ['he', 'iw']) {
        expect(
          CanonicalLanguageCatalog.catalog.containsKey(excluded),
          isFalse,
          reason: 'excluded language id "$excluded" must not be registered',
        );
        expect(CanonicalLanguageCatalog.isSupported(excluded), isFalse);
      }
      final nativeNames =
          CanonicalLanguageCatalog.getAllProfiles().map((p) => p.nativeName);
      expect(nativeNames.contains('עברית'), isFalse);
    });

    test('generated registry artifact stays in sync with the Dart catalog', () {
      final file = File('assets/registry/languages_100.json');
      expect(file.existsSync(), isTrue, reason: 'run tools/polyglot/registry_sync.py --write');

      final payload = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      expect(payload['languageCount'], equals(100));

      final generated = <String, Map<String, dynamic>>{
        for (final raw in (payload['languages'] as List))
          (raw as Map<String, dynamic>)['id'] as String: raw,
      };
      expect(generated.length, equals(CanonicalLanguageCatalog.totalCount));

      for (final entry in CanonicalLanguageCatalog.catalog.entries) {
        final mirrored = generated[entry.key];
        expect(mirrored, isNotNull, reason: 'missing ${entry.key} in generated registry');
        expect(mirrored!['bcp47'], equals(entry.value.bcp47));
        expect(mirrored['script'], equals(entry.value.script.code));
        expect(
          mirrored['direction'],
          equals(entry.value.script.isRtl ? 'rtl' : 'ltr'),
        );
      }
      expect(payload['policy']['hebrewExcluded'], isTrue);
    });

    test('every registered language has exactly one content-pack placeholder', () {
      final stubs = Directory('assets/languages')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .map((f) => f.uri.pathSegments.last.replaceAll('.json', ''))
          .toSet();
      expect(stubs.length, equals(CanonicalLanguageCatalog.totalCount));
      expect(stubs.difference(CanonicalLanguageCatalog.catalog.keys.toSet()), isEmpty);
      expect(CanonicalLanguageCatalog.catalog.keys.toSet().difference(stubs), isEmpty);
    });
  });
}

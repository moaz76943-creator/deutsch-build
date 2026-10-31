import 'dart:convert';

import 'package:deutsch_bilarabi/core/catalog/canonical_language_catalog.dart';
import 'package:deutsch_bilarabi/core/catalog/language_readiness_matrix.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CanonicalLanguageCatalog catalog;
  late Map<String, dynamic> bundled;

  setUpAll(() async {
    bundled = jsonDecode(
      await rootBundle.loadString('assets/data/catalog.json'),
    ) as Map<String, dynamic>;
    catalog = CanonicalLanguageCatalog.fromJson(bundled);
  });

  test('public registry maintains exactly 100 pinned identities', () {
    const expected = <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'it',
    'tr',
    'ru',
    'zh',
    'ja',
    'ko',
    'pt',
    'nl',
    'pl',
    'sv',
    'no',
    'da',
    'fi',
    'el',
    'hi',
    'ur',
    'fa',
    'id',
    'ms',
    'vi',
    'th',
    'bn',
    'pa',
    'ta',
    'te',
    'mr',
    'gu',
    'uk',
    'cs',
    'ro',
    'hu',
    'bg',
    'sk',
    'hr',
    'sr',
    'bs',
    'sq',
    'hy',
    'ka',
    'az',
    'kk',
    'uz',
    'sw',
    'tl',
    'af',
    'et',
    'lv',
    'lt',
    'sl',
    'mk',
    'is',
    'ga',
    'cy',
    'eu',
    'ca',
    'gl',
    'be',
    'mn',
    'ne',
    'si',
    'my',
    'km',
    'lo',
    'am',
    'so',
    'ha',
    'yo',
    'ig',
    'zu',
    'xh',
    'sn',
    'rw',
    'mg',
    'eo',
    'la',
    'kn',
    'ml',
    'or',
    'as',
    'sd',
    'ps',
    'ku',
    'tg',
    'tk',
    'ky',
    'tt',
    'ba',
    'ug',
    'dv',
    'mt',
    'lb',
    'fo',
    'fy',
    'gd',
    'br',
    ];
    expect(catalog.canonicalIds.length, 100);
    expect(catalog.canonicalIds.toSet(), expected.toSet());
    expect(catalog.canonicalIds.toSet().length, 100);
    expect(bundled['maxRegisteredLanguages'], 100);
    expect(bundled['theoreticalDirectedPairCapacity'], 9900);
    expect(bundled['canonicalSource']['registryMergeHead'],
        '469fc77d9b4ba26d59da46c7d7904c3613d3b5da');
  });

  test('five pilot IDs remain metadata-only, not content-ready', () {
    for (final code in <String>['de', 'ar', 'en', 'es', 'fr']) {
      final lifecycle = catalog.readinessFor(code);
      expect(lifecycle.registered, isTrue, reason: code);
      expect(lifecycle.contentAvailable, isFalse, reason: code);
      expect(lifecycle.packVerified, isFalse, reason: code);
      expect(lifecycle.installed, isFalse, reason: code);
      expect(lifecycle.productionReady, isFalse, reason: code);
      expect(LanguageReadinessMatrix.getTier(code),
          LanguageReadinessTier.nominal);
    }
  });

  test('all nine private-only persisted IDs survive unchanged', () {
    const historical = <String>[
      'fil', 'he', 'jv', 'ny', 'om', 'st', 'su', 'ti', 'wo',
    ];
    expect(catalog.legacyIds.toSet(), historical.toSet());
    for (final code in historical) {
      final result = catalog.resolvePersistedId(code);
      expect(result.requestedTag, code);
      expect(result.language?.id, code);
      expect(result.status, CatalogIdentityStatus.retainedLegacy);
      expect(result.canonicalId, isNull);
      expect(catalog.readinessFor(code).productionReady, isFalse);
    }
  });

  test('lossy aliases stay review-only; do not silently rewrite', () {
    final norwegian = catalog.resolvePersistedId('nb');
    expect(norwegian.status, CatalogIdentityStatus.reviewRequired);
    expect(norwegian.requestedTag, 'nb');
    expect(norwegian.canonicalId, isNull);
    expect(norwegian.suggestedId, 'no');

    final filipino = catalog.resolvePersistedId('fil');
    expect(filipino.status, CatalogIdentityStatus.retainedLegacy);
    expect(filipino.canonicalId, isNull);
    expect(filipino.suggestedId, 'tl');
    expect(filipino.requiresReview, isTrue);

    expect(catalog.resolvePersistedId('tl').canonicalId, 'tl');
  });

  test('script variants preserve requested locale without pack claims', () {
    final han = catalog.resolvePersistedId('zh-Hant');
    expect(han.status, CatalogIdentityStatus.canonical);
    expect(han.canonicalId, 'zh');
    expect(han.requestedTag, 'zh-Hant');
    expect(catalog.readinessFor('zh-Hant').packVerified, isFalse);
    expect(catalog.resolvePersistedId('ku-Arab').language?.id, 'ku');
  });

  test('unknown identifiers never pivot to German', () {
    for (final code in <String>['zz', '', 'he-IL', 'not/a/language']) {
      final result = catalog.resolvePersistedId(code);
      expect(result.canonicalId, isNull, reason: code);
      expect(result.language, isNull, reason: code);
      expect(catalog.readinessFor(code).registered, isFalse, reason: code);
    }
  });

  test('readiness needs explicit matching verification evidence', () {
    const verified = CatalogVerificationEvidence(
      languageCode: 'fr',
      licenseApproved: true,
      contentValidated: true,
      acceptedEntryCount: 3,
      checksumSha256:
          'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      packSchemaValidated: true,
      packDigestValidated: true,
      installedOnDevice: true,
      productionGateApproved: true,
    );

    final ready = catalog.readinessFor('fr', evidence: verified);
    expect(ready.registered, isTrue);
    expect(ready.contentAvailable, isTrue);
    expect(ready.packVerified, isTrue);
    expect(ready.installed, isTrue);
    expect(ready.productionReady, isTrue);
    expect(LanguageReadinessMatrix.getTier('fr', lifecycle: ready),
        LanguageReadinessTier.productionReady);
    expect(LanguageReadinessMatrix.getTier('es', lifecycle: ready),
        LanguageReadinessTier.nominal);
    expect(catalog.readinessFor('es', evidence: verified).productionReady,
        isFalse);
    expect(catalog.readinessFor('zh-Hant', evidence: verified).packVerified,
        isFalse);
    expect(catalog.readinessFor('fil', evidence: verified).registered, isFalse);

    const missingDigest = CatalogVerificationEvidence(
      languageCode: 'fr',
      licenseApproved: true,
      contentValidated: true,
      acceptedEntryCount: 3,
      checksumSha256: null,
      packSchemaValidated: true,
      packDigestValidated: false,
      installedOnDevice: true,
      productionGateApproved: true,
    );
    final blocked = catalog.readinessFor('fr', evidence: missingDigest);
    expect(blocked.contentAvailable, isTrue);
    expect(blocked.packVerified, isFalse);
    expect(blocked.installed, isFalse);
    expect(blocked.productionReady, isFalse);
  });

  test('malformed or overclaimed catalogs fail closed', () {
    final duplicate = jsonDecode(jsonEncode(bundled)) as Map<String, dynamic>;
    final entries = duplicate['languages'] as List<dynamic>;
    final second = entries[1] as Map<String, dynamic>;
    second['languageCode'] = (entries[0] as Map<String, dynamic>)['languageCode'];
    second['id'] = second['languageCode'];
    expect(() => CanonicalLanguageCatalog.fromJson(duplicate),
        throwsFormatException);

    final overclaim = jsonDecode(jsonEncode(bundled)) as Map<String, dynamic>;
    final statuses = overclaim['readiness'] as Map<String, dynamic>;
    statuses['de'] = 'production_ready';
    expect(() => CanonicalLanguageCatalog.fromJson(overclaim),
        throwsFormatException);
  });
}

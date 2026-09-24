import 'package:deutsch_bilarabi/language/language_identity.dart';
import 'package:deutsch_bilarabi/semantic_content/artifact_provenance.dart';
import 'package:deutsch_bilarabi/semantic_content/language_realization.dart';
import 'package:deutsch_bilarabi/semantic_content/learner_content_key.dart';
import 'package:deutsch_bilarabi/semantic_content/legacy_binding.dart';
import 'package:deutsch_bilarabi/semantic_content/semantic_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('F2-SCHEMA-A learner identity', () {
    test('same local id across languages does not collide', () {
      final de = LearnerContentKey(
        languageId: 'de',
        contentNamespaceId: 'core',
        localItemId: 'w0001',
      );
      final ar = LearnerContentKey(
        languageId: 'ar',
        contentNamespaceId: 'core',
        localItemId: 'w0001',
      );

      expect(de, isNot(ar));
      expect(<LearnerContentKey>{de, ar}, hasLength(2));
    });

    test('legacy German id remains resolvable without semantic substitution', () {
      final binding = LegacyBinding.german(
        legacyId: 'w0001',
        bindingVersion: 1,
        semanticRefs: const ['sem:opaque:greeting'],
        provenance: ArtifactProvenance.unknown(
          producer: 'legacy-import',
        ),
      );

      expect(
        binding.resolveLearnerContentKey(),
        LearnerContentKey.germanLegacy('w0001'),
      );
      expect(binding.semanticRefs.single, 'sem:opaque:greeting');
      expect(
        binding.resolveLearnerContentKey().localItemId,
        isNot(binding.semanticRefs.single),
      );
    });
  });

  group('F2-SCHEMA-A semantic identity prevention', () {
    test('row order and numeric legacy suffix do not allocate semantic identity', () {
      final first = LegacyBinding(
        legacyNamespace: 'legacy-german-content',
        legacyId: 'w9999',
        bindingVersion: 1,
        languageId: 'de',
        semanticRefs: const ['sem:opaque:stable'],
        provenance: ArtifactProvenance.unknown(producer: 'fixture-a'),
      );
      final reordered = LegacyBinding(
        legacyNamespace: 'legacy-german-content',
        legacyId: 'w0001',
        bindingVersion: 1,
        languageId: 'de',
        semanticRefs: const ['sem:opaque:stable'],
        provenance: ArtifactProvenance.unknown(producer: 'fixture-b'),
      );

      expect(first.semanticRefs.single, 'sem:opaque:stable');
      expect(reordered.semanticRefs.single, 'sem:opaque:stable');
      expect(first.legacyId, isNot(reordered.legacyId));
    });

    test('surface edits do not reallocate semantic identity', () {
      final language = LanguageIdentity(
        languageId: 'de',
        displayName: 'German',
        primaryLocale: 'de-DE',
      );
      final provenance = ArtifactProvenance.unknown(producer: 'synthetic-test');

      final before = LanguageRealization(
        realizationId: 'real:de:1',
        semanticId: 'sem:opaque:1',
        language: language,
        realizationVersion: 1,
        kind: LanguageRealizationKind.phrase,
        surface: 'Guten Tag',
        provenance: provenance,
      );
      final after = LanguageRealization(
        realizationId: 'real:de:1',
        semanticId: 'sem:opaque:1',
        language: language,
        realizationVersion: 2,
        kind: LanguageRealizationKind.phrase,
        surface: 'Guten Tag!',
        provenance: provenance,
      );

      expect(before.semanticId, after.semanticId);
      expect(before.surface, isNot(after.surface));
    });

    test('semantic record keeps concept and intent aliases separate from id', () {
      final record = SemanticRecord(
        semanticId: 'sem:opaque:42',
        semanticVersion: 1,
        kind: SemanticKind.intent,
        conceptId: 'COMMERCE_PRICE',
        intentId: 'ASK_PRICE',
        provenance: ArtifactProvenance.unknown(producer: 'synthetic-test'),
      );

      expect(record.semanticId, 'sem:opaque:42');
      expect(record.conceptId, 'COMMERCE_PRICE');
      expect(record.intentId, 'ASK_PRICE');
      expect(record.semanticId, isNot(record.conceptId));
      expect(record.semanticId, isNot(record.intentId));
    });
  });

  group('F2-SCHEMA-A fail closed evidence boundaries', () {
    test('language-owned extension mismatch fails closed', () {
      final language = LanguageIdentity(
        languageId: 'de',
        displayName: 'German',
        primaryLocale: 'de-DE',
      );
      final extension = LanguageOwnedExtension(
        languageId: 'ar',
        schemaRef: 'schema:ar:test',
        schemaVersion: '1',
        payload: const {'fixture': true},
      );

      expect(
        () => LanguageRealization(
          realizationId: 'real:de:mismatch',
          semanticId: 'sem:opaque:mismatch',
          language: language,
          realizationVersion: 1,
          kind: LanguageRealizationKind.lexeme,
          extensions: [extension],
          provenance: ArtifactProvenance.unknown(producer: 'synthetic-test'),
        ),
        throwsStateError,
      );
    });

    test('unknown provenance cannot self-promote to canonical or ready', () {
      final provenance = ArtifactProvenance.unknown(producer: 'ai-candidate');

      expect(provenance.status, ArtifactProvenanceStatus.unknown);
      expect(provenance.grantsCanonicalAuthority, isFalse);
      expect(provenance.grantsReadinessAuthority, isFalse);
    });

    test('artifact fingerprints require explicit version and fingerprint', () {
      expect(
        () => ArtifactFingerprint(
          artifactType: 'semantic-record',
          version: '',
          fingerprint: 'sha256:test',
        ),
        throwsArgumentError,
      );
      expect(
        () => ArtifactFingerprint(
          artifactType: 'semantic-record',
          version: '1',
          fingerprint: '',
        ),
        throwsArgumentError,
      );
    });
  });
}

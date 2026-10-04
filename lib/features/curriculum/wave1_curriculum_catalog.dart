import '../../core/content_pipeline/content_cas_manifest.dart';
import '../../core/content_pipeline/parallel_content_pipeline.dart';

final class Wave1LanguagePackDescriptor {
  const Wave1LanguagePackDescriptor({
    required this.source,
    required this.packId,
    required this.languageCode,
  });

  final String source;
  final String packId;
  final String languageCode;

  LanguagePackRequest toImportRequest() => LanguagePackRequest(
        packId: packId,
        languageCode: languageCode,
        source: source,
        requireManifestVerification: true,
      );
}

final class Wave1DirectedPair {
  const Wave1DirectedPair(
    this.sourceLanguage,
    this.targetLanguage,
  );

  final String sourceLanguage;
  final String targetLanguage;

  String get id => '$sourceLanguage->$targetLanguage';
}

final class Wave1CurriculumCatalog {
  const Wave1CurriculumCatalog(this.manifest);

  static const String manifestPath =
      'assets/data/manifest/checksums.json';
  static const String validatorVersion = 'phase18-wave1-v1';

  static const List<Wave1LanguagePackDescriptor> packs =
      <Wave1LanguagePackDescriptor>[
    Wave1LanguagePackDescriptor(
      source: 'assets/data/wave1/de.json',
      packId: 'wave1-de-core',
      languageCode: 'de',
    ),
    Wave1LanguagePackDescriptor(
      source: 'assets/data/wave1/ar.json',
      packId: 'wave1-ar-core',
      languageCode: 'ar',
    ),
    Wave1LanguagePackDescriptor(
      source: 'assets/data/wave1/en.json',
      packId: 'wave1-en-core',
      languageCode: 'en',
    ),
    Wave1LanguagePackDescriptor(
      source: 'assets/data/wave1/zh-hans.json',
      packId: 'wave1-zh-hans-core',
      languageCode: 'zh-Hans',
    ),
    Wave1LanguagePackDescriptor(
      source: 'assets/data/wave1/ru.json',
      packId: 'wave1-ru-core',
      languageCode: 'ru',
    ),
    Wave1LanguagePackDescriptor(
      source: 'assets/data/wave1/hi.json',
      packId: 'wave1-hi-core',
      languageCode: 'hi',
    ),
  ];

  static const List<Wave1DirectedPair> directedPairs =
      <Wave1DirectedPair>[
    Wave1DirectedPair('de', 'ar'),
    Wave1DirectedPair('ar', 'de'),
    Wave1DirectedPair('en', 'ar'),
    Wave1DirectedPair('ar', 'en'),
    Wave1DirectedPair('zh-Hans', 'ar'),
    Wave1DirectedPair('ar', 'zh-Hans'),
    Wave1DirectedPair('ru', 'ar'),
    Wave1DirectedPair('ar', 'ru'),
    Wave1DirectedPair('hi', 'ar'),
    Wave1DirectedPair('ar', 'hi'),
  ];

  final ContentCasManifest manifest;

  Iterable<LanguagePackRequest> get importRequests sync* {
    _requireManifestCoverage();
    for (final pack in packs) {
      yield pack.toImportRequest();
    }
  }

  bool supportsDirectedPair(
    String sourceLanguage,
    String targetLanguage,
  ) {
    return manifest.supportsDirectedPair(
      sourceLanguage,
      targetLanguage,
    );
  }

  void _requireManifestCoverage() {
    if (manifest.contentEpoch != validatorVersion) {
      throw const FormatException(
        'Wave 1 content epoch does not match curriculum validator',
      );
    }
    for (final pack in packs) {
      manifest.verifySource(
        source: pack.source,
        packId: pack.packId,
        languageCode: pack.languageCode,
        checksum: manifest.requireEntry(pack.source).sha256,
      );
    }
    for (final pair in directedPairs) {
      if (!manifest.supportsDirectedPair(
        pair.sourceLanguage,
        pair.targetLanguage,
      )) {
        throw FormatException(
          'Wave 1 manifest is missing directed pair: ' + pair.id,
        );
      }
    }
  }
}

import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// A product identity is distinct from a locale/script variant and pack state.
class CatalogLanguage {
  const CatalogLanguage({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.nativeName,
    required this.textDirection,
    required this.isLegacy,
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final String nativeName;
  final String textDirection;
  final bool isLegacy;

  factory CatalogLanguage.fromJson(Map<String, dynamic> record,
      {required bool isLegacy}) {
    return CatalogLanguage(
      id: record['languageCode'] as String,
      nameEn: record['displayName'] as String,
      nameAr: record['displayNameAr'] as String,
      nativeName: record['nativeName'] as String,
      textDirection: record['textDirection'] as String,
      isLegacy: isLegacy,
    );
  }
}

enum CatalogIdentityStatus { canonical, retainedLegacy, reviewRequired, unknown }

class CatalogIdentityResolution {
  const CatalogIdentityResolution({
    required this.requestedTag,
    required this.status,
    this.language,
    this.canonicalId,
    this.suggestedId,
    this.requiresReview = false,
  });

  /// Original selection must be preserved in learner storage.
  final String requestedTag;
  final CatalogIdentityStatus status;
  final CatalogLanguage? language;
  final String? canonicalId;

  /// For UI review only; must never be substituted automatically.
  final String? suggestedId;
  final bool requiresReview;
}

/// External verified facts from the approved content, installer and release
/// gates; the metadata registry itself never creates these facts.
class CatalogVerificationEvidence {
  const CatalogVerificationEvidence({
    required this.languageCode,
    required this.licenseApproved,
    required this.contentValidated,
    required this.acceptedEntryCount,
    required this.checksumSha256,
    required this.packSchemaValidated,
    required this.packDigestValidated,
    required this.installedOnDevice,
    required this.productionGateApproved,
  });

  final String languageCode;
  final bool licenseApproved;
  final bool contentValidated;
  final int acceptedEntryCount;
  final String? checksumSha256;
  final bool packSchemaValidated;
  final bool packDigestValidated;
  final bool installedOnDevice;
  final bool productionGateApproved;
}

class CatalogLifecycle {
  const CatalogLifecycle({
    required this.languageCode,
    required this.registered,
    required this.contentAvailable,
    required this.packVerified,
    required this.installed,
    required this.productionReady,
  });

  final String languageCode;
  final bool registered;
  final bool contentAvailable;
  final bool packVerified;
  final bool installed;
  final bool productionReady;
}

/// Offline-only canonical public registry with explicit preservation of the
/// nine private identities that predate the public 100-ID selection.
///
/// All maps scale linearly with language count. No pair cache or implicit
/// source/target language switching occurs in this catalog.
class CanonicalLanguageCatalog {
  CanonicalLanguageCatalog._(
    this._canonical,
    this._legacy,
    this._aliases,
    this._variants,
  );

  final Map<String, CatalogLanguage> _canonical;
  final Map<String, CatalogLanguage> _legacy;
  final Map<String, String> _aliases;
  final Map<String, String> _variants;

  static final RegExp _validId = RegExp(r'^[a-z]{2,3}$');
  static final RegExp _validSha256 = RegExp(r'^[0-9a-fA-F]{64}$');

  List<String> get canonicalIds => List<String>.unmodifiable(_canonical.keys);
  List<String> get legacyIds => List<String>.unmodifiable(_legacy.keys);
  Iterable<CatalogLanguage> get registeredLanguages => _canonical.values;

  static Future<CanonicalLanguageCatalog> loadBundled() async {
    final content = await rootBundle.loadString('assets/data/catalog.json');
    return CanonicalLanguageCatalog.fromJson(
      jsonDecode(content) as Map<String, dynamic>,
    );
  }

  factory CanonicalLanguageCatalog.fromJson(Map<String, dynamic> document) {
    if (document['languageCount'] != 100 ||
        document['maxRegisteredLanguages'] != 100 ||
        document['theoreticalDirectedPairCapacity'] != 9900 ||
        document['readinessScope'] != 'metadata_only') {
      throw const FormatException('Unsupported canonical catalog metadata');
    }

    final rawLanguages = document['languages'];
    final rawLegacy = document['legacyLanguages'];
    final rawReadiness = document['readiness'];
    final rawAliases = document['aliases'];
    final rawVariants = document['localeVariants'];
    if (rawLanguages is! List ||
        rawLanguages.length != 100 ||
        rawLegacy is! List ||
        rawReadiness is! Map ||
        rawAliases is! List ||
        rawVariants is! List ||
        rawReadiness.length != 100) {
      throw const FormatException('Invalid canonical inventory');
    }

    final canonical = <String, CatalogLanguage>{};
    final legacy = <String, CatalogLanguage>{};
    for (final raw in rawLanguages) {
      if (raw is! Map) throw const FormatException('Invalid language entry');
      final row = Map<String, dynamic>.from(raw);
      final code = row['languageCode'];
      if (code is! String ||
          !_validId.hasMatch(code) ||
          row['id'] != code ||
          row['contentStatus'] != 'not_verified' ||
          canonical.containsKey(code)) {
        throw const FormatException('Invalid canonical identity or readiness');
      }
      canonical[code] = CatalogLanguage.fromJson(row, isLegacy: false);
    }
    for (final raw in rawLegacy) {
      if (raw is! Map) throw const FormatException('Invalid legacy entry');
      final row = Map<String, dynamic>.from(raw);
      final code = row['languageCode'];
      if (code is! String ||
          !_validId.hasMatch(code) ||
          canonical.containsKey(code) ||
          legacy.containsKey(code) ||
          row['contentStatus'] != 'not_verified') {
        throw const FormatException('Invalid legacy identity');
      }
      legacy[code] = CatalogLanguage.fromJson(row, isLegacy: true);
    }
    if (legacy.length != 9 || document['legacyLanguageCount'] != 9) {
      throw const FormatException('Unreviewed legacy language migration');
    }
    final expectedLegacy = <String>{
      'fil', 'he', 'jv', 'ny', 'om', 'st', 'su', 'ti', 'wo',
    };
    if (legacy.keys.toSet().difference(expectedLegacy).isNotEmpty ||
        expectedLegacy.difference(legacy.keys.toSet()).isNotEmpty) {
      throw const FormatException('Historical identity loss or substitution');
    }
    if (rawReadiness.keys.any((key) =>
            !canonical.containsKey(key) || rawReadiness[key] != 'unverified') ||
        canonical.keys.any((key) => !rawReadiness.containsKey(key))) {
      throw const FormatException('Unverified registry must not claim content');
    }

    final aliases = <String, String>{};
    for (final raw in rawAliases) {
      if (raw is! Map) throw const FormatException('Invalid alias');
      final row = Map<String, dynamic>.from(raw);
      final from = row['from'];
      final to = row['to'];
      if (from is! String ||
          to is! String ||
          row['lossy'] != true ||
          row['status'] != 'migration_review_required' ||
          !canonical.containsKey(to) ||
          aliases.containsKey(from)) {
        throw const FormatException('Unreviewed alias');
      }
      aliases[from] = to;
    }

    final variants = <String, String>{};
    for (final raw in rawVariants) {
      if (raw is! Map) throw const FormatException('Invalid locale variant');
      final row = Map<String, dynamic>.from(raw);
      final tag = row['tag'];
      final id = row['language_id'];
      if (tag is! String ||
          id is! String ||
          row['content_status'] != 'unverified' ||
          !canonical.containsKey(id) ||
          variants.containsKey(tag.toLowerCase())) {
        throw const FormatException('Invalid locale variant');
      }
      variants[tag.toLowerCase()] = id;
    }

    final rules = document['migrationRules'];
    if (rules is! List) {
      throw const FormatException('Missing explicit migration rules');
    }
    for (final code in legacy.keys) {
      if (!rules.any((raw) => raw is Map &&
          raw['persistedId'] == code &&
          raw['policy'] == 'retain_exact_identity' &&
          raw['canonicalId'] == null)) {
        throw const FormatException('Missing historical preservation rule');
      }
    }

    return CanonicalLanguageCatalog._(
      Map<String, CatalogLanguage>.unmodifiable(canonical),
      Map<String, CatalogLanguage>.unmodifiable(legacy),
      Map<String, String>.unmodifiable(aliases),
      Map<String, String>.unmodifiable(variants),
    );
  }

  CatalogIdentityResolution resolvePersistedId(String persistedId) {
    final original = persistedId.trim().replaceAll('_', '-');
    final key = original.toLowerCase();
    final canonical = _canonical[key];
    if (canonical != null) {
      return CatalogIdentityResolution(
        requestedTag: persistedId,
        status: CatalogIdentityStatus.canonical,
        language: canonical,
        canonicalId: canonical.id,
      );
    }

    final legacy = _legacy[key];
    if (legacy != null) {
      return CatalogIdentityResolution(
        requestedTag: persistedId,
        status: CatalogIdentityStatus.retainedLegacy,
        language: legacy,
        suggestedId: _aliases[key],
        requiresReview: true,
      );
    }

    final variantId = _variants[key];
    if (variantId != null) {
      return CatalogIdentityResolution(
        requestedTag: persistedId,
        status: CatalogIdentityStatus.canonical,
        canonicalId: variantId,
        language: _canonical[variantId],
      );
    }

    final proposed = _aliases[key];
    if (proposed != null) {
      return CatalogIdentityResolution(
        requestedTag: persistedId,
        status: CatalogIdentityStatus.reviewRequired,
        suggestedId: proposed,
        requiresReview: true,
      );
    }

    return CatalogIdentityResolution(
      requestedTag: persistedId,
      status: CatalogIdentityStatus.unknown,
    );
  }

  /// Readiness is progressive and entirely evidence-gated. Published metadata
  /// and historical .pack.gz filenames cannot independently set any stage.
  CatalogLifecycle readinessFor(String persistedId,
      {CatalogVerificationEvidence? evidence}) {
    final identity = resolvePersistedId(persistedId);
    final registered = identity.status == CatalogIdentityStatus.canonical &&
        identity.canonicalId != null;
    // A variant must have its own matching evidence; never infer that a
    // proof for zh also validates zh-Hant (or the reverse).
    final matched = registered &&
        evidence != null &&
        evidence.languageCode.toLowerCase() ==
            persistedId.trim().replaceAll('_', '-').toLowerCase();
    final content = matched &&
        evidence.licenseApproved &&
        evidence.contentValidated &&
        evidence.acceptedEntryCount > 0;
    final verified = content &&
        evidence.packSchemaValidated &&
        evidence.packDigestValidated &&
        evidence.checksumSha256 != null &&
        _validSha256.hasMatch(evidence.checksumSha256!);
    final installed = verified && evidence.installedOnDevice;
    final production = installed && evidence.productionGateApproved;
    return CatalogLifecycle(
      languageCode: persistedId,
      registered: registered,
      contentAvailable: content,
      packVerified: verified,
      installed: installed,
      productionReady: production,
    );
  }
}

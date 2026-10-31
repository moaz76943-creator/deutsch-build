import 'content_card.dart';

enum ContentDisposition {
  canonical,
  quarantine,
}

enum ContentGateReason {
  invalidSemanticId('semantic.invalid_id'),
  semanticNamespaceMismatch('semantic.namespace_mismatch'),
  duplicateSemanticId('semantic.duplicate_id'),
  hiddenDirectionalControl('safety.hidden_directional_control'),
  externalLink('safety.external_link'),
  semanticConfidenceLow('semantic.confidence_low'),
  culturalReviewRequired('cultural.review_required'),
  culturalRiskFlagged('cultural.risk_flagged'),
  reviewRejected('review.rejected');

  const ContentGateReason(this.code);

  final String code;
}

final class ContentGateDecision {
  ContentGateDecision._(
    this.disposition,
    Iterable<ContentGateReason> reasons,
  ) : reasons = List<ContentGateReason>.unmodifiable(reasons);

  factory ContentGateDecision.canonical() =>
      ContentGateDecision._(
        ContentDisposition.canonical,
        const <ContentGateReason>[],
      );

  factory ContentGateDecision.quarantine(
    Iterable<ContentGateReason> reasons,
  ) {
    final unique = <ContentGateReason>{
      ...reasons,
    };
    if (unique.isEmpty) {
      throw ArgumentError(
        'A quarantine decision requires at least one reason.',
      );
    }
    return ContentGateDecision._(
      ContentDisposition.quarantine,
      unique,
    );
  }

  final ContentDisposition disposition;
  final List<ContentGateReason> reasons;

  bool get isCanonical =>
      disposition == ContentDisposition.canonical;
}

final class QuarantinedContentCard {
  QuarantinedContentCard({
    required this.card,
    required Iterable<ContentGateReason> reasons,
  }) : reasons = List<ContentGateReason>.unmodifiable(reasons) {
    if (this.reasons.isEmpty) {
      throw ArgumentError(
        'Quarantined content requires at least one reason.',
      );
    }
  }

  final PipelineContentCard card;
  final List<ContentGateReason> reasons;

  Map<String, Object?> toAuditJson() => <String, Object?>{
        'cardId': card.id,
        'semanticId': card.semanticId,
        'languageCode': card.languageCode,
        'reasons': reasons
            .map((reason) => reason.code)
            .toList(growable: false),
      };
}

final class ContentPromotionBatch {
  const ContentPromotionBatch.empty()
      : canonical = const <PipelineContentCard>[],
        quarantine = const <QuarantinedContentCard>[];

  ContentPromotionBatch({
    required Iterable<PipelineContentCard> canonical,
    required Iterable<QuarantinedContentCard> quarantine,
  })  : canonical =
            List<PipelineContentCard>.unmodifiable(canonical),
        quarantine =
            List<QuarantinedContentCard>.unmodifiable(quarantine);

  final List<PipelineContentCard> canonical;
  final List<QuarantinedContentCard> quarantine;

  int get canonicalCount => canonical.length;
  int get quarantineCount => quarantine.length;
}

final class CanonicalContentGate {
  const CanonicalContentGate({
    this.minimumSemanticConfidence = 0.80,
  }) : assert(
          minimumSemanticConfidence >= 0 &&
              minimumSemanticConfidence <= 1,
        );

  static const String policyVersion =
      'phase18-canonical-gate-v1';

  final double minimumSemanticConfidence;

  ContentGateDecision review(PipelineContentCard card) {
    final reasons = <ContentGateReason>{};

    final semanticId = card.semanticId.trim().toLowerCase();
    if (!RegExp(r'^[a-z0-9][a-z0-9._-]{0,159}$')
        .hasMatch(semanticId)) {
      reasons.add(ContentGateReason.invalidSemanticId);
    }

    final category = card.metadata['category'];
    if (category is String && category.trim().isNotEmpty) {
      final namespace = semanticId.split('.').first;
      final normalizedCategory =
          category.trim().toLowerCase().replaceAll('_', '-');
      if (namespace != normalizedCategory) {
        reasons.add(
          ContentGateReason.semanticNamespaceMismatch,
        );
      }
    }

    for (final value in <String?>[
      card.text,
      card.translation,
      card.example,
    ]) {
      if (value == null) continue;
      if (_containsHiddenDirectionalControl(value)) {
        reasons.add(
          ContentGateReason.hiddenDirectionalControl,
        );
      }
      if (_externalLink.hasMatch(value)) {
        reasons.add(ContentGateReason.externalLink);
      }
    }

    _applySemanticConfidence(card.metadata, reasons);
    _applyCulturalReview(card.metadata, reasons);
    _applyCulturalRisk(card.metadata, reasons);
    _applyReviewStatus(card.metadata, reasons);

    if (reasons.isEmpty) {
      return ContentGateDecision.canonical();
    }
    return ContentGateDecision.quarantine(reasons);
  }

  ContentPromotionBatch classify(
    Iterable<PipelineContentCard> input,
  ) {
    final cards = input.toList(growable: false);
    final reasonBuckets = List<Set<ContentGateReason>>.generate(
      cards.length,
      (_) => <ContentGateReason>{},
      growable: false,
    );
    final semanticIndexes = <String, List<int>>{};

    for (var index = 0; index < cards.length; index += 1) {
      final card = cards[index];
      reasonBuckets[index].addAll(review(card).reasons);
      final key = card.semanticId.trim().toLowerCase();
      semanticIndexes
          .putIfAbsent(key, () => <int>[])
          .add(index);
    }

    for (final indexes in semanticIndexes.values) {
      if (indexes.length < 2) continue;
      for (final index in indexes) {
        reasonBuckets[index].add(
          ContentGateReason.duplicateSemanticId,
        );
      }
    }

    final canonical = <PipelineContentCard>[];
    final quarantine = <QuarantinedContentCard>[];
    for (var index = 0; index < cards.length; index += 1) {
      final reasons = reasonBuckets[index];
      if (reasons.isEmpty) {
        canonical.add(cards[index]);
      } else {
        quarantine.add(
          QuarantinedContentCard(
            card: cards[index],
            reasons: reasons,
          ),
        );
      }
    }

    return ContentPromotionBatch(
      canonical: canonical,
      quarantine: quarantine,
    );
  }

  void _applySemanticConfidence(
    Map<String, Object?> metadata,
    Set<ContentGateReason> reasons,
  ) {
    if (!metadata.containsKey('semanticConfidence')) return;
    final raw = metadata['semanticConfidence'];
    if (raw is! num) {
      reasons.add(ContentGateReason.semanticConfidenceLow);
      return;
    }
    final value = raw.toDouble();
    if (!value.isFinite ||
        value < minimumSemanticConfidence ||
        value > 1) {
      reasons.add(ContentGateReason.semanticConfidenceLow);
    }
  }

  static void _applyCulturalReview(
    Map<String, Object?> metadata,
    Set<ContentGateReason> reasons,
  ) {
    if (!metadata.containsKey('culturalReview')) return;
    final raw = metadata['culturalReview'];
    if (raw is! String) {
      reasons.add(ContentGateReason.culturalReviewRequired);
      return;
    }
    switch (raw.trim().toLowerCase()) {
      case 'not-required':
      case 'approved':
        return;
      case 'required':
      case 'pending':
      case 'needs-review':
      default:
        reasons.add(
          ContentGateReason.culturalReviewRequired,
        );
    }
  }

  static void _applyCulturalRisk(
    Map<String, Object?> metadata,
    Set<ContentGateReason> reasons,
  ) {
    if (!metadata.containsKey('culturalRisk')) return;
    final raw = metadata['culturalRisk'];
    if (raw is! String) {
      reasons.add(ContentGateReason.culturalRiskFlagged);
      return;
    }
    switch (raw.trim().toLowerCase()) {
      case 'none':
      case 'low':
        return;
      case 'medium':
      case 'high':
      default:
        reasons.add(ContentGateReason.culturalRiskFlagged);
    }
  }

  static void _applyReviewStatus(
    Map<String, Object?> metadata,
    Set<ContentGateReason> reasons,
  ) {
    if (!metadata.containsKey('reviewStatus')) return;
    final raw = metadata['reviewStatus'];
    if (raw is! String) {
      reasons.add(ContentGateReason.culturalReviewRequired);
      return;
    }
    switch (raw.trim().toLowerCase()) {
      case 'approved':
      case 'verified':
        return;
      case 'rejected':
        reasons.add(ContentGateReason.reviewRejected);
        return;
      case 'pending':
      case 'needs-review':
      default:
        reasons.add(
          ContentGateReason.culturalReviewRequired,
        );
    }
  }

  static bool _containsHiddenDirectionalControl(
    String value,
  ) {
    for (final rune in value.runes) {
      if ((rune >= 0x202A && rune <= 0x202E) ||
          (rune >= 0x2066 && rune <= 0x2069)) {
        return true;
      }
    }
    return false;
  }

  static final RegExp _externalLink = RegExp(
    r'(?:https?://|www\.)',
    caseSensitive: false,
  );
}

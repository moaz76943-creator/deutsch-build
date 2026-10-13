import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/cefr_classifier.dart';

CefrEvidence record(
  CefrLevel level, {
  String language = 'de',
  String content = 'sense-1',
  CefrEvidenceSource source = CefrEvidenceSource.explicitPolicy,
}) => CefrEvidence(
  source: source,
  confidence: 0.95,
  explicitLevel: level,
  languageCode: language,
  contentId: content,
  sourceId: 'approved-corpus',
  sourceVersion: '2026-10',
);

void main() {
  test('unattested lexical heuristics cannot assign CEFR', () {
    expect(CefrClassifier.detectLevel(10, 3), CefrLevel.unknown);
    expect(CefrClassifier.classifyWord(const []), CefrLevel.unknown);
    expect(CefrClassifier.classifyWord([
      const CefrEvidence(
        source: CefrEvidenceSource.inferredDifficulty,
        confidence: 1.0,
        explicitLevel: CefrLevel.a1,
      ),
    ]), CefrLevel.unknown);
  });

  test('explicit sourced same-sense evidence is eligible', () {
    expect(CefrClassifier.classifyWord([record(CefrLevel.a2)]), CefrLevel.a2);
    expect(CefrClassifier.getGrouping(CefrLevel.a2), CefrGrouping.beginner);
  });

  test('conflicting same-rank evidence fails closed even when confident', () {
    expect(CefrClassifier.classifyWord([
      record(CefrLevel.a1),
      record(CefrLevel.b1),
    ]), CefrLevel.unknown);
  });

  test('cross-language and cross-sense CEFR mixing fails closed', () {
    expect(CefrClassifier.classifyWord([
      record(CefrLevel.a1), record(CefrLevel.a1, language: 'ar'),
    ]), CefrLevel.unknown);
    expect(CefrClassifier.classifyExample([
      record(CefrLevel.a1), record(CefrLevel.a1, content: 'sense-2'),
    ]), CefrLevel.unknown);
    expect(
      CefrClassifier.classifyWord([record(CefrLevel.a1)], languageCode: 'fr'),
      CefrLevel.unknown,
    );
  });

  test('unmapped proficiency framework and incomplete provenance are unknown', () {
    expect(CefrClassifier.classifyWord([
      const CefrEvidence(
        source: CefrEvidenceSource.certifiedCorpus,
        confidence: 0.9, explicitLevel: CefrLevel.a1,
        languageCode: 'ja', contentId: 'sense', sourceId: 'ref',
        sourceVersion: 'v1', frameworkId: 'JLPT',
      ),
    ]), CefrLevel.unknown);
  });
  test('oversized or lazy CEFR evidence is rejected without unbounded memory', () {
    final records = List<CefrEvidence>.generate(
      65, (_) => record(CefrLevel.a1),
    );
    expect(CefrClassifier.classifyWord(records), CefrLevel.unknown);
  });

}

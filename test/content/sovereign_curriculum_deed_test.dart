import 'package:test/test.dart';
import '../../lib/src/content/sovereign_curriculum_deed.dart';

void main() {
  group('SovereignCurriculumDeed Unit Tests (L097)', () {
    final deed = SovereignCurriculumDeed();

    test('Confirms complete ethical purity, open licensing, and permanent exclusions', () {
      final report = deed.generateDeed();

      expect(report.license, equals('Apache-2.0'));
      expect(report.is100PercentEthicalAndHalalCertified, isTrue);
      expect(report.isCitizenshipExamsPermanentlyExcluded, isTrue);
      expect(report.isProhibitedLocalesExcluded, isTrue);
      expect(report.sovereignPledge, contains('wholesome, pure, and accessible'));
    });

    test('Prohibited locales list covers Hebrew exclusions strictly', () {
      expect(SovereignCurriculumDeed.prohibitedLanguageCodes.contains('he'), isTrue);
    });
  });
}

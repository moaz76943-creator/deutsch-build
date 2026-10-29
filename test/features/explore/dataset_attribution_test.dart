import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/features/explore/presentation/section_explorer_screen.dart';

void main() {
  group('DatasetAttribution', () {
    test('does not invent provenance for absent pack metadata', () {
      final info = DatasetAttribution.fromMetadata(const {});
      expect(info.sourceLabel, 'غير موثق');
      expect(info.licenseLabel, 'غير موثق');
      expect(info.hasSourceAndLicense, isFalse);
    });

    test('does not count blank values as license evidence', () {
      final info = DatasetAttribution.fromMetadata(const {
        'source': '   ',
        'license': 'CC BY-SA 4.0',
      });
      expect(info.sourceLabel, 'غير موثق');
      expect(info.hasSourceAndLicense, isFalse);
    });

    test('displays actual metadata without claiming a default license', () {
      final info = DatasetAttribution.fromMetadata(const {
        'source': 'Approved dataset',
        'license': 'CC0',
      });
      expect(info.sourceLabel, 'Approved dataset');
      expect(info.licenseLabel, 'CC0');
      expect(info.hasSourceAndLicense, isTrue);
    });
  });
}

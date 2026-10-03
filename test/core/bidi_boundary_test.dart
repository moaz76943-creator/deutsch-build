import 'package:deutsch_bilarabi/core/language/app_text_direction.dart';
import 'package:deutsch_bilarabi/core/text/bidi_boundary.dart';
import 'package:deutsch_bilarabi/core/text/directional_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('German is always LTR and Arabic is always RTL', () {
    final german = DirectionalText.german('der Tisch');
    final arabic = DirectionalText.arabic('الطاولة');

    expect(german.direction, AppTextDirection.ltr);
    expect(arabic.direction, AppTextDirection.rtl);
  });

  test('plain mixed text uses directional isolates at every boundary', () {
    final value = BidiBoundary.join(<DirectionalText>[
      DirectionalText.arabic('استخدم '),
      DirectionalText.german('mit dem Bus'),
      DirectionalText.arabic(' في الجملة.'),
    ]);

    expect(value, contains(BidiBoundary.rli));
    expect(value, contains(BidiBoundary.lri));
    expect(BidiBoundary.pdi.allMatches(value).length, 3);
  });
}

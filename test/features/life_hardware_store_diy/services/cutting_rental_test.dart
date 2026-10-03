import 'package:deutsch_bilarabi/features/life_hardware_store_diy/services/cutting_rental_sub_agent.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const agent = CuttingRentalSubAgent();

  test('covers Holzzuschnitt, large equipment rental, Kaution, and return', () {
    final ids = agent.phrases.map((item) => item.id).toSet();

    expect(
      ids,
      containsAll(<String>{
        'services-cut-exact-size',
        'services-cut-tolerance',
        'services-rental-floor-sander',
        'services-rental-drill-hammer',
        'services-rental-deposit',
        'services-rental-return',
      }),
    );
  });

  test('search finds service language in German and Arabic', () {
    expect(
      agent.search('HOLZZUSCHNITT').map((item) => item.id),
      contains('services-cut-exact-size'),
    );
    expect(
      agent.search('الوديعة').map((item) => item.id),
      contains('services-rental-deposit'),
    );
  });

  test('cutting request keeps dimensions and unit explicit', () {
    final cut = agent.byId('services-cut-exact-size')!;

    expect(cut.german, contains('1200 × 600 mm'));
    expect(cut.german, contains('Holzzuschnitt'));
    expect(cut.contextAr, contains('المقاسات'));
  });

  test('rental checklist asks about deposit, condition, return time, and accessories', () {
    final checklist = agent.rentalChecklistDe.join(' ');

    expect(checklist, contains('Kaution'));
    expect(checklist, contains('Zustand'));
    expect(checklist, contains('Rückgabe'));
    expect(checklist, contains('Zubehör'));
  });
}

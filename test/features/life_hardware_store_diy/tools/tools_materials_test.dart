import 'package:deutsch_bilarabi/features/life_hardware_store_diy/tools/tools_materials_sub_agent.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const agent = ToolsMaterialsSubAgent();

  test('covers fasteners, drill bits, paint, adhesive, plumbing, and electrics', () {
    final ids = agent.phrases.map((item) => item.id).toSet();

    expect(
      ids,
      containsAll(<String>{
        'tools-screw-size',
        'tools-nail-purpose',
        'tools-drill-bit',
        'materials-interior-paint',
        'materials-adhesive',
        'materials-plumbing',
        'materials-electrical',
      }),
    );
  });

  test('technical consultation search is case-insensitive and bilingual', () {
    expect(agent.search('BOHRER').map((item) => item.id), contains('tools-drill-bit'));
    expect(agent.search('دهان').map((item) => item.id), contains('materials-interior-paint'));
    expect(agent.search('   '), hasLength(agent.phrases.length));
  });

  test('consultation prompts keep measurements explicit and ask staff safely', () {
    final screw = agent.byId('tools-screw-size')!;

    expect(screw.german, contains('5 × 50 mm'));
    expect(screw.german, contains('welchen Dübel'));
    expect(screw.contextAr, contains('الموظف'));
  });

  test('simple electrical and plumbing content avoids hazardous repair instructions', () {
    final electrical = agent.byId('materials-electrical')!;
    final plumbing = agent.byId('materials-plumbing')!;
    final combined = (
      electrical.german +
      ' ' +
      electrical.arabic +
      ' ' +
      plumbing.german +
      ' ' +
      plumbing.arabic
    ).toLowerCase();

    expect(combined, isNot(contains('sicherungskasten öffnen')));
    expect(combined, isNot(contains('لوحة الكهرباء')));
    expect(electrical.german, contains('passendes'));
    expect(plumbing.german, contains('Dichtung'));
  });
}

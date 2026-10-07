// Content Contracts Integration Test - Post-V1 Expansion
// Verifies integration between registry, manager, and contracts

import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/content/contract/content_contracts.dart';
import 'package:deutsch_bilarabi/content/contract/language_pack_manager.dart';

void main() {
  test('Verify Hundred Languages Registry contains core languages', () {
    final de = HundredLanguagesRegistry.getLanguage('de');
    final ar = HundredLanguagesRegistry.getLanguage('ar');
    
    expect(de, isNotNull);
    expect(ar, isNotNull);
    expect(de?.nativeName, 'Deutsch');
    expect(ar?.nativeName, 'العربية');
  });

  test('Verify Language Pack Manager lifecycle simulation', () async {
    final manager = LanguagePackManager();
    const packId = 'pack_de_v1';
    
    manager.registerPack(packId);
    expect(manager.isPackActive(packId), false);
    
    final activated = await manager.activatePack(packId);
    expect(activated, true);
    expect(manager.isPackActive(packId), true);
  });
}

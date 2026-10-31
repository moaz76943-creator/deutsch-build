import 'package:deutsch_build/core/linguistics/connectors_engine.dart';

void main() {
  final engine = KonnektorenSatzverbindungEngine();

  // 1. denn (Position 0): Ich will bestehen (denn + [0: Ich, 1: will, 2: bestehen])
  final dennProfile = engine.lookup('denn');
  assert(dennProfile != null && dennProfile.grammarType == ConnectorGrammarType.positionZero);
  assert(engine.validateVerbPosition(connector: 'denn', verbTokenIndex: 1));

  // 2. deshalb (Position 1 Inversion): deshalb + [0: deshalb, 1: bleibe, 2: ich]
  final deshalbProfile = engine.lookup('deshalb');
  assert(deshalbProfile != null && deshalbProfile.grammarType == ConnectorGrammarType.positionOneInversion);
  assert(engine.validateVerbPosition(connector: 'deshalb', verbTokenIndex: 1));

  // 3. weil (Subjunktion): الفعل في النهاية
  final weilProfile = engine.lookup('weil');
  assert(weilProfile != null && weilProfile.grammarType == ConnectorGrammarType.subordinatingFinal);

  // 4. trotzdem (Position 1 Inversion)
  final trotzdemProfile = engine.lookup('trotzdem');
  assert(trotzdemProfile != null && trotzdemProfile.grammarType == ConnectorGrammarType.positionOneInversion);

  print('Konnektoren engine unit assertions passed.');
}

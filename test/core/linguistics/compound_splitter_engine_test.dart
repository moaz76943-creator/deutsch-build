import 'package:deutsch_build/core/linguistics/compound_splitter_engine.dart';

void main() {
  final engine = CharSplitCompoundEngine();

  // 1. Handschuh = Hand + Schuh -> der (لأن Schuh مذكر)
  final resHandschuh = engine.split('Handschuh');
  assert(resHandschuh != null);
  assert(resHandschuh!.headPart == 'schuh');
  assert(resHandschuh!.derivedArticle == 'der');
  assert(resHandschuh!.fugenelement == null);

  // 2. Geburtstagskarte = Geburtstag + s + karte -> die (لأن karte مؤنث مع fuge -s-)
  final resKarte = engine.split('Geburtstagskarte');
  assert(resKarte != null);
  assert(resKarte!.headPart == 'karte');
  assert(resKarte!.derivedArticle == 'die');
  assert(resKarte!.fugenelement == 's');

  // 3. Krankenhaus = Kranken + haus -> das (لأن haus محايد مع fuge -en-)
  final resKrankenhaus = engine.split('Krankenhaus');
  assert(resKrankenhaus != null);
  assert(resKrankenhaus!.headPart == 'haus');
  assert(resKrankenhaus!.derivedArticle == 'das');
  assert(resKrankenhaus!.fugenelement == 'en');

  // 4. Wörterbuch = Wörter + buch -> das
  final resBuch = engine.split('Wörterbuch');
  assert(resBuch != null);
  assert(resBuch!.headPart == 'buch');
  assert(resBuch!.derivedArticle == 'das');

  print('CharSplit compound engine unit assertions passed.');
}

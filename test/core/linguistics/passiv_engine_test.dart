import 'package:deutsch_build/core/linguistics/passiv_engine.dart';

void main() {
  final engine = PassivAndPassiversatzEngine();

  // 1. Vorgangspassiv: Das Haus wird gebaut / von dem Architekten gebaut
  final vPassiv = engine.buildVorgangspassivPresent(
    subject: 'Das Haus',
    partizipIi: 'gebaut',
    agentVonDativ: 'dem Architekten',
  );
  assert(vPassiv == 'Das Haus wird von dem Architekten gebaut');

  // 2. Zustandspassiv: Die Tür ist geöffnet (حالة قائمة وليست حدثاً)
  final zPassiv = engine.buildZustandspassivPresent(
    subject: 'Die Tür',
    partizipIi: 'geöffnet',
  );
  assert(zPassiv == 'Die Tür ist geöffnet');

  // 3. Passiversatz: Das Problem lässt sich lösen <=> kann gelöst werden
  final ersatz = engine.resolvePassiversatz('lösen', 'Das Problem');
  assert(ersatz.equivalentConstruction == 'Das Problem lässt sich lösen');

  // 4. حروف جر الفاعل: von للأشخاص، durch للوسائل
  assert(engine.selectAgentPreposition(isPersonOrInstitution: true) == 'von');
  assert(engine.selectAgentPreposition(isPersonOrInstitution: false) == 'durch');

  print('Passiv and Passiversatz engine unit assertions passed.');
}

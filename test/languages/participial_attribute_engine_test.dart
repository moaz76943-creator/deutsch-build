import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/languages/german/participial_attribute_engine.dart';

void main() {
  group('ParticipialAttributeEngine C1 German Tests', () {
    test('1. تحويل النعت الفاعلي الحاضر (Partizip I - Active Present)', () {
      // die im Labor forschenden Wissenschaftler -> die Wissenschaftler, die im Labor forschen
      final result = ParticipialAttributeEngine.convertToRelativeClause(
        article: 'die',
        headNoun: 'Wissenschaftler',
        extensionPhrase: 'im Labor',
        participleLemma: 'forsch',
        voice: ParticipleVoice.activePresent,
      );

      expect(result, equals('die Wissenschaftler, die im Labor forschen'));
    });

    test('2. تحويل النعت المفعولي الماضي (Partizip II - Passive Past)', () {
      // die von Forschern entwickelte Methode -> die Methode, die von Forschern entwickelt wurde
      final result = ParticipialAttributeEngine.convertToRelativeClause(
        article: 'die',
        headNoun: 'Methode',
        extensionPhrase: 'von Forschern',
        participleLemma: 'entwickelt',
        voice: ParticipleVoice.passivePast,
      );

      expect(result, equals('die Methode, die von Forschern entwickelt wurde'));
    });

    test('3. تحويل صيغة الإلزام والضرورة (Gerundivum / zu + Partizip I)', () {
      // die zu lösende Aufgabe -> die Aufgabe, die gelöst werden muss
      final result = ParticipialAttributeEngine.convertToRelativeClause(
        article: 'die',
        headNoun: 'Aufgabe',
        extensionPhrase: '',
        participleLemma: 'gelöst',
        voice: ParticipleVoice.gerundiveObligation,
      );

      expect(result, equals('die Aufgabe, die gelöst werden muss'));
    });

    test('4. دعم أداة التعريف المحايد والمذكر (das / der)', () {
      final dasResult = ParticipialAttributeEngine.convertToRelativeClause(
        article: 'das',
        headNoun: 'Buch',
        extensionPhrase: 'gestern gelesene',
        participleLemma: 'gelesen',
        voice: ParticipleVoice.passivePast,
      );
      expect(dasResult, equals('das Buch, das gestern gelesene gelesen wurde'));

      final derResult = ParticipialAttributeEngine.convertToRelativeClause(
        article: 'der',
        headNoun: 'Student',
        extensionPhrase: 'fleißig',
        participleLemma: 'lern',
        voice: ParticipleVoice.activePresent,
      );
      expect(derResult, equals('der Student, der fleißig lernen'));
    });
  });
}

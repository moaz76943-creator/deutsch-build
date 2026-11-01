import 'package:test/test.dart';
import 'package:deutsch_build/src/core/krashen/narrow_reading_curriculum_generator.dart';

void main() {
  group('NarrowReadingCurriculumGenerator Suite', () {
    final generator = NarrowReadingCurriculumGenerator();

    setUpAll(() {
      // Article 1 on Astronomy (Arabic)
      generator.registerArticle(const NarrowReadingArticle(
        id: 'astro_01',
        domain: ThematicDomain.astronomyAndNavigation,
        title: 'الأسطرلاب وأدوات الرصد الفلكي',
        passageText: 'كان الأسطرلاب أداة فلكية بالغة الأهمية لرصد النجوم وتحديد المواقع في البحر.',
        targetThematicLemmas: ['أسطرلاب', 'فلك', 'نجوم', 'رصد', 'ملاحة'],
        languageCode: 'ar',
      ));

      // Article 2 on Astronomy with overlapping vocabulary
      generator.registerArticle(const NarrowReadingArticle(
        id: 'astro_02',
        domain: ThematicDomain.astronomyAndNavigation,
        title: 'رحلات البحر وتوجيه السفن بالنجوم',
        passageText: 'اعتمد البحارة على رصد النجوم والأسطرلاب لحساب خطوط العرض بأمان.',
        targetThematicLemmas: ['أسطرلاب', 'نجوم', 'رصد', 'بحارة', 'سفن'],
        languageCode: 'ar',
      ));
    });

    test('Assembles thematic cluster and computes strong vocabulary recycling rate', () {
      final cluster = generator.buildCluster(
        domain: ThematicDomain.astronomyAndNavigation,
        languageCode: 'ar',
      );

      expect(cluster.articles.length, equals(2));
      expect(cluster.vocabularyRecyclingRate, greaterThan(35.0)); // 3 out of 7 unique words shared
      expect(cluster.articles.first.id, equals('astro_01'));
      expect(cluster.articles.last.id, equals('astro_02'));
    });
  });
}

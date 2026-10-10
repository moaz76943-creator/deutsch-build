import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../core/srs/review_command_port.dart';

// 1. إصلاح ثغرة SQL (من البند 6 في التقرير)
// استبدل استعلام الـ Database القديم بهذه الدالة المحصنة:
Future<List<Map<String, dynamic>>> loadFlashcardsSafe(String targetLangCode) async {
  // يمنع حقن كود Dart داخل استعلام SQL
  final results = await contentDb.rawQuery(
    '''
    SELECT l.lexeme_id, l.article, l.lemma, l.plural, e.translation_ar, e.sentence 
    FROM lexemes AS l 
    LEFT JOIN examples AS e 
      ON e.concept_id = l.concept_id AND e.language_code = l.language_code 
    WHERE l.language_code = ? 
    LIMIT 10
    ''',
    [targetLangCode], // المعاملات المربوطة الآمنة
  );
  return results;
}

// 2. ربط التقييم بالمحرك المرجعي وإلغاء الدوال الفارغة (من البند 3 و 25)
// يجب تمرير منفذ المراجعة كاعتمادية (Dependency) للشاشة.
Future<void> handleCardRating(
  ReviewCommandPort srsPort,
  String cardId, 
  ReviewRating rating, 
  bool wasHinted
) async {
  final command = ReviewCommand(
    reviewId: const Uuid().v4(), // معرّف فريد يمنع تكرار المراجعة عند النقر المزدوج
    sourceLanguageId: 'ar', // سيتم سحبها لاحقاً من مدير الجلسة
    targetLanguageId: 'de', // سيتم سحبها لاحقاً من مدير الجلسة
    cardId: cardId,
    facetKey: 'core_meaning',
    pairEpoch: 1, // لحماية تقدم المتعلم إذا تم تحديث حزمة اللغة
    rating: rating,
    hinted: wasHinted,
  );

  // إرسال المراجعة للمحرك الرئيسي كمعاملة غير قابلة للتجزئة (Atomic Transaction)
  await srsPort.submit(command);
  
  // لا تقم بنقل المستخدم للبطاقة التالية إلا بعد نجاح الـ submit
  // moveToNextCard(); 
}

class FlashcardsScreen extends StatelessWidget {
  const FlashcardsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مراجعة البطاقات')),
      body: const Center(
        child: Text('هذه شاشة تجريبية، سيتم بناء الواجهة لاحقاً.'),
      ),
    );
  }
}

// هذا كود تجريبي لـ contentDb لكي لا يظهر خطأ أثناء الفحص المبدئي
// سيتم ربطه بقاعدة البيانات الفعلية لاحقاً
class ContentDbStub {
  Future<List<Map<String, dynamic>>> rawQuery(String sql, List<dynamic> arguments) async {
    return [];
  }
}
final contentDb = ContentDbStub();

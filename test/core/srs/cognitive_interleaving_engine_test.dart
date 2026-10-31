import 'package:deutsch_build/core/srs/cognitive_interleaving_engine.dart';

void main() {
  const engine = CognitiveInterleavingEngine(maxConsecutiveModality: 2);

  // إدخال قائمة مكدسة: 4 مفردات متتالية، تليها قواعد واستماع
  final blockedList = [
    const InterleavedReviewItem(itemId: 'v1', modality: LearningModality.vocabularyRecognition, overduePriority: 10.0),
    const InterleavedReviewItem(itemId: 'v2', modality: LearningModality.vocabularyRecognition, overduePriority: 9.5),
    const InterleavedReviewItem(itemId: 'v3', modality: LearningModality.vocabularyRecognition, overduePriority: 9.0),
    const InterleavedReviewItem(itemId: 'v4', modality: LearningModality.vocabularyRecognition, overduePriority: 8.5),
    const InterleavedReviewItem(itemId: 'g1', modality: LearningModality.grammarSyntaxValidation, overduePriority: 7.0),
    const InterleavedReviewItem(itemId: 'l1', modality: LearningModality.listeningComprehension, overduePriority: 6.0),
  ];

  final interleaved = engine.interleave(blockedList);
  assert(interleaved.length == 6);

  // التحقق من كسر التكدس: لا يجوز وجود 3 عناصر متتالية من نفس النمط
  int consecutive = 1;
  for (int i = 1; i < interleaved.length; i++) {
    if (interleaved[i].modality == interleaved[i - 1].modality) {
      consecutive++;
      assert(consecutive <= 2, 'Failed: Max consecutive limit violated at index $i');
    } else {
      consecutive = 1;
    }
  }

  print('Cognitive interleaving engine unit assertions passed.');
}

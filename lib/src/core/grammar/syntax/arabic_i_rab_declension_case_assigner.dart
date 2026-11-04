/// Task 1305: Classical Arabic grammatical case declension (I'rab)
enum ArabicCase { marfoo, mansoob, majroor, majzoom }
class ArabicIrabAssigner {
  ArabicCase assignCase(String syntacticRole) => syntacticRole == 'fa3il' ? ArabicCase.marfoo : ArabicCase.mansoob;
}

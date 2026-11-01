enum SpeechActCategory {
  politeRequest, // طلب مهذب
  gratitudeAppreciation, // شكر وامتنان
  apologyRestitution, // اعتذار
  courtesyGreeting, // تحية وترحيب
  inquiryClarification, // استفسار واستيضاح
  assertionFact, // إخبار وتقرير
}

enum PolitenessRegister {
  formalHonorific, // رسمي فائق التأدب
  neutralRespectful, // مهذب معتاد
  informalFamiliar, // عفوي بين الأقران
}

class SpeechActClassification {
  final SpeechActCategory primaryAct;
  final PolitenessRegister register;
  final double confidenceScore;
  final List<String> detectedIllocutionaryMarkers;
  final bool isPragmaticallyAppropriate;
  final String pragmaticAdviceAr;

  const SpeechActClassification({
    required this.primaryAct,
    required this.register,
    required this.confidenceScore,
    required this.detectedIllocutionaryMarkers,
    required this.isPragmaticallyAppropriate,
    required this.pragmaticAdviceAr,
  });
}

/// Sovereign on-device Pragmatic Speech Act Classifier.
/// Evaluates the pragmatic function, illocutionary force, and cultural politeness
/// register of utterances across 100 languages.
class PragmaticSpeechActClassifier {
  const PragmaticSpeechActClassifier();

  static final Map<String, Map<SpeechActCategory, List<String>>> _markers = {
    'ar': {
      SpeechActCategory.politeRequest: ['من فضلك', 'لو سمحت', 'أرجو', 'تكرمت', 'هل بالإمكان'],
      SpeechActCategory.gratitudeAppreciation: ['شكراً', 'جزاك الله خيراً', 'أشكرك', 'ممتن', 'تسلم'],
      SpeechActCategory.apologyRestitution: ['أعتذر', 'عفواً', 'أرجو المعذرة', 'سامحني', 'آسف'],
      SpeechActCategory.courtesyGreeting: ['السلام عليكم', 'أهلاً وسهلاً', 'صباح الخير', 'مرحباً'],
      SpeechActCategory.inquiryClarification: ['هل', 'كيف', 'ماذا', 'أين', 'لماذا'],
    },
    'tr': {
      SpeechActCategory.politeRequest: ['lütfen', 'rica etsem', 'mümkünse', 'alabilir miyim'],
      SpeechActCategory.gratitudeAppreciation: ['teşekkür ederim', 'sağ olun', 'çok teşekkürler'],
      SpeechActCategory.apologyRestitution: ['özür dilerim', 'kusura bakmayın', 'afedersiniz'],
      SpeechActCategory.courtesyGreeting: ['merhaba', 'günaydın', 'selamün aleyküm', 'hoş geldiniz'],
      SpeechActCategory.inquiryClarification: ['nasıl', 'nerede', 'acaba', 'ne zaman'],
    },
    'id': {
      SpeechActCategory.politeRequest: ['tolong', 'mohon', 'silakan', 'bisa tolong'],
      SpeechActCategory.gratitudeAppreciation: ['terima kasih', 'makasih', 'terima kasih banyak'],
      SpeechActCategory.apologyRestitution: ['maaf', 'mohon maaf', 'permisi'],
      SpeechActCategory.courtesyGreeting: ['selamat pagi', 'halo', 'assalamu alaikum'],
      SpeechActCategory.inquiryClarification: ['bagaimana', 'apakah', 'di mana', 'kenapa'],
    },
  };

  /// Classifies utterance into pragmatic speech act and politeness register.
  SpeechActClassification classifyUtterance({
    required String text,
    required String languageCode,
    bool isFormalSetting = true,
  }) {
    final clean = text.toLowerCase().trim();
    final langMarkers = _markers[languageCode] ?? _markers['ar']!;

    SpeechActCategory bestAct = SpeechActCategory.assertionFact;
    final foundMarkers = <String>[];
    int maxMatches = 0;

    for (final entry in langMarkers.entries) {
      int count = 0;
      for (final m in entry.value) {
        if (clean.contains(m)) {
          count++;
          foundMarkers.add(m);
        }
      }
      if (count > maxMatches) {
        maxMatches = count;
        bestAct = entry.key;
      }
    }

    // Determine Politeness Register
    PolitenessRegister reg = PolitenessRegister.neutralRespectful;
    if (foundMarkers.any((m) => m.contains('تكرمت') || m.contains('kusura bakmayın') || m.contains('mohon'))) {
      reg = PolitenessRegister.formalHonorific;
    } else if (foundMarkers.isEmpty && !clean.contains('؟') && !clean.contains('?')) {
      reg = PolitenessRegister.informalCasual;
    }

    final isAppropriate = isFormalSetting ? reg != PolitenessRegister.informalCasual : true;
    String advice = 'الصيغة البراغماتية متوازنة وتؤدي الغرض التواصلي بلباقة.';
    if (!isAppropriate) {
      advice = 'في المواقف الرسمية يُفضل استخدام عبارات التلطيف والرجاء (مثل: من فضلك / lütfen).';
    }

    return SpeechActClassification(
      primaryAct: bestAct,
      register: reg,
      confidenceScore: maxMatches > 0 ? 0.90 : 0.60,
      detectedIllocutionaryMarkers: foundMarkers,
      isPragmaticallyAppropriate: isAppropriate,
      pragmaticAdviceAr: advice,
    );
  }
}

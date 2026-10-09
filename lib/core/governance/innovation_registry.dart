import 'dart:convert';

class InnovationRegistry {
  // سجل الابتكارات المسجلة لمنع التكرار أو الترتيج (Deduplication Gate)
  static const List<String> registeredInnovations = [
    'SM-2 Memory Algorithm & Haptic Feedback',
    'Modular Polyglot Packs Architecture (100 Languages)',
    'Morphological Distance & Spacing Index',
    'Multi-Script Bi-Directional Typography Engine',
    'Incremental Delta Pack Sync',
    'Universal Phonetic IPA Mapper',
    'Universal Semantic Concept Graph',
    'On-Device Pronunciation Scoring Engine',
    'Zero-Knowledge Encrypted Cloud Sync',
    'Pragmatic Register & Cultural Nuance Filter',
    'Adaptive Neural Gamification Matrix',
    'Offline Crowdsourced Feedback',
    'Generative Root-Pattern Morphological Engine',
    'Zero-Footprint Garbage Collection & Shredding',
    'Kinetic Synesthetic Typography',
    'Cognitive Burnout & Impulse Shield',
    'Decentralized Peer-Audited QC',
    'Socio-Cultural Pragmatic Bias Auditor',
    'Subliminal Micro-Audio Pacing Matrix'
  ];

  static bool isNovel(String proposedFeatureName) {
    String normalized = proposedFeatureName.toLowerCase();
    for (var item in registeredInnovations) {
      if (item.toLowerCase().contains(normalized) || normalized.contains(item.toLowerCase())) {
        return false; // تكرار أو ترجيع مرفوض فوراً
      }
    }
    return true; // فكرة جديدة ومبتكرة كلياً
  }

  static Map<String, dynamic> auditNovelty(String newFeature) {
    bool novel = isNovel(newFeature);
    return {
      'module': 'Innovation Registry & Deduplication Gate',
      'feature': newFeature,
      'isNoveltyVerified': novel,
      'status': novel ? 'Approved for Sandboxed Integration' : 'Rejected: Duplicate or Recycled Concept'
    };
  }
}

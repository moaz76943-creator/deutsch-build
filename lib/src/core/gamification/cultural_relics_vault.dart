/// Rarity classification for collectible cultural artifacts.
enum RelicRarity { common, rare, epic, legendary }

/// Collectible cultural artifact tied to language mastery milestones.
class CulturalRelic {
  final String id;
  final String name;
  final String culture; // e.g. "German", "Arabic", "Japanese"
  final String description;
  final RelicRarity rarity;
  final int requiredMasteryPoints;
  final bool isUnlocked;

  const CulturalRelic({
    required this.id,
    required this.name,
    required this.culture,
    required this.description,
    required this.rarity,
    required this.requiredMasteryPoints,
    this.isUnlocked = false,
  });

  CulturalRelic unlock() => CulturalRelic(
    id: id,
    name: name,
    culture: culture,
    description: description,
    rarity: rarity,
    requiredMasteryPoints: requiredMasteryPoints,
    isUnlocked: true,
  );
}

/// Manages cultural achievement trophies unlocked through language milestones.
class CulturalRelicsVault {
  final Map<String, CulturalRelic> _relics = {};

  CulturalRelicsVault();

  static const List<CulturalRelic> defaultRelics = [
    CulturalRelic(
      id: 'relic_brandenburg',
      name: 'بوابة براندنبورغ الذهبية',
      culture: 'German',
      description: 'وسام الإتقان لإتمام 100 كلمة وتصريف في قواعد الألمانية.',
      rarity: RelicRarity.rare,
      requiredMasteryPoints: 500,
    ),
    CulturalRelic(
      id: 'relic_astrolabe',
      name: 'إسطرلاب بيت الحكمة',
      culture: 'Arabic',
      description: 'وسام البلاغة والدقة الصرفية للأوزان والمشتقات.',
      rarity: RelicRarity.epic,
      requiredMasteryPoints: 1000,
    ),
    CulturalRelic(
      id: 'relic_wave',
      name: 'موجة هوكوساي الرمزية',
      culture: 'Japanese',
      description: 'وسام التمكن من قراءة واستيعاب مقاطع الهيراغانا والكانجي.',
      rarity: RelicRarity.legendary,
      requiredMasteryPoints: 2000,
    ),
  ];

  void initialize({List<CulturalRelic>? customRelics}) {
    _relics.clear();
    final list = customRelics ?? defaultRelics;
    for (final r in list) {
      _relics[r.id] = r;
    }
  }

  /// Evaluates learner points and unlocks eligible cultural trophies.
  List<CulturalRelic> evaluateUnlocks(int currentPoints) {
    final newlyUnlocked = <CulturalRelic>[];

    for (final entry in _relics.entries) {
      final relic = entry.value;
      if (!relic.isUnlocked && currentPoints >= relic.requiredMasteryPoints) {
        final unlocked = relic.unlock();
        _relics[entry.key] = unlocked;
        newlyUnlocked.add(unlocked);
      }
    }

    return newlyUnlocked;
  }

  List<CulturalRelic> get unlockedRelics =>
      _relics.values.where((r) => r.isUnlocked).toList();
}
